package mx.edu.utez.awgva.Model;

import java.io.Serializable;

public class DetalleGrupoSolicitud implements Serializable {
    private static final long serialVersionUID = 1L;
    private String carrera;
    private String area;
    private String cuatrimestre;
    private String grupo;
    private Integer cantidadAlumnos;

    public String getCarrera() { return carrera; }
    public void setCarrera(String carrera) { this.carrera = carrera; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public String getCuatrimestre() { return cuatrimestre; }
    public void setCuatrimestre(String cuatrimestre) { this.cuatrimestre = cuatrimestre; }
    public String getGrupo() { return grupo; }
    public void setGrupo(String grupo) { this.grupo = grupo; }
    public Integer getCantidadAlumnos() { return cantidadAlumnos; }
    public void setCantidadAlumnos(Integer cantidadAlumnos) { this.cantidadAlumnos = cantidadAlumnos; }
}