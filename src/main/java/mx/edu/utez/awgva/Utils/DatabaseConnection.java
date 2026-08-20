package mx.edu.utez.awgva.Utils;

import oracle.jdbc.OracleConnection;

import java.io.File;
import java.io.InputStream;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.net.URI;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.SQLNonTransientConnectionException;
import java.sql.SQLRecoverableException;
import java.util.Properties;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Fábrica de conexiones Oracle con un pool ligero y acotado.
 *
 * La conexión física a Autonomous Database/Wallet es costosa. Antes, cada DAO
 * abría una sesión TLS nueva para cada consulta, por lo que cambiar de vista
 * podía tardar varios segundos. Ahora las conexiones físicas se reutilizan y
 * Connection.close() simplemente devuelve la conexión al pool.
 *
 * Se puede desactivar sin tocar código definiendo DB_POOL_ENABLED=false.
 */
public final class DatabaseConnection {

    private static final String PROPERTIES_FILE = "database.properties";
    private static final Properties DB_PROPERTIES = loadProperties();

    private static final boolean POOL_ENABLED = booleanValue("DB_POOL_ENABLED", "db.pool.enabled", true);
    private static final int MAX_POOL_SIZE = intValue("DB_POOL_SIZE", "db.pool.size", 4, 1, 12);
    private static final long BORROW_TIMEOUT_MS = intValue(
            "DB_POOL_TIMEOUT_MS", "db.pool.timeout.ms", 15000, 1000, 60000);
    private static final int STATEMENT_CACHE_SIZE = intValue(
            "DB_STATEMENT_CACHE_SIZE", "db.statement.cache.size", 32, 0, 100);

    private static final BlockingQueue<Connection> IDLE = new LinkedBlockingQueue<>();
    private static final AtomicInteger CREATED = new AtomicInteger();
    private static final Object CREATE_LOCK = new Object();
    private static final AtomicBoolean SHUTTING_DOWN = new AtomicBoolean(false);

    static {
        try {
            Class.forName(value("DB_DRIVER", "db.driver", "oracle.jdbc.OracleDriver"));
        } catch (ClassNotFoundException exception) {
            throw new ExceptionInInitializerError("No se encontró el controlador JDBC de Oracle.");
        }
    }

    private DatabaseConnection() {
    }

    /**
     * Obtiene una conexión lógica. Al cerrarla, vuelve al pool en vez de cerrar
     * la sesión Oracle física. Los DAO existentes no necesitan ningún cambio.
     */
    public static Connection getConnection() throws SQLException {
        if (!POOL_ENABLED) {
            return createPhysicalConnection();
        }
        if (SHUTTING_DOWN.get()) {
            throw new SQLException("El pool de conexiones se está cerrando.");
        }

        long deadline = System.nanoTime() + TimeUnit.MILLISECONDS.toNanos(BORROW_TIMEOUT_MS);
        while (true) {
            Connection physical = IDLE.poll();
            if (isUsable(physical)) {
                return wrap(physical);
            }
            if (physical != null) {
                destroy(physical);
            }

            synchronized (CREATE_LOCK) {
                if (CREATED.get() < MAX_POOL_SIZE) {
                    Connection created = createPhysicalConnection();
                    CREATED.incrementAndGet();
                    return wrap(created);
                }
            }

            long remaining = deadline - System.nanoTime();
            if (remaining <= 0) {
                throw new SQLException("Tiempo agotado esperando una conexión Oracle disponible.");
            }

            try {
                physical = IDLE.poll(remaining, TimeUnit.NANOSECONDS);
            } catch (InterruptedException exception) {
                Thread.currentThread().interrupt();
                throw new SQLException("La espera por una conexión Oracle fue interrumpida.", exception);
            }

            if (isUsable(physical)) {
                return wrap(physical);
            }
            if (physical != null) {
                destroy(physical);
            }
        }
    }

    /** Abre y devuelve una conexión para dejar una sesión lista al arrancar Tomcat. */
    public static void warmUp() throws SQLException {
        if (!POOL_ENABLED || SHUTTING_DOWN.get()) return;
        try (Connection ignored = getConnection()) {
            // El close del try-with-resources devuelve la conexión al pool.
        }
    }

    /** Cierra las conexiones físicas al detener o redesplegar la aplicación. */
    public static void closePool() {
        if (!SHUTTING_DOWN.compareAndSet(false, true)) return;
        Connection connection;
        while ((connection = IDLE.poll()) != null) {
            closePhysical(connection);
            CREATED.decrementAndGet();
        }
    }

    public static int idleConnections() {
        return IDLE.size();
    }

    public static int physicalConnections() {
        return CREATED.get();
    }

    private static Connection createPhysicalConnection() throws SQLException {
        String url = required("DB_URL", "db.url");
        String user = required("DB_USER", "db.user");
        String password = required("DB_PASSWORD", "db.password");

        Properties connectionProperties = new Properties();
        connectionProperties.setProperty("user", user);
        connectionProperties.setProperty("password", password);

        String walletDirectory = resolveWalletDirectory();
        if (walletDirectory != null) {
            connectionProperties.setProperty("oracle.net.tns_admin", walletDirectory);
            configureJksStores(connectionProperties, walletDirectory);
        }

        Connection connection = DriverManager.getConnection(url, connectionProperties);
        configureOracleStatementCache(connection);
        return connection;
    }

    private static void configureOracleStatementCache(Connection connection) {
        if (STATEMENT_CACHE_SIZE <= 0 || connection == null) return;
        try {
            OracleConnection oracle = connection.isWrapperFor(OracleConnection.class)
                    ? connection.unwrap(OracleConnection.class)
                    : (connection instanceof OracleConnection oc ? oc : null);
            if (oracle != null) {
                oracle.setStatementCacheSize(STATEMENT_CACHE_SIZE);
                oracle.setImplicitCachingEnabled(true);
            }
        } catch (SQLException ignored) {
            // La caché de statements es una optimización opcional; nunca bloquea la conexión.
        }
    }

    private static Connection wrap(Connection physical) {
        InvocationHandler handler = new InvocationHandler() {
            private boolean closed;
            private boolean broken;

            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                String name = method.getName();

                if ("close".equals(name)) {
                    if (!closed) {
                        closed = true;
                        recycle(physical, broken);
                    }
                    return null;
                }
                if ("isClosed".equals(name)) {
                    return closed || physical.isClosed();
                }
                if ("abort".equals(name)) {
                    broken = true;
                }
                if (closed) {
                    throw new SQLException("La conexión lógica ya fue cerrada.");
                }
                if ("unwrap".equals(name) && args != null && args.length == 1
                        && args[0] instanceof Class<?> type && type.isInstance(physical)) {
                    return type.cast(physical);
                }
                if ("isWrapperFor".equals(name) && args != null && args.length == 1
                        && args[0] instanceof Class<?> type && type.isInstance(physical)) {
                    return true;
                }

                try {
                    return method.invoke(physical, args);
                } catch (InvocationTargetException exception) {
                    Throwable cause = exception.getCause();
                    if (cause instanceof SQLRecoverableException
                            || cause instanceof SQLNonTransientConnectionException) {
                        broken = true;
                    }
                    throw cause;
                }
            }
        };

        return (Connection) Proxy.newProxyInstance(
                DatabaseConnection.class.getClassLoader(),
                new Class<?>[]{Connection.class},
                handler
        );
    }

    private static void recycle(Connection connection, boolean broken) {
        if (connection == null) return;
        if (broken || SHUTTING_DOWN.get() || !isUsable(connection)) {
            destroy(connection);
            return;
        }

        try {
            if (!connection.getAutoCommit()) {
                connection.rollback();
                connection.setAutoCommit(true);
            }
            connection.clearWarnings();
            if (!IDLE.offer(connection)) {
                destroy(connection);
            }
        } catch (SQLException exception) {
            destroy(connection);
        }
    }

    private static boolean isUsable(Connection connection) {
        if (connection == null) return false;
        try {
            return !connection.isClosed();
        } catch (SQLException exception) {
            return false;
        }
    }

    private static void destroy(Connection connection) {
        closePhysical(connection);
        CREATED.updateAndGet(value -> Math.max(0, value - 1));
    }

    private static void closePhysical(Connection connection) {
        if (connection == null) return;
        try {
            connection.close();
        } catch (SQLException ignored) {
        }
    }

    private static void configureJksStores(Properties properties, String walletDirectory) {
        String walletPassword = value("ORACLE_WALLET_PASSWORD", "wallet.password", null);
        File trustStore = new File(walletDirectory, "truststore.jks");
        File keyStore = new File(walletDirectory, "keystore.jks");

        if (walletPassword == null || !trustStore.isFile() || !keyStore.isFile()) {
            return;
        }

        properties.setProperty("javax.net.ssl.trustStore", trustStore.getAbsolutePath());
        properties.setProperty("javax.net.ssl.trustStoreType", "JKS");
        properties.setProperty("javax.net.ssl.trustStorePassword", walletPassword);
        properties.setProperty("javax.net.ssl.keyStore", keyStore.getAbsolutePath());
        properties.setProperty("javax.net.ssl.keyStoreType", "JKS");
        properties.setProperty("javax.net.ssl.keyStorePassword", walletPassword);
    }

    private static String resolveWalletDirectory() throws SQLException {
        String configuredPath = System.getenv("ORACLE_WALLET_DIR");
        if (configuredPath != null && !configuredPath.isBlank()) {
            File directory = new File(configuredPath.trim());
            if (!directory.isDirectory()) {
                throw new SQLException("ORACLE_WALLET_DIR no apunta a una carpeta válida.");
            }
            return directory.getAbsolutePath();
        }

        URL resource = DatabaseConnection.class.getClassLoader().getResource("Wallet");
        if (resource == null) {
            return null;
        }

        try {
            URI uri = resource.toURI();
            if (!"file".equalsIgnoreCase(uri.getScheme())) {
                throw new SQLException("Configura ORACLE_WALLET_DIR al desplegar el WAR.");
            }
            Path directory = Path.of(uri).toAbsolutePath();
            return Files.isRegularFile(directory.resolve("tnsnames.ora"))
                    ? directory.toString()
                    : null;
        } catch (Exception exception) {
            if (exception instanceof SQLException sqlException) {
                throw sqlException;
            }
            throw new SQLException("No fue posible resolver la carpeta Wallet.", exception);
        }
    }

    private static Properties loadProperties() {
        Properties properties = new Properties();
        try (InputStream input = DatabaseConnection.class.getClassLoader()
                .getResourceAsStream(PROPERTIES_FILE)) {
            if (input != null) {
                properties.load(input);
            }
            return properties;
        } catch (Exception exception) {
            throw new ExceptionInInitializerError("No fue posible leer database.properties.");
        }
    }

    private static String required(String environmentName, String propertyName) throws SQLException {
        String result = value(environmentName, propertyName, null);
        if (result == null) {
            throw new SQLException(
                    "Falta configurar " + environmentName + " o la propiedad local " + propertyName + "."
            );
        }
        return result;
    }

    private static String value(String environmentName, String propertyName, String defaultValue) {
        String environmentValue = System.getenv(environmentName);
        if (environmentValue != null && !environmentValue.isBlank()) {
            return environmentValue.trim();
        }

        String propertyValue = DB_PROPERTIES.getProperty(propertyName);
        if (propertyValue != null && !propertyValue.isBlank()) {
            return propertyValue.trim();
        }
        return defaultValue;
    }

    private static boolean booleanValue(String environmentName, String propertyName, boolean defaultValue) {
        String raw = value(environmentName, propertyName, null);
        return raw == null ? defaultValue : Boolean.parseBoolean(raw.trim());
    }

    private static int intValue(String environmentName, String propertyName,
                                int defaultValue, int min, int max) {
        String raw = value(environmentName, propertyName, null);
        if (raw == null) return defaultValue;
        try {
            int parsed = Integer.parseInt(raw.trim());
            return Math.max(min, Math.min(max, parsed));
        } catch (NumberFormatException ignored) {
            return defaultValue;
        }
    }
}
