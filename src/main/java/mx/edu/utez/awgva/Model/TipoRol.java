package mx.edu.utez.awgva.Model;

import java.text.Normalizer;
import java.util.Locale;
import java.util.Optional;

/**
 * Roles reconocidos por la aplicación.
 *
 * El acceso nunca depende del ID numérico del rol, porque ese ID puede cambiar
 * entre bases de datos. La autorización usa el nombre normalizado almacenado en
 * la tabla ROL.
 */
public enum TipoRol {
    DOCENTE,
    DIRECTOR,
    ESTADIAS,
    ADMIN;

    public static Optional<TipoRol> from(String nombreRol) {
        if (nombreRol == null || nombreRol.isBlank()) {
            return Optional.empty();
        }

        String normalizado = Normalizer.normalize(nombreRol, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .trim()
                .replace(' ', '_')
                .toUpperCase(Locale.ROOT);

        try {
            return Optional.of(TipoRol.valueOf(normalizado));
        } catch (IllegalArgumentException exception) {
            return Optional.empty();
        }
    }
}
