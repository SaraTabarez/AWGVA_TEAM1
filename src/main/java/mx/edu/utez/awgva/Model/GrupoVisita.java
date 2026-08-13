package mx.edu.utez.awgva.Model;

import java.time.LocalDateTime;

public class GrupoVisita {
    private Long idGrupo;
    private Long idVisitaFk;
    private String programaEducativo;
    private String semestre;
    private String nombreGrupo;
    private Integer numeroEstudiantes;
    private LocalDateTime creadoEn;
    private String area;

    // Constructor vacío
    public GrupoVisita() {}

    // Constructor completo
    public GrupoVisita(Long idVisitaFk, String programaEducativo, String semestre,
                       String nombreGrupo, Integer numeroEstudiantes) {
        this.idVisitaFk = idVisitaFk;
        this.programaEducativo = programaEducativo;
        this.semestre = semestre;
        this.nombreGrupo = nombreGrupo;
        this.numeroEstudiantes = numeroEstudiantes;
    }

    // Getters y Setters
    public Long getIdGrupo() { return idGrupo; }
    public void setIdGrupo(Long idGrupo) { this.idGrupo = idGrupo; }

    public Long getIdVisitaFk() { return idVisitaFk; }
    public void setIdVisitaFk(Long idVisitaFk) { this.idVisitaFk = idVisitaFk; }

    public String getProgramaEducativo() { return programaEducativo; }
    public void setProgramaEducativo(String programaEducativo) { this.programaEducativo = programaEducativo; }

    public String getSemestre() { return semestre; }
    public void setSemestre(String semestre) { this.semestre = semestre; }

    public String getNombreGrupo() { return nombreGrupo; }
    public void setNombreGrupo(String nombreGrupo) { this.nombreGrupo = nombreGrupo; }

    public Integer getNumeroEstudiantes() { return numeroEstudiantes; }
    public void setNumeroEstudiantes(Integer numeroEstudiantes) { this.numeroEstudiantes = numeroEstudiantes; }

    public LocalDateTime getCreadoEn() { return creadoEn; }
    public void setCreadoEn(LocalDateTime creadoEn) { this.creadoEn = creadoEn; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
}