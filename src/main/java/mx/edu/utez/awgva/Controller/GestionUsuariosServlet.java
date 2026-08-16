package mx.edu.utez.awgva.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mx.edu.utez.awgva.Service.UsuarioService;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Utils.RecordTokenUtil;

import java.util.List;

import java.io.IOException;

@WebServlet(urlPatterns = {"/GestionUsuariosServlet", "/admin/usuarios"})
public class GestionUsuariosServlet extends HttpServlet {

    private UsuarioService usuarioService;

    @Override
    public void init() {
        usuarioService = new UsuarioService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        show(request, response);
    }

    private void show(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario current = (Usuario) request.getSession(false).getAttribute("usuario");
        List<Usuario> users = usuarioService.findAll();
        for (Usuario user : users) {
            user.setReferenceToken(RecordTokenUtil.issue(request.getSession(), current.getIdUsuario(),
                    "admin-user", user.getIdUsuario()));
        }
        request.setAttribute("listaUsuarios", users);
        request.setAttribute("roles", usuarioService.findRoles());
        request.setAttribute("divisiones", usuarioService.findDivisiones());
        Object message = request.getSession().getAttribute("adminUsersMessage");
        if (message != null) {
            request.setAttribute("success", message);
            request.getSession().removeAttribute("adminUsersMessage");
        }
        request.getRequestDispatcher("/WEB-INF/views/admin/bajas-usuario.jsp").forward(request, response);
    }
}

