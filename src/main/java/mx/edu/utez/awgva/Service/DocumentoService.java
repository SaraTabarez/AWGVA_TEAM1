package mx.edu.utez.awgva.Service;

import mx.edu.utez.awgva.Dao.DocumentoDao;
import mx.edu.utez.awgva.Model.Documento;

import java.util.List;
import java.util.Locale;
import java.util.Set;

public class DocumentoService {
    private static final Set<String> TIPOS_BASE = Set.of(
            "SOLICITUD_VISITA", "CARTA_RESPONSIVA", "REPORTE"
    );
    private static final Set<String> TIPOS_EVIDENCIA = Set.of(
            "EVIDENCIA_1", "EVIDENCIA_2", "EVIDENCIA_3"
    );

    private final DocumentoDao documentoDao = new DocumentoDao();

    public List<Documento> listarPorVisita(Long idVisita) {
        return documentoDao.listarPorVisita(idVisita);
    }

    public List<Documento> listarEvidenciasReporte(Long idVisita) {
        return documentoDao.listarEvidenciasReporte(idVisita);
    }

    public List<Documento> listarParaEstadias(String busqueda, String tipo) {
        String tipoNormalizado = tipo == null ? null : tipo.trim().toUpperCase(Locale.ROOT);
        if (tipoNormalizado != null && !tipoNormalizado.isBlank() && !TIPOS_BASE.contains(tipoNormalizado)) {
            throw new IllegalArgumentException("Tipo de documento no válido.");
        }
        return documentoDao.listarParaEstadias(busqueda, tipoNormalizado);
    }

    public Documento buscarPorId(Long idDocumento) {
        return documentoDao.buscarPorId(idDocumento);
    }

    public Documento buscarPorVisitaYTipo(Long idVisita, String tipo) {
        return documentoDao.buscarPorVisitaYTipo(idVisita, normalizarTipo(tipo));
    }

    public boolean guardar(Documento documento) {
        documento.setTipoDocumento(normalizarTipo(documento.getTipoDocumento()));
        return documentoDao.guardarDocumento(documento);
    }

    public boolean guardarLote(List<Documento> documentos) {
        if (documentos == null || documentos.isEmpty()) return false;
        for (Documento documento : documentos) {
            documento.setTipoDocumento(normalizarTipo(documento.getTipoDocumento()));
        }
        return documentoDao.guardarLote(documentos);
    }

    public boolean revisar(Long idDocumento, String decision, String observaciones, Long revisor) {
        String estado;
        if ("ACEPTAR".equalsIgnoreCase(decision)) {
            estado = "ACEPTADO";
        } else if ("RECHAZAR".equalsIgnoreCase(decision)) {
            estado = "RECHAZADO";
        } else {
            throw new IllegalArgumentException("Decisión no válida.");
        }
        if ("RECHAZADO".equals(estado) && (observaciones == null || observaciones.isBlank())) {
            throw new IllegalArgumentException("Escribe el motivo del rechazo.");
        }
        String motivo = observaciones == null ? null : observaciones.trim();
        if (motivo != null && motivo.length() > 500) {
            throw new IllegalArgumentException("Las observaciones no pueden superar 500 caracteres.");
        }
        return documentoDao.revisar(idDocumento, estado, motivo, revisor);
    }

    private String normalizarTipo(String tipo) {
        if (tipo == null) throw new IllegalArgumentException("Tipo de documento obligatorio.");
        String normalizado = tipo.trim().replace(' ', '_').toUpperCase(Locale.ROOT);
        normalizado = switch (normalizado) {
            case "SOLICITUD", "SOLICITUD_DE_VISITA" -> "SOLICITUD_VISITA";
            case "CARTA" -> "CARTA_RESPONSIVA";
            case "REPORTE_DE_VISITA" -> "REPORTE";
            default -> normalizado;
        };
        if (!TIPOS_BASE.contains(normalizado) && !TIPOS_EVIDENCIA.contains(normalizado)) {
            throw new IllegalArgumentException("Tipo de documento no permitido.");
        }
        return normalizado;
    }
}
