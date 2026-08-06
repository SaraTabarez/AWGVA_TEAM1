package mx.edu.utez.awgva.Model;

import java.time.LocalDateTime;

public class Division {
    private Long idDivision;
    private String division;
    private String descripcion;
    private LocalDateTime fechaCreacion;

    // Constructor vacío
    public Division() {}

    // Constructor completo
    public Division(String division, String descripcion) {
        this.division = division;
        this.descripcion = descripcion;
    }

    // Getters y Setters
    public Long getIdDivision() { return idDivision; }
    public void setIdDivision(Long idDivision) { this.idDivision = idDivision; }

    public String getDivision() { return division; }
    public void setDivision(String division) { this.division = division; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
}