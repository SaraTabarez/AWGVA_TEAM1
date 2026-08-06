package mx.edu.utez.awgva.Model;

import java.time.LocalDateTime;

public class Documento {
    private Long idDocumento;
    private Long idVisitaFk;
    private String tipoDocumento;
    private String rutaArchivo;
    private String nombreArchivo;
    private Long tamanoArchivo;
    private LocalDateTime subidoEn;
    private String estado;
    private String observaciones;
    private Long idRevisorFk;
    private LocalDateTime revisadoEn;

    // Datos auxiliares de las consultas para Estadías y autorización.
    private Long idPropietario;
    private Long idDivision;
    private String empresa;
    private String docente;
    private String division;
    private String carrera;

    // Constructor vacío
    public Documento() {}

    // Constructor completo
    public Documento(Long idVisitaFk, String tipoDocumento, String rutaArchivo,
                     String nombreArchivo, Long tamanoArchivo) {
        this.idVisitaFk = idVisitaFk;
        this.tipoDocumento = tipoDocumento;
        this.rutaArchivo = rutaArchivo;
        this.nombreArchivo = nombreArchivo;
        this.tamanoArchivo = tamanoArchivo;
    }

    // Getters y Setters
    public Long getIdDocumento() { return idDocumento; }
    public void setIdDocumento(Long idDocumento) { this.idDocumento = idDocumento; }

    public Long getIdVisitaFk() { return idVisitaFk; }
    public void setIdVisitaFk(Long idVisitaFk) { this.idVisitaFk = idVisitaFk; }

    public String getTipoDocumento() { return tipoDocumento; }
    public void setTipoDocumento(String tipoDocumento) { this.tipoDocumento = tipoDocumento; }

    public String getRutaArchivo() { return rutaArchivo; }
    public void setRutaArchivo(String rutaArchivo) { this.rutaArchivo = rutaArchivo; }

    public String getNombreArchivo() { return nombreArchivo; }
    public void setNombreArchivo(String nombreArchivo) { this.nombreArchivo = nombreArchivo; }

    public Long getTamanoArchivo() { return tamanoArchivo; }
    public void setTamanoArchivo(Long tamanoArchivo) { this.tamanoArchivo = tamanoArchivo; }

    public LocalDateTime getSubidoEn() { return subidoEn; }
    public void setSubidoEn(LocalDateTime subidoEn) { this.subidoEn = subidoEn; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
    public Long getIdRevisorFk() { return idRevisorFk; }
    public void setIdRevisorFk(Long idRevisorFk) { this.idRevisorFk = idRevisorFk; }
    public LocalDateTime getRevisadoEn() { return revisadoEn; }
    public void setRevisadoEn(LocalDateTime revisadoEn) { this.revisadoEn = revisadoEn; }
    public Long getIdPropietario() { return idPropietario; }
    public void setIdPropietario(Long idPropietario) { this.idPropietario = idPropietario; }
    public Long getIdDivision() { return idDivision; }
    public void setIdDivision(Long idDivision) { this.idDivision = idDivision; }
    public String getEmpresa() { return empresa; }
    public void setEmpresa(String empresa) { this.empresa = empresa; }
    public String getDocente() { return docente; }
    public void setDocente(String docente) { this.docente = docente; }
    public String getDivision() { return division; }
    public void setDivision(String division) { this.division = division; }
    public String getCarrera() { return carrera; }
    public void setCarrera(String carrera) { this.carrera = carrera; }

    public String getTipoLegible() {
        if (tipoDocumento == null) return "Documento";
        return switch (tipoDocumento.trim().toUpperCase()) {
            case "SOLICITUD", "SOLICITUD_DE_VISITA", "SOLICITUD_VISITA" -> "Solicitud de visita";
            case "CARTA", "CARTA_RESPONSIVA" -> "Carta responsiva";
            case "REPORTE", "REPORTE_DE_VISITA" -> "Reporte";
            case "EVIDENCIA_1" -> "Evidencia 1";
            case "EVIDENCIA_2" -> "Evidencia 2";
            case "EVIDENCIA_3" -> "Evidencia 3";
            default -> tipoDocumento.replace('_', ' ');
        };
    }

    public String getEstadoLegible() {
        if (estado == null || estado.isBlank()) return "Pendiente";
        return switch (estado.trim().toUpperCase()) {
            case "ACEPTADO" -> "Aceptado";
            case "RECHAZADO" -> "Rechazado";
            default -> "Pendiente";
        };
    }

    public String getTamanoLegible() {
        if (tamanoArchivo == null) return "0 KB";
        if (tamanoArchivo < 1024L * 1024L) return String.format("%.1f KB", tamanoArchivo / 1024.0);
        return String.format("%.1f MB", tamanoArchivo / (1024.0 * 1024.0));
    }
}
