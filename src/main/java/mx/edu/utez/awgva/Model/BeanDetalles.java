package mx.edu.utez.awgva.Model;

public class BeanDetalles {
    private int id;
    private String lugarVisita;
    private String fechaVisita;
    private String carrera;
    private String grupo;
    private String empresaNombre;
    private String empresaTelefono;
    private String empresaCorreo;
    private String docenteResponsable;
    private String docenteAcompanante;
    private int totalEstudiantes;
    private String estado;

    public BeanDetalles() {}

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getLugarVisita() { return lugarVisita; }
    public void setLugarVisita(String lugarVisita) { this.lugarVisita = lugarVisita; }

    public String getFechaVisita() { return fechaVisita; }
    public void setFechaVisita(String fechaVisita) { this.fechaVisita = fechaVisita; }

    public String getCarrera() { return carrera; }
    public void setCarrera(String carrera) { this.carrera = carrera; }

    public String getGrupo() { return grupo; }
    public void setGrupo(String grupo) { this.grupo = grupo; }

    public String getEmpresaNombre() { return empresaNombre; }
    public void setEmpresaNombre(String empresaNombre) { this.empresaNombre = empresaNombre; }

    public String getEmpresaTelefono() { return empresaTelefono; }
    public void setEmpresaTelefono(String empresaTelefono) { this.empresaTelefono = empresaTelefono; }

    public String getEmpresaCorreo() { return empresaCorreo; }
    public void setEmpresaCorreo(String empresaCorreo) { this.empresaCorreo = empresaCorreo; }

    public String getDocenteResponsable() { return docenteResponsable; }
    public void setDocenteResponsable(String docenteResponsable) { this.docenteResponsable = docenteResponsable; }

    public String getDocenteAcompanante() { return docenteAcompanante; }
    public void setDocenteAcompanante(String docenteAcompanante) { this.docenteAcompanante = docenteAcompanante; }

    public int getTotalEstudiantes() { return totalEstudiantes; }
    public void setTotalEstudiantes(int totalEstudiantes) { this.totalEstudiantes = totalEstudiantes; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}