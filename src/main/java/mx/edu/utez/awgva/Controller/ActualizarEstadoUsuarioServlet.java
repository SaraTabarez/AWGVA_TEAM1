package mx.edu.utez.awgva.Controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.UsuarioService;
import mx.edu.utez.awgva.Utils.CsrfTokenUtil;

import java.io.IOException;

@WebServlet("/ActualizarEstadoUsuarioServlet")
public class ActualizarEstadoUsuarioServlet extends HttpServlet {

    private UsuarioService usuarioService;

    @Override
    public void init() {
        usuarioService = new UsuarioService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        if (!CsrfTokenUtil.matches(session, request.getParameter("csrfToken"))) {
            writeResult(response, HttpServletResponse.SC_FORBIDDEN, false, "Formulario expirado.");
            return;
        }

        try {
            Long idUsuario = Long.valueOf(request.getParameter("idUsuario"));
            int estado = Integer.parseInt(request.getParameter("estado"));
            Usuario currentUser = (Usuario) session.getAttribute("usuario");

            if (currentUser.getIdUsuario().equals(idUsuario) && estado == 0) {
                writeResult(response, HttpServletResponse.SC_BAD_REQUEST, false,
                        "No puedes desactivar tu propia cuenta.");
                return;
            }

            boolean updated = usuarioService.updateStatus(idUsuario, estado);
            writeResult(
                    response,
                    updated ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST,
                    updated,
                    updated ? "Estado actualizado." : "No fue posible actualizar el estado."
            );
        } catch (NumberFormatException exception) {
            writeResult(response, HttpServletResponse.SC_BAD_REQUEST, false, "Datos no válidos.");
        }
    }

    private void writeResult(HttpServletResponse response, int status, boolean success, String message)
            throws IOException {
        response.setStatus(status);
        String safeMessage = message.replace("\\", "\\\\").replace("\"", "\\\"");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + safeMessage + "\"}");
    }
}
