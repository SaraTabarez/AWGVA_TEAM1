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

/** Elimina físicamente cuentas no administrativas desde el panel ADMIN. */
@WebServlet(urlPatterns = {"/EliminarUsuarioServlet", "/admin/usuarios/eliminar"})
public class EliminarUsuarioServlet extends HttpServlet {

    private UsuarioService usuarioService;

    @Override
    public void init() {
        usuarioService = new UsuarioService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        if (!CsrfTokenUtil.matches(session, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "El formulario expiró. Recarga la página.");
            return;
        }

        Usuario currentUser = session == null ? null : (Usuario) session.getAttribute("usuario");
        UsuarioService.UserDeletionResult result;
        try {
            Long idUsuario = Long.valueOf(request.getParameter("idUsuario"));
            result = usuarioService.deleteUser(idUsuario, currentUser);
        } catch (NumberFormatException exception) {
            result = UsuarioService.UserDeletionResult.NOT_FOUND;
        }

        String code = switch (result) {
            case DELETED -> "eliminado";
            case NOT_FOUND -> "no-encontrado";
            case SELF_PROTECTED -> "cuenta-propia";
            case ADMIN_PROTECTED -> "admin-protegido";
            case HAS_DEPENDENCIES -> "con-registros";
            case UNAUTHORIZED -> "sin-permiso";
            case ERROR -> "error";
        };

        response.sendRedirect(request.getContextPath() + "/admin/usuarios?resultado=" + code);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
