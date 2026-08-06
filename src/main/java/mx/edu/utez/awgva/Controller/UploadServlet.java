package mx.edu.utez.awgva.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import mx.edu.utez.awgva.Model.SolicitudVisita;
import mx.edu.utez.awgva.Utils.FileValidationUtil;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@WebServlet(name = "UploadEvidenceServlet", urlPatterns = {"/UploadServlet"})
@MultipartConfig(
        fileSizeThreshold = 2 * 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 50 * 1024 * 1024
)
public class UploadServlet extends HttpServlet {

    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(".pdf", ".png", ".jpg", ".jpeg", ".webp");
    private Path uploadRoot;

    @Override
    public void init() throws ServletException {
        String configuredDirectory = System.getenv("AWGVA_UPLOAD_DIR");
        Path base = configuredDirectory == null || configuredDirectory.isBlank()
                ? ((java.io.File) getServletContext().getAttribute("jakarta.servlet.context.tempdir")).toPath()
                : Path.of(configuredDirectory);
        uploadRoot = base.resolve("evidencias-reportes").toAbsolutePath().normalize();
        try {
            Files.createDirectories(uploadRoot);
        } catch (IOException exception) {
            throw new ServletException("No fue posible preparar el almacenamiento de evidencias.", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        for (Part part : request.getParts()) {
            String submittedName = part.getSubmittedFileName();
            if (submittedName == null || submittedName.isBlank()) {
                continue;
            }

            String extension = extensionOf(submittedName);
            if (!ALLOWED_EXTENSIONS.contains(extension) || part.getSize() == 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo de archivo no permitido.");
                return;
            }

            Path target = uploadRoot.resolve(UUID.randomUUID() + extension).normalize();
            if (!target.startsWith(uploadRoot)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            try (InputStream input = part.getInputStream()) {
                Files.copy(input, target, StandardCopyOption.REPLACE_EXISTING);
            }
            if (!FileValidationUtil.hasExpectedSignature(target, extension)) {
                Files.deleteIfExists(target);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "El contenido del archivo no coincide con su extensión.");
                return;
            }
        }

        updateSessionStatus(request);
        response.sendRedirect(request.getContextPath() + "/reporte-exito.jsp");
    }

    private void updateSessionStatus(HttpServletRequest request) {
        String indexParam = request.getParameter("solicitudIndex");
        if (indexParam == null || indexParam.isBlank()) {
            return;
        }

        try {
            int index = Integer.parseInt(indexParam);
            HttpSession session = request.getSession(false);
            @SuppressWarnings("unchecked")
            List<SolicitudVisita> solicitudes = session == null
                    ? null
                    : (List<SolicitudVisita>) session.getAttribute("listaSolicitudes");
            if (solicitudes != null && index >= 0 && index < solicitudes.size()) {
                solicitudes.get(index).setEstado("REPORTE_ENVIADO");
            }
        } catch (NumberFormatException ignored) {
            // El índice no es confiable; se ignora sin afectar el archivo validado.
        }
    }

    private String extensionOf(String fileName) {
        String normalizedName = fileName.replace('\\', '/');
        normalizedName = normalizedName.substring(normalizedName.lastIndexOf('/') + 1)
                .toLowerCase(Locale.ROOT);
        int dot = normalizedName.lastIndexOf('.');
        return dot < 0 ? "" : normalizedName.substring(dot);
    }
}