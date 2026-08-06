package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.CatalogoCarreras;
import mx.edu.utez.awgva.Model.Documento;
import mx.edu.utez.awgva.Model.Empresa;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.GrupoVisita;
import mx.edu.utez.awgva.Model.SolicitudVisita;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Model.Visita;
import mx.edu.utez.awgva.Service.DocumentoService;
import mx.edu.utez.awgva.Service.VisitaService;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/** Flujo completo del Docente. Todas las lecturas se limitan al usuario autenticado. */
@WebServlet(name = "DocenteServlet", urlPatterns = {
        "/mis-solicitudes", "/nueva-solicitud", "/solicitud-previa", "/confirmar-solicitud",
        "/detalle-solicitud", "/carta-responsiva", "/oficio-autorizacion",
        "/subir-solicitud-firmada", "/subir-carta-firmada", "/docente/marcar-descarga",
        "/reportes-docente", "/historico-docente", "/reporte-docente"
})
public class DocenteServlet extends HttpServlet {
    private static final String BORRADOR_SOLICITUD = "borradorSolicitud";
    private static final String DATOS_POR_VISITA = "datosSolicitudPorVisita";
    private static final String CARTAS_DESCARGADAS = "cartasResponsivasDescargadas";

    private final VisitaService visitaService = new VisitaService();
    private final DocumentoService documentoService = new DocumentoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = usuario(request);
        try {
            switch (request.getServletPath()) {
                case "/mis-solicitudes" -> {
                    request.setAttribute("solicitudes",
                            visitaService.listarSolicitudesActivasDocente(usuario.getIdUsuario()));
                    forward(request, response, "/solicitud.jsp");
                }
                case "/nueva-solicitud" -> mostrarFormulario(request, response, usuario);
                case "/solicitud-previa" -> mostrarPrevia(request, response, usuario);
                case "/detalle-solicitud" -> mostrarDetallePropio(request, response, usuario);
                case "/carta-responsiva" -> mostrarDocumentoGenerado(
                        request, response, usuario, "/cartaResponsiva.jsp");
                case "/oficio-autorizacion" -> mostrarDocumentoGenerado(
                        request, response, usuario, "/oficio-autorizacion.jsp");
                case "/subir-solicitud-firmada" -> mostrarCargaDocumento(
                        request, response, usuario, "SOLICITUD_VISITA", "/subirDocumento.jsp");
                case "/subir-carta-firmada" -> mostrarCargaDocumento(
                        request, response, usuario, "CARTA_RESPONSIVA", "/subirCartaResponsiva.jsp");
                case "/reportes-docente" -> {
                    request.setAttribute("solicitudes",
                            visitaService.listarReportesDelDocente(usuario.getIdUsuario()));
                    forward(request, response, "/subir-docs.jsp");
                }
                case "/historico-docente" -> {
                    request.setAttribute("solicitudes",
                            visitaService.listarHistoricoDocente(usuario.getIdUsuario()));
                    forward(request, response, "/historico-docente.jsp");
                }
                case "/reporte-docente" -> mostrarReportePropio(request, response, usuario);
                default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (IllegalArgumentException exception) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, exception.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Usuario usuario = usuario(request);
        try {
            switch (request.getServletPath()) {
                case "/nueva-solicitud" -> prepararVistaPrevia(request, response, usuario);
                case "/confirmar-solicitud" -> confirmarSolicitud(request, response, usuario);
                case "/docente/marcar-descarga" -> marcarDescarga(request, response, usuario);
                default -> response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            }
        } catch (IllegalArgumentException | IllegalStateException exception) {
            if ("/docente/marcar-descarga".equals(request.getServletPath())) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, exception.getMessage());
                return;
            }
            SolicitudVisita borrador = (SolicitudVisita) request.getSession().getAttribute(BORRADOR_SOLICITUD);
            request.setAttribute("borrador", borrador);
            request.setAttribute("error", exception.getMessage());
            request.setAttribute("carreras", CatalogoCarreras.deDivision(usuario.getNombreDivision()));
            forward(request, response, "/nueva-solicitud.jsp");
        }
    }

    private void mostrarFormulario(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if ("1".equals(request.getParameter("editar"))) {
            request.setAttribute("borrador", session.getAttribute(BORRADOR_SOLICITUD));
        } else {
            session.removeAttribute(BORRADOR_SOLICITUD);
        }
        request.setAttribute("carreras", CatalogoCarreras.deDivision(usuario.getNombreDivision()));
        forward(request, response, "/nueva-solicitud.jsp");
    }

    private void prepararVistaPrevia(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {
        SolicitudVisita borrador = leerFormulario(request, usuario);
        request.getSession().setAttribute(BORRADOR_SOLICITUD, borrador);
        response.sendRedirect(request.getContextPath() + "/solicitud-previa");
    }

    private void mostrarPrevia(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        SolicitudVisita solicitud;
        Long idVisita = idOpcional(request.getParameter("id"));
        if (idVisita == null) {
            solicitud = (SolicitudVisita) request.getSession().getAttribute(BORRADOR_SOLICITUD);
            if (solicitud == null) {
                response.sendRedirect(request.getContextPath() + "/nueva-solicitud");
                return;
            }
        } else {
            ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
            solicitud = datosSolicitud(expediente, usuario, request.getSession());
            request.setAttribute("expediente", expediente);
            request.setAttribute("idVisita", idVisita);
        }
        request.setAttribute("solicitud", solicitud);
        request.setAttribute("divisionDocente", usuario.getNombreDivision());
        forward(request, response, "/solicitud-previa.jsp");
    }

    private void confirmarSolicitud(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        SolicitudVisita solicitud = (SolicitudVisita) session.getAttribute(BORRADOR_SOLICITUD);
        if (solicitud == null) {
            throw new IllegalStateException("La vista previa expiró. Captura nuevamente la solicitud.");
        }

        LocalDate inicio = parseFecha(solicitud.getFechaInicio());
        LocalDate fin = parseFecha(solicitud.getFechaTermino());
        if (fin.isBefore(inicio)) {
            throw new IllegalArgumentException("La fecha de término no puede ser anterior a la fecha de inicio.");
        }

        Visita visita = new Visita();
        visita.setIdUsuarioFk(usuario.getIdUsuario());
        visita.setIdDivisionFk(requerido(usuario.getIdDivisionFk(),
                "Tu usuario no tiene una división asignada."));
        visita.setTituloVisita("Visita académica a " + solicitud.getEmpresaNombre());
        visita.setAsignaturaAReforzar(solicitud.getAsignaturas());
        visita.setDocenteAcompanante(solicitud.getDocentesAcompanantes());
        visita.setDocenteEncargado(usuario.getNombreCompleto());
        visita.setPropositoVisita(solicitud.getObjetivo());
        visita.setFechaInicioVisita(inicio);
        visita.setFechaFinVisita(fin);
        visita.setEstado("PENDIENTE_DIRECTOR");

        Empresa empresa = new Empresa(solicitud.getEmpresaNombre(), solicitud.getEmpresaDireccion(),
                solicitud.getEmpresaTelefono(), solicitud.getEmpresaEmail());
        GrupoVisita grupo = new GrupoVisita(null, solicitud.getProgramaEducativo(),
                solicitud.getSemestre(), solicitud.getGrupo(), Integer.parseInt(solicitud.getTotalEstudiantes()));

        if (!visitaService.crearVisitaCompleta(visita, empresa, grupo) || visita.getIdVisita() == null) {
            throw new IllegalStateException("No fue posible guardar la solicitud. Revisa la conexión con Oracle.");
        }

        guardarDatosSolicitud(session, visita.getIdVisita(), solicitud);
        session.removeAttribute(BORRADOR_SOLICITUD);
        request.setAttribute("solicitud", solicitud);
        request.setAttribute("idVisita", visita.getIdVisita());
        request.setAttribute("divisionDocente", usuario.getNombreDivision());
        request.setAttribute("autoPrint", true);
        forward(request, response, "/solicitud-previa.jsp");
    }

    private void mostrarDetallePropio(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        Long idVisita = id(request.getParameter("id"));
        ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
        expediente.setDocumentos(documentoService.listarPorVisita(idVisita));

        Documento solicitudFirmada = documentoService.buscarPorVisitaYTipo(idVisita, "SOLICITUD_VISITA");
        Documento cartaFirmada = documentoService.buscarPorVisitaYTipo(idVisita, "CARTA_RESPONSIVA");
        boolean cartaDescargada = cartasDescargadas(request.getSession()).contains(idVisita)
                || cartaFirmada != null;

        request.setAttribute("expediente", expediente);
        request.setAttribute("solicitudFirmada", solicitudFirmada);
        request.setAttribute("cartaFirmada", cartaFirmada);
        request.setAttribute("cartaDescargada", cartaDescargada);
        forward(request, response, "/solicitud-detalle.jsp");
    }

    private void mostrarDocumentoGenerado(HttpServletRequest request, HttpServletResponse response,
                                          Usuario usuario, String jsp)
            throws ServletException, IOException {
        Long idVisita = id(request.getParameter("id"));
        ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
        request.setAttribute("expediente", expediente);
        request.setAttribute("solicitud", datosSolicitud(expediente, usuario, request.getSession()));
        forward(request, response, jsp);
    }

    private void mostrarCargaDocumento(HttpServletRequest request, HttpServletResponse response,
                                       Usuario usuario, String tipo, String jsp)
            throws ServletException, IOException {
        Long idVisita = id(request.getParameter("id"));
        ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
        if ("CARTA_RESPONSIVA".equals(tipo)
                && !cartasDescargadas(request.getSession()).contains(idVisita)
                && documentoService.buscarPorVisitaYTipo(idVisita, tipo) == null) {
            response.sendRedirect(request.getContextPath() + "/detalle-solicitud?id=" + idVisita + "&pendienteCarta=1");
            return;
        }
        request.setAttribute("expediente", expediente);
        request.setAttribute("documentoExistente", documentoService.buscarPorVisitaYTipo(idVisita, tipo));
        String mensaje = (String) request.getSession().getAttribute("mensajeCarga");
        if (mensaje != null) {
            request.setAttribute("error", mensaje);
            request.getSession().removeAttribute("mensajeCarga");
        }
        forward(request, response, jsp);
    }

    private void mostrarReportePropio(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        Long idVisita = id(request.getParameter("id"));
        ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
        expediente.setDocumentos(documentoService.listarEvidenciasReporte(idVisita));
        request.setAttribute("expediente", expediente);
        request.setAttribute("reporte", documentoService.buscarPorVisitaYTipo(idVisita, "REPORTE"));
        String mensaje = (String) request.getSession().getAttribute("mensajeCarga");
        if (mensaje != null) {
            request.setAttribute("error", mensaje);
            request.getSession().removeAttribute("mensajeCarga");
        }
        forward(request, response, "/llenar-reporte.jsp");
    }

    private void marcarDescarga(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {
        Long idVisita = id(request.getParameter("idVisita"));
        expedientePropio(idVisita, usuario);
        String tipo = request.getParameter("tipo");
        if ("CARTA_RESPONSIVA".equals(tipo)) {
            cartasDescargadas(request.getSession()).add(idVisita);
        } else if (!"SOLICITUD_VISITA".equals(tipo)) {
            throw new IllegalArgumentException("Tipo de descarga no válido.");
        }
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    private SolicitudVisita leerFormulario(HttpServletRequest request, Usuario usuario) {
        SolicitudVisita solicitud = new SolicitudVisita();
        solicitud.setSolicitanteNombre(usuario.getNombreCompleto());
        solicitud.setSolicitanteCargo("DOCENTE");
        solicitud.setSolicitanteTelefono(texto(request, "solicitanteTelefono", 30, null));
        solicitud.setDocentesAcompanantes(String.valueOf(entero(request, "docentesAcompanantes", 0, 3,
                "El número de docentes acompañantes debe estar entre 0 y 3.")));
        solicitud.setEmpresaNombre(texto(request, "empresaNombre", 150, null));
        solicitud.setEmpresaDireccion(texto(request, "empresaDireccion", 250, null));
        solicitud.setEmpresaTelefono(texto(request, "empresaTelefono", 30, null));
        solicitud.setEmpresaEmail(texto(request, "empresaEmail", 160, null));
        solicitud.setFechaInicio(texto(request, "fechaInicio", 10, null));
        solicitud.setFechaTermino(texto(request, "fechaTermino", 10, null));
        solicitud.setHoraInicio(texto(request, "horaInicio", 5, "No registrada"));
        solicitud.setObjetivo(texto(request, "objetivo", 1000, null));

        String carrera = texto(request, "programaEducativo", 180, null);
        if (!CatalogoCarreras.pertenece(usuario.getNombreDivision(), carrera)) {
            throw new IllegalArgumentException("Selecciona una carrera de tu división.");
        }
        solicitud.setProgramaEducativo(carrera);
        solicitud.setSemestre(texto(request, "semestre", 30, null));
        solicitud.setGrupo(texto(request, "grupo", 30, null));

        int dacea = entero(request, "dacea", 0, 200, "Captura cantidades válidas por división.");
        int datefi = entero(request, "datefi", 0, 200, "Captura cantidades válidas por división.");
        int datid = entero(request, "datid", 0, 200, "Captura cantidades válidas por división.");
        int dami = entero(request, "dami", 0, 200, "Captura cantidades válidas por división.");
        int total = entero(request, "totalEstudiantes", 1, 200,
                "El total de estudiantes debe estar entre 1 y 200.");
        if (dacea + datefi + datid + dami != total) {
            throw new IllegalArgumentException("El total de estudiantes debe coincidir con la suma de las divisiones.");
        }
        solicitud.setDacea(String.valueOf(dacea));
        solicitud.setDatefi(String.valueOf(datefi));
        solicitud.setDatid(String.valueOf(datid));
        solicitud.setDami(String.valueOf(dami));
        solicitud.setTotalEstudiantes(String.valueOf(total));
        solicitud.setAsignaturas(texto(request, "asignaturas", 500, null));

        LocalDate inicio = parseFecha(solicitud.getFechaInicio());
        LocalDate fin = parseFecha(solicitud.getFechaTermino());
        if (fin.isBefore(inicio)) {
            throw new IllegalArgumentException("La fecha de término no puede ser anterior a la fecha de inicio.");
        }
        return solicitud;
    }

    private ExpedienteVisita expedientePropio(Long idVisita, Usuario usuario) {
        ExpedienteVisita expediente = visitaService.buscarDelDocente(idVisita, usuario.getIdUsuario());
        if (expediente == null) {
            throw new IllegalArgumentException("La solicitud no existe o no te pertenece.");
        }
        return expediente;
    }

    private SolicitudVisita datosSolicitud(ExpedienteVisita expediente, Usuario usuario, HttpSession session) {
        SolicitudVisita guardada = datosPorVisita(session).get(expediente.getIdVisita());
        if (guardada != null) return guardada;

        SolicitudVisita solicitud = new SolicitudVisita();
        solicitud.setSolicitanteNombre(expediente.getDocente());
        solicitud.setSolicitanteCargo("DOCENTE");
        solicitud.setSolicitanteTelefono("");
        solicitud.setDocentesAcompanantes(valor(expediente.getDocenteAcompanante(), "0"));
        solicitud.setEmpresaNombre(expediente.getEmpresa());
        solicitud.setEmpresaDireccion(expediente.getDireccionEmpresa());
        solicitud.setEmpresaTelefono(expediente.getTelefonoEmpresa());
        solicitud.setEmpresaEmail(expediente.getCorreoEmpresa());
        solicitud.setFechaInicio(expediente.getFechaInicio() == null ? "" : expediente.getFechaInicio().toString());
        solicitud.setFechaTermino(expediente.getFechaFin() == null ? "" : expediente.getFechaFin().toString());
        solicitud.setHoraInicio("No registrada");
        solicitud.setObjetivo(expediente.getProposito());
        solicitud.setProgramaEducativo(expediente.getCarrera());
        solicitud.setSemestre(expediente.getSemestre());
        solicitud.setGrupo(expediente.getGrupo());
        solicitud.setAsignaturas(expediente.getAsignatura());

        int total = expediente.getNumeroEstudiantes() == null ? 0 : expediente.getNumeroEstudiantes();
        solicitud.setDacea("0");
        solicitud.setDatefi("0");
        solicitud.setDatid("0");
        solicitud.setDami("0");
        String division = valor(expediente.getDivision(), usuario.getNombreDivision()).toUpperCase(Locale.ROOT);
        if (division.contains("DACEA")) solicitud.setDacea(String.valueOf(total));
        else if (division.contains("DATEFI")) solicitud.setDatefi(String.valueOf(total));
        else if (division.contains("DATID")) solicitud.setDatid(String.valueOf(total));
        else if (division.contains("DAMI")) solicitud.setDami(String.valueOf(total));
        solicitud.setTotalEstudiantes(String.valueOf(total));
        solicitud.setEstado(expediente.getEstado());
        return solicitud;
    }

    @SuppressWarnings("unchecked")
    private Map<Long, SolicitudVisita> datosPorVisita(HttpSession session) {
        Object existente = session.getAttribute(DATOS_POR_VISITA);
        if (existente instanceof Map<?, ?>) return (Map<Long, SolicitudVisita>) existente;
        Map<Long, SolicitudVisita> mapa = new HashMap<>();
        session.setAttribute(DATOS_POR_VISITA, mapa);
        return mapa;
    }

    private void guardarDatosSolicitud(HttpSession session, Long idVisita, SolicitudVisita solicitud) {
        datosPorVisita(session).put(idVisita, solicitud);
    }

    @SuppressWarnings("unchecked")
    private Set<Long> cartasDescargadas(HttpSession session) {
        Object existente = session.getAttribute(CARTAS_DESCARGADAS);
        if (existente instanceof Set<?>) return (Set<Long>) existente;
        Set<Long> ids = new HashSet<>();
        session.setAttribute(CARTAS_DESCARGADAS, ids);
        return ids;
    }

    private Usuario usuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (Usuario) session.getAttribute("usuario");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String jsp)
            throws ServletException, IOException {
        request.getRequestDispatcher(jsp).forward(request, response);
    }

    private Long id(String valor) {
        Long id = idOpcional(valor);
        if (id == null) throw new IllegalArgumentException("Identificador no válido.");
        return id;
    }

    private Long idOpcional(String valor) {
        if (valor == null || valor.isBlank()) return null;
        try {
            long id = Long.parseLong(valor);
            if (id < 1) throw new NumberFormatException();
            return id;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Identificador no válido.");
        }
    }

    private LocalDate parseFecha(String valor) {
        try {
            return LocalDate.parse(valor);
        } catch (DateTimeParseException exception) {
            throw new IllegalArgumentException("Captura fechas válidas.");
        }
    }

    private int entero(HttpServletRequest request, String nombre, int minimo, int maximo, String mensaje) {
        try {
            int valor = Integer.parseInt(request.getParameter(nombre));
            if (valor < minimo || valor > maximo) throw new NumberFormatException();
            return valor;
        } catch (NumberFormatException | NullPointerException exception) {
            throw new IllegalArgumentException(mensaje);
        }
    }

    private String texto(HttpServletRequest request, String nombre, int maximo, String valorPredeterminado) {
        String valor = request.getParameter(nombre);
        if (valor == null || valor.isBlank()) {
            if (valorPredeterminado != null) return valorPredeterminado;
            throw new IllegalArgumentException("Completa todos los campos obligatorios.");
        }
        valor = valor.trim();
        if (valor.length() > maximo) {
            throw new IllegalArgumentException("Uno de los campos supera el tamaño permitido.");
        }
        return valor;
    }

    private String valor(String actual, String predeterminado) {
        return actual == null || actual.isBlank() ? predeterminado : actual;
    }

    private <T> T requerido(T valor, String mensaje) {
        if (valor == null) throw new IllegalArgumentException(mensaje);
        return valor;
    }
}
