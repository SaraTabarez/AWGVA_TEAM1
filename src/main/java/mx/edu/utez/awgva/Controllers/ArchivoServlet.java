package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.Documento;
import mx.edu.utez.awgva.Model.TipoRol;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.DocumentoService;
import mx.edu.utez.awgva.Utils.RecordTokenUtil;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;

@WebServlet(name = "ArchivoServlet", value = "/archivo")
public class ArchivoServlet extends HttpServlet {
    private final DocumentoService documentoService = new DocumentoService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        Usuario usuario = usuario(request);
        Long id;
        try {
            id = RecordTokenUtil.requireId(request.getSession(false), usuario.getIdUsuario(),
                    "documento-archivo", request.getParameter("fileRef"));
        } catch (IllegalArgumentException exception) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, exception.getMessage());
            return;
        }

        Documento documento = documentoService.buscarPorId(id);
        if (documento == null || !autorizado(usuario, documento)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        Path archivo = Path.of(documento.getRutaArchivo()).toAbsolutePath().normalize();
        Path raiz = DocumentoWorkflowServlet.carpetaCarga();
        if (!archivo.startsWith(raiz) || !Files.isRegularFile(archivo)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = Files.probeContentType(archivo);
        response.setContentType(mime == null ? "application/octet-stream" : mime);
        response.setContentLengthLong(Files.size(archivo));
        String modo = "1".equals(request.getParameter("descargar")) ? "attachment" : "inline";
        String nombre = documento.getNombreArchivo().replaceAll("[\\r\\n\\\"]", "_");
        response.setHeader("Content-Disposition", modo + "; filename=\"" + nombre + "\"");
        try (OutputStream output = response.getOutputStream()) {
            Files.copy(archivo, output);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private boolean autorizado(Usuario usuario, Documento documento) {
        TipoRol rol = usuario.getTipoRol().orElse(null);
        if (rol == TipoRol.ADMIN || rol == TipoRol.ESTADIAS) return true;
        if (rol == TipoRol.DOCENTE) return usuario.getIdUsuario().equals(documento.getIdPropietario());
        return rol == TipoRol.DIRECTOR && usuario.getIdDivisionFk() != null
                && usuario.getIdDivisionFk().equals(documento.getIdDivision());
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }
}