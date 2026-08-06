package mx.edu.utez.awgva.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mx.edu.utez.awgva.Service.UsuarioService;

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
            throws ServletException, IOException {
        request.setAttribute("listaUsuarios", usuarioService.findAll());
        request.getRequestDispatcher("/WEB-INF/views/admin/bajas-usuario.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
