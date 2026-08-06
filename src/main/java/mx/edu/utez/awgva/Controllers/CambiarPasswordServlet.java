package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.UsuarioService;

import java.io.IOException;

@WebServlet(name = "CambiarPasswordServlet", value = "/cambiar-contrasena")
public class CambiarPasswordServlet extends HttpServlet {
    private final UsuarioService usuarioService = new UsuarioService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/cuenta/cambiar-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String nueva = request.getParameter("nueva");
        String confirmar = request.getParameter("confirmar");
        if (nueva == null || !nueva.equals(confirmar)) {
            request.setAttribute("error", "La nueva contraseña y su confirmación no coinciden.");
            doGet(request, response);
            return;
        }
        HttpSession session = request.getSession(false);
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        try {
            if (!usuarioService.changeOwnPassword(usuario, request.getParameter("actual"), nueva)) {
                throw new IllegalArgumentException("La contraseña actual no es correcta.");
            }
            request.setAttribute("exito", "Contraseña actualizada correctamente.");
        } catch (IllegalArgumentException exception) {
            request.setAttribute("error", exception.getMessage());
        }
        doGet(request, response);
    }
}
