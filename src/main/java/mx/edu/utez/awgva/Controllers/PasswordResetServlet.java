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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
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
            throws ServletException, IOException {
        String email = resend ? (String) session.getAttribute(RESET_EMAIL)
                : normalizeEmail(request.getParameter("correo"));
        if (email == null || !INSTITUTIONAL_EMAIL.matcher(email).matches()) {
            show(request, response, "no-existe",
                    "Debes escribir tu correo institucional @utez.edu.mx en la pantalla de inicio.", null);
            return;
        }

        Long lastSend = (Long) session.getAttribute(LAST_SEND);
        long now = System.currentTimeMillis();
        if (resend && lastSend != null && now - lastSend < 60_000L) {
            show(request, response, "codigo", null,
                    "Espera un minuto antes de solicitar otro código.");
            return;
        }

        UsuarioService.PasswordResetRequest result = usuarioService.requestPasswordReset(email);
        if (result == UsuarioService.PasswordResetRequest.ACCOUNT_NOT_FOUND) {
            clear(session);
            show(request, response, "no-existe",
                    "El correo que estás usando NO EXISTE en el sistema. Verifica que esté escrito correctamente o comunícate con Administración.", null);
            return;
        }
        if (result == UsuarioService.PasswordResetRequest.ACCOUNT_INACTIVE) {
            clear(session);
            show(request, response, "no-existe",
                    "La cuenta existe, pero está INACTIVA. Comunícate con Administración para que la reactiven antes de recuperar la contraseña.", null);
            return;
        }
        if (result == UsuarioService.PasswordResetRequest.INVALID_EMAIL) {
            clear(session);
            show(request, response, "no-existe",
                    "El correo no pertenece al dominio institucional @utez.edu.mx.", null);
            return;
        }
        if (result != UsuarioService.PasswordResetRequest.SENT) {
            show(request, response, "no-existe",
                    "No fue posible enviar el correo. Comunícate con Administración.", null);
            return;
        }

        session.setAttribute(RESET_EMAIL, email);
        session.setAttribute(RESET_VERIFIED, false);
        session.setAttribute(LAST_SEND, now);
        CsrfTokenUtil.rotate(session);
        show(request, response, "codigo", null,
                resend ? "Se envió un nuevo código." : "Revisa tu correo institucional.");
    }

    private void validateCode(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session) throws ServletException, IOException {
        String email = (String) session.getAttribute(RESET_EMAIL);
        String code = request.getParameter("codigo");
        String key = "reset|" + email + "|" + request.getRemoteAddr();
        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        if (attemptService.isBlocked(key)) {
            response.setStatus(429);
            show(request, response, "codigo", "Demasiados intentos. Espera 15 minutos.", null);
            return;
        }
        if (!usuarioService.verifyPasswordResetCode(email, code)) {
            attemptService.recordFailure(key);
            show(request, response, "codigo", "El código es incorrecto o expiró.", null);
            return;
        }
        attemptService.recordSuccess(key);
        session.setAttribute(RESET_VERIFIED, true);
        CsrfTokenUtil.rotate(session);
        show(request, response, "cambiar", null, null);
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response,
                                HttpSession session) throws ServletException, IOException {
        String email = (String) session.getAttribute(RESET_EMAIL);
        boolean verified = Boolean.TRUE.equals(session.getAttribute(RESET_VERIFIED));
        if (email == null || !verified) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String password = request.getParameter("nuevaPassword");
        String confirmation = request.getParameter("confirmarPassword");
        if (password == null || !password.equals(confirmation)) {
            show(request, response, "cambiar", "Las contraseñas no coinciden.", null);
            return;
        }
        try {
            if (!usuarioService.completePasswordReset(email, password)) {
                throw new IllegalArgumentException("No fue posible actualizar la contraseña.");
            }
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?password=updated");
        } catch (IllegalArgumentException exception) {
            show(request, response, "cambiar", exception.getMessage(), null);
        }
    }

    private void show(HttpServletRequest request, HttpServletResponse response,
                      String step, String error, String message)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        request.setAttribute("step", step);
        request.setAttribute("error", error);
        request.setAttribute("mensaje", message);
        request.setAttribute("correoRecuperacion",
                session == null ? null : session.getAttribute(RESET_EMAIL));
        request.getRequestDispatcher("/recuperar-contra.jsp").forward(request, response);
    }

    private String normalizeEmail(String value) {
        if (value == null || value.isBlank() || value.length() > 160) return null;
        return value.trim().toLowerCase(Locale.ROOT);
    }

    private void clear(HttpSession session) {
        session.removeAttribute(RESET_EMAIL);
        session.removeAttribute(RESET_VERIFIED);
        session.removeAttribute(LAST_SEND);
    }
}
