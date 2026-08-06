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

@WebServlet(name = "PasswordResetServlet", value = "/reset-password")
public class PasswordResetServlet extends HttpServlet {

    private UsuarioService usuarioService;
    private LoginAttemptService resetAttemptService;

    @Override
    public void init() {
        usuarioService = new UsuarioService();
        resetAttemptService = new LoginAttemptService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        session.removeAttribute("resetCorreo");
        CsrfTokenUtil.rotate(session);
        request.setAttribute("step", "solicitar");
        request.getRequestDispatcher("/recuperar-contra.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (!CsrfTokenUtil.matches(session, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "El formulario expiró.");
            return;
        }

        String action = request.getParameter("action");
        if ("solicitar".equals(action)) {
            requestCode(request, response);
        } else if ("restablecer".equals(action)) {
            resetPassword(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/reset-password");
        }
    }

    private void requestCode(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String correo = request.getParameter("correo");
        if (correo == null || correo.isBlank() || correo.length() > 160) {
            show(request, response, "solicitar", "Ingresa un correo válido.", null);
            return;
        }

        // La respuesta es deliberadamente igual exista o no la cuenta.
        usuarioService.generateAndSendResetCode(correo.trim());
        HttpSession session = request.getSession();
        session.setAttribute("resetCorreo", correo.trim());
        CsrfTokenUtil.rotate(session);
        show(
                request,
                response,
                "restablecer",
                null,
                "Si el correo está registrado, recibirás un código de 8 dígitos."
        );
    }

    private void resetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String attemptKey = "reset|" + request.getRemoteAddr();
        if (resetAttemptService.isBlocked(attemptKey)) {
            response.setStatus(429);
            show(request, response, "restablecer", "Demasiados intentos. Espera 15 minutos.", null);
            return;
        }

        String code = request.getParameter("codigo");
        String newPassword = request.getParameter("nuevaPassword");
        String confirmation = request.getParameter("confirmarPassword");
        HttpSession session = request.getSession(false);
        String resetCorreo = session == null ? null : (String) session.getAttribute("resetCorreo");
        if (code == null || !code.matches("\\d{8}") || newPassword == null
                || !newPassword.equals(confirmation)) {
            resetAttemptService.recordFailure(attemptKey);
            show(request, response, "restablecer", "Código o confirmación no válidos.", null);
            return;
        }

        try {
            if (!usuarioService.resetPassword(code, resetCorreo, newPassword)) {
                resetAttemptService.recordFailure(attemptKey);
                show(request, response, "restablecer", "El código es inválido o expiró.", null);
                return;
            }
        } catch (IllegalArgumentException exception) {
            show(request, response, "restablecer", exception.getMessage(), null);
            return;
        }

        resetAttemptService.recordSuccess(attemptKey);
        request.getSession().invalidate();
        response.sendRedirect(request.getContextPath() + "/login.jsp?password=updated");
    }

    private void show(
            HttpServletRequest request,
            HttpServletResponse response,
            String step,
            String error,
            String message
    ) throws ServletException, IOException {
        request.setAttribute("step", step);
        request.setAttribute("error", error);
        request.setAttribute("mensaje", message);
        request.getRequestDispatcher("/recuperar-contra.jsp").forward(request, response);
    }
}