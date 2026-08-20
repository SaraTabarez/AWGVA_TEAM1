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
import mx.edu.utez.awgva.Utils.RecordTokenUtil;

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
        Long visitaId;
        try {
            visitaId = RecordTokenUtil.requireId(request.getSession(false), docente.getIdUsuario(),
                    "docente-visita", request.getParameter("ref"));
        } catch (IllegalArgumentException exception) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, exception.getMessage());
            return;
        }
        ExpedienteVisita expediente = visitaService.buscarDelDocente(visitaId, docente.getIdUsuario());
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "La solicitud no te pertenece.");
            return;
        }

        List<Path> creados = new ArrayList<>();
        try {
            if ("/docente/subir-documento".equals(request.getServletPath())) {
                String tipo = subirDocumentoBase(request, expediente, visitaId, creados);
                request.setAttribute("referenceToken", RecordTokenUtil.issue(request.getSession(),
                        docente.getIdUsuario(), "docente-visita", visitaId));
                request.getRequestDispatcher("SOLICITUD_VISITA".equals(tipo)
                        ? "/exito.jsp" : "/cartaEnviadaExito.jsp").forward(request, response);
            } else {
                subirReporte(request, expediente, visitaId, creados);
                request.getRequestDispatcher("/reporte-exito.jsp").forward(request, response);
            }
        } catch (IllegalArgumentException exception) {
            limpiar(creados);
            request.getSession().setAttribute("mensajeCarga", exception.getMessage());
            String ruta = "/docente/subir-reporte".equals(request.getServletPath())
                    ? "/reporte-docente"
                    : ("CARTA_RESPONSIVA".equals(request.getParameter("tipo"))
                    ? "/subir-carta-firmada" : "/subir-solicitud-firmada");
            request.getRequestDispatcher(ruta).forward(request, response);
        }
    }

    private String subirDocumentoBase(HttpServletRequest request, ExpedienteVisita expediente,
                                      Long visitaId, List<Path> creados)
            throws IOException, ServletException {
        String tipo = request.getParameter("tipo");
        if (!"SOLICITUD_VISITA".equals(tipo) && !"CARTA_RESPONSIVA".equals(tipo)) {
            throw new IllegalArgumentException("Sólo puedes subir la Solicitud de visita o la Carta responsiva aquí.");
        }
        String estado = estado(expediente);
        if ("SOLICITUD_VISITA".equals(tipo)
                && !Set.of("SOLICITUD_DESCARGADA", "SOLICITUD_RECHAZADA_ESTADIAS",
                "ACEPTADA_DIRECTOR").contains(estado)) {
            throw new IllegalArgumentException(
                    "Primero descarga la solicitud sin firmas; después podrás subirla firmada.");
        }
        if ("CARTA_RESPONSIVA".equals(tipo)
                && !Set.of("CARTA_DESCARGADA", "CARTA_RECHAZADA_ESTADIAS").contains(estado)) {
            throw new IllegalArgumentException(
                    "Primero descarga la carta responsiva; después podrás subirla firmada.");
        }
        Documento documento = guardarParte(request.getPart("archivo"), visitaId, tipo, Set.of(".pdf"), creados);
        if (!documentoService.guardar(documento)) {
            throw new IllegalArgumentException("No fue posible registrar el documento.");
        }
        return tipo;
    }

    private void subirReporte(HttpServletRequest request, ExpedienteVisita expediente,
                              Long visitaId, List<Path> creados)
            throws IOException, ServletException {
        if (!Set.of("CARTA_APROBADA_ESTADIAS", "OFICIO_GENERADO", "REPORTE_RECHAZADO")
                .contains(estado(expediente))) {
            throw new IllegalArgumentException("El reporte no está habilitado en el estado actual.");
        }
        boolean existe = documentoService.buscarPorVisitaYTipo(visitaId, "REPORTE") != null;
        List<Documento> documentos = new ArrayList<>();
        documentos.add(crearReporte(expediente, visitaId, creados));
        agregarEvidencia(request.getPart("evidencia1"), visitaId, "EVIDENCIA_1", documentos, creados, existe);
        agregarEvidencia(request.getPart("evidencia2"), visitaId, "EVIDENCIA_2", documentos, creados, existe);
        agregarEvidencia(request.getPart("evidencia3"), visitaId, "EVIDENCIA_3", documentos, creados, existe);
        if (documentos.size() == 1) {
            throw new IllegalArgumentException("Selecciona al menos una evidencia para actualizar el reporte.");
        }
        if (!documentoService.guardarLote(documentos)) {
            throw new IllegalArgumentException("No fue posible registrar el reporte.");
        }
    }

    private void agregarEvidencia(Part part, Long visitaId, String tipo, List<Documento> documentos,
                                  List<Path> creados, boolean existe) throws IOException {
        if (part == null || part.getSize() <= 0 || part.getSubmittedFileName() == null
                || part.getSubmittedFileName().isBlank()) {
            if (!existe) throw new IllegalArgumentException("Selecciona las tres evidencias obligatorias.");
            return;
        }
        documentos.add(guardarParte(part, visitaId, tipo, IMAGENES, creados));
    }

    private Documento crearReporte(ExpedienteVisita expediente, Long visitaId, List<Path> creados) throws IOException {
        Path carpeta = carpetaCarga().resolve(String.valueOf(visitaId)).normalize();
        Files.createDirectories(carpeta);
        Path destino = carpeta.resolve("reporte-" + UUID.randomUUID() + ".html");
        String contenido = "<!doctype html><html lang=\"es\"><head><meta charset=\"UTF-8\">"
                + "<title>Reporte de visita académica</title><style>body{font-family:Arial,sans-serif;margin:48px;color:#17324d}"
                + "h1{border-bottom:3px solid #f08a24;padding-bottom:12px}.dato{margin:14px 0}strong{display:block}</style>"
                + "</head><body><h1>Reporte de visita académica</h1>"
                + dato("Empresa visitada", expediente.getEmpresa())
                + dato("Docente responsable", expediente.getDocente())
                + dato("División", expediente.getDivision())
                + dato("Carrera y grupo", expediente.getCarrera() + " · " + expediente.getSemestre()
                + " · " + expediente.getGrupo())
                + dato("Periodo de la visita", expediente.getFechaInicio() + " a " + expediente.getFechaFin())
                + dato("Objetivo", expediente.getProposito())
                + dato("Evidencias", "Las evidencias fotográficas se encuentran anexas en el expediente digital.")
                + dato("Fecha de envío", LocalDateTime.now().toLocalDate().toString())
                + "</body></html>";
        Files.writeString(destino, contenido, StandardCharsets.UTF_8);
        creados.add(destino);

        Documento documento = new Documento();
        documento.setIdVisitaFk(visitaId);
        documento.setTipoDocumento("REPORTE");
        documento.setRutaArchivo(destino.toAbsolutePath().toString());
        documento.setNombreArchivo("Reporte final de visita.html");
        documento.setTamanoArchivo(Files.size(destino));
        return documento;
    }

    private String dato(String titulo, Object valor) {
        return "<div class=\"dato\"><strong>" + html(titulo) + "</strong>"
                + html(valor == null ? "" : String.valueOf(valor)) + "</div>";
    }

    private String html(String valor) {
        return valor == null ? "" : valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    private String estado(ExpedienteVisita expediente) {
        return expediente.getEstado() == null ? "" : expediente.getEstado().trim().toUpperCase(Locale.ROOT);
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
            } catch (IOException ignored) { }
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

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }
}