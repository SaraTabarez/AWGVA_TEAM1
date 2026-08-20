package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.TipoRol;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Service.VisitaService;
import mx.edu.utez.awgva.Utils.RecordTokenUtil;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "InicioServlet", value = "/inicio")
public class InicioServlet extends HttpServlet {

    private final VisitaService visitaService = new VisitaService();

    private static final Map<TipoRol, String> ROLE_VIEWS = Map.of(
            TipoRol.DOCENTE, "/WEB-INF/views/inicio/inicio-docente.jsp",
            TipoRol.DIRECTOR, "/WEB-INF/views/inicio/inicio-director.jsp",
            TipoRol.ESTADIAS, "/WEB-INF/views/inicio/inicio-estadias.jsp",
            TipoRol.ADMIN, "/WEB-INF/views/inicio/inicio-admin.jsp"
    );

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        showHome(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        showHome(request, response);
    }

    private void showHome(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Usuario usuario = session == null ? null : (Usuario) session.getAttribute("usuario");
        TipoRol role = usuario == null ? null : usuario.getTipoRol().orElse(null);

        if (role == null) {
            if (session != null) {
                session.invalidate();
            }
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        request.setAttribute("role", role.name());
        if (role == TipoRol.ESTADIAS) {
            response.sendRedirect(request.getContextPath() + "/estadias/documentos");
            return;
        }
        if (role == TipoRol.DOCENTE) {
            int[] resumen = visitaService.contarResumenDocente(usuario.getIdUsuario());
            int solicitudes = resumen[0];
            int reportes = resumen[1];
            int historico = resumen[2];
            request.setAttribute("totalSolicitudes", solicitudes + reportes + historico);
            request.setAttribute("solicitudesActivas", solicitudes);
            request.setAttribute("reportesActivos", reportes);
            request.setAttribute("historicoTotal", historico);
        } else if (role == TipoRol.ADMIN) {
            var solicitudes = visitaService.listarTodasActivasAdmin();
            for (var solicitud : solicitudes) {
                solicitud.setReferenceToken(RecordTokenUtil.issue(session, usuario.getIdUsuario(),
                        "admin-visita", solicitud.getIdVisita()));
            }
            request.setAttribute("solicitudes", solicitudes);
        }
        request.getRequestDispatcher(ROLE_VIEWS.get(role)).forward(request, response);
    }
}