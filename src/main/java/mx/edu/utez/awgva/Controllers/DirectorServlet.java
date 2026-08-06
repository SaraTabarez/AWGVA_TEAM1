package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.CatalogoCarreras;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.DocumentoService;
import mx.edu.utez.awgva.Service.VisitaService;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/** Bandeja del Director; el ID de división siempre procede de la sesión. */
@WebServlet(name = "DirectorServlet", urlPatterns = {
        "/director/solicitudes", "/director/detalle", "/director/historico"
})
public class DirectorServlet extends HttpServlet {
    private final VisitaService visitaService = new VisitaService();
    private final DocumentoService documentoService = new DocumentoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario director = usuario(request);
        if (director.getIdDivisionFk() == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "El Director no tiene división asignada.");
            return;
        }
        switch (request.getServletPath()) {
            case "/director/solicitudes" -> listar(request, response, director, false);
            case "/director/historico" -> listar(request, response, director, true);
            case "/director/detalle" -> detalle(request, response, director);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response, Usuario director, boolean historico)
            throws ServletException, IOException {
        String carrera = request.getParameter("carrera");
        if (carrera != null && !carrera.isBlank()
                && !CatalogoCarreras.pertenece(director.getNombreDivision(), carrera)) {
            carrera = null;
        }
        LocalDate fecha = null;
        String fechaTexto = request.getParameter("fecha");
        if (fechaTexto != null && !fechaTexto.isBlank()) {
            try { fecha = LocalDate.parse(fechaTexto); } catch (DateTimeParseException ignored) { }
        }
        request.setAttribute("solicitudes", visitaService.listarParaDirector(
                director.getIdDivisionFk(), request.getParameter("q"), request.getParameter("lugar"),
                fecha, request.getParameter("estado"), carrera, historico));
        request.setAttribute("carreras", CatalogoCarreras.deDivision(director.getNombreDivision()));
        request.setAttribute("carreraSeleccionada", carrera);
        request.getRequestDispatcher(historico
                ? "/WEB-INF/views/director/historico.jsp"
                : "/WEB-INF/views/director/solicitudes.jsp").forward(request, response);
    }

    private void detalle(HttpServletRequest request, HttpServletResponse response, Usuario director)
            throws ServletException, IOException {
        Long id = id(request);
        ExpedienteVisita expediente = visitaService.buscarParaDirector(id, director.getIdDivisionFk());
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "La solicitud no existe o pertenece a otra división.");
            return;
        }
        expediente.setDocumentos(documentoService.listarPorVisita(id));
        request.setAttribute("expediente", expediente);
        request.setAttribute("soloLectura", "historico".equals(request.getParameter("origen")));
        request.getRequestDispatcher("/WEB-INF/views/director/detalle.jsp").forward(request, response);
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }

    private Long id(HttpServletRequest request) {
        try {
            long value = Long.parseLong(request.getParameter("id"));
            if (value < 1) throw new NumberFormatException();
            return value;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Identificador no válido.");
        }
    }
}
