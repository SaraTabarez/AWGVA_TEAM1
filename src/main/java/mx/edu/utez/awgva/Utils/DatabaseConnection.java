package mx.edu.utez.awgva.Utils;

import java.io.File;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Fábrica de conexiones. Las credenciales se toman primero de variables de
 * entorno; database.properties queda únicamente como alternativa local no
 * versionada.
 */
public final class DatabaseConnection {

    private static final String PROPERTIES_FILE = "database.properties";
    private static final Properties DB_PROPERTIES = loadProperties();

    static {
        try {
            Class.forName(value("DB_DRIVER", "db.driver", "oracle.jdbc.OracleDriver"));
        } catch (ClassNotFoundException exception) {
            throw new ExceptionInInitializerError("No se encontró el controlador JDBC de Oracle.");
        }
    }

    private DatabaseConnection() {
    }

    public static Connection getConnection() throws SQLException {
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

        return DriverManager.getConnection(url, connectionProperties);
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
}
