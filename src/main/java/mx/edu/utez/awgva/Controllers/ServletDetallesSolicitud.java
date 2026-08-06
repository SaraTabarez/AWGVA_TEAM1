package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mx.edu.utez.awgva.Model.BeanDetalles;
import mx.edu.utez.awgva.Service.ServiceDetalles;

import java.io.IOException;

@WebServlet(name = "servlet-detalles-solicitud", value = "/servlet-detalles-solicitud")
public class ServletDetallesSolicitud extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        ServiceDetalles miServicio = new ServiceDetalles();
        BeanDetalles solicitud = miServicio.obtenerSolicitud();

        req.setAttribute("solicitud", solicitud);
        // Se quita "/WEB-INF/" porque el archivo JSP está en la raíz de webapp
        req.getRequestDispatcher("/solicitud-visita-industrial.jsp").forward(req, resp);
    }
}