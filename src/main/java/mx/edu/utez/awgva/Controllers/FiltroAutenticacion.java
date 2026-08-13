package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.TipoRol;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Utils.CsrfTokenUtil;
import mx.edu.utez.awgva.Utils.PostNavigationResponse;

import java.io.IOException;
import java.util.Set;
import java.util.Map;

/**
 * Autenticación y autorización centralizadas. El menú mejora la experiencia,
 * pero este filtro es el que impide el acceso escribiendo una URL manualmente.
 */
@WebFilter("/*")
public class FiltroAutenticacion extends HttpFilter {

    private static final Set<String> PUBLIC_PATHS = Set.of(
            "/", "/login.jsp", "/login", "/recuperar-contra.jsp", "/reset-password"
    );

    private static final Set<String> SHARED_PATHS = Set.of(
            "/inicio", "/index.jsp", "/logout", "/archivo"
    );

    private static final Set<String> ADMIN_PATHS = Set.of(
            "/GestionUsuariosServlet", "/RegistrarUsuarioServlet",
            "/EliminarUsuarioServlet", "/ActualizarEstadoUsuarioServlet",
            "/admin/usuarios", "/admin/usuarios/alta", "/admin/usuarios/eliminar",
            "/admin/usuarios/estado",
            "/gestion-usuarios.jsp", "/registrar-usuario.jsp", "/hello-servlet",
            "/admin/firmantes"
    );

    private static final Set<String> DOCENTE_PATHS = Set.of(
            "/mis-solicitudes", "/nueva-solicitud", "/solicitud-previa", "/confirmar-solicitud",
            "/detalle-solicitud", "/carta-responsiva", "/oficio-autorizacion",
            "/subir-solicitud-firmada", "/subir-carta-firmada", "/docente/marcar-descarga",
            "/reportes-docente", "/historico-docente", "/reporte-docente",
            "/docente/subir-documento", "/docente/subir-reporte",
            "/solicitud.jsp", "/nueva-solicitud.jsp", "/solicitud",
            "/solicitud-servlet", "/solicitud-previa.jsp", "/solicitud-detalle.jsp",
            "/subir-docs.jsp", "/upload-servlet", "/UploadServlet",
            "/subir-documento", "/subirDocumento.jsp", "/subirCartaResponsiva.jsp",
            "/cartaResponsiva.jsp", "/cartaEnviadaExito.jsp", "/llenar-reporte.jsp",
            "/reporte-exito.jsp", "/exito.jsp", "/historico-docente.jsp",
            "/oficio-autorizacion.jsp", "/resumen.jsp"
    );

    private static final Set<String> DIRECTOR_PATHS = Set.of(
            "/cambiar-contrasena",
            "/servlet-gestion-solicitudes", "/gestion-solicitudes.jsp",
            "/servlet-detalles-solicitud", "/solicitud-visita-industrial.jsp"
    );

    private static final Set<String> ESTADIAS_PATHS = Set.of(
            "/gestion-documentos.jsp", "/historico-estadias.jsp",
            "/revisar-reporte.jsp", "/reporte-aceptado.jsp", "/reporte-rechazado.jsp"
    );

    @Override
    protected void doFilter(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain chain
    ) throws IOException, ServletException {
        addSecurityHeaders(response);

        String contextPath = request.getContextPath();
        String path = request.getRequestURI().substring(contextPath.length());
        HttpSession session = request.getSession(true);
        CsrfTokenUtil.getOrCreate(session);
        Usuario usuario = session == null ? null : (Usuario) session.getAttribute("usuario");
        boolean loggedIn = usuario != null;

        if (isStaticAsset(path)) {
            chain.doFilter(request, response);
            return;
        }

        if ("POST".equalsIgnoreCase(request.getMethod())
                && !CsrfTokenUtil.matches(session, request.getHeader(CsrfTokenUtil.HEADER_NAME))
                && !CsrfTokenUtil.matches(session, request.getParameter(CsrfTokenUtil.PARAMETER_NAME))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "El formulario expiró. Recarga la página.");
            return;
        }

        if (!loggedIn) {
            if (path.equals("/recuperar-contra.jsp")) {
                response.sendRedirect(contextPath + "/reset-password");
                return;
            }
            if (PUBLIC_PATHS.contains(path)) {
                chain.doFilter(request, response);
            } else {
                response.sendRedirect(contextPath + "/login.jsp");
            }
            return;
        }

        if (PUBLIC_PATHS.contains(path)) {
            PostNavigationResponse.send(response, contextPath + "/inicio",
                    CsrfTokenUtil.getOrCreate(session), Map.of());
            return;
        }

        TipoRol role = usuario.getTipoRol().orElse(null);
        if (role == null) {
            session.invalidate();
            response.sendRedirect(contextPath + "/login.jsp?error=rol");
            return;
        }

        String rutaActualizada = legacyRedirect(role, path);
        if (rutaActualizada != null) {
            PostNavigationResponse.send(response, contextPath + rutaActualizada,
                    CsrfTokenUtil.getOrCreate(session), Map.of());
            return;
        }

        if ("GET".equalsIgnoreCase(request.getMethod())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                    "La navegación autenticada requiere POST.");
            return;
        }

        if (role == TipoRol.ADMIN || isAuthorized(role, path)) {
            chain.doFilter(request, response);
            return;
        }

        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        request.setAttribute("rutaDenegada", path);
        request.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(request, response);
    }

    private boolean isAuthorized(TipoRol role, String path) {
        if (SHARED_PATHS.contains(path)) {
            return true;
        }
        if (ADMIN_PATHS.contains(path)) {
            return role == TipoRol.ADMIN;
        }
        if (DOCENTE_PATHS.contains(path) || path.startsWith("/evidencias_reportes/")) {
            return role == TipoRol.DOCENTE;
        }
        if (DIRECTOR_PATHS.contains(path) || path.startsWith("/director/")) {
            return role == TipoRol.DIRECTOR;
        }
        if (ESTADIAS_PATHS.contains(path) || path.startsWith("/estadias/")) {
            return role == TipoRol.ESTADIAS;
        }

        // Denegación por defecto: una ruta nueva debe asignarse explícitamente.
        return false;
    }

    private boolean isStaticAsset(String path) {
        return path.startsWith("/assets/") || path.equals("/favicon.ico");
    }

    private String legacyRedirect(TipoRol role, String path) {
        if (role == TipoRol.ADMIN && (path.equals("/gestion-usuarios.jsp")
                || path.equals("/registrar-usuario.jsp") || path.equals("/GestionUsuariosServlet"))) {
            return "/admin/usuarios";
        }
        if (role == TipoRol.DOCENTE) {
            return switch (path) {
                case "/solicitud.jsp" -> "/mis-solicitudes";
                case "/nueva-solicitud.jsp" -> "/nueva-solicitud";
                case "/subir-docs.jsp", "/llenar-reporte.jsp" -> "/reportes-docente";
                case "/historico-docente.jsp" -> "/historico-docente";
                case "/solicitud-detalle.jsp" -> "/mis-solicitudes";
                default -> null;
            };
        }
        if (role == TipoRol.DIRECTOR
                && (path.equals("/gestion-solicitudes.jsp") || path.equals("/servlet-gestion-solicitudes"))) {
            return "/director/solicitudes";
        }
        if (role == TipoRol.ESTADIAS && (path.equals("/gestion-documentos.jsp")
                || path.equals("/revisar-reporte.jsp") || path.equals("/historico-estadias.jsp"))) {
            return path.equals("/historico-estadias.jsp") ? "/estadias/historico" : "/estadias/documentos";
        }
        return null;
    }

    private void addSecurityHeaders(HttpServletResponse response) {
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        response.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
        response.setHeader("Cache-Control", "no-store");
    }
}