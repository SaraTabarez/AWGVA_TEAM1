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
import mx.edu.utez.awgva.Utils.RecordTokenUtil;
import mx.edu.utez.awgva.Utils.TokenViewUtil;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * Consulta de Dirección.
 *
 * El Director únicamente visualiza las solicitudes de su propia división.
 * No existe ninguna acción para aprobar, rechazar ni modificar el flujo.
 */
@WebServlet(name = "DirectorServlet", urlPatterns = {
        "/director/solicitudes", "/director/detalle", "/director/historico"
})
public class DirectorServlet extends HttpServlet {
    private final VisitaService visitaService = new VisitaService();
    private final DocumentoService documentoService = new DocumentoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        atenderConsulta(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        atenderConsulta(request, response);
    }

    private void atenderConsulta(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Usuario director = usuario(request);
        if (director == null || director.getIdDivisionFk() == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        switch (request.getServletPath()) {
            case "/director/solicitudes" -> listar(request, response, director, false);
            case "/director/historico" -> listar(request, response, director, true);
            case "/director/detalle" -> detalle(request, response, director);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response,
                        Usuario director, boolean historico)
            throws ServletException, IOException {
        String carrera = request.getParameter("carrera");
        if (carrera != null && !carrera.isBlank()
                && !CatalogoCarreras.pertenece(director.getNombreDivision(), carrera)) {
            carrera = null;
        }

        LocalDate fecha = null;
        String fechaTexto = request.getParameter("fecha");
        if (fechaTexto != null && !fechaTexto.isBlank()) {
            try {
                fecha = LocalDate.parse(fechaTexto);
            } catch (DateTimeParseException ignored) {
                // Si la fecha del filtro no es válida, se ignora el filtro.
            }
        }

        List<ExpedienteVisita> solicitudes = visitaService.listarParaDirector(
                director.getIdDivisionFk(),
                request.getParameter("q"),
                request.getParameter("lugar"),
                fecha,
                request.getParameter("estado"),
                carrera,
                historico
        );

        for (ExpedienteVisita item : solicitudes) {
            item.setReferenceToken(RecordTokenUtil.issue(
                    request.getSession(),
                    director.getIdUsuario(),
                    "director-visita",
                    item.getIdVisita()
            ));
        }

        request.setAttribute("solicitudes", solicitudes);
        request.setAttribute("carreras", CatalogoCarreras.deDivision(director.getNombreDivision()));
        request.setAttribute("carreraSeleccionada", carrera);
        request.getRequestDispatcher(
                historico
                        ? "/WEB-INF/views/director/historico.jsp"
                        : "/WEB-INF/views/director/solicitudes.jsp"
        ).forward(request, response);
    }

    private void detalle(HttpServletRequest request, HttpServletResponse response, Usuario director)
            throws ServletException, IOException {
        Long id = RecordTokenUtil.requireId(
                request.getSession(false),
                director.getIdUsuario(),
                "director-visita",
                request.getParameter("ref")
        );

        ExpedienteVisita expediente = visitaService.buscarParaDirector(
                id, director.getIdDivisionFk()
        );
        if (expediente == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "La solicitud no existe o pertenece a otra división."
            );
            return;
        }

        expediente.setDocumentos(documentoService.listarPorVisita(id));
        TokenViewUtil.decorateDocuments(request, director, expediente.getDocumentos());
        expediente.setReferenceToken(RecordTokenUtil.issue(
                request.getSession(),
                director.getIdUsuario(),
                "director-visita",
                id
        ));

        request.setAttribute("expediente", expediente);
        request.setAttribute("volverHistorico", "historico".equalsIgnoreCase(request.getParameter("origen")));
        request.getRequestDispatcher("/WEB-INF/views/director/detalle.jsp")
                .forward(request, response);
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (Usuario) session.getAttribute("usuario");
    }
}
