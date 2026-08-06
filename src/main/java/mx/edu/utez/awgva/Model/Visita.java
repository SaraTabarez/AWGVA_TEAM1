package mx.edu.utez.awgva.Model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Visita {
    private Long idVisita;
    private Long idUsuarioFk;
    private Long idDivisionFk;
    private Long idEmpresaFk;
    private String tituloVisita;
    private String asignaturaAReforzar;
    private String docenteAcompanante;
    private String docenteEncargado;
    private String propositoVisita;
    private LocalDate fechaInicioVisita;
    private LocalDate fechaFinVisita;
    private String estado;
    private String motivoRechazo;
    private LocalDateTime creadoEn;
    private LocalDateTime actualizadoEn;

    // Constructor vacío
    public Visita() {}

    // Constructor completo
    public Visita(Long idUsuarioFk, Long idDivisionFk, Long idEmpresaFk, String tituloVisita,
                  String asignaturaAReforzar, String docenteAcompanante, String docenteEncargado,
                  String propositoVisita, LocalDate fechaInicioVisita, LocalDate fechaFinVisita) {
        this.idUsuarioFk = idUsuarioFk;
        this.idDivisionFk = idDivisionFk;
        this.idEmpresaFk = idEmpresaFk;
        this.tituloVisita = tituloVisita;
        this.asignaturaAReforzar = asignaturaAReforzar;
        this.docenteAcompanante = docenteAcompanante;
        this.docenteEncargado = docenteEncargado;
        this.propositoVisita = propositoVisita;
        this.fechaInicioVisita = fechaInicioVisita;
        this.fechaFinVisita = fechaFinVisita;
        this.estado = "Pendiente";
    }

    // Getters y Setters
    public Long getIdVisita() { return idVisita; }
    public void setIdVisita(Long idVisita) { this.idVisita = idVisita; }

    public Long getIdUsuarioFk() { return idUsuarioFk; }
    public void setIdUsuarioFk(Long idUsuarioFk) { this.idUsuarioFk = idUsuarioFk; }

    public Long getIdDivisionFk() { return idDivisionFk; }
    public void setIdDivisionFk(Long idDivisionFk) { this.idDivisionFk = idDivisionFk; }

    public Long getIdEmpresaFk() { return idEmpresaFk; }
    public void setIdEmpresaFk(Long idEmpresaFk) { this.idEmpresaFk = idEmpresaFk; }

    public String getTituloVisita() { return tituloVisita; }
    public void setTituloVisita(String tituloVisita) { this.tituloVisita = tituloVisita; }

    public String getAsignaturaAReforzar() { return asignaturaAReforzar; }
    public void setAsignaturaAReforzar(String asignaturaAReforzar) { this.asignaturaAReforzar = asignaturaAReforzar; }

    public String getDocenteAcompanante() { return docenteAcompanante; }
    public void setDocenteAcompanante(String docenteAcompanante) { this.docenteAcompanante = docenteAcompanante; }

    public String getDocenteEncargado() { return docenteEncargado; }
    public void setDocenteEncargado(String docenteEncargado) { this.docenteEncargado = docenteEncargado; }

    public String getPropositoVisita() { return propositoVisita; }
    public void setPropositoVisita(String propositoVisita) { this.propositoVisita = propositoVisita; }

    public LocalDate getFechaInicioVisita() { return fechaInicioVisita; }
    public void setFechaInicioVisita(LocalDate fechaInicioVisita) { this.fechaInicioVisita = fechaInicioVisita; }

    public LocalDate getFechaFinVisita() { return fechaFinVisita; }
    public void setFechaFinVisita(LocalDate fechaFinVisita) { this.fechaFinVisita = fechaFinVisita; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getMotivoRechazo() { return motivoRechazo; }
    public void setMotivoRechazo(String motivoRechazo) { this.motivoRechazo = motivoRechazo; }

    public LocalDateTime getCreadoEn() { return creadoEn; }
    public void setCreadoEn(LocalDateTime creadoEn) { this.creadoEn = creadoEn; }

    public LocalDateTime getActualizadoEn() { return actualizadoEn; }
    public void setActualizadoEn(LocalDateTime actualizadoEn) { this.actualizadoEn = actualizadoEn; }
}