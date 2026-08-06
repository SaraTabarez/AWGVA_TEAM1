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

import java.io.IOException;

/** Gestión de los tres documentos de Estadías y su histórico global. */
@WebServlet(name = "EstadiasServlet", urlPatterns = {
        "/estadias/documentos", "/estadias/documento", "/estadias/reporte",
        "/estadias/historico", "/estadias/revisar",
        "/estadias/documento-aceptado", "/estadias/documento-rechazado",
        "/estadias/reporte-aceptado", "/estadias/reporte-rechazado"
})
public class EstadiasServlet extends HttpServlet {
    private final DocumentoService documentoService = new DocumentoService();
    private final VisitaService visitaService = new VisitaService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        switch (request.getServletPath()) {
            case "/estadias/documentos" -> bandeja(request, response);
            case "/estadias/documento" -> revisarDocumento(request, response);
            case "/estadias/reporte" -> revisarReporte(request, response);
            case "/estadias/historico" -> historico(request, response);
            case "/estadias/documento-aceptado" -> resultado(request, response, "documento-aceptado.jsp");
            case "/estadias/documento-rechazado" -> resultado(request, response, "documento-rechazado.jsp");
            case "/estadias/reporte-aceptado" -> resultado(request, response, "reporte-aceptado.jsp");
            case "/estadias/reporte-rechazado" -> resultado(request, response, "reporte-rechazado.jsp");
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        if (!"/estadias/revisar".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        request.setCharacterEncoding("UTF-8");
        Long idDocumento = id(request, "idDocumento");
        Documento documento = documentoService.buscarPorId(idDocumento);
        if (documento == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String decision = request.getParameter("decision");
        try {
            Usuario revisor = usuario(request);
            if (!documentoService.revisar(idDocumento, decision,
                    request.getParameter("observaciones"), revisor.getIdUsuario())) {
                throw new IllegalArgumentException("No fue posible actualizar el documento.");
            }
            boolean reporte = "REPORTE".equalsIgnoreCase(documento.getTipoDocumento());
            boolean aceptar = "ACEPTAR".equalsIgnoreCase(decision);
            String ruta = reporte
                    ? (aceptar ? "/estadias/reporte-aceptado" : "/estadias/reporte-rechazado")
                    : (aceptar ? "/estadias/documento-aceptado" : "/estadias/documento-rechazado");
            response.sendRedirect(request.getContextPath() + ruta + "?idDocumento=" + idDocumento);
        } catch (IllegalArgumentException exception) {
            request.setAttribute("error", exception.getMessage());
            request.setAttribute("documento", documento);
            request.setAttribute("expediente", visitaService.buscarParaEstadias(documento.getIdVisitaFk()));
            if ("REPORTE".equalsIgnoreCase(documento.getTipoDocumento())) {
                request.setAttribute("evidencias", documentoService.listarEvidenciasReporte(documento.getIdVisitaFk()));
                request.getRequestDispatcher("/WEB-INF/views/estadias/revisar-reporte.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/views/estadias/revisar-documento.jsp").forward(request, response);
            }
        }
    }

    private void bandeja(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("documentos", documentoService.listarParaEstadias(
                    request.getParameter("q"), request.getParameter("tipo")));
        } catch (IllegalArgumentException exception) {
            request.setAttribute("error", exception.getMessage());
            request.setAttribute("documentos", documentoService.listarParaEstadias(null, null));
        }
        request.getRequestDispatcher("/WEB-INF/views/estadias/documentos.jsp").forward(request, response);
    }

    private void revisarDocumento(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Documento documento = documento(request, response);
        if (documento == null) return;
        if ("REPORTE".equalsIgnoreCase(documento.getTipoDocumento())) {
            response.sendRedirect(request.getContextPath() + "/estadias/reporte?idDocumento=" + documento.getIdDocumento());
            return;
        }
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
        request.setAttribute("documento", documento);
        request.setAttribute("expediente", visitaService.buscarParaEstadias(documento.getIdVisitaFk()));
        request.setAttribute("evidencias", documentoService.listarEvidenciasReporte(documento.getIdVisitaFk()));
        request.getRequestDispatcher("/WEB-INF/views/estadias/revisar-reporte.jsp").forward(request, response);
    }

    private void historico(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("solicitudes", visitaService.listarHistoricoEstadias(request.getParameter("q")));
        request.getRequestDispatcher("/WEB-INF/views/estadias/historico.jsp").forward(request, response);
    }

    private void resultado(HttpServletRequest request, HttpServletResponse response, String vista)
            throws ServletException, IOException {
        Documento documento = documento(request, response);
        if (documento == null) return;
        request.setAttribute("documento", documento);
        request.getRequestDispatcher("/WEB-INF/views/estadias/" + vista).forward(request, response);
    }

    private Documento documento(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Documento documento = documentoService.buscarPorId(id(request, "idDocumento"));
        if (documento == null) response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return documento;
    }

    private Long id(HttpServletRequest request, String nombre) {
        try {
            long value = Long.parseLong(request.getParameter(nombre));
            if (value < 1) throw new NumberFormatException();
            return value;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Identificador no válido.");
        }
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }
}
