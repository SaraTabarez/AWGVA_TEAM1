package mx.edu.utez.awgva.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "DocumentoServlet", value = "/subir-documento")
public class DocumentoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Aquí podrías procesar los archivos en la base de datos o servidor en el futuro

        // Redirige directamente a la pantalla de éxito (exito.jsp)
        response.sendRedirect("exito.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("subirDocumento.jsp");
    }
}