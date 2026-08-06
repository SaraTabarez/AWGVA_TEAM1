package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mx.edu.utez.awgva.Model.BeanSolicitud;
import mx.edu.utez.awgva.Service.ServiceSolicitud;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "servlet-gestion-solicitudes", value = "/servlet-gestion-solicitudes")
public class ServletGestionSolicitudes extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Instanciamos usando el nombre exacto de tu clase ServiceSolicitud (en singular)
        ServiceSolicitud servicio = new ServiceSolicitud();
        List<BeanSolicitud> listaSolicitudes = servicio.obtenerSolicitudes();

        // Enviamos la lista completa a la vista
        req.setAttribute("solicitudes", listaSolicitudes);

        // La vista existente está en la raíz de webapp.
        req.getRequestDispatcher("/gestion-solicitudes.jsp").forward(req, resp);
    }
}
