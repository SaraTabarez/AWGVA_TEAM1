package mx.edu.utez.awgva.Model;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/** Catálogo académico solicitado, separado por división. */
public final class CatalogoCarreras {

    private static final Map<String, List<String>> CARRERAS = Map.of(
            "DATEFI", List.of(
                    "Licenciatura en Terapia Física",
                    "Licenciatura en Gestión del Bienestar"
            ),
            "DAMI", List.of(
                    "Ingeniería en Mantenimiento Industrial",
                    "Ingeniería en Nanotecnología",
                    "Ingeniería Industrial",
                    "Ingeniería Mecatrónica"
            ),
            "DACEA", List.of(
                    "Licenciatura en Administración",
                    "Licenciatura en Contaduría",
                    "Licenciatura en Negocios y Mercadotecnia"
            ),
            "DATID", List.of(
                    "Ingeniería en Tecnologías de la Información e Innovación Digital",
                    "Licenciatura en Diseño Digital y Producción Audiovisual",
                    "Licenciatura en Diseño Textil y Moda",
                    "TSU en Infraestructura de Redes Digitales",
                    "TSU en Desarrollo de Software Multiplataforma"
            )
    );

    private CatalogoCarreras() {
    }

    public static List<String> deDivision(String division) {
        return CARRERAS.getOrDefault(codigoDivision(division), List.of());
    }

    public static boolean pertenece(String division, String carrera) {
        if (carrera == null) return false;
        return deDivision(division).stream().anyMatch(item -> item.equalsIgnoreCase(carrera.trim()));
    }

    /**
     * Devuelve siempre la clave institucional de la división. Acepta tanto DATID/DAMI/DATEFI/DACEA
     * como las descripciones largas que puedan venir de Oracle o de una cuenta creada manualmente.
     */
    public static String codigoDivision(String valor) {
        String normalizado = normalizar(valor);
        if (normalizado.isBlank()) return "";

        if (normalizado.equals("DATID") || normalizado.contains("DATID")
                || normalizado.contains("TECNOLOGIAS DE LA INFORMACION")) return "DATID";
        if (normalizado.equals("DAMI") || normalizado.contains("DAMI")
                || normalizado.contains("MANTENIMIENTO E INGENIERIA INDUSTRIAL")) return "DAMI";
        if (normalizado.equals("DATEFI") || normalizado.contains("DATEFI")
                || normalizado.contains("TERAPIA FISICA")) return "DATEFI";
        if (normalizado.equals("DACEA") || normalizado.contains("DACEA")
                || normalizado.contains("ECONOMICO-ADMINISTRATIVA")
                || normalizado.contains("ECONOMICO ADMINISTRATIVA")) return "DACEA";

        return normalizado;
    }

    private static String normalizar(String valor) {
        if (valor == null) return "";
        return Normalizer.normalize(valor, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .trim()
                .toUpperCase(Locale.ROOT);
    }
}
