package mx.edu.utez.awgva.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.UsuarioService;
import mx.edu.utez.awgva.Utils.CsrfTokenUtil;

import java.io.IOException;

@WebServlet(urlPatterns = {"/RegistrarUsuarioServlet", "/admin/usuarios/alta"})
public class RegistrarUsuarioServlet extends HttpServlet {

    private UsuarioService usuarioService;

    @Override
    public void init() {
        usuarioService = new UsuarioService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadCatalogs(request);
        request.getRequestDispatcher("/WEB-INF/views/admin/altas-usuario.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (!CsrfTokenUtil.matches(session, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "El formulario expiró. Recarga la página.");
            return;
        }

        try {
            Usuario usuario = buildUsuario(request);
            if (!usuarioService.register(usuario, request.getParameter("password"))) {
                throw new IllegalArgumentException("No fue posible guardar el usuario.");
            }
            response.sendRedirect(request.getContextPath() + "/admin/usuarios?creado=1");
        } catch (IllegalArgumentException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", exception.getMessage());
            copySafeValues(request);
            loadCatalogs(request);
            request.getRequestDispatcher("/WEB-INF/views/admin/altas-usuario.jsp").forward(request, response);
        }
    }

    private Usuario buildUsuario(HttpServletRequest request) {
        Usuario usuario = new Usuario();
        usuario.setNombres(request.getParameter("nombres"));
        usuario.setApellidoPaterno(request.getParameter("apellidoPaterno"));
        usuario.setApellidoMaterno(request.getParameter("apellidoMaterno"));
        usuario.setCorreo(request.getParameter("correo"));
        usuario.setIdRolFk(parseRequiredLong(request.getParameter("idRol"), "Selecciona un rol válido."));
        usuario.setIdDivisionFk(parseOptionalLong(request.getParameter("idDivision")));
        return usuario;
    }

    private Long parseRequiredLong(String value, String message) {
        try {
            return Long.valueOf(value);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(message);
        }
    }

    private Long parseOptionalLong(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Long.valueOf(value);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Selecciona una división válida.");
        }
    }

    private void loadCatalogs(HttpServletRequest request) {
        request.setAttribute("roles", usuarioService.findRoles());
        request.setAttribute("divisiones", usuarioService.findDivisiones());
    }

    private void copySafeValues(HttpServletRequest request) {
        request.setAttribute("nombresValue", request.getParameter("nombres"));
        request.setAttribute("apellidoPaternoValue", request.getParameter("apellidoPaterno"));
        request.setAttribute("apellidoMaternoValue", request.getParameter("apellidoMaterno"));
        request.setAttribute("correoValue", request.getParameter("correo"));
        request.setAttribute("idRolValue", request.getParameter("idRol"));
        request.setAttribute("idDivisionValue", request.getParameter("idDivision"));
    }
}