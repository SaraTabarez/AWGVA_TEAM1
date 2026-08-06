package mx.edu.utez.awgva.Model;

import java.time.LocalDateTime;

public class Empresa {
    private Long idEmpresa;
    private String nombreEmpresa;
    private String direccion;
    private String telefono;
    private String correo;
    private LocalDateTime creadoEn;
    private LocalDateTime actualizadoEn;

    // Constructor vacío
    public Empresa() {}

    // Constructor completo
    public Empresa(String nombreEmpresa, String direccion, String telefono, String correo) {
        this.nombreEmpresa = nombreEmpresa;
        this.direccion = direccion;
        this.telefono = telefono;
        this.correo = correo;
    }

    // Getters y Setters
    public Long getIdEmpresa() { return idEmpresa; }
    public void setIdEmpresa(Long idEmpresa) { this.idEmpresa = idEmpresa; }

    public String getNombreEmpresa() { return nombreEmpresa; }
    public void setNombreEmpresa(String nombreEmpresa) { this.nombreEmpresa = nombreEmpresa; }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public LocalDateTime getCreadoEn() { return creadoEn; }
    public void setCreadoEn(LocalDateTime creadoEn) { this.creadoEn = creadoEn; }

    public LocalDateTime getActualizadoEn() { return actualizadoEn; }
    public void setActualizadoEn(LocalDateTime actualizadoEn) { this.actualizadoEn = actualizadoEn; }
}
