package mx.edu.utez.awgva.Service;
import mx.edu.utez.awgva.Dao.VisitaDao;
import mx.edu.utez.awgva.Model.Empresa;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.GrupoVisita;
import mx.edu.utez.awgva.Model.Visita;

import java.time.LocalDate;
import java.util.List;

public class VisitaService {

    private VisitaDao visitaDao;

    public VisitaService() {
        this.visitaDao = new VisitaDao();
    }

    public boolean crearVisitaCompleta(Visita visita, Empresa empresa, GrupoVisita grupoVisita) {
        return visitaDao.guardarVisitaCompleta(visita, empresa, grupoVisita);
    }

    public boolean crearVisitaCompleta(Visita visita, Empresa empresa, List<GrupoVisita> grupos) {
        return visitaDao.guardarVisitaCompleta(visita, empresa, grupos);
    }

    public List<Visita> obtenerVisitasPorUsuario(Long idUsuario) {
        return visitaDao.obtenerVisitasPorUsuario(idUsuario);
    }

    public List<ExpedienteVisita> listarTodasActivasAdmin() {
        return visitaDao.listarTodasActivasAdmin();
    }

    public List<ExpedienteVisita> listarSolicitudesAdmin() {
        return visitaDao.listarSolicitudesAdmin();
    }

    public List<ExpedienteVisita> listarHistoricoAdmin() {
        return visitaDao.listarHistoricoAdmin();
    }

    public List<ExpedienteVisita> listarDelDocente(Long idUsuario) {
        return visitaDao.listarDelDocente(idUsuario);
    }

    public List<ExpedienteVisita> listarSolicitudesActivasDocente(Long idUsuario) {
        return visitaDao.listarSolicitudesActivasDocente(idUsuario);
    }

    public List<ExpedienteVisita> listarReportesDelDocente(Long idUsuario) {
        return visitaDao.listarReportesDelDocente(idUsuario);
    }

    public List<ExpedienteVisita> listarHistoricoDocente(Long idUsuario) {
        return visitaDao.listarHistoricoDocente(idUsuario);
    }

    public ExpedienteVisita buscarDelDocente(Long idVisita, Long idUsuario) {
        return visitaDao.buscarDelDocente(idVisita, idUsuario);
    }

    public List<GrupoVisita> listarGrupos(Long idVisita) {
        return visitaDao.listarGrupos(idVisita);
    }

    public int contarDelDocente(Long idUsuario) {
        return visitaDao.contarDelDocente(idUsuario);
    }

    public List<ExpedienteVisita> listarParaDirector(
            Long division, String busqueda, String lugar, LocalDate fecha,
            String estado, String carrera, boolean historico
    ) {
        return visitaDao.listarParaDirector(division, busqueda, lugar, fecha, estado, carrera, historico);
    }

    public ExpedienteVisita buscarParaDirector(Long idVisita, Long division) {
        return visitaDao.buscarParaDirector(idVisita, division);
    }

    public boolean marcarSolicitudDescargada(Long idVisita, Long idUsuario) {
        return visitaDao.marcarSolicitudDescargada(idVisita, idUsuario);
    }

    public boolean marcarCartaDescargada(Long idVisita, Long idUsuario) {
        return visitaDao.marcarCartaDescargada(idVisita, idUsuario);
    }

    public List<ExpedienteVisita> listarHistoricoEstadias(String busqueda) {
        return visitaDao.listarHistoricoEstadias(busqueda);
    }

    public ExpedienteVisita buscarParaEstadias(Long idVisita) {
        return visitaDao.buscarParaEstadias(idVisita);
    }

    public boolean marcarOficioGenerado(Long idVisita, Long idUsuario) {
        return visitaDao.marcarOficioGenerado(idVisita, idUsuario);
    }
}