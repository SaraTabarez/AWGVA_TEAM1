package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.Documento;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.DocumentoService;
import mx.edu.utez.awgva.Service.VisitaService;
import mx.edu.utez.awgva.Service.UsuarioService;
import mx.edu.utez.awgva.Utils.EmailSender;
import mx.edu.utez.awgva.Utils.RecordTokenUtil;
import mx.edu.utez.awgva.Utils.TokenViewUtil;

import java.io.IOException;
import java.util.List;
import java.util.LinkedHashSet;
import java.util.Set;

@WebServlet(name = "EstadiasServlet", urlPatterns = {
        "/estadias/documentos", "/estadias/documento", "/estadias/reporte",
        "/estadias/historico", "/estadias/expediente", "/estadias/revisar",
        "/estadias/documento-aceptado", "/estadias/documento-rechazado",
        "/estadias/reporte-aceptado", "/estadias/reporte-rechazado"
})
public class EstadiasServlet extends HttpServlet {
    private final DocumentoService documentoService = new DocumentoService();
    private final VisitaService visitaService = new VisitaService();
    private final UsuarioService usuarioService = new UsuarioService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        switch (request.getServletPath()) {
            case "/estadias/documentos" -> bandeja(request, response);
            case "/estadias/documento" -> revisarDocumento(request, response);
            case "/estadias/reporte" -> revisarReporte(request, response);
            case "/estadias/historico" -> historico(request, response);
            case "/estadias/expediente" -> expedienteHistorico(request, response);
            default -> response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        switch (request.getServletPath()) {
            case "/estadias/documentos" -> bandeja(request, response);
            case "/estadias/documento" -> revisarDocumento(request, response);
            case "/estadias/reporte" -> revisarReporte(request, response);
            case "/estadias/historico" -> historico(request, response);
            case "/estadias/expediente" -> expedienteHistorico(request, response);
            case "/estadias/revisar" -> revisar(request, response);
            default -> response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    private void revisar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario revisor = usuario(request);
        Long idDocumento = documentoId(request, revisor);
        Documento documento = documentoService.buscarPorId(idDocumento);
        if (documento == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String decision = request.getParameter("decision");
        try {
            if (!documentoService.revisar(idDocumento, decision,
                    request.getParameter("observaciones"), revisor.getIdUsuario())) {
                throw new IllegalArgumentException("No fue posible actualizar el documento.");
            }
            Documento actualizado = documentoService.buscarPorId(idDocumento);
            notificar(actualizado, decision, request.getParameter("observaciones"), revisor);
            boolean reporte = "REPORTE".equalsIgnoreCase(actualizado.getTipoDocumento());
            boolean aceptar = "ACEPTAR".equalsIgnoreCase(decision);
            request.setAttribute("documento", actualizado);
            request.getRequestDispatcher("/WEB-INF/views/estadias/" + (reporte
                            ? (aceptar ? "reporte-aceptado.jsp" : "reporte-rechazado.jsp")
                            : (aceptar ? "documento-aceptado.jsp" : "documento-rechazado.jsp")))
                    .forward(request, response);
        } catch (IllegalArgumentException exception) {
            request.setAttribute("error", exception.getMessage());
            request.setAttribute("documento", documento);
            request.setAttribute("expediente", visitaService.buscarParaEstadias(documento.getIdVisitaFk()));
            TokenViewUtil.decorateDocument(request, revisor, documento);
            if ("REPORTE".equalsIgnoreCase(documento.getTipoDocumento())) {
                List<Documento> evidencias = documentoService.listarEvidenciasReporte(documento.getIdVisitaFk());
                TokenViewUtil.decorateDocuments(request, revisor, evidencias);
                request.setAttribute("evidencias", evidencias);
                request.getRequestDispatcher("/WEB-INF/views/estadias/revisar-reporte.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/views/estadias/revisar-documento.jsp").forward(request, response);
            }
        }
    }

    private void bandeja(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = usuario(request);
        try {
            List<Documento> documentos = documentoService.listarParaEstadias(
                    request.getParameter("q"), request.getParameter("tipo"));
            TokenViewUtil.decorateDocuments(request, usuario, documentos);
            request.setAttribute("documentos", documentos);
        } catch (IllegalArgumentException exception) {
            request.setAttribute("error", exception.getMessage());
            List<Documento> documentos = documentoService.listarParaEstadias(null, null);
            TokenViewUtil.decorateDocuments(request, usuario, documentos);
            request.setAttribute("documentos", documentos);
        }
        request.getRequestDispatcher("/WEB-INF/views/estadias/documentos.jsp").forward(request, response);
    }

    private void revisarDocumento(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Documento documento = documento(request, response);
        if (documento == null) return;
        if ("REPORTE".equalsIgnoreCase(documento.getTipoDocumento())) {
            revisarReporteCargado(request, response, documento);
            return;
        }
        TokenViewUtil.decorateDocument(request, usuario(request), documento);
        request.setAttribute("documento", documento);
        request.setAttribute("expediente", visitaService.buscarParaEstadias(documento.getIdVisitaFk()));
        request.getRequestDispatcher("/WEB-INF/views/estadias/revisar-documento.jsp").forward(request, response);
    }

    private void revisarReporte(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Documento documento = documento(request, response);
        if (documento == null) return;
        if (!"REPORTE".equalsIgnoreCase(documento.getTipoDocumento())) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "El documento no es un reporte.");
            return;
        }
        revisarReporteCargado(request, response, documento);
    }

    private void revisarReporteCargado(HttpServletRequest request, HttpServletResponse response,
                                       Documento documento) throws ServletException, IOException {
        Usuario usuario = usuario(request);
        TokenViewUtil.decorateDocument(request, usuario, documento);
        request.setAttribute("documento", documento);
        request.setAttribute("expediente", visitaService.buscarParaEstadias(documento.getIdVisitaFk()));
        List<Documento> evidencias = documentoService.listarEvidenciasReporte(documento.getIdVisitaFk());
        TokenViewUtil.decorateDocuments(request, usuario, evidencias);
        request.setAttribute("evidencias", evidencias);
        request.getRequestDispatcher("/WEB-INF/views/estadias/revisar-reporte.jsp").forward(request, response);
    }

    private void historico(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = usuario(request);
        List<ExpedienteVisita> solicitudes = visitaService.listarHistoricoEstadias(request.getParameter("q"));
        for (ExpedienteVisita solicitud : solicitudes) {
            solicitud.setReferenceToken(RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(),
                    "estadias-visita", solicitud.getIdVisita()));
        }
        request.setAttribute("solicitudes", solicitudes);
        request.getRequestDispatcher("/WEB-INF/views/estadias/historico.jsp").forward(request, response);
    }

    private void expedienteHistorico(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = usuario(request);
        Long id = RecordTokenUtil.requireId(request.getSession(false), usuario.getIdUsuario(),
                "estadias-visita", request.getParameter("ref"));
        ExpedienteVisita expediente = visitaService.buscarParaEstadias(id);
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        List<Documento> documentos = documentoService.listarPorVisita(id);
        TokenViewUtil.decorateDocuments(request, usuario, documentos);
        expediente.setDocumentos(documentos);

        List<Documento> evidencias = documentoService.listarEvidenciasReporte(id);
        TokenViewUtil.decorateDocuments(request, usuario, evidencias);
        request.setAttribute("evidencias", evidencias);
        request.setAttribute("expediente", expediente);
        request.getRequestDispatcher("/WEB-INF/views/estadias/expediente.jsp").forward(request, response);
    }

    private Documento documento(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Usuario usuario = usuario(request);
        Documento documento = documentoService.buscarPorId(documentoId(request, usuario));
        if (documento == null) response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return documento;
    }

    private Long documentoId(HttpServletRequest request, Usuario usuario) {
        return RecordTokenUtil.requireId(request.getSession(false), usuario.getIdUsuario(),
                "documento-revision", request.getParameter("ref"));
    }

    private void notificar(Documento documento, String decision, String observaciones, Usuario revisor) {
        if (documento == null || revisor == null) return;
        ExpedienteVisita expediente = visitaService.buscarParaEstadias(documento.getIdVisitaFk());
        if (expediente == null) return;

        boolean aceptado = "ACEPTAR".equalsIgnoreCase(decision);
        String actor = revisor.getTipoRol().map(Enum::name).orElse("").equals("ADMIN")
                ? "Administración" : "Estadías";
        String motivo = observaciones == null || observaciones.isBlank()
                ? "Sin observaciones adicionales." : observaciones.trim();
        String mensaje = aceptado
                ? actor + " aceptó " + documento.getTipoLegible() + " de la solicitud #"
                + documento.getIdVisitaFk() + ". El proceso puede continuar con la siguiente etapa."
                : actor + " rechazó " + documento.getTipoLegible() + " de la solicitud #"
                + documento.getIdVisitaFk() + ". Motivo del rechazo: " + motivo;

        Set<String> destinatarios = new LinkedHashSet<>();
        if (expediente.getCorreoDocente() != null && !expediente.getCorreoDocente().isBlank()) {
            destinatarios.add(expediente.getCorreoDocente().trim());
        }
        destinatarios.addAll(usuarioService.findActiveEmailsByRoleAndDivision(
                "DIRECTOR", expediente.getIdDivision()));

        String cuerpo = "<html><body style=\"font-family:Arial,sans-serif;color:#1e3656\">"
                + "<h2 style=\"color:#1f3b5f\">Actualización de solicitud AWGVA</h2>"
                + "<p>" + html(mensaje) + "</p>"
                + "<p><strong>Empresa:</strong> " + html(expediente.getEmpresa()) + "</p>"
                + "<p><strong>Docente responsable:</strong> " + html(expediente.getDocente()) + "</p>"
                + "</body></html>";

        for (String correo : destinatarios) {
            try {
                EmailSender.sendMail(correo, "Actualización de documentos AWGVA", cuerpo);
            } catch (RuntimeException exception) {
                System.err.println("No fue posible notificar a " + correo + ": " + exception.getMessage());
            }
        }
    }

    private String html(String value) {
        return value == null ? "" : value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }
}
