package mx.edu.utez.awgva.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mx.edu.utez.awgva.Model.FirmantesOficiales;
import mx.edu.utez.awgva.Service.FirmanteService;

import java.io.IOException;

@WebServlet("/admin/firmantes")
public class FirmantesServlet extends HttpServlet {
    private final FirmanteService service = new FirmanteService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            FirmantesOficiales values = new FirmantesOficiales();
            values.setDirectorNombre(request.getParameter("directorNombre"));
            values.setDirectorCargo(request.getParameter("directorCargo"));
            values.setDocenteNombre(request.getParameter("docenteNombre"));
            values.setDocenteCargo(request.getParameter("docenteCargo"));
            values.setEstadiasNombre(request.getParameter("estadiasNombre"));
            values.setEstadiasCargo(request.getParameter("estadiasCargo"));
            service.save(values);
            request.setAttribute("success", "Firmantes actualizados correctamente.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", exception.getMessage());
        }
        show(request, response);
    }

    private void show(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("firmantes", service.load());
        request.getRequestDispatcher("/WEB-INF/views/admin/firmantes.jsp").forward(request, response);
    }
}