package mx.edu.utez.awgva.Controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.UsuarioService;
import mx.edu.utez.awgva.Utils.RecordTokenUtil;

import java.io.IOException;

@WebServlet(urlPatterns = {"/ActualizarEstadoUsuarioServlet", "/admin/usuarios/estado"})
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
        Usuario current = session == null ? null : (Usuario) session.getAttribute("usuario");
        try {
            int estado = Integer.parseInt(request.getParameter("estado"));
            Long id = RecordTokenUtil.requireId(session, current.getIdUsuario(), "admin-user",
                    request.getParameter("userRef"));
            UsuarioService.StatusUpdateResult result = usuarioService.updateStatus(id, estado, current);
            switch (result) {
                case UPDATED -> write(response, 200, true, estado == 1 ? "Usuario activado." : "Usuario desactivado.");
                case SELF_PROTECTED -> write(response, 400, false, "No puedes desactivar tu propia cuenta.");
                case ADMIN_PROTECTED -> write(response, 400, false, "La cuenta administradora está protegida.");
                case UNAUTHORIZED -> write(response, 403, false, "No tienes permiso para realizar esta acción.");
                case NOT_FOUND -> write(response, 404, false, "El usuario ya no existe.");
                default -> write(response, 400, false, "No fue posible actualizar el estado.");
            }
        } catch (RuntimeException exception) {
            write(response, 400, false, exception.getMessage() == null
                    ? "La solicitud no es válida." : exception.getMessage());
        }
    }

    private void write(HttpServletResponse response, int status, boolean success, String message)
            throws IOException {
        response.setStatus(status);
        String safe = message.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\r", " ").replace("\n", " ");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + safe + "\"}");
    }
}