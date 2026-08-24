package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Service.LoginAttemptService;
import mx.edu.utez.awgva.Service.UsuarioService;
import mx.edu.utez.awgva.Utils.CsrfTokenUtil;

import java.io.IOException;
import java.util.Locale;
import java.util.regex.Pattern;

@WebServlet(name = "PasswordResetServlet", value = "/reset-password")
public class PasswordResetServlet extends HttpServlet {
    private static final String RESET_EMAIL = "resetCorreo";
    private static final String RESET_VERIFIED = "resetCodigoValidado";
    private static final String LAST_SEND = "resetUltimoEnvio";

    private static final String FLASH_STEP = "resetFlashStep";
    private static final String FLASH_ERROR = "resetFlashError";
    private static final String FLASH_MESSAGE = "resetFlashMessage";

    private static final Pattern INSTITUTIONAL_EMAIL = Pattern.compile(
            "^[A-Z0-9._%+-]+@utez\\.edu\\.mx$", Pattern.CASE_INSENSITIVE);

    private UsuarioService usuarioService;
    private LoginAttemptService attemptService;

    @Override
    public void init() {
        usuarioService = new UsuarioService();
        attemptService = new LoginAttemptService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        noStore(response);
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String step = takeString(session, FLASH_STEP);
        String error = takeString(session, FLASH_ERROR);
        String message = takeString(session, FLASH_MESSAGE);
        String email = (String) session.getAttribute(RESET_EMAIL);
        boolean verified = Boolean.TRUE.equals(session.getAttribute(RESET_VERIFIED));

        if (step == null) {
            if (email == null || email.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            step = verified ? "cambiar" : "codigo";
        }

        request.setAttribute("step", step);
        request.setAttribute("error", error);
        request.setAttribute("mensaje", message);
        request.setAttribute("correoRecuperacion", email);
        request.getRequestDispatcher("/recuperar-contra.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        noStore(response);

        HttpSession session = request.getSession(true);
        if (!CsrfTokenUtil.matches(session, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "El formulario expiró.");
            return;
        }

        String action = request.getParameter("action");
        if ("solicitar".equals(action)) {
            requestCode(request, response, session, false);
        } else if ("reenviar".equals(action)) {
            requestCode(request, response, session, true);
        } else if ("validar".equals(action)) {
            validateCode(request, response, session);
        } else if ("cambiar".equals(action)) {
            changePassword(request, response, session);
        } else if ("cancelar".equals(action)) {
            clear(session);
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void requestCode(HttpServletRequest request, HttpServletResponse response,
                             HttpSession session, boolean resend)
            throws IOException {
        String email = resend ? (String) session.getAttribute(RESET_EMAIL)
                : normalizeEmail(request.getParameter("correo"));

        if (email == null || !INSTITUTIONAL_EMAIL.matcher(email).matches()) {
            clear(session);
            redirectStep(request, response, session, "no-existe",
                    "Debes escribir tu correo institucional @utez.edu.mx en la pantalla de inicio.", null);
            return;
        }

        Long lastSend = (Long) session.getAttribute(LAST_SEND);
        long now = System.currentTimeMillis();
        if (resend && lastSend != null && now - lastSend < 60_000L) {
            redirectStep(request, response, session, "codigo", null,
                    "Espera un minuto antes de solicitar otro código.");
            return;
        }

        UsuarioService.PasswordResetRequest result = usuarioService.requestPasswordReset(email);
        if (result == UsuarioService.PasswordResetRequest.ACCOUNT_NOT_FOUND) {
            clear(session);
            redirectStep(request, response, session, "no-existe",
                    "El correo que estás usando NO EXISTE en el sistema. Verifica que esté escrito correctamente o comunícate con Administración.", null);
            return;
        }
        if (result == UsuarioService.PasswordResetRequest.ACCOUNT_INACTIVE) {
            clear(session);
            redirectStep(request, response, session, "no-existe",
                    "La cuenta existe, pero está INACTIVA. Comunícate con Administración para que la reactiven antes de recuperar la contraseña.", null);
            return;
        }
        if (result == UsuarioService.PasswordResetRequest.INVALID_EMAIL) {
            clear(session);
            redirectStep(request, response, session, "no-existe",
                    "El correo no pertenece al dominio institucional @utez.edu.mx.", null);
            return;
        }
        if (result == UsuarioService.PasswordResetRequest.EMAIL_NOT_CONFIGURED) {
            session.setAttribute(RESET_EMAIL, email);
            redirectStep(request, response, session, "correo-no-configurado",
                    "El correo de recuperación todavía no está configurado en este servidor. Administración debe configurar el SMTP emisor antes de usar esta función.", null);
            return;
        }
        if (result != UsuarioService.PasswordResetRequest.SENT) {
            session.setAttribute(RESET_EMAIL, email);
            redirectStep(request, response, session, "correo-error",
                    "La cuenta fue localizada, pero no fue posible enviar el código. Revisa la configuración SMTP del servidor e inténtalo nuevamente.", null);
            return;
        }

        session.setAttribute(RESET_EMAIL, email);
        session.setAttribute(RESET_VERIFIED, false);
        session.setAttribute(LAST_SEND, now);
        CsrfTokenUtil.rotate(session);
        redirectStep(request, response, session, "codigo", null,
                resend ? "Se envió un nuevo código." : "Revisa tu correo institucional.");
    }

    private void validateCode(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session) throws IOException {
        String email = (String) session.getAttribute(RESET_EMAIL);
        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String code = request.getParameter("codigo");
        String key = "reset|" + email + "|" + request.getRemoteAddr();
        if (attemptService.isBlocked(key)) {
            redirectStep(request, response, session, "codigo",
                    "Demasiados intentos. Espera 15 minutos.", null);
            return;
        }

        if (!usuarioService.verifyPasswordResetCode(email, code)) {
            attemptService.recordFailure(key);
            redirectStep(request, response, session, "codigo",
                    "El código es incorrecto o expiró.", null);
            return;
        }

        attemptService.recordSuccess(key);
        session.setAttribute(RESET_VERIFIED, true);
        CsrfTokenUtil.rotate(session);
        redirectStep(request, response, session, "cambiar", null, null);
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response,
                                HttpSession session) throws IOException {
        String email = (String) session.getAttribute(RESET_EMAIL);
        boolean verified = Boolean.TRUE.equals(session.getAttribute(RESET_VERIFIED));
        if (email == null || !verified) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String password = request.getParameter("nuevaPassword");
        String confirmation = request.getParameter("confirmarPassword");
        if (password == null || !password.equals(confirmation)) {
            redirectStep(request, response, session, "cambiar",
                    "Las contraseñas no coinciden.", null);
            return;
        }

        try {
            if (!usuarioService.completePasswordReset(email, password)) {
                throw new IllegalArgumentException("No fue posible actualizar la contraseña.");
            }
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?password=updated");
        } catch (IllegalArgumentException exception) {
            redirectStep(request, response, session, "cambiar", exception.getMessage(), null);
        }
    }

    /**
     * Aplica Post/Redirect/Get: ningún POST de recuperación termina en un forward.
     * Así el botón Atrás/Regresar del navegador no intenta reenviar formularios ni produce ERR_CACHE_MISS.
     */
    private void redirectStep(HttpServletRequest request, HttpServletResponse response, HttpSession session,
                              String step, String error, String message) throws IOException {
        setOrRemove(session, FLASH_STEP, step);
        setOrRemove(session, FLASH_ERROR, error);
        setOrRemove(session, FLASH_MESSAGE, message);
        response.sendRedirect(request.getContextPath() + "/reset-password");
    }

    private void setOrRemove(HttpSession session, String key, String value) {
        if (value == null || value.isBlank()) session.removeAttribute(key);
        else session.setAttribute(key, value);
    }

    private String takeString(HttpSession session, String key) {
        Object value = session.getAttribute(key);
        session.removeAttribute(key);
        return value instanceof String ? (String) value : null;
    }

    private void noStore(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0L);
    }

    private String normalizeEmail(String value) {
        if (value == null || value.isBlank() || value.length() > 160) return null;
        return value.trim().toLowerCase(Locale.ROOT);
    }

    private void clear(HttpSession session) {
        session.removeAttribute(RESET_EMAIL);
        session.removeAttribute(RESET_VERIFIED);
        session.removeAttribute(LAST_SEND);
        session.removeAttribute(FLASH_STEP);
        session.removeAttribute(FLASH_ERROR);
        session.removeAttribute(FLASH_MESSAGE);
    }
}
