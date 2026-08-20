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
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Service.DocumentoService;
import mx.edu.utez.awgva.Service.VisitaService;
import mx.edu.utez.awgva.Utils.RecordTokenUtil;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.InvalidPathException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

@WebServlet(name = "ArchivoServlet", value = "/archivo")
public class ArchivoServlet extends HttpServlet {
    private final DocumentoService documentoService = new DocumentoService();
    private final VisitaService visitaService = new VisitaService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        Usuario usuario = usuario(request);
        if (usuario == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

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

        // El reporte se sirve siempre como una vista integral reconstruida desde la BD.
        // Así el histórico no depende de un HTML temporal antiguo y puede incluir las
        // evidencias fotográficas que pertenecen al mismo expediente.
        if ("REPORTE".equalsIgnoreCase(documento.getTipoDocumento())) {
            servirReporteReconstruido(response, documento, "1".equals(request.getParameter("descargar")));
            return;
        }

        Path archivo = resolverArchivoSeguro(documento.getRutaArchivo());
        if (archivo == null || !Files.isRegularFile(archivo)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "El archivo físico ya no se encuentra disponible en el servidor.");
            return;
        }

        String mime = Files.probeContentType(archivo);
        response.setContentType(mime == null ? "application/octet-stream" : mime);
        response.setContentLengthLong(Files.size(archivo));
        String modo = "1".equals(request.getParameter("descargar")) ? "attachment" : "inline";
        String nombre = documento.getNombreArchivo() == null ? archivo.getFileName().toString()
                : documento.getNombreArchivo().replaceAll("[\\r\\n\\\"]", "_");
        response.setHeader("Content-Disposition", modo + "; filename=\"" + nombre + "\"");
        try (OutputStream output = response.getOutputStream()) {
            Files.copy(archivo, output);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    /**
     * Acepta la carpeta actual de cargas y también ubicaciones históricas seguras que
     * fueron utilizadas por versiones anteriores del proyecto (temporal de Java/Tomcat
     * y el webapp desplegado). Nunca sirve una ruta arbitraria fuera de esas raíces.
     */
    private Path resolverArchivoSeguro(String rutaGuardada) {
        if (rutaGuardada == null || rutaGuardada.isBlank()) return null;

        final Path candidata;
        try {
            Path original = Path.of(rutaGuardada);
            candidata = original.isAbsolute()
                    ? original.toAbsolutePath().normalize()
                    : DocumentoWorkflowServlet.carpetaCarga().resolve(original).toAbsolutePath().normalize();
        } catch (InvalidPathException exception) {
            return null;
        }

        for (Path raiz : raicesPermitidas()) {
            if (candidata.startsWith(raiz) && Files.isRegularFile(candidata)) {
                return candidata;
            }
        }

        // Compatibilidad: algunas versiones antiguas guardaron sólo el nombre o una
        // ruta relativa. Se intenta encontrarlo únicamente dentro de raíces permitidas.
        Path nombre;
        try {
            nombre = Path.of(rutaGuardada).getFileName();
        } catch (InvalidPathException exception) {
            return null;
        }
        if (nombre == null) return null;

        for (Path raiz : raicesPermitidas()) {
            Path alternativa = raiz.resolve(nombre).normalize();
            if (alternativa.startsWith(raiz) && Files.isRegularFile(alternativa)) {
                return alternativa;
            }
        }
        return null;
    }

    private List<Path> raicesPermitidas() {
        List<Path> raices = new ArrayList<>();
        agregarRaiz(raices, DocumentoWorkflowServlet.carpetaCarga());
        agregarRaiz(raices, Path.of(System.getProperty("java.io.tmpdir")));

        String catalina = System.getProperty("catalina.base");
        if (catalina != null && !catalina.isBlank()) {
            agregarRaiz(raices, Path.of(catalina, "temp"));
            agregarRaiz(raices, Path.of(catalina, "awgva-uploads"));
        }

        String realPath = getServletContext().getRealPath("/");
        if (realPath != null && !realPath.isBlank()) {
            Path webapp = Path.of(realPath);
            agregarRaiz(raices, webapp);
            agregarRaiz(raices, webapp.resolve("evidencias_reportes"));
        }
        return raices;
    }

    private void agregarRaiz(List<Path> raices, Path raiz) {
        if (raiz != null) {
            Path normalizada = raiz.toAbsolutePath().normalize();
            if (!raices.contains(normalizada)) raices.add(normalizada);
        }
    }


    private void servirReporteReconstruido(HttpServletResponse response, Documento documento,
                                           boolean descargar) throws IOException {
        ExpedienteVisita expediente = visitaService.buscarParaEstadias(documento.getIdVisitaFk());
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        List<Documento> evidencias = documentoService.listarEvidenciasReporte(documento.getIdVisitaFk());
        StringBuilder galeria = new StringBuilder();
        int numero = 1;
        for (Documento evidencia : evidencias) {
            Path imagen = resolverArchivoSeguro(evidencia.getRutaArchivo());
            if (imagen == null || !Files.isRegularFile(imagen)) continue;

            String mime = Files.probeContentType(imagen);
            if (mime == null || !mime.toLowerCase().startsWith("image/")) continue;

            byte[] bytesImagen = Files.readAllBytes(imagen);
            String dataUrl = "data:" + mime + ";base64," + Base64.getEncoder().encodeToString(bytesImagen);
            galeria.append("<figure><img alt=\"Evidencia ").append(numero).append("\" src=\"")
                    .append(dataUrl).append("\"><figcaption>")
                    .append(html(evidencia.getNombreArchivo() == null
                            ? "Evidencia " + numero : evidencia.getNombreArchivo()))
                    .append("</figcaption></figure>");
            numero++;
        }

        String bloqueEvidencias = galeria.length() == 0
                ? "<p class=\"sin-evidencias\">No hay imágenes disponibles en el almacenamiento actual.</p>"
                : "<div class=\"galeria\">" + galeria + "</div>";

        String html = "<!doctype html><html lang=\"es\"><head><meta charset=\"UTF-8\">"
                + "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
                + "<title>Reporte de visita académica</title><style>"
                + "body{font-family:Arial,sans-serif;margin:42px;color:#17324d;background:#fff}"
                + "h1{border-bottom:3px solid #f08a24;padding-bottom:12px;margin-bottom:26px}"
                + ".datos{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px 22px}"
                + ".dato{padding:10px 12px;background:#f4f7fa;border:1px solid #d7dee7;border-radius:6px}"
                + "strong{display:block;margin-bottom:4px}.evidencias{margin-top:28px}"
                + ".galeria{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px}"
                + "figure{margin:0;border:1px solid #d7dee7;border-radius:8px;overflow:hidden;background:#fff}"
                + "figure img{display:block;width:100%;height:240px;object-fit:contain;background:#eef3f8}"
                + "figcaption{padding:8px 10px;font-size:12px;word-break:break-word}"
                + ".sin-evidencias{color:#65758b}@media(max-width:760px){.datos,.galeria{grid-template-columns:1fr}}"
                + "@media print{body{margin:14mm}.galeria{grid-template-columns:repeat(2,minmax(0,1fr))}}"
                + "</style></head><body><h1>Reporte de visita académica</h1><div class=\"datos\">"
                + dato("Empresa visitada", expediente.getEmpresa())
                + dato("Docente responsable", expediente.getDocente())
                + dato("División", expediente.getDivision())
                + dato("Carrera y grupo", safe(expediente.getCarrera()) + " · "
                + safe(expediente.getSemestre()) + " · " + safe(expediente.getGrupo()))
                + dato("Periodo de la visita", safe(expediente.getFechaInicio()) + " a " + safe(expediente.getFechaFin()))
                + dato("Objetivo", expediente.getProposito())
                + dato("Fecha de envío", documento.getSubidoEn() == null ? "" : documento.getSubidoEn().toLocalDate())
                + "</div><section class=\"evidencias\"><h2>Evidencias fotográficas</h2>"
                + bloqueEvidencias + "</section></body></html>";

        byte[] bytes = html.getBytes(StandardCharsets.UTF_8);
        response.setContentType("text/html; charset=UTF-8");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", (descargar ? "attachment" : "inline")
                + "; filename=\"Reporte_final_de_visita.html\"");
        response.getOutputStream().write(bytes);
    }

    private String dato(String titulo, Object valor) {
        return "<div class=\"dato\"><strong>" + html(titulo) + "</strong>"
                + html(valor == null ? "" : String.valueOf(valor)) + "</div>";
    }

    private String safe(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private String html(String value) {
        return value == null ? "" : value.replace("&", "&amp;").replace("<", "&lt;")
                                    .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
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
        return session == null ? null : (Usuario) session.getAttribute("usuario");
    }
}
