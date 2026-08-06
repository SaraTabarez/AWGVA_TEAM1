package mx.edu.utez.awgva.Service;

import mx.edu.utez.awgva.Dao.UsuarioDao;
import mx.edu.utez.awgva.Model.TipoRol;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Utils.EmailSender;

import java.security.SecureRandom;
import java.sql.Timestamp;
import java.text.MessageFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

public class UsuarioService {

    private static final Pattern INSTITUTIONAL_EMAIL = Pattern.compile(
            "^[A-Z0-9._%+-]+@utez\\.edu\\.mx$",
            Pattern.CASE_INSENSITIVE
    );
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final UsuarioDao usuarioDao;
    private final PasswordService passwordService;

    public UsuarioService() {
        this(new UsuarioDao(), new PasswordService());
    }

    UsuarioService(UsuarioDao usuarioDao, PasswordService passwordService) {
        this.usuarioDao = usuarioDao;
        this.passwordService = passwordService;
    }

    public Usuario authenticate(String correo, String password) {
        if (correo == null || password == null || correo.length() > 160 || password.length() > 200) {
            return null;
        }

        Usuario usuario = usuarioDao.findByEmail(correo.trim().toLowerCase(Locale.ROOT));
        if (usuario == null || usuario.getEstado() == null || usuario.getEstado() != 1) {
            return null;
        }

        PasswordService.Verification verification = passwordService.verify(
                password,
                usuario.getPasswordHash()
        );
        if (!verification.valid() || usuario.getTipoRol().isEmpty()) {
            return null;
        }

        // Migración transparente de los registros antiguos en texto plano/SHA-256.
        if (verification.needsRehash()) {
            usuarioDao.updatePasswordHash(usuario.getIdUsuario(), passwordService.hash(password));
        }

        // El hash no debe permanecer dentro del objeto guardado en la sesión.
        usuario.setPasswordHash(null);
        usuario.setResetToken(null);
        usuario.setResetTokenExpiration(null);
        return usuario;
    }

    public boolean register(Usuario usuario, String plainPassword) {
        validateRegistration(usuario, plainPassword);
        usuario.setCorreo(usuario.getCorreo().trim().toLowerCase(Locale.ROOT));
        usuario.setPasswordHash(passwordService.hash(plainPassword));
        return usuarioDao.save(usuario);
    }

    public List<Usuario> findAll() {
        return usuarioDao.findAll();
    }

    public Map<Long, String> findRoles() {
        return usuarioDao.findRoles();
    }

    public Map<Long, String> findDivisiones() {
        return usuarioDao.findDivisiones();
    }

    public boolean updateStatus(Long idUsuario, int estado) {
        if (idUsuario == null || (estado != 0 && estado != 1)) {
            return false;
        }
        return usuarioDao.updateEstado(idUsuario, estado);
    }

    public UserDeletionResult deleteUser(Long idUsuario, Usuario currentUser) {
        if (idUsuario == null || currentUser == null
                || currentUser.getTipoRol().orElse(null) != TipoRol.ADMIN) {
            return UserDeletionResult.UNAUTHORIZED;
        }
        if (idUsuario.equals(currentUser.getIdUsuario())) {
            return UserDeletionResult.SELF_PROTECTED;
        }

        Usuario target = usuarioDao.findById(idUsuario);
        if (target == null) {
            return UserDeletionResult.NOT_FOUND;
        }
        if (target.getTipoRol().orElse(null) == TipoRol.ADMIN) {
            return UserDeletionResult.ADMIN_PROTECTED;
        }

        return switch (usuarioDao.deleteById(idUsuario)) {
            case DELETED -> UserDeletionResult.DELETED;
            case NOT_FOUND -> UserDeletionResult.NOT_FOUND;
            case HAS_DEPENDENCIES -> UserDeletionResult.HAS_DEPENDENCIES;
            case ERROR -> UserDeletionResult.ERROR;
        };
    }

    public boolean generateAndSendResetCode(String correo) {
        Usuario usuario = usuarioDao.findByEmail(correo);
        if (usuario == null) {
            return false;
        }

        String resetToken = generateRandomCode(8);
        Timestamp expiration = new Timestamp(System.currentTimeMillis() + (15 * 60 * 1000));
        if (!usuarioDao.updateResetToken(correo, resetToken, expiration)) {
            return false;
        }

        String plantillaHtml = """
                <html>
                    <body style="font-family: Arial, sans-serif; color: #333333;">
                        <h2 style="color: #1e3a5f;">Recuperación de contraseña</h2>
                        <p>Hola, <strong>{0}</strong>.</p>
                        <p>Tu código de verificación es:</p>
                        <div style="font-size: 30px; font-weight: bold; letter-spacing: 5px;">{1}</div>
                        <p>El código expirará en 15 minutos.</p>
                    </body>
                </html>
                """;

        String body = MessageFormat.format(plantillaHtml, usuario.getNombreCompleto(), resetToken);
        try {
            EmailSender.sendMail(correo, "Código de recuperación de contraseña", body);
            return true;
        } catch (RuntimeException exception) {
            System.err.println("No fue posible enviar el correo de recuperación.");
            return false;
        }
    }

    public boolean resetPassword(String token, String correo, String newPassword) {
        validatePassword(newPassword);
        if (correo == null || !usuarioDao.isResetTokenValid(token, correo)) {
            return false;
        }

        Usuario usuario = usuarioDao.findByResetToken(token, correo);
        return usuario != null && usuarioDao.updatePassword(
                usuario.getCorreo(),
                passwordService.hash(newPassword)
        );
    }

    public boolean changeOwnPassword(Usuario sessionUser, String currentPassword, String newPassword) {
        if (sessionUser == null || currentPassword == null) return false;
        validatePassword(newPassword);
        Usuario storedUser = usuarioDao.findByEmail(sessionUser.getCorreo());
        if (storedUser == null || !passwordService.verify(currentPassword, storedUser.getPasswordHash()).valid()) {
            return false;
        }
        return usuarioDao.updatePasswordHash(sessionUser.getIdUsuario(), passwordService.hash(newPassword));
    }

    private void validateRegistration(Usuario usuario, String password) {
        if (usuario == null) {
            throw new IllegalArgumentException("Los datos del usuario son obligatorios.");
        }
        requireText(usuario.getNombres(), "El nombre es obligatorio.", 100);
        requireText(usuario.getApellidoPaterno(), "El apellido paterno es obligatorio.", 100);
        requireText(usuario.getApellidoMaterno(), "El apellido materno es obligatorio.", 100);

        if (usuario.getCorreo() == null || !INSTITUTIONAL_EMAIL.matcher(usuario.getCorreo().trim()).matches()) {
            throw new IllegalArgumentException("Usa un correo institucional @utez.edu.mx válido.");
        }
        validatePassword(password);

        Map<Long, String> roles = usuarioDao.findRoles();
        String roleName = roles.get(usuario.getIdRolFk());
        TipoRol role = TipoRol.from(roleName)
                .orElseThrow(() -> new IllegalArgumentException("Selecciona un rol válido."));

        if (!usuarioDao.divisionExists(usuario.getIdDivisionFk())) {
            throw new IllegalArgumentException("La división seleccionada no existe.");
        }
        if ((role == TipoRol.DOCENTE || role == TipoRol.DIRECTOR)
                && usuario.getIdDivisionFk() == null) {
            throw new IllegalArgumentException("Docente y Director deben tener una división asignada.");
        }
        if (usuarioDao.emailExists(usuario.getCorreo())) {
            throw new IllegalArgumentException("Ya existe un usuario con ese correo.");
        }
    }

    private void validatePassword(String password) {
        if (password == null || password.length() < 10
                || !password.matches(".*[A-Z].*")
                || !password.matches(".*[a-z].*")
                || !password.matches(".*\\d.*")
                || !password.matches(".*[^A-Za-z0-9].*")) {
            throw new IllegalArgumentException(
                    "La contraseña debe tener al menos 10 caracteres, mayúscula, minúscula, número y símbolo."
            );
        }
    }

    private void requireText(String value, String message, int maxLength) {
        if (value == null || value.isBlank() || value.length() > maxLength) {
            throw new IllegalArgumentException(message);
        }
    }

    private String generateRandomCode(int length) {
        StringBuilder code = new StringBuilder(length);
        for (int index = 0; index < length; index++) {
            code.append(SECURE_RANDOM.nextInt(10));
        }
        return code.toString();
    }

    public enum UserDeletionResult {
        DELETED,
        NOT_FOUND,
        SELF_PROTECTED,
        ADMIN_PROTECTED,
        HAS_DEPENDENCIES,
        UNAUTHORIZED,
        ERROR
    }
}
