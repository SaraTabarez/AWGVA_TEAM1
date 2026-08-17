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
import mx.edu.utez.awgva.Utils.CsrfTokenUtil;
import mx.edu.utez.awgva.Utils.PostNavigationResponse;

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
        if (role == TipoRol.DIRECTOR) {
            PostNavigationResponse.send(
                    response,
                    request.getContextPath() + "/director/solicitudes",
                    CsrfTokenUtil.getOrCreate(session),
                    Map.of()
            );
            return;
        }
        if (role == TipoRol.ESTADIAS) {
            PostNavigationResponse.send(
                    response,
                    request.getContextPath() + "/estadias/documentos",
                    CsrfTokenUtil.getOrCreate(session),
                    Map.of()
            );
            return;
        }
        if (role == TipoRol.DOCENTE) {
            request.setAttribute("totalSolicitudes", visitaService.contarDelDocente(usuario.getIdUsuario()));
        }
        request.getRequestDispatcher(ROLE_VIEWS.get(role)).forward(request, response);
    }
}