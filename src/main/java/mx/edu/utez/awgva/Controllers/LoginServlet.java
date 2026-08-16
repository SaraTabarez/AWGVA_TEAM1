package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.LoginAttemptService;
import mx.edu.utez.awgva.Service.UsuarioService;
import mx.edu.utez.awgva.Utils.CsrfTokenUtil;
import mx.edu.utez.awgva.Utils.PostNavigationResponse;

import java.io.IOException;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

@WebServlet(name = "LoginServlet", value = "/login")
public class LoginServlet extends HttpServlet {
    private static final Pattern INSTITUTIONAL_EMAIL = Pattern.compile(
            "^[A-Z0-9._%+-]+@utez\\.edu\\.mx$", Pattern.CASE_INSENSITIVE);

    private UsuarioService usuarioService;
    private LoginAttemptService loginAttemptService;

    @Override
    public void init() {
        usuarioService = new UsuarioService();
        loginAttemptService = new LoginAttemptService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        String correo = normalizeEmail(request.getParameter("correo"));
        String password = request.getParameter("password");
        if (correo == null || password == null || password.isBlank()) {
            showError(request, response, "Correo o contraseña incorrectos.", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String attemptKey = correo + "|" + request.getRemoteAddr();
        if (loginAttemptService.isBlocked(attemptKey)) {
            showError(
                    request,
                    response,
                    "Demasiados intentos. Espera 15 minutos antes de volver a intentarlo.",
                    429
            );
            return;
        }

        Usuario usuario = usuarioService.authenticate(correo, password);
        if (usuario == null) {
            loginAttemptService.recordFailure(attemptKey);
            showError(request, response, "Correo o contraseña incorrectos.", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        loginAttemptService.recordSuccess(attemptKey);

        HttpSession previousSession = request.getSession(false);
        if (previousSession != null) {
            previousSession.invalidate();
        }

        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(30 * 60);
        session.setAttribute("usuario", usuario);
        session.setAttribute("nombreUsuario", usuario.getNombreCompleto());
        session.setAttribute("rol", usuario.getTipoRol().orElseThrow().name());
        String csrfToken = CsrfTokenUtil.rotate(session);
        PostNavigationResponse.send(response, request.getContextPath() + "/inicio", csrfToken, Map.of());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    private String normalizeEmail(String correo) {
        if (correo == null || correo.isBlank() || correo.length() > 160) {
            return null;
        }
        String normalized = correo.trim().toLowerCase(Locale.ROOT);
        return INSTITUTIONAL_EMAIL.matcher(normalized).matches() ? normalized : null;
    }

    private void showError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message,
            int status
    ) throws ServletException, IOException {
        response.setStatus(status);
        request.setAttribute("error", message);
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
}
