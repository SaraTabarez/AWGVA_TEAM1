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
import mx.edu.utez.awgva.Utils.EmailSender;
import mx.edu.utez.awgva.Utils.RecordTokenUtil;
import mx.edu.utez.awgva.Utils.TokenViewUtil;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/** Bandeja del Director; el ID de división siempre procede de la sesión. */
@WebServlet(name = "DirectorServlet", urlPatterns = {
        "/director/solicitudes", "/director/detalle", "/director/historico", "/director/revisar"
})
public class DirectorServlet extends HttpServlet {
    private final VisitaService visitaService = new VisitaService();
    private final DocumentoService documentoService = new DocumentoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario director = usuario(request);
        if (director.getIdDivisionFk() == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        switch (request.getServletPath()) {
            case "/director/solicitudes" -> listar(request, response, director, false);
            case "/director/historico" -> listar(request, response, director, true);
            case "/director/detalle" -> detalle(request, response, director);
            case "/director/revisar" -> revisar(request, response, director);
            default -> response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
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
        java.util.List<ExpedienteVisita> solicitudes = visitaService.listarParaDirector(
                director.getIdDivisionFk(), request.getParameter("q"), request.getParameter("lugar"),
                fecha, request.getParameter("estado"), carrera, historico);
        for (ExpedienteVisita item : solicitudes) {
            item.setReferenceToken(RecordTokenUtil.issue(request.getSession(), director.getIdUsuario(),
                    "director-visita", item.getIdVisita()));
        }
        request.setAttribute("solicitudes", solicitudes);
        request.setAttribute("carreras", CatalogoCarreras.deDivision(director.getNombreDivision()));
        request.setAttribute("carreraSeleccionada", carrera);
        request.getRequestDispatcher(historico
                ? "/WEB-INF/views/director/historico.jsp"
                : "/WEB-INF/views/director/solicitudes.jsp").forward(request, response);
    }

    private void detalle(HttpServletRequest request, HttpServletResponse response, Usuario director)
            throws ServletException, IOException {
        Long id = RecordTokenUtil.requireId(request.getSession(false), director.getIdUsuario(),
                "director-visita", request.getParameter("ref"));
        ExpedienteVisita expediente = visitaService.buscarParaDirector(id, director.getIdDivisionFk());
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "La solicitud no existe o pertenece a otra división.");
            return;
        }
        expediente.setDocumentos(documentoService.listarPorVisita(id));
        TokenViewUtil.decorateDocuments(request, director, expediente.getDocumentos());
        expediente.setReferenceToken(RecordTokenUtil.issue(request.getSession(), director.getIdUsuario(),
                "director-visita", id));
        request.setAttribute("expediente", expediente);
        request.setAttribute("soloLectura", "historico".equals(request.getParameter("origen")));
        request.getRequestDispatcher("/WEB-INF/views/director/detalle.jsp").forward(request, response);
    }

    private void revisar(HttpServletRequest request, HttpServletResponse response, Usuario director)
            throws ServletException, IOException {
        Long id = RecordTokenUtil.requireId(request.getSession(false), director.getIdUsuario(),
                "director-visita", request.getParameter("ref"));
        String decision = request.getParameter("decision");
        String motivo = request.getParameter("motivo");
        try {
            if (!visitaService.revisarComoDirector(id, director.getIdDivisionFk(), decision, motivo)) {
                throw new IllegalArgumentException("La solicitud ya fue revisada o no pertenece a tu división.");
            }
            ExpedienteVisita updated = visitaService.buscarParaDirector(id, director.getIdDivisionFk());
            if (updated != null) {
                try {
                    String text = "ACEPTAR".equalsIgnoreCase(decision)
                            ? "Tu solicitud fue aceptada por Dirección y ya puedes continuar con la solicitud firmada."
                            : "Tu solicitud fue rechazada por Dirección. Motivo: " + motivo;
                    EmailSender.sendMail(updated.getCorreoDocente(), "Actualización de solicitud AWGVA",
                            "<html><body><p>" + html(text) + "</p></body></html>");
                } catch (RuntimeException ignored) { }
            }
            request.setAttribute("success", "Solicitud actualizada correctamente.");
        } catch (IllegalArgumentException exception) {
            request.setAttribute("error", exception.getMessage());
        }
        detalleConId(request, response, director, id);
    }

    private void detalleConId(HttpServletRequest request, HttpServletResponse response,
                              Usuario director, Long id) throws ServletException, IOException {
        ExpedienteVisita expediente = visitaService.buscarParaDirector(id, director.getIdDivisionFk());
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        expediente.setDocumentos(documentoService.listarPorVisita(id));
        TokenViewUtil.decorateDocuments(request, director, expediente.getDocumentos());
        expediente.setReferenceToken(RecordTokenUtil.issue(request.getSession(), director.getIdUsuario(),
                "director-visita", id));
        request.setAttribute("expediente", expediente);
        request.setAttribute("soloLectura", false);
        request.getRequestDispatcher("/WEB-INF/views/director/detalle.jsp").forward(request, response);
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }

    private String html(String value) {
        return value == null ? "" : value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

}
