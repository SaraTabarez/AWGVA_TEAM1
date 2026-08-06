package mx.edu.utez.awgva.Controller;

import mx.edu.utez.awgva.Model.SolicitudVisita;
import mx.edu.utez.awgva.Service.SolicitudService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/solicitud")
public class SolicitudServlet extends HttpServlet {

    private SolicitudService service = new SolicitudService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        SolicitudVisita sol = new SolicitudVisita();
        sol.setSolicitanteNombre(req.getParameter("solicitanteNombre"));
        sol.setSolicitanteCargo(req.getParameter("solicitanteCargo"));
        sol.setSolicitanteTelefono(req.getParameter("solicitanteTelefono"));
        sol.setDocentesAcompanantes(req.getParameter("docentesAcompanantes"));
        sol.setEmpresaDireccion(req.getParameter("empresaDireccion"));
        sol.setEmpresaNombre(req.getParameter("empresaNombre"));
        sol.setEmpresaTelefono(req.getParameter("empresaTelefono"));
        sol.setEmpresaEmail(req.getParameter("empresaEmail"));
        sol.setFechaInicio(req.getParameter("fechaInicio"));
        sol.setFechaTermino(req.getParameter("fechaTermino"));
        sol.setHoraInicio(req.getParameter("horaInicio"));
        sol.setObjetivo(req.getParameter("objetivo"));
        sol.setDacea(req.getParameter("dacea"));
        sol.setDatefi(req.getParameter("datefi"));
        sol.setDatid(req.getParameter("datid"));
        sol.setDami(req.getParameter("dami"));
        sol.setTotalEstudiantes(req.getParameter("totalEstudiantes"));
        sol.setAsignaturas(req.getParameter("asignaturas"));

        service.procesarSolicitud(sol);

        HttpSession session = req.getSession();
        List<SolicitudVisita> listaSolicitudes = (List<SolicitudVisita>) session.getAttribute("listaSolicitudes");

        if (listaSolicitudes == null) {
            listaSolicitudes = new ArrayList<>();
        }
        listaSolicitudes.add(sol);
        session.setAttribute("listaSolicitudes", listaSolicitudes);

        int nuevoIndex = listaSolicitudes.size() - 1;
        // REDIRIGE A LA HOJA DE VISTA PREVIA
        resp.sendRedirect("solicitud-previa.jsp?index=" + nuevoIndex);
    }
}