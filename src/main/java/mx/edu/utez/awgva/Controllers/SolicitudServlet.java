package mx.edu.utez.awgva.Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mx.edu.utez.awgva.Model.Empresa;
import mx.edu.utez.awgva.Model.GrupoVisita;
import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Model.Visita;
import mx.edu.utez.awgva.Service.VisitaService;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet(name = "SolicitudServlet", value = "/solicitud-servlet")
public class SolicitudServlet extends HttpServlet {

    private VisitaService visitaService;

    @Override
    public void init() throws ServletException {
        this.visitaService = new VisitaService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Usuario usuario = (Usuario) (session != null ? session.getAttribute("usuario") : null);

        if (usuario == null || usuario.getIdDivisionFk() == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "El usuario no tiene división asignada.");
            return;
        }

        // Obtener parámetros del formulario
        String tituloVisita = request.getParameter("tituloVisita");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");
        String asignatura = request.getParameter("asignatura");
        String division = request.getParameter("division");
        String docenteEncargado = request.getParameter("docenteEncargado");
        String docenteAcompanante = request.getParameter("docenteAcompanante");
        String proposito = request.getParameter("proposito");

        String nombreEmpresa = request.getParameter("nombreEmpresa");
        String telefonoEmpresa = request.getParameter("telefonoEmpresa");
        String correoEmpresa = request.getParameter("correoEmpresa");
        String direccionEmpresa = request.getParameter("direccionEmpresa");

        String programaEducativo = request.getParameter("programaEducativo");
        String semestre = request.getParameter("semestre");
        String nombreGrupo = request.getParameter("nombreGrupo");
        String numeroEstudiantes = request.getParameter("numeroEstudiantes");

        // Validar campos requeridos
        if (tituloVisita == null || tituloVisita.isBlank() || fechaInicio == null || fechaInicio.isBlank() ||
                fechaFin == null || fechaFin.isBlank() || asignatura == null || asignatura.isBlank() ||
                division == null || division.isBlank() || docenteEncargado == null || docenteEncargado.isBlank() ||
                proposito == null || proposito.isBlank() || nombreEmpresa == null || nombreEmpresa.isBlank() ||
                programaEducativo == null || programaEducativo.isBlank() || semestre == null || semestre.isBlank() ||
                nombreGrupo == null || nombreGrupo.isBlank() || numeroEstudiantes == null || numeroEstudiantes.isBlank()) {

            request.setAttribute("error", "Por favor, completa todos los campos requeridos.");
            request.getRequestDispatcher("nueva-solicitud.jsp").forward(request, response);
            return;
        }

        // Crear objetos del modelo
        Visita visita = new Visita();
        visita.setIdUsuarioFk(usuario.getIdUsuario());
        // La división proviene de la sesión autenticada; no se confía en un ID enviado por el navegador.
        visita.setIdDivisionFk(usuario.getIdDivisionFk());
        visita.setTituloVisita(tituloVisita);
        visita.setAsignaturaAReforzar(asignatura);
        visita.setDocenteEncargado(docenteEncargado);
        visita.setDocenteAcompanante(docenteAcompanante != null ? docenteAcompanante : "");
        visita.setPropositoVisita(proposito);
        visita.setFechaInicioVisita(LocalDate.parse(fechaInicio));
        visita.setFechaFinVisita(LocalDate.parse(fechaFin));

        Empresa empresa = new Empresa();
        empresa.setNombreEmpresa(nombreEmpresa);
        empresa.setTelefono(telefonoEmpresa != null ? telefonoEmpresa : "");
        empresa.setCorreo(correoEmpresa != null ? correoEmpresa : "");
        empresa.setDireccion(direccionEmpresa != null ? direccionEmpresa : "");

        GrupoVisita grupoVisita = new GrupoVisita();
        grupoVisita.setProgramaEducativo(programaEducativo);
        grupoVisita.setSemestre(semestre);
        grupoVisita.setNombreGrupo(nombreGrupo);
        grupoVisita.setNumeroEstudiantes(Integer.parseInt(numeroEstudiantes));

        // Guardar en base de datos
        boolean exito = visitaService.crearVisitaCompleta(visita, empresa, grupoVisita);

        if (exito) {
            response.sendRedirect(request.getContextPath() + "/inicio");
        } else {
            request.setAttribute("error", "Error al crear la solicitud. Intente nuevamente.");
            request.getRequestDispatcher("nueva-solicitud.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/nueva-solicitud.jsp");
    }
}