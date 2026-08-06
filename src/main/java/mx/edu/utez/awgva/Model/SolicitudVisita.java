package mx.edu.utez.awgva.Model;

import java.io.Serializable;

/**
 * Borrador temporal del formulario del Docente.
 * Se guarda en sesión únicamente mientras el usuario revisa la vista previa.
 */
public class SolicitudVisita implements Serializable {
    private String solicitanteNombre;
    private String solicitanteCargo;
    private String solicitanteTelefono;
    private String docentesAcompanantes;
    private String empresaNombre;
    private String empresaDireccion;
    private String empresaTelefono;
    private String empresaEmail;
    private String fechaInicio;
    private String fechaTermino;
    private String horaInicio;
    private String objetivo;
    private String dacea;
    private String datefi;
    private String datid;
    private String dami;
    private String totalEstudiantes;
    private String asignaturas;
    private String programaEducativo;
    private String semestre;
    private String grupo;
    private String division;
    private String estado = "PENDIENTE";

    public SolicitudVisita() { }

    public String getSolicitanteNombre() { return solicitanteNombre; }
    public void setSolicitanteNombre(String solicitanteNombre) { this.solicitanteNombre = solicitanteNombre; }
    public String getSolicitanteCargo() { return solicitanteCargo; }
    public void setSolicitanteCargo(String solicitanteCargo) { this.solicitanteCargo = solicitanteCargo; }
    public String getSolicitanteTelefono() { return solicitanteTelefono; }
    public void setSolicitanteTelefono(String solicitanteTelefono) { this.solicitanteTelefono = solicitanteTelefono; }
    public String getDocentesAcompanantes() { return docentesAcompanantes; }
    public void setDocentesAcompanantes(String docentesAcompanantes) { this.docentesAcompanantes = docentesAcompanantes; }
    public String getEmpresaNombre() { return empresaNombre; }
    public void setEmpresaNombre(String empresaNombre) { this.empresaNombre = empresaNombre; }
    public String getEmpresaDireccion() { return empresaDireccion; }
    public void setEmpresaDireccion(String empresaDireccion) { this.empresaDireccion = empresaDireccion; }
    public String getEmpresaTelefono() { return empresaTelefono; }
    public void setEmpresaTelefono(String empresaTelefono) { this.empresaTelefono = empresaTelefono; }
    public String getEmpresaEmail() { return empresaEmail; }
    public void setEmpresaEmail(String empresaEmail) { this.empresaEmail = empresaEmail; }
    public String getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(String fechaInicio) { this.fechaInicio = fechaInicio; }
    public String getFechaTermino() { return fechaTermino; }
    public void setFechaTermino(String fechaTermino) { this.fechaTermino = fechaTermino; }
    public String getHoraInicio() { return horaInicio; }
    public void setHoraInicio(String horaInicio) { this.horaInicio = horaInicio; }
    public String getObjetivo() { return objetivo; }
    public void setObjetivo(String objetivo) { this.objetivo = objetivo; }
    public String getDacea() { return dacea; }
    public void setDacea(String dacea) { this.dacea = dacea; }
    public String getDatefi() { return datefi; }
    public void setDatefi(String datefi) { this.datefi = datefi; }
    public String getDatid() { return datid; }
    public void setDatid(String datid) { this.datid = datid; }
    public String getDami() { return dami; }
    public void setDami(String dami) { this.dami = dami; }
    public String getTotalEstudiantes() { return totalEstudiantes; }
    public void setTotalEstudiantes(String totalEstudiantes) { this.totalEstudiantes = totalEstudiantes; }
    public String getAsignaturas() { return asignaturas; }
    public void setAsignaturas(String asignaturas) { this.asignaturas = asignaturas; }
    public String getProgramaEducativo() { return programaEducativo; }
    public void setProgramaEducativo(String programaEducativo) { this.programaEducativo = programaEducativo; }
    public String getSemestre() { return semestre; }
    public void setSemestre(String semestre) { this.semestre = semestre; }
    public String getGrupo() { return grupo; }
    public void setGrupo(String grupo) { this.grupo = grupo; }
    public String getDivision() { return division; }
    public void setDivision(String division) { this.division = division; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}