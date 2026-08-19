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
import mx.edu.utez.awgva.Utils.RecordTokenUtil;
import mx.edu.utez.awgva.Utils.TokenViewUtil;

import java.io.IOException;
import java.util.List;

/**
 * Bandejas propias de Administración. La cuenta ADMIN puede consultar todas las
 * visitas, revisar los documentos cargados y, al mismo tiempo, crear sus propias
 * solicitudes usando el flujo normal de Docente.
 */
@WebServlet(name = "AdminFlujoServlet", urlPatterns = {
        "/admin/solicitudes", "/admin/solicitud", "/admin/reportes", "/admin/historico"
})
public class AdminFlujoServlet extends HttpServlet {

    private final VisitaService visitaService = new VisitaService();
    private final DocumentoService documentoService = new DocumentoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        switch (request.getServletPath()) {
            case "/admin/solicitudes" -> solicitudes(request, response);
            case "/admin/solicitud" -> detalle(request, response);
            case "/admin/reportes" -> reportes(request, response);
            case "/admin/historico" -> historico(request, response);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void solicitudes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario admin = usuario(request);
        List<ExpedienteVisita> solicitudes = visitaService.listarSolicitudesAdmin();
        decorarVisitas(request, admin, solicitudes, false);
        request.setAttribute("solicitudes", solicitudes);
        request.getRequestDispatcher("/WEB-INF/views/admin/solicitudes.jsp").forward(request, response);
    }

    private void detalle(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario admin = usuario(request);
        Long idVisita;
        try {
            idVisita = RecordTokenUtil.requireId(request.getSession(false), admin.getIdUsuario(),
                    "admin-visita", request.getParameter("ref"));
        } catch (IllegalArgumentException exception) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, exception.getMessage());
            return;
        }

        ExpedienteVisita expediente = visitaService.buscarParaEstadias(idVisita);
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        expediente.setReferenceToken(RecordTokenUtil.issue(request.getSession(), admin.getIdUsuario(),
                "admin-visita", idVisita));
        List<Documento> documentos = documentoService.listarPorVisita(idVisita);
        TokenViewUtil.decorateDocuments(request, admin, documentos);
        expediente.setDocumentos(documentos);

        if (admin.getIdUsuario().equals(expediente.getIdUsuario())) {
            request.setAttribute("ownerRef", RecordTokenUtil.issue(request.getSession(), admin.getIdUsuario(),
                    "docente-visita", idVisita));
        }

        request.setAttribute("expediente", expediente);
        request.getRequestDispatcher("/WEB-INF/views/admin/solicitud-detalle.jsp").forward(request, response);
    }

    private void reportes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario admin = usuario(request);
        List<Documento> reportes = documentoService.listarParaEstadias(request.getParameter("q"), "REPORTE")
                .stream()
                .filter(documento -> documento.getEstado() == null
                        || !"ACEPTADO".equalsIgnoreCase(documento.getEstado().trim()))
                .toList();
        TokenViewUtil.decorateDocuments(request, admin, reportes);
        request.setAttribute("reportes", reportes);
        request.getRequestDispatcher("/WEB-INF/views/admin/reportes.jsp").forward(request, response);
    }

    private void historico(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario admin = usuario(request);
        List<ExpedienteVisita> solicitudes = visitaService.listarHistoricoAdmin();
        decorarVisitas(request, admin, solicitudes, false);
        request.setAttribute("solicitudes", solicitudes);
        request.getRequestDispatcher("/WEB-INF/views/admin/historico.jsp").forward(request, response);
    }

    private void decorarVisitas(HttpServletRequest request, Usuario admin,
                                List<ExpedienteVisita> solicitudes, boolean incluirDocumentos) {
        for (ExpedienteVisita solicitud : solicitudes) {
            solicitud.setReferenceToken(RecordTokenUtil.issue(request.getSession(), admin.getIdUsuario(),
                    "admin-visita", solicitud.getIdVisita()));
            if (incluirDocumentos) {
                List<Documento> documentos = documentoService.listarPorVisita(solicitud.getIdVisita());
                TokenViewUtil.decorateDocuments(request, admin, documentos);
                solicitud.setDocumentos(documentos);
            }
        }
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }
}
