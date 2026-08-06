package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.CatalogoCarreras;
import mx.edu.utez.awgva.Model.Empresa;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.GrupoVisita;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Model.Visita;
import mx.edu.utez.awgva.Service.DocumentoService;
import mx.edu.utez.awgva.Service.VisitaService;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/** Flujo del Docente. Todas las lecturas se limitan por el usuario de la sesión. */
@WebServlet(name = "DocenteServlet", urlPatterns = {
        "/mis-solicitudes", "/nueva-solicitud", "/detalle-solicitud",
        "/reportes-docente", "/historico-docente", "/reporte-docente"
})
public class DocenteServlet extends HttpServlet {
    private final VisitaService visitaService = new VisitaService();
    private final DocumentoService documentoService = new DocumentoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = usuario(request);
        String path = request.getServletPath();

        switch (path) {
            case "/mis-solicitudes" -> {
                request.setAttribute("solicitudes", visitaService.listarDelDocente(usuario.getIdUsuario()));
                forward(request, response, "/solicitud.jsp");
            }
            case "/nueva-solicitud" -> {
                request.setAttribute("carreras", CatalogoCarreras.deDivision(usuario.getNombreDivision()));
                forward(request, response, "/nueva-solicitud.jsp");
            }
            case "/detalle-solicitud" -> mostrarDetallePropio(request, response, usuario);
            case "/reportes-docente" -> {
                request.setAttribute("solicitudes", visitaService.listarDelDocente(usuario.getIdUsuario()));
                forward(request, response, "/subir-docs.jsp");
            }
            case "/historico-docente" -> {
                request.setAttribute("solicitudes", visitaService.listarHistoricoDocente(usuario.getIdUsuario()));
                forward(request, response, "/historico-docente.jsp");
            }
            case "/reporte-docente" -> mostrarReportePropio(request, response, usuario);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!"/nueva-solicitud".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        request.setCharacterEncoding("UTF-8");
        Usuario usuario = usuario(request);
        try {
            Visita visita = new Visita();
            visita.setIdUsuarioFk(usuario.getIdUsuario());
            visita.setIdDivisionFk(requerido(usuario.getIdDivisionFk(), "Tu usuario no tiene una división asignada."));
            visita.setTituloVisita(texto(request, "tituloVisita", 180,
                    "Visita académica a " + texto(request, "empresaNombre", 150, null)));
            visita.setAsignaturaAReforzar(texto(request, "asignaturas", 500, null));
            visita.setDocenteAcompanante(texto(request, "docentesAcompanantes", 100, "0"));
            visita.setDocenteEncargado(usuario.getNombreCompleto());
            visita.setPropositoVisita(texto(request, "objetivo", 1000, null));
            visita.setFechaInicioVisita(fecha(request, "fechaInicio"));
            visita.setFechaFinVisita(fecha(request, "fechaTermino"));
            visita.setEstado("PENDIENTE_DIRECTOR");
            if (visita.getFechaFinVisita().isBefore(visita.getFechaInicioVisita())) {
                throw new IllegalArgumentException("La fecha de término no puede ser anterior a la fecha de inicio.");
            }

            Empresa empresa = new Empresa(
                    texto(request, "empresaNombre", 150, null),
                    texto(request, "empresaDireccion", 250, null),
                    texto(request, "empresaTelefono", 30, null),
                    texto(request, "empresaEmail", 160, null)
            );

            String carrera = texto(request, "programaEducativo", 180, null);
            if (!CatalogoCarreras.pertenece(usuario.getNombreDivision(), carrera)) {
                throw new IllegalArgumentException("Selecciona una carrera de tu división.");
            }
            int estudiantes = entero(request, "totalEstudiantes", 1, 200);
            GrupoVisita grupo = new GrupoVisita(null, carrera,
                    texto(request, "semestre", 30, null),
                    texto(request, "grupo", 30, null), estudiantes);

            if (!visitaService.crearVisitaCompleta(visita, empresa, grupo)) {
                throw new IllegalStateException("No fue posible guardar la solicitud. Revisa la conexión con Oracle.");
            }
            response.sendRedirect(request.getContextPath() + "/mis-solicitudes?creada=1");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            request.setAttribute("error", exception.getMessage());
            request.setAttribute("carreras", CatalogoCarreras.deDivision(usuario.getNombreDivision()));
            forward(request, response, "/nueva-solicitud.jsp");
        }
    }

    private void mostrarDetallePropio(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        Long id = id(request, "id");
        ExpedienteVisita expediente = visitaService.buscarDelDocente(id, usuario.getIdUsuario());
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "La solicitud no existe o no te pertenece.");
            return;
        }
        expediente.setDocumentos(documentoService.listarPorVisita(id));
        request.setAttribute("expediente", expediente);
        forward(request, response, "/solicitud-detalle.jsp");
    }

    private void mostrarReportePropio(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        Long id = id(request, "id");
        ExpedienteVisita expediente = visitaService.buscarDelDocente(id, usuario.getIdUsuario());
        if (expediente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "La solicitud no existe o no te pertenece.");
            return;
        }
        expediente.setDocumentos(documentoService.listarEvidenciasReporte(id));
        request.setAttribute("expediente", expediente);
        request.setAttribute("reporte", documentoService.buscarPorVisitaYTipo(id, "REPORTE"));
        forward(request, response, "/llenar-reporte.jsp");
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String jsp)
            throws ServletException, IOException {
        request.getRequestDispatcher(jsp).forward(request, response);
    }

    private Long id(HttpServletRequest request, String nombre) {
        try {
            long valor = Long.parseLong(request.getParameter(nombre));
            if (valor < 1) throw new NumberFormatException();
            return valor;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Identificador no válido.");
        }
    }

    private LocalDate fecha(HttpServletRequest request, String nombre) {
        try {
            return LocalDate.parse(texto(request, nombre, 10, null));
        } catch (DateTimeParseException exception) {
            throw new IllegalArgumentException("Captura fechas válidas.");
        }
    }

    private int entero(HttpServletRequest request, String nombre, int minimo, int maximo) {
        try {
            int valor = Integer.parseInt(request.getParameter(nombre));
            if (valor < minimo || valor > maximo) throw new NumberFormatException();
            return valor;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("El total de estudiantes debe estar entre " + minimo + " y " + maximo + ".");
        }
    }

    private String texto(HttpServletRequest request, String nombre, int maximo, String valorPredeterminado) {
        String valor = request.getParameter(nombre);
        if (valor == null || valor.isBlank()) {
            if (valorPredeterminado != null) return valorPredeterminado;
            throw new IllegalArgumentException("Completa todos los campos obligatorios.");
        }
        valor = valor.trim();
        if (valor.length() > maximo) throw new IllegalArgumentException("Uno de los campos supera el tamaño permitido.");
        return valor;
    }

    private <T> T requerido(T valor, String mensaje) {
        if (valor == null) throw new IllegalArgumentException(mensaje);
        return valor;
    }
}
