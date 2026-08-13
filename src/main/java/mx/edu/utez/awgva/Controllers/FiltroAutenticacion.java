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

import java.io.IOException;
import java.util.Set;

@WebFilter("/*")
public class FiltroAutenticacion extends HttpFilter {

    private static final Set<String> PUBLIC_PATHS = Set.of(
            "/",
            "/login.jsp",
            "/login",
            "/recuperar-contra.jsp",
            "/reset-password"
    );

    private static final Set<String> SHARED_PATHS = Set.of(
            "/inicio",
            "/index.jsp",
            "/logout",
            "/archivo",
            "/cambiar-contrasena"
    );

    private static final Set<String> ADMIN_PATHS = Set.of(
            "/GestionUsuariosServlet",
            "/RegistrarUsuarioServlet",
            "/EliminarUsuarioServlet",
            "/ActualizarEstadoUsuarioServlet",
            "/gestion-usuarios.jsp",
            "/registrar-usuario.jsp",
            "/hello-servlet"
    );

    private static final Set<String> DOCENTE_PATHS = Set.of(
            "/mis-solicitudes",
            "/nueva-solicitud",
            "/solicitud-previa",
            "/confirmar-solicitud",
            "/detalle-solicitud",
            "/carta-responsiva",
            "/oficio-autorizacion",
            "/subir-solicitud-firmada",
            "/subir-carta-firmada",
            "/reportes-docente",
            "/historico-docente",
            "/reporte-docente",
            "/solicitud.jsp",
            "/nueva-solicitud.jsp",
            "/solicitud",
            "/solicitud-servlet",
            "/solicitud-previa.jsp",
            "/solicitud-detalle.jsp",
            "/subir-docs.jsp",
            "/upload-servlet",
            "/UploadServlet",
            "/subir-documento",
            "/subirDocumento.jsp",
            "/subirCartaResponsiva.jsp",
            "/cartaResponsiva.jsp",
            "/cartaEnviadaExito.jsp",
            "/llenar-reporte.jsp",
            "/reporte-exito.jsp",
            "/exito.jsp",
            "/historico-docente.jsp",
            "/oficio-autorizacion.jsp",
            "/resumen.jsp"
    );

    private static final Set<String> DIRECTOR_PATHS = Set.of(
            "/servlet-gestion-solicitudes",
            "/gestion-solicitudes.jsp",
            "/servlet-detalles-solicitud",
            "/solicitud-visita-industrial.jsp"
    );

    private static final Set<String> ESTADIAS_PATHS = Set.of(
            "/gestion-documentos.jsp",
            "/historico-estadias.jsp",
            "/revisar-reporte.jsp",
            "/reporte-aceptado.jsp",
            "/reporte-rechazado.jsp"
    );

    private static final Set<String> TRANSITIONAL_CSRF_EXEMPT_PATHS = Set.of(
            "/login"
    );

    @Override
    protected void doFilter(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain chain
    ) throws IOException, ServletException {

        addSecurityHeaders(response);

        String path = resolvePath(request);

        if (isStaticAsset(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);

        if (PUBLIC_PATHS.contains(path)) {
            if (session == null) {
                session = request.getSession(true);
            }

            CsrfTokenUtil.getOrCreate(session);
        }

        if (isPost(request)
                && !TRANSITIONAL_CSRF_EXEMPT_PATHS.contains(path)
                && !CsrfTokenUtil.matches(request)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "El formulario expiró o la solicitud no es válida."
            );
            return;
        }

        Usuario usuario = getAuthenticatedUser(session);

        if (usuario == null) {
            if (PUBLIC_PATHS.contains(path)) {
                chain.doFilter(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
            return;
        }

        if (PUBLIC_PATHS.contains(path)) {
            response.sendRedirect(request.getContextPath() + "/inicio");
            return;
        }

        TipoRol role = usuario.getTipoRol().orElse(null);

        if (role == null) {
            session.invalidate();
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp?error=rol"
            );
            return;
        }

        String legacyRoute = resolveLegacyRoute(role, path);

        if (legacyRoute != null) {
            response.sendRedirect(request.getContextPath() + legacyRoute);
            return;
        }

        if (isAuthorized(role, path)) {
            chain.doFilter(request, response);
            return;
        }

        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        request.setAttribute("rutaDenegada", path);
        request.getRequestDispatcher(
                "/WEB-INF/views/error/403.jsp"
        ).forward(request, response);
    }

    private Usuario getAuthenticatedUser(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object sessionUser = session.getAttribute("usuario");

        if (sessionUser instanceof Usuario usuario) {
            return usuario;
        }

        return null;
    }

    private boolean isAuthorized(TipoRol role, String path) {
        if (SHARED_PATHS.contains(path)) {
            return true;
        }

        if (role == TipoRol.ADMIN) {
            return isAdminPath(path)
                    || isDocentePath(path)
                    || isDirectorPath(path)
                    || isEstadiasPath(path);
        }

        return switch (role) {
            case DOCENTE -> isDocentePath(path);
            case DIRECTOR -> isDirectorPath(path);
            case ESTADIAS -> isEstadiasPath(path);
            case ADMIN -> false;
        };
    }

    private boolean isAdminPath(String path) {
        return ADMIN_PATHS.contains(path)
                || path.startsWith("/admin/");
    }

    private boolean isDocentePath(String path) {
        return DOCENTE_PATHS.contains(path)
                || path.startsWith("/docente/");
    }

    private boolean isDirectorPath(String path) {
        return DIRECTOR_PATHS.contains(path)
                || path.startsWith("/director/");
    }

    private boolean isEstadiasPath(String path) {
        return ESTADIAS_PATHS.contains(path)
                || path.startsWith("/estadias/");
    }

    private boolean isStaticAsset(String path) {
        return path.startsWith("/assets/")
                || path.startsWith("/webjars/")
                || path.equals("/favicon.ico");
    }

    private boolean isPost(HttpServletRequest request) {
        return "POST".equalsIgnoreCase(request.getMethod());
    }

    private String resolvePath(HttpServletRequest request) {
        String contextPath = request.getContextPath();
        String requestUri = request.getRequestURI();
        String path = requestUri.substring(contextPath.length());

        int pathParameterIndex = path.indexOf(';');

        if (pathParameterIndex >= 0) {
            path = path.substring(0, pathParameterIndex);
        }

        if (path.isBlank()) {
            return "/";
        }

        if (path.length() > 1 && path.endsWith("/")) {
            return path.substring(0, path.length() - 1);
        }

        return path;
    }

    private String resolveLegacyRoute(TipoRol role, String path) {
        if (role == TipoRol.DOCENTE) {
            return switch (path) {
                case "/solicitud.jsp" -> "/mis-solicitudes";
                case "/nueva-solicitud.jsp" -> "/nueva-solicitud";
                case "/subir-docs.jsp", "/llenar-reporte.jsp" ->
                        "/reportes-docente";
                case "/historico-docente.jsp" -> "/historico-docente";
                case "/solicitud-detalle.jsp" -> "/mis-solicitudes";
                default -> null;
            };
        }

        if (role == TipoRol.DIRECTOR
                && (path.equals("/gestion-solicitudes.jsp")
                || path.equals("/servlet-gestion-solicitudes"))) {

            return "/director/solicitudes";
        }

        if (role == TipoRol.ESTADIAS
                && (path.equals("/gestion-documentos.jsp")
                || path.equals("/revisar-reporte.jsp")
                || path.equals("/historico-estadias.jsp"))) {

            if (path.equals("/historico-estadias.jsp")) {
                return "/estadias/historico";
            }

            return "/estadias/documentos";
        }

        return null;
    }

    private void addSecurityHeaders(HttpServletResponse response) {
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader(
                "Referrer-Policy",
                "strict-origin-when-cross-origin"
        );
        response.setHeader(
                "Permissions-Policy",
                "camera=(), microphone=(), geolocation=()"
        );
        response.setHeader(
                "Cache-Control",
                "no-store, no-cache, must-revalidate, max-age=0"
        );
        response.setHeader("Pragma", "no-cache");
    }
}