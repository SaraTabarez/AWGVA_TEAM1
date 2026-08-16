package mx.edu.utez.awgva.Service;

import mx.edu.utez.awgva.Model.FirmantesOficiales;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Properties;

public class FirmanteService {
    private static final Object LOCK = new Object();

    public FirmantesOficiales load() {
        synchronized (LOCK) {
            Properties properties = new Properties();
            Path file = file();
            if (Files.isRegularFile(file)) {
                try (Reader reader = Files.newBufferedReader(file, StandardCharsets.UTF_8)) {
                    properties.load(reader);
                } catch (IOException exception) {
                    throw new IllegalStateException("No fue posible leer los firmantes.", exception);
                }
            }
            FirmantesOficiales values = new FirmantesOficiales();
            values.setDirectorNombre(properties.getProperty("director.nombre", "Por configurar"));
            values.setDirectorCargo(properties.getProperty("director.cargo", "Director(a) de Carrera"));
            values.setDocenteNombre(properties.getProperty("docente.nombre", "Por configurar"));
            values.setDocenteCargo(properties.getProperty("docente.cargo", "Docente responsable"));
            values.setEstadiasNombre(properties.getProperty("estadias.nombre", "Por configurar"));
            values.setEstadiasCargo(properties.getProperty("estadias.cargo", "Jefatura de Estadías"));
            return values;
        }
    }

    public void save(FirmantesOficiales values) {
        validate(values);
        synchronized (LOCK) {
            Path file = file();
            Path temporary = null;
            try {
                Files.createDirectories(file.getParent());
                temporary = Files.createTempFile(file.getParent(), "firmantes-", ".tmp");
                Properties properties = new Properties();
                properties.setProperty("director.nombre", values.getDirectorNombre().trim());
                properties.setProperty("director.cargo", values.getDirectorCargo().trim());
                properties.setProperty("docente.nombre", values.getDocenteNombre().trim());
                properties.setProperty("docente.cargo", values.getDocenteCargo().trim());
                properties.setProperty("estadias.nombre", values.getEstadiasNombre().trim());
                properties.setProperty("estadias.cargo", values.getEstadiasCargo().trim());
                try (Writer writer = Files.newBufferedWriter(temporary, StandardCharsets.UTF_8)) {
                    properties.store(writer, null);
                }
                try {
                    Files.move(temporary, file, StandardCopyOption.ATOMIC_MOVE,
                            StandardCopyOption.REPLACE_EXISTING);
                } catch (IOException exception) {
                    Files.move(temporary, file, StandardCopyOption.REPLACE_EXISTING);
                }
            } catch (IOException exception) {
                if (temporary != null) {
                    try { Files.deleteIfExists(temporary); } catch (IOException ignored) { }
                }
                throw new IllegalStateException("No fue posible guardar los firmantes.", exception);
            }
        }
    }

    private void validate(FirmantesOficiales values) {
        if (values == null) throw new IllegalArgumentException("Los firmantes son obligatorios.");
        required(values.getDirectorNombre());
        required(values.getDirectorCargo());
        required(values.getDocenteNombre());
        required(values.getDocenteCargo());
        required(values.getEstadiasNombre());
        required(values.getEstadiasCargo());
    }

    private void required(String value) {
        if (value == null || value.isBlank() || value.trim().length() > 180) {
            throw new IllegalArgumentException("Completa todos los nombres y cargos con máximo 180 caracteres.");
        }
    }

    private Path file() {
        String custom = System.getenv("AWGVA_CONFIG_DIR");
        if (custom != null && !custom.isBlank()) {
            return Path.of(custom).toAbsolutePath().normalize().resolve("firmantes.properties");
        }
        String catalina = System.getProperty("catalina.base");
        Path base = catalina == null || catalina.isBlank()
                ? Path.of(System.getProperty("java.io.tmpdir"), "awgva-config")
                : Path.of(catalina, "awgva-config");
        return base.toAbsolutePath().normalize().resolve("firmantes.properties");
    }
}