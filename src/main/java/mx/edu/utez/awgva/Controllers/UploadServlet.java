package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import mx.edu.utez.awgva.Dao.DocumentoDao;
import mx.edu.utez.awgva.Model.Documento;
import mx.edu.utez.awgva.Utils.FileValidationUtil;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@WebServlet(name = "UploadDocumentServlet", value = "/upload-servlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 15 * 1024 * 1024)
public class UploadServlet extends HttpServlet {

    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(".pdf", ".png", ".jpg", ".jpeg", ".webp");
    private DocumentoDao documentoDao;
    private Path uploadRoot;

    @Override
    public void init() throws ServletException {
        documentoDao = new DocumentoDao();
        String configuredDirectory = System.getenv("AWGVA_UPLOAD_DIR");
        Path base = configuredDirectory == null || configuredDirectory.isBlank()
                ? ((java.io.File) getServletContext().getAttribute("jakarta.servlet.context.tempdir")).toPath()
                : Path.of(configuredDirectory);
        uploadRoot = base.resolve("documentos").toAbsolutePath().normalize();
        try {
            Files.createDirectories(uploadRoot);
        } catch (IOException exception) {
            throw new ServletException("No fue posible preparar el almacenamiento de documentos.", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Long visitaId = Long.valueOf(request.getParameter("visitaId"));
            String tipoDocumento = request.getParameter("tipoDocumento");
            Part filePart = request.getPart("archivo");

            if (tipoDocumento == null || tipoDocumento.isBlank() || tipoDocumento.length() > 50
                    || filePart == null || filePart.getSize() == 0) {
                throw new IllegalArgumentException("Faltan datos del documento.");
            }

            String submittedName = filePart.getSubmittedFileName();
            if (submittedName == null || submittedName.isBlank()) {
                throw new IllegalArgumentException("Nombre de archivo no válido.");
            }
            String originalName = submittedName.replace('\\', '/');
            originalName = originalName.substring(originalName.lastIndexOf('/') + 1);
            String extension = extensionOf(originalName);
            if (!ALLOWED_EXTENSIONS.contains(extension)) {
                throw new IllegalArgumentException("Tipo de archivo no permitido.");
            }

            Path target = uploadRoot.resolve(UUID.randomUUID() + extension).normalize();
            if (!target.startsWith(uploadRoot)) {
                throw new IllegalArgumentException("Nombre de archivo no válido.");
            }
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, target, StandardCopyOption.REPLACE_EXISTING);
            }
            if (!FileValidationUtil.hasExpectedSignature(target, extension)) {
                Files.deleteIfExists(target);
                throw new IllegalArgumentException("El contenido no coincide con la extensión del archivo.");
            }

            Documento documento = new Documento();
            documento.setIdVisitaFk(visitaId);
            documento.setTipoDocumento(tipoDocumento);
            documento.setRutaArchivo(target.toString());
            documento.setNombreArchivo(originalName);
            documento.setTamanoArchivo(filePart.getSize());

            if (!documentoDao.guardarDocumento(documento)) {
                Files.deleteIfExists(target);
                throw new IllegalStateException("No fue posible registrar el documento.");
            }

            request.setAttribute("mensaje", "Documento subido exitosamente.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", exception.getMessage());
        }
        request.getRequestDispatcher("/subir-docs.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/subir-docs.jsp");
    }

    private String extensionOf(String fileName) {
        String lowerName = fileName.toLowerCase(Locale.ROOT);
        int dot = lowerName.lastIndexOf('.');
        return dot < 0 ? "" : lowerName.substring(dot);
    }
}