package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.CatalogoCarreras;
import mx.edu.utez.awgva.Model.Documento;
import mx.edu.utez.awgva.Model.DetalleGrupoSolicitud;
import mx.edu.utez.awgva.Model.Empresa;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.GrupoVisita;
import mx.edu.utez.awgva.Model.SolicitudVisita;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Model.Visita;
import mx.edu.utez.awgva.Service.DocumentoService;
import mx.edu.utez.awgva.Service.FirmanteService;
import mx.edu.utez.awgva.Service.VisitaService;
import mx.edu.utez.awgva.Utils.RecordTokenUtil;
import mx.edu.utez.awgva.Utils.TokenViewUtil;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
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

    private final VisitaService visitaService = new VisitaService();
    private final DocumentoService documentoService = new DocumentoService();
    private final FirmanteService firmanteService = new FirmanteService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        switch (request.getServletPath()) {
            case "/mis-solicitudes",
                 "/nueva-solicitud",
                 "/solicitud-previa",
                 "/detalle-solicitud",
                 "/carta-responsiva",
                 "/oficio-autorizacion",
                 "/subir-solicitud-firmada",
                 "/subir-carta-firmada",
                 "/reportes-docente",
                 "/historico-docente",
                 "/reporte-docente" -> handleView(request, response);
            default -> response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    private void handleView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = usuario(request);
        try {
            switch (request.getServletPath()) {
                case "/mis-solicitudes" -> {
                    List<ExpedienteVisita> items = visitaService.listarSolicitudesActivasDocente(usuario.getIdUsuario());
                    decorate(request, usuario, items);
                    request.setAttribute("solicitudes", items);
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
                    List<ExpedienteVisita> items = visitaService.listarReportesDelDocente(usuario.getIdUsuario());
                    decorate(request, usuario, items);
                    request.setAttribute("solicitudes", items);
                    forward(request, response, "/subir-docs.jsp");
                }
                case "/historico-docente" -> {
                    List<ExpedienteVisita> items = visitaService.listarHistoricoDocente(usuario.getIdUsuario());
                    decorate(request, usuario, items);
                    request.setAttribute("solicitudes", items);
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
                case "/mis-solicitudes", "/solicitud-previa", "/detalle-solicitud",
                     "/carta-responsiva", "/oficio-autorizacion", "/subir-solicitud-firmada",
                     "/subir-carta-firmada", "/reportes-docente", "/historico-docente",
                     "/reporte-docente" -> handleView(request, response);
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
            throws IOException, ServletException {
        SolicitudVisita borrador = leerFormulario(request, usuario);
        request.getSession().setAttribute(BORRADOR_SOLICITUD, borrador);
        mostrarPrevia(request, response, usuario);
    }

    private void mostrarPrevia(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        SolicitudVisita solicitud;
        Long idVisita = request.getParameter("ref") == null ? null : visitaId(request, usuario);
        if (idVisita == null) {
            solicitud = (SolicitudVisita) request.getSession().getAttribute(BORRADOR_SOLICITUD);
            if (solicitud == null) {
                request.setAttribute("carreras", CatalogoCarreras.deDivision(usuario.getNombreDivision()));
                forward(request, response, "/nueva-solicitud.jsp");
                return;
            }
        } else {
            ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
            solicitud = datosSolicitud(expediente, usuario, request.getSession());
            request.setAttribute("expediente", expediente);
        }
        request.setAttribute("solicitud", solicitud);
        if (idVisita != null) request.setAttribute("referenceToken",
                RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(), "docente-visita", idVisita));
        request.setAttribute("divisionDocente", usuario.getNombreDivision());
        request.setAttribute("firmantes", firmanteService.load());
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
        visita.setEstado("SOLICITUD_CREADA");

        Empresa empresa = new Empresa(solicitud.getEmpresaNombre(), solicitud.getEmpresaDireccion(),
                solicitud.getEmpresaTelefono(), solicitud.getEmpresaEmail());
        List<GrupoVisita> grupos = new ArrayList<>();
        for (DetalleGrupoSolicitud detalle : solicitud.getGrupos()) {
            GrupoVisita grupo = new GrupoVisita(null, detalle.getCarrera(), detalle.getCuatrimestre(),
                    detalle.getGrupo(), detalle.getCantidadAlumnos());
            grupo.setArea(detalle.getArea());
            grupos.add(grupo);
        }

        if (!visitaService.crearVisitaCompleta(visita, empresa, grupos) || visita.getIdVisita() == null) {
            throw new IllegalStateException("No fue posible guardar la solicitud. Revisa la conexión con Oracle.");
        }

        guardarDatosSolicitud(session, visita.getIdVisita(), solicitud);
        session.removeAttribute(BORRADOR_SOLICITUD);
        request.setAttribute("solicitud", solicitud);
        request.setAttribute("referenceToken", RecordTokenUtil.issue(request.getSession(),
                usuario.getIdUsuario(), "docente-visita", visita.getIdVisita()));
        request.setAttribute("divisionDocente", usuario.getNombreDivision());
        request.setAttribute("firmantes", firmanteService.load());
        request.setAttribute("autoPrint", true);
        forward(request, response, "/solicitud-previa.jsp");
    }

    private void mostrarDetallePropio(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {
        Long idVisita = visitaId(request, usuario);
        ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
        expediente.setDocumentos(documentoService.listarPorVisita(idVisita));

        Documento solicitudFirmada = documentoService.buscarPorVisitaYTipo(idVisita, "SOLICITUD_VISITA");
        Documento cartaFirmada = documentoService.buscarPorVisitaYTipo(idVisita, "CARTA_RESPONSIVA");
        TokenViewUtil.decorateDocuments(request, usuario, expediente.getDocumentos());
        TokenViewUtil.decorateDocument(request, usuario, solicitudFirmada);
        TokenViewUtil.decorateDocument(request, usuario, cartaFirmada);
        String estadoActual = expediente.getEstado() == null
                ? "" : expediente.getEstado().trim().toUpperCase(Locale.ROOT);
        boolean cartaDescargada = cartaFirmada != null || Set.of(
                "CARTA_DESCARGADA", "CARTA_EN_REVISION", "CARTA_APROBADA_ESTADIAS",
                "OFICIO_GENERADO", "REPORTE_EN_REVISION", "REPORTE_RECHAZADO", "COMPLETADA"
        ).contains(estadoActual);

        request.setAttribute("expediente", expediente);
        expediente.setReferenceToken(RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(),
                "docente-visita", idVisita));
        request.setAttribute("solicitudFirmada", solicitudFirmada);
        request.setAttribute("cartaFirmada", cartaFirmada);
        request.setAttribute("cartaDescargada", cartaDescargada);
        forward(request, response, "/solicitud-detalle.jsp");
    }

    private void mostrarDocumentoGenerado(HttpServletRequest request, HttpServletResponse response,
                                          Usuario usuario, String jsp)
            throws ServletException, IOException {
        Long idVisita = visitaId(request, usuario);
        ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
        String state = expediente.getEstado() == null ? "" : expediente.getEstado().toUpperCase(Locale.ROOT);
        if ("/cartaResponsiva.jsp".equals(jsp)
                && !Set.of("SOLICITUD_APROBADA_ESTADIAS", "CARTA_DESCARGADA", "CARTA_EN_REVISION",
                "CARTA_RECHAZADA_ESTADIAS", "CARTA_APROBADA_ESTADIAS", "OFICIO_GENERADO",
                "REPORTE_EN_REVISION", "REPORTE_RECHAZADO", "COMPLETADA").contains(state)) {
            throw new IllegalStateException("La carta responsiva se habilita cuando el departamento correspondiente acepta la solicitud firmada.");
        }
        if ("/oficio-autorizacion.jsp".equals(jsp)) {
            if (!Set.of("CARTA_APROBADA_ESTADIAS", "OFICIO_GENERADO", "REPORTE_EN_REVISION",
                    "REPORTE_RECHAZADO", "COMPLETADA").contains(state)) {
                throw new IllegalStateException("El oficio se habilita cuando el departamento correspondiente acepta la carta responsiva.");
            }
            if ("CARTA_APROBADA_ESTADIAS".equals(state)
                    && !visitaService.marcarOficioGenerado(idVisita, usuario.getIdUsuario())) {
                throw new IllegalStateException("No fue posible registrar la generación del oficio.");
            }
            expediente = expedientePropio(idVisita, usuario);
        }
        expediente.setReferenceToken(RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(),
                "docente-visita", idVisita));
        request.setAttribute("expediente", expediente);
        request.setAttribute("solicitud", datosSolicitud(expediente, usuario, request.getSession()));
        request.setAttribute("firmantes", firmanteService.load());
        forward(request, response, jsp);
    }

    private void mostrarCargaDocumento(HttpServletRequest request, HttpServletResponse response,
                                       Usuario usuario, String tipo, String jsp)
            throws ServletException, IOException {
        Long idVisita = visitaId(request, usuario);
        ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
        String state = expediente.getEstado() == null ? "" : expediente.getEstado().toUpperCase(Locale.ROOT);
        if ("SOLICITUD_VISITA".equals(tipo)
                && !Set.of("SOLICITUD_DESCARGADA", "SOLICITUD_RECHAZADA_ESTADIAS",
                "ACEPTADA_DIRECTOR").contains(state))
            throw new IllegalStateException(
                    "Primero descarga la solicitud sin firmas; después podrás subirla firmada.");
        if ("CARTA_RESPONSIVA".equals(tipo)
                && !Set.of("CARTA_DESCARGADA", "CARTA_RECHAZADA_ESTADIAS").contains(state))
            throw new IllegalStateException(
                    "Primero descarga la carta responsiva; después podrás subirla firmada.");
        expediente.setReferenceToken(RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(),
                "docente-visita", idVisita));
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
        Long idVisita = visitaId(request, usuario);
        ExpedienteVisita expediente = expedientePropio(idVisita, usuario);
        String state = expediente.getEstado() == null ? "" : expediente.getEstado().toUpperCase(Locale.ROOT);
        if (!Set.of("CARTA_APROBADA_ESTADIAS", "OFICIO_GENERADO", "REPORTE_EN_REVISION",
                "REPORTE_RECHAZADO").contains(state))
            throw new IllegalStateException("El reporte se habilita cuando la carta responsiva fue aceptada.");
        expediente.setReferenceToken(RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(),
                "docente-visita", idVisita));
        expediente.setDocumentos(documentoService.listarEvidenciasReporte(idVisita));
        TokenViewUtil.decorateDocuments(request, usuario, expediente.getDocumentos());
        request.setAttribute("expediente", expediente);
        Documento reporte = documentoService.buscarPorVisitaYTipo(idVisita, "REPORTE");
        TokenViewUtil.decorateDocument(request, usuario, reporte);
        request.setAttribute("reporte", reporte);
        String mensaje = (String) request.getSession().getAttribute("mensajeCarga");
        if (mensaje != null) {
            request.setAttribute("error", mensaje);
            request.getSession().removeAttribute("mensajeCarga");
        }
        forward(request, response, "/llenar-reporte.jsp");
    }

    private void marcarDescarga(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {
        Long idVisita = visitaId(request, usuario);
        expedientePropio(idVisita, usuario);
        String tipo = request.getParameter("tipo");

        boolean registrado;
        if ("SOLICITUD_VISITA".equals(tipo)) {
            registrado = visitaService.marcarSolicitudDescargada(idVisita, usuario.getIdUsuario());
        } else if ("CARTA_RESPONSIVA".equals(tipo)) {
            registrado = visitaService.marcarCartaDescargada(idVisita, usuario.getIdUsuario());
        } else {
            throw new IllegalArgumentException("Tipo de descarga no válido.");
        }

        if (!registrado) {
            throw new IllegalStateException("No fue posible registrar la descarga del documento.");
        }
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    private SolicitudVisita leerFormulario(HttpServletRequest request, Usuario usuario) {
        SolicitudVisita solicitud = new SolicitudVisita();
        solicitud.setSolicitanteNombre(usuario.getNombreCompleto());
        solicitud.setSolicitanteCargo(usuario.getTipoRol().map(Enum::name).orElse("DOCENTE"));
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

        List<DetalleGrupoSolicitud> grupos = leerGrupos(request, usuario);
        solicitud.setGrupos(grupos);
        DetalleGrupoSolicitud primero = grupos.get(0);
        solicitud.setProgramaEducativo(primero.getCarrera());
        solicitud.setSemestre(primero.getCuatrimestre());
        solicitud.setGrupo(primero.getGrupo());
        int total = grupos.stream().mapToInt(DetalleGrupoSolicitud::getCantidadAlumnos).sum();
        solicitud.setDacea("0");
        solicitud.setDatefi("0");
        solicitud.setDatid("0");
        solicitud.setDami("0");
        String area = valor(usuario.getNombreDivision(), "").toUpperCase(Locale.ROOT);
        if (area.contains("DACEA")) solicitud.setDacea(String.valueOf(total));
        else if (area.contains("DATEFI")) solicitud.setDatefi(String.valueOf(total));
        else if (area.contains("DATID")) solicitud.setDatid(String.valueOf(total));
        else if (area.contains("DAMI")) solicitud.setDami(String.valueOf(total));
        solicitud.setTotalEstudiantes(String.valueOf(total));
        solicitud.setAsignaturas(texto(request, "asignaturas", 500, null));

        LocalDate inicio = parseFecha(solicitud.getFechaInicio());
        LocalDate fin = parseFecha(solicitud.getFechaTermino());
        if (fin.isBefore(inicio)) {
            throw new IllegalArgumentException("La fecha de término no puede ser anterior a la fecha de inicio.");
        }
        return solicitud;
    }

    private List<DetalleGrupoSolicitud> leerGrupos(HttpServletRequest request, Usuario usuario) {
        String[] carreras = request.getParameterValues("carrera");
        String[] areas = request.getParameterValues("area");
        String[] cuatrimestres = request.getParameterValues("cuatrimestre");
        String[] grupos = request.getParameterValues("grupoNombre");
        String[] cantidades = request.getParameterValues("cantidadAlumnos");
        if (carreras == null || areas == null || cuatrimestres == null || grupos == null
                || cantidades == null || carreras.length == 0 || carreras.length > 10
                || areas.length != carreras.length || cuatrimestres.length != carreras.length
                || grupos.length != carreras.length || cantidades.length != carreras.length) {
            throw new IllegalArgumentException("Agrega al menos un grupo completo.");
        }
        List<DetalleGrupoSolicitud> result = new ArrayList<>();
        int total = 0;
        for (int index = 0; index < carreras.length; index++) {
            String carrera = carreras[index] == null ? "" : carreras[index].trim();
            String area = areas[index] == null ? "" : areas[index].trim();
            String cuatrimestre = cuatrimestres[index] == null ? "" : cuatrimestres[index].trim();
            String grupo = grupos[index] == null ? "" : grupos[index].trim();
            if (!CatalogoCarreras.pertenece(usuario.getNombreDivision(), carrera)) {
                throw new IllegalArgumentException("Selecciona carreras pertenecientes a tu división.");
            }
            if (!area.equalsIgnoreCase(valor(usuario.getNombreDivision(), ""))) {
                throw new IllegalArgumentException("El área debe coincidir con la división de tu cuenta.");
            }
            if (cuatrimestre.isBlank() || cuatrimestre.length() > 30
                    || grupo.isBlank() || grupo.length() > 30) {
                throw new IllegalArgumentException("Completa cuatrimestre y grupo.");
            }
            int alumnos;
            try { alumnos = Integer.parseInt(cantidades[index]); }
            catch (NumberFormatException exception) { throw new IllegalArgumentException("Captura cantidades válidas."); }
            if (alumnos < 1 || alumnos > 200 || total + alumnos > 200) {
                throw new IllegalArgumentException("La cantidad total de alumnos debe estar entre 1 y 200.");
            }
            total += alumnos;
            DetalleGrupoSolicitud item = new DetalleGrupoSolicitud();
            item.setCarrera(carrera);
            item.setArea(area);
            item.setCuatrimestre(cuatrimestre);
            item.setGrupo(grupo);
            item.setCantidadAlumnos(alumnos);
            result.add(item);
        }
        return result;
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
        solicitud.setSolicitanteCargo(usuario.getTipoRol().map(Enum::name).orElse("DOCENTE"));
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
        List<DetalleGrupoSolicitud> detalles = new ArrayList<>();
        for (GrupoVisita grupo : visitaService.listarGrupos(expediente.getIdVisita())) {
            DetalleGrupoSolicitud detalle = new DetalleGrupoSolicitud();
            detalle.setCarrera(grupo.getProgramaEducativo());
            detalle.setArea(valor(expediente.getDivision(), usuario.getNombreDivision()));
            detalle.setCuatrimestre(grupo.getSemestre());
            detalle.setGrupo(grupo.getNombreGrupo());
            detalle.setCantidadAlumnos(grupo.getNumeroEstudiantes());
            detalles.add(detalle);
        }
        if (detalles.isEmpty()) {
            DetalleGrupoSolicitud detalle = new DetalleGrupoSolicitud();
            detalle.setCarrera(expediente.getCarrera());
            detalle.setArea(valor(expediente.getDivision(), usuario.getNombreDivision()));
            detalle.setCuatrimestre(expediente.getSemestre());
            detalle.setGrupo(expediente.getGrupo());
            detalle.setCantidadAlumnos(total);
            detalles.add(detalle);
        }
        solicitud.setGrupos(detalles);
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

    private Long visitaId(HttpServletRequest request, Usuario usuario) {
        return RecordTokenUtil.requireId(request.getSession(false), usuario.getIdUsuario(),
                "docente-visita", request.getParameter("ref"));
    }

    private void decorate(HttpServletRequest request, Usuario usuario, List<ExpedienteVisita> items) {
        for (ExpedienteVisita item : items) {
            item.setReferenceToken(RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(),
                    "docente-visita", item.getIdVisita()));
        }
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