package mx.edu.utez.awgva.Model;

import java.sql.Timestamp;
import java.util.Optional;

public class Usuario {

    private Long idUsuario;
    private String correo;
    private String passwordHash;
    private String nombres;
    private String apellidoPaterno;
    private String apellidoMaterno;
    private Long idRolFk;
    private Long idDivisionFk;
    private Integer estado;
    private Timestamp creadoEn;
    private Timestamp actualizadoEn;

    private String resetToken;
    private Timestamp resetTokenExpiration;

    // Campos auxiliares para la tabla de la vista
    private String nombreRol;
    private String nombreDivision;
    private String referenceToken;

    public Usuario() {
    }

    public Usuario(String correo, String passwordHash) {
        this.correo = correo;
        this.passwordHash = passwordHash;
    }

    public Usuario(Long idUsuario, String correo, String passwordHash, String nombres,
                   String apellidoPaterno, String apellidoMaterno, Long idRolFk,
                   Long idDivisionFk, Integer estado, Timestamp creadoEn,
                   Timestamp actualizadoEn, String resetToken, Timestamp resetTokenExpiration) {
        this.idUsuario = idUsuario;
        this.correo = correo;
        this.passwordHash = passwordHash;
        this.nombres = nombres;
        this.apellidoPaterno = apellidoPaterno;
        this.apellidoMaterno = apellidoMaterno;
        this.idRolFk = idRolFk;
        this.idDivisionFk = idDivisionFk;
        this.estado = estado;
        this.creadoEn = creadoEn;
        this.actualizadoEn = actualizadoEn;
        this.resetToken = resetToken;
        this.resetTokenExpiration = resetTokenExpiration;
    }

    public Long getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Long idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public String getApellidoPaterno() {
        return apellidoPaterno;
    }

    public void setApellidoPaterno(String apellidoPaterno) {
        this.apellidoPaterno = apellidoPaterno;
    }

    public String getApellidoMaterno() {
        return apellidoMaterno;
    }

    public void setApellidoMaterno(String apellidoMaterno) {
        this.apellidoMaterno = apellidoMaterno;
    }

    public Long getIdRolFk() {
        return idRolFk;
    }

    public void setIdRolFk(Long idRolFk) {
        this.idRolFk = idRolFk;
    }

    public Long getIdDivisionFk() {
        return idDivisionFk;
    }

    public void setIdDivisionFk(Long idDivisionFk) {
        this.idDivisionFk = idDivisionFk;
    }

    public Integer getEstado() {
        return estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public Timestamp getCreadoEn() {
        return creadoEn;
    }

    public void setCreadoEn(Timestamp creadoEn) {
        this.creadoEn = creadoEn;
    }

    public Timestamp getActualizadoEn() {
        return actualizadoEn;
    }

    public void setActualizadoEn(Timestamp actualizadoEn) {
        this.actualizadoEn = actualizadoEn;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public Timestamp getResetTokenExpiration() {
        return resetTokenExpiration;
    }

    public void setResetTokenExpiration(Timestamp resetTokenExpiration) {
        this.resetTokenExpiration = resetTokenExpiration;
    }

    public String getNombreCompleto() {
        return String.join(" ",
                valueOrEmpty(nombres),
                valueOrEmpty(apellidoPaterno),
                valueOrEmpty(apellidoMaterno)
        ).replaceAll("\\s+", " ").trim();
    }

    public Optional<TipoRol> getTipoRol() {
        return TipoRol.from(nombreRol);
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value;
    }

    // ==========================================
    // GETTERS Y SETTERS AUXILIARES PARA VISTA/SERVLET
    // ==========================================
    public String getNombreRol() {
        return nombreRol;
    }

    public void setNombreRol(String nombreRol) {
        this.nombreRol = nombreRol;
    }

    public String getNombreDivision() {
        return nombreDivision;
    }

    public void setNombreDivision(String nombreDivision) {
        this.nombreDivision = nombreDivision;
    }

    public Long getIdRol() {
        return idRolFk;
    }

    public void setIdRol(Long idRol) {
        this.idRolFk = idRol;
    }

    public Long getIdDivision() {
        return idDivisionFk;
    }

    public void setIdDivision(Long idDivision) {
        this.idDivisionFk = idDivision;
    }

    public void setPassword(String password) {
        this.passwordHash = password;
    }

    public String getReferenceToken() {
        return referenceToken;
    }

    public void setReferenceToken(String referenceToken) {
        this.referenceToken = referenceToken;
    }
}
