package mx.edu.utez.awgva.Model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Proyección de una visita con los datos reales que necesitan las vistas. */
public class ExpedienteVisita {
    private Long idVisita;
    private Long idUsuario;
    private Long idDivision;
    private String division;
    private String docente;
    private String correoDocente;
    private String titulo;
    private String asignatura;
    private String docenteAcompanante;
    private String proposito;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
    private String estado;
    private String motivoRechazo;
    private LocalDateTime creadoEn;
    private String empresa;
    private String direccionEmpresa;
    private String telefonoEmpresa;
    private String correoEmpresa;
    private String carrera;
    private String semestre;
    private String grupo;
    private Integer numeroEstudiantes;
    private String estadoReporte;
    private List<Documento> documentos = new ArrayList<>();
    private String referenceToken;

    public Long getIdVisita() { return idVisita; }
    public void setIdVisita(Long idVisita) { this.idVisita = idVisita; }
    public Long getIdUsuario() { return idUsuario; }
    public void setIdUsuario(Long idUsuario) { this.idUsuario = idUsuario; }
    public Long getIdDivision() { return idDivision; }
    public void setIdDivision(Long idDivision) { this.idDivision = idDivision; }
    public String getDivision() { return division; }
    public void setDivision(String division) { this.division = division; }
    public String getDocente() { return docente; }
    public void setDocente(String docente) { this.docente = docente; }
    public String getCorreoDocente() { return correoDocente; }
    public void setCorreoDocente(String correoDocente) { this.correoDocente = correoDocente; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getAsignatura() { return asignatura; }
    public void setAsignatura(String asignatura) { this.asignatura = asignatura; }
    public String getDocenteAcompanante() { return docenteAcompanante; }
    public void setDocenteAcompanante(String docenteAcompanante) { this.docenteAcompanante = docenteAcompanante; }
    public String getProposito() { return proposito; }
    public void setProposito(String proposito) { this.proposito = proposito; }
    public LocalDate getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(LocalDate fechaInicio) { this.fechaInicio = fechaInicio; }
    public LocalDate getFechaFin() { return fechaFin; }
    public void setFechaFin(LocalDate fechaFin) { this.fechaFin = fechaFin; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getMotivoRechazo() { return motivoRechazo; }
    public void setMotivoRechazo(String motivoRechazo) { this.motivoRechazo = motivoRechazo; }
    public LocalDateTime getCreadoEn() { return creadoEn; }
    public void setCreadoEn(LocalDateTime creadoEn) { this.creadoEn = creadoEn; }
    public String getEmpresa() { return empresa; }
    public void setEmpresa(String empresa) { this.empresa = empresa; }
    public String getDireccionEmpresa() { return direccionEmpresa; }
    public void setDireccionEmpresa(String direccionEmpresa) { this.direccionEmpresa = direccionEmpresa; }
    public String getTelefonoEmpresa() { return telefonoEmpresa; }
    public void setTelefonoEmpresa(String telefonoEmpresa) { this.telefonoEmpresa = telefonoEmpresa; }
    public String getCorreoEmpresa() { return correoEmpresa; }
    public void setCorreoEmpresa(String correoEmpresa) { this.correoEmpresa = correoEmpresa; }
    public String getCarrera() { return carrera; }
    public void setCarrera(String carrera) { this.carrera = carrera; }
    public String getSemestre() { return semestre; }
    public void setSemestre(String semestre) { this.semestre = semestre; }
    public String getGrupo() { return grupo; }
    public void setGrupo(String grupo) { this.grupo = grupo; }
    public Integer getNumeroEstudiantes() { return numeroEstudiantes; }
    public void setNumeroEstudiantes(Integer numeroEstudiantes) { this.numeroEstudiantes = numeroEstudiantes; }
    public String getEstadoReporte() { return estadoReporte; }
    public void setEstadoReporte(String estadoReporte) { this.estadoReporte = estadoReporte; }
    public List<Documento> getDocumentos() { return documentos; }
    public void setDocumentos(List<Documento> documentos) {
        this.documentos = documentos == null ? new ArrayList<>() : documentos;
    }
    public String getReferenceToken() { return referenceToken; }
    public void setReferenceToken(String referenceToken) { this.referenceToken = referenceToken; }

    public String getEstadoLegible() {
        if (estado == null) return "Sin estado";
        return switch (estado.trim().toUpperCase()) {
            case "PENDIENTE" -> "Pendiente";
            case "PENDIENTE_DIRECTOR" -> "Pendiente de revisión por Dirección";
            case "ACEPTADA" -> "Aceptada";
            case "ACEPTADA_DIRECTOR" -> "Aprobada por Dirección · esperando solicitud firmada";
            case "RECHAZADA" -> "Rechazada";
            case "RECHAZADA_DIRECTOR" -> "Rechazada por Dirección";
            case "SOLICITUD_APROBADA_ESTADIAS" -> "Solicitud firmada aceptada · carta habilitada";
            case "SOLICITUD_RECHAZADA_ESTADIAS" -> "Solicitud firmada rechazada · requiere corrección";
            case "CARTA_APROBADA_ESTADIAS" -> "Carta aceptada · oficio y reporte habilitados";
            case "CARTA_RECHAZADA_ESTADIAS" -> "Carta rechazada · requiere corrección";
            case "OFICIO_GENERADO" -> "Oficio generado · reporte pendiente";
            case "DOCUMENTACION_APROBADA" -> "Documentación aprobada";
            case "DOCUMENTACION_RECHAZADA" -> "Documentación con correcciones";
            case "REPORTE_EN_REVISION" -> "Reporte pendiente de revisión";
            case "REPORTE_RECHAZADO" -> "Reporte rechazado · requiere corrección";
            case "COMPLETADA" -> "Finalizada";
            default -> estado.replace('_', ' ');
        };
    }
}