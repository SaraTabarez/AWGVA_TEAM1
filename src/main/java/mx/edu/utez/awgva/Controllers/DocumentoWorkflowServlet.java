package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import mx.edu.utez.awgva.Model.Documento;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.DocumentoService;
import mx.edu.utez.awgva.Service.VisitaService;
import mx.edu.utez.awgva.Utils.FileValidationUtil;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

/** Carga de documentos del Docente. La visita siempre se valida contra el usuario autenticado. */
@WebServlet(name = "DocumentoWorkflowServlet", urlPatterns = {
        "/docente/subir-documento", "/docente/subir-reporte"
})
@MultipartConfig(maxFileSize = 10L * 1024 * 1024, maxRequestSize = 32L * 1024 * 1024)
public class DocumentoWorkflowServlet extends HttpServlet {
    private static final Set<String> IMAGENES = Set.of(".png", ".jpg", ".jpeg", ".webp");
    private final DocumentoService documentoService = new DocumentoService();
    private final VisitaService visitaService = new VisitaService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Usuario docente = usuario(request);
        Long visitaId = id(request.getParameter("idVisita"));
        ExpedienteVisita expediente = visitaService.buscarDelDocente(visitaId, docente.getIdUsuario());
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "La solicitud no te pertenece.");
            return;
        }

        List<Path> creados = new ArrayList<>();
        try {
            if ("/docente/subir-documento".equals(request.getServletPath())) {
                String tipo = subirDocumentoBase(request, visitaId, creados);
                String resultado = "SOLICITUD_VISITA".equals(tipo)
                        ? "/exito.jsp?id=" + visitaId
                        : "/cartaEnviadaExito.jsp?id=" + visitaId;
                response.sendRedirect(request.getContextPath() + resultado);
            } else {
                subirReporte(request, visitaId, creados);
                response.sendRedirect(request.getContextPath() + "/reporte-exito.jsp?id=" + visitaId);
            }
        } catch (IllegalArgumentException exception) {
            limpiar(creados);
            request.getSession().setAttribute("mensajeCarga", exception.getMessage());
            String ruta;
            if ("/docente/subir-reporte".equals(request.getServletPath())) {
                ruta = "/reporte-docente?id=" + visitaId;
            } else if ("CARTA_RESPONSIVA".equals(request.getParameter("tipo"))) {
                ruta = "/subir-carta-firmada?id=" + visitaId;
            } else {
                ruta = "/subir-solicitud-firmada?id=" + visitaId;
            }
            response.sendRedirect(request.getContextPath() + ruta);
        }
    }

    private String subirDocumentoBase(HttpServletRequest request, Long visitaId, List<Path> creados)
            throws IOException, ServletException {
        String tipo = request.getParameter("tipo");
        if (!"SOLICITUD_VISITA".equals(tipo) && !"CARTA_RESPONSIVA".equals(tipo)) {
            throw new IllegalArgumentException("Sólo puedes subir la Solicitud de visita o la Carta responsiva aquí.");
        }
        Documento documento = guardarParte(request.getPart("archivo"), visitaId, tipo, Set.of(".pdf"), creados);
        if (!documentoService.guardar(documento)) {
            throw new IllegalArgumentException("Oracle no pudo registrar el documento.");
        }
        return tipo;
    }

    /**
     * El reporte del docente está formado únicamente por tres evidencias fotográficas.
     * Se registra un marcador interno de tipo REPORTE para conservar el flujo de revisión de Estadías,
     * sin solicitar ni mostrar un PDF adicional al docente.
     */
    private void subirReporte(HttpServletRequest request, Long visitaId, List<Path> creados)
            throws IOException, ServletException {
        List<Documento> documentos = new ArrayList<>();
        documentos.add(crearMarcadorReporte(visitaId, creados));
        documentos.add(guardarParte(request.getPart("evidencia1"), visitaId, "EVIDENCIA_1", IMAGENES, creados));
        documentos.add(guardarParte(request.getPart("evidencia2"), visitaId, "EVIDENCIA_2", IMAGENES, creados));
        documentos.add(guardarParte(request.getPart("evidencia3"), visitaId, "EVIDENCIA_3", IMAGENES, creados));
        if (!documentoService.guardarLote(documentos)) {
            throw new IllegalArgumentException("Oracle no pudo registrar el reporte.");
        }
    }

    private Documento crearMarcadorReporte(Long visitaId, List<Path> creados) throws IOException {
        Path carpeta = carpetaCarga().resolve(String.valueOf(visitaId)).normalize();
        Files.createDirectories(carpeta);
        Path destino = carpeta.resolve("reporte-" + UUID.randomUUID() + ".txt");
        String contenido = "Reporte de visita académica\n"
                + "Solicitud: " + visitaId + "\n"
                + "Enviado: " + LocalDateTime.now() + "\n"
                + "Contenido: tres evidencias fotográficas.\n";
        Files.writeString(destino, contenido, StandardCharsets.UTF_8);
        creados.add(destino);

        Documento documento = new Documento();
        documento.setIdVisitaFk(visitaId);
        documento.setTipoDocumento("REPORTE");
        documento.setRutaArchivo(destino.toAbsolutePath().toString());
        documento.setNombreArchivo("Reporte de visita (3 evidencias)");
        documento.setTamanoArchivo(Files.size(destino));
        return documento;
    }

    private Documento guardarParte(Part part, Long visitaId, String tipo,
                                   Set<String> extensiones, List<Path> creados) throws IOException {
        if (part == null || part.getSize() <= 0 || part.getSubmittedFileName() == null) {
            throw new IllegalArgumentException("Selecciona todos los archivos obligatorios.");
        }
        if (part.getSize() > 10L * 1024 * 1024) {
            throw new IllegalArgumentException("Cada archivo debe pesar como máximo 10 MB.");
        }
        String original = nombreSeguro(part.getSubmittedFileName());
        String extension = extension(original);
        if (!extensiones.contains(extension)) {
            throw new IllegalArgumentException("Formato no permitido para " + original + ".");
        }

        Path carpeta = carpetaCarga().resolve(String.valueOf(visitaId)).normalize();
        Files.createDirectories(carpeta);
        Path temporal = Files.createTempFile(carpeta, "carga-", ".tmp");
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, temporal, StandardCopyOption.REPLACE_EXISTING);
        }
        if (!FileValidationUtil.hasExpectedSignature(temporal, extension)) {
            Files.deleteIfExists(temporal);
            throw new IllegalArgumentException("El contenido de " + original + " no coincide con su extensión.");
        }
        Path destino = carpeta.resolve(tipo.toLowerCase(Locale.ROOT) + "-" + UUID.randomUUID() + extension);
        Files.move(temporal, destino, StandardCopyOption.REPLACE_EXISTING);
        creados.add(destino);

        Documento documento = new Documento();
        documento.setIdVisitaFk(visitaId);
        documento.setTipoDocumento(tipo);
        documento.setRutaArchivo(destino.toAbsolutePath().toString());
        documento.setNombreArchivo(original);
        documento.setTamanoArchivo(part.getSize());
        return documento;
    }

    public static Path carpetaCarga() {
        String configurada = System.getenv("AWGVA_UPLOAD_DIR");
        if (configurada != null && !configurada.isBlank()) {
            return Path.of(configurada).toAbsolutePath().normalize();
        }
        String catalina = System.getProperty("catalina.base");
        if (catalina != null && !catalina.isBlank()) {
            return Path.of(catalina, "awgva-uploads").toAbsolutePath().normalize();
        }
        return Path.of(System.getProperty("java.io.tmpdir"), "awgva-uploads").toAbsolutePath().normalize();
    }

    private void limpiar(List<Path> paths) {
        for (Path path : paths) {
            try {
                Files.deleteIfExists(path);
            } catch (IOException ignored) {
                // La limpieza no debe ocultar el mensaje de validación original.
            }
        }
    }

    private String nombreSeguro(String submitted) {
        String normalizado = submitted.replace('\\', '/');
        int slash = normalizado.lastIndexOf('/');
        String nombre = (slash >= 0 ? normalizado.substring(slash + 1) : normalizado)
                .replaceAll("[\\r\\n\\\"]", "_");
        if (nombre.length() > 180) nombre = nombre.substring(nombre.length() - 180);
        return nombre;
    }

    private String extension(String nombre) {
        int punto = nombre.lastIndexOf('.');
        return punto < 0 ? "" : nombre.substring(punto).toLowerCase(Locale.ROOT);
    }

    private Long id(String valor) {
        try {
            long id = Long.parseLong(valor);
            if (id < 1) throw new NumberFormatException();
            return id;
        } catch (NumberFormatException | NullPointerException exception) {
            throw new IllegalArgumentException("Solicitud no válida.");
        }
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }
}
