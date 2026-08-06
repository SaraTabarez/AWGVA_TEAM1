package mx.edu.utez.awgva.Model;

public class BeanSolicitud {
    private String id;
    private String division;
    private String lugar;
    private String fechaSalida;
    private String estado;

    public BeanSolicitud() {}

    public BeanSolicitud(String id, String division, String lugar, String fechaSalida, String estado) {
        this.id = id;
        this.division = division;
        this.lugar = lugar;
        this.fechaSalida = fechaSalida;
        this.estado = estado;
    }

    // Getters y Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getDivision() { return division; }
    public void setDivision(String division) { this.division = division; }

    public String getLugar() { return lugar; }
    public void setLugar(String lugar) { this.lugar = lugar; }

    public String getFechaSalida() { return fechaSalida; }
    public void setFechaSalida(String fechaSalida) { this.fechaSalida = fechaSalida; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}