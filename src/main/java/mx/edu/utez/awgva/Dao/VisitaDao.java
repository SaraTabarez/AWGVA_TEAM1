package mx.edu.utez.awgva.Dao;

import mx.edu.utez.awgva.Model.Empresa;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.GrupoVisita;
import mx.edu.utez.awgva.Model.Visita;
import mx.edu.utez.awgva.Utils.DatabaseConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/** Consultas de visitas. Los límites por propietario/división se aplican en SQL. */
import mx.edu.utez.awgva.Model.Empresa;
import mx.edu.utez.awgva.Model.ExpedienteVisita;
import mx.edu.utez.awgva.Model.GrupoVisita;
import mx.edu.utez.awgva.Model.Visita;
import mx.edu.utez.awgva.Utils.DatabaseConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/** Consultas de visitas. Los límites por propietario/división se aplican en SQL. */
public class VisitaDao {

    private static final String BASE_SELECT = "SELECT "
            + "v.ID_VISITA, v.ID_USUARIO_FK, v.ID_DIVISION_FK, v.TITULO_VISITA, "
            + "v.ASIGNATURA_A_REFORZAR, v.DOCENTE_ACOMPANANTE, v.DOCENTE_ENCARGADO, "
            + "v.PROPOSITO_VISITA, v.FECHA_INICIO_VISITA, v.FECHA_FIN_VISITA, "
            + "v.ESTADO, v.MOTIVO_RECHAZO, v.CREADO_EN, "
            + "d.DIVISION AS NOMBRE_DIVISION, "
            + "TRIM(u.NOMBRES || ' ' || u.APELLIDO_PATERNO || ' ' || NVL(u.APELLIDO_MATERNO, '')) AS DOCENTE, "
            + "u.CORREO AS CORREO_DOCENTE, e.NOMBRE_EMPRESA, e.DIRECCION, e.TELEFONO, e.CORREO, "
            + "g.PROGRAMA_EDUCATIVO, g.SEMESTRE, g.NOMBRE_GRUPO, g.NUMERO_ESTUDIANTES, "
            + "rep.ESTADO_REPORTE "
            + "FROM VISITA v "
            + "JOIN USUARIO u ON u.ID_USUARIO = v.ID_USUARIO_FK "
            + "JOIN DIVISION d ON d.ID_DIVISION = v.ID_DIVISION_FK "
            + "JOIN EMPRESA e ON e.ID_EMPRESA = v.ID_EMPRESA_FK "
            + "LEFT JOIN (SELECT ID_VISITA_FK, "
            + "LISTAGG(PROGRAMA_EDUCATIVO, ', ') WITHIN GROUP (ORDER BY ID_GRUPO) AS PROGRAMA_EDUCATIVO, "
            + "LISTAGG(SEMESTRE, ', ') WITHIN GROUP (ORDER BY ID_GRUPO) AS SEMESTRE, "
            + "LISTAGG(NOMBRE_GRUPO, ', ') WITHIN GROUP (ORDER BY ID_GRUPO) AS NOMBRE_GRUPO, "
            + "SUM(NUMERO_ESTUDIANTES) AS NUMERO_ESTUDIANTES "
            + "FROM GRUPO_VISITA GROUP BY ID_VISITA_FK) g ON g.ID_VISITA_FK = v.ID_VISITA "
            + "LEFT JOIN (SELECT ID_VISITA_FK, "
            + "MAX(ESTADO) KEEP (DENSE_RANK LAST ORDER BY SUBIDO_EN) AS ESTADO_REPORTE "
            + "FROM DOCUMENTO WHERE UPPER(TIPO_DOCUMENTO) = 'REPORTE' GROUP BY ID_VISITA_FK) rep "
            + "ON rep.ID_VISITA_FK = v.ID_VISITA ";

    public boolean guardarVisitaCompleta(Visita visita, Empresa empresa, GrupoVisita grupo) {
        return guardarVisitaCompleta(visita, empresa, List.of(grupo));
    }

    public boolean guardarVisitaCompleta(Visita visita, Empresa empresa, List<GrupoVisita> grupos) {
        if (grupos == null || grupos.isEmpty()) return false;
        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                Long idEmpresa = insertarOBuscarEmpresa(connection, empresa);
                visita.setIdEmpresaFk(idEmpresa);
                if (visita.getEstado() == null || visita.getEstado().isBlank()) {
                    visita.setEstado("SOLICITUD_CREADA");
                }

                Long idVisita = insertarVisita(connection, visita);
                for (GrupoVisita grupo : grupos) {
                    grupo.setIdVisitaFk(idVisita);
                    insertarGrupoVisita(connection, grupo);
                }
                connection.commit();
                visita.setIdVisita(idVisita);
                return true;
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible guardar la visita: " + exception.getMessage());
            return false;
        }
    }

    /** Inicio de Administración: todas las solicitudes que todavía están en proceso. */
    public List<ExpedienteVisita> listarTodasActivasAdmin() {
        return consultarLista(BASE_SELECT
                        + "WHERE UPPER(v.ESTADO) <> 'COMPLETADA' ORDER BY v.CREADO_EN DESC",
                statement -> { });
    }

    /** Bandeja Solicitudes de Administración: el expediente permanece aquí hasta que se adjunta el reporte. */
    public List<ExpedienteVisita> listarSolicitudesAdmin() {
        return consultarLista(BASE_SELECT
                + "WHERE UPPER(v.ESTADO) NOT IN ('REPORTE_EN_REVISION','REPORTE_RECHAZADO','COMPLETADA') "
                + "ORDER BY v.CREADO_EN DESC", statement -> { });
    }

    /** Histórico de Administración: únicamente expedientes finalizados con reporte aceptado. */
    public List<ExpedienteVisita> listarHistoricoAdmin() {
        return consultarLista(BASE_SELECT
                + "WHERE UPPER(v.ESTADO) = 'COMPLETADA' AND UPPER(rep.ESTADO_REPORTE) = 'ACEPTADO' "
                + "ORDER BY v.FECHA_FIN_VISITA DESC", statement -> { });
    }

    public List<ExpedienteVisita> listarDelDocente(Long idUsuario) {
        return consultarLista(BASE_SELECT
                        + "WHERE v.ID_USUARIO_FK = ? ORDER BY v.CREADO_EN DESC",
                statement -> statement.setLong(1, idUsuario));
    }

    public List<ExpedienteVisita> listarSolicitudesActivasDocente(Long idUsuario) {
        return consultarLista(BASE_SELECT
                        + "WHERE v.ID_USUARIO_FK = ? "
                        + "AND UPPER(v.ESTADO) NOT IN ('REPORTE_EN_REVISION','REPORTE_RECHAZADO','COMPLETADA') "
                        + "ORDER BY v.CREADO_EN DESC",
                statement -> statement.setLong(1, idUsuario));
    }

    public List<ExpedienteVisita> listarReportesDelDocente(Long idUsuario) {
        return consultarLista(BASE_SELECT
                        + "WHERE v.ID_USUARIO_FK = ? "
                        + "AND (rep.ESTADO_REPORTE IS NOT NULL "
                        + "OR UPPER(v.ESTADO) IN ('REPORTE_EN_REVISION','REPORTE_RECHAZADO')) "
                        + "AND UPPER(v.ESTADO) <> 'COMPLETADA' ORDER BY v.CREADO_EN DESC",
                statement -> statement.setLong(1, idUsuario));
    }

    public List<ExpedienteVisita> listarHistoricoDocente(Long idUsuario) {
        return consultarLista(BASE_SELECT
                        + "WHERE v.ID_USUARIO_FK = ? AND UPPER(v.ESTADO) = 'COMPLETADA' "
                        + "AND UPPER(rep.ESTADO_REPORTE) = 'ACEPTADO' "
                        + "ORDER BY v.FECHA_FIN_VISITA DESC",
                statement -> statement.setLong(1, idUsuario));
    }

    public ExpedienteVisita buscarDelDocente(Long idVisita, Long idUsuario) {
        return consultarUno(BASE_SELECT
                        + "WHERE v.ID_VISITA = ? AND v.ID_USUARIO_FK = ?",
                statement -> {
                    statement.setLong(1, idVisita);
                    statement.setLong(2, idUsuario);
                });
    }

    public int contarDelDocente(Long idUsuario) {
        String sql = "SELECT COUNT(*) FROM VISITA WHERE ID_USUARIO_FK = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, idUsuario);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt(1) : 0;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible contar las visitas: " + exception.getMessage());
            return 0;
        }
    }

    /**
     * Resumen del inicio del Docente en una sola consulta. Antes el Inicio cargaba
     * tres listas completas (con JOIN/LISTAGG) únicamente para obtener sus tamaños.
     * El arreglo devuelto contiene: solicitudes, reportes, histórico.
     */
    public int[] contarResumenDocente(Long idUsuario) {
        String sql = "SELECT "
                + "SUM(CASE WHEN UPPER(v.ESTADO) NOT IN "
                + "('REPORTE_EN_REVISION','REPORTE_RECHAZADO','COMPLETADA') THEN 1 ELSE 0 END) AS SOLICITUDES, "
                + "SUM(CASE WHEN UPPER(v.ESTADO) <> 'COMPLETADA' "
                + "AND (rep.ESTADO_REPORTE IS NOT NULL OR UPPER(v.ESTADO) IN "
                + "('REPORTE_EN_REVISION','REPORTE_RECHAZADO')) THEN 1 ELSE 0 END) AS REPORTES, "
                + "SUM(CASE WHEN UPPER(v.ESTADO) = 'COMPLETADA' "
                + "AND UPPER(rep.ESTADO_REPORTE) = 'ACEPTADO' THEN 1 ELSE 0 END) AS HISTORICO "
                + "FROM VISITA v "
                + "LEFT JOIN (SELECT ID_VISITA_FK, "
                + "MAX(ESTADO) KEEP (DENSE_RANK LAST ORDER BY SUBIDO_EN) AS ESTADO_REPORTE "
                + "FROM DOCUMENTO WHERE UPPER(TIPO_DOCUMENTO) = 'REPORTE' "
                + "GROUP BY ID_VISITA_FK) rep ON rep.ID_VISITA_FK = v.ID_VISITA "
                + "WHERE v.ID_USUARIO_FK = ?";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, idUsuario);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return new int[]{
                            resultSet.getInt("SOLICITUDES"),
                            resultSet.getInt("REPORTES"),
                            resultSet.getInt("HISTORICO")
                    };
                }
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible cargar el resumen del docente: " + exception.getMessage());
        }
        return new int[]{0, 0, 0};
    }

    public List<ExpedienteVisita> listarParaDirector(
            Long idDivision, String busqueda, String lugar, LocalDate fecha,
            String estado, String carrera, boolean soloHistorico
    ) {
        StringBuilder sql = new StringBuilder(BASE_SELECT).append("WHERE v.ID_DIVISION_FK = ? ");
        List<Object> parametros = new ArrayList<>();
        parametros.add(idDivision);

        if (soloHistorico) {
            sql.append("AND UPPER(v.ESTADO) = 'COMPLETADA' ");
        } else {
            sql.append("AND UPPER(v.ESTADO) <> 'COMPLETADA' ");
        }
        if (busqueda != null && !busqueda.isBlank()) {
            sql.append("AND (TO_CHAR(v.ID_VISITA) LIKE ? OR UPPER(e.NOMBRE_EMPRESA) LIKE ? "
                    + "OR UPPER(e.DIRECCION) LIKE ? OR UPPER(g.PROGRAMA_EDUCATIVO) LIKE ?) ");
            String patron = "%" + busqueda.trim().toUpperCase() + "%";
            parametros.add(patron);
            parametros.add(patron);
            parametros.add(patron);
            parametros.add(patron);
        }
        if (lugar != null && !lugar.isBlank()) {
            sql.append("AND UPPER(e.DIRECCION) LIKE ? ");
            parametros.add("%" + lugar.trim().toUpperCase() + "%");
        }
        if (fecha != null) {
            sql.append("AND TRUNC(v.FECHA_INICIO_VISITA) = ? ");
            parametros.add(Date.valueOf(fecha));
        }
        if (estado != null && !estado.isBlank()) {
            sql.append("AND UPPER(v.ESTADO) = ? ");
            parametros.add(normalizarEstado(estado));
        }
        if (carrera != null && !carrera.isBlank()) {
            sql.append("AND EXISTS (SELECT 1 FROM GRUPO_VISITA gf WHERE gf.ID_VISITA_FK = v.ID_VISITA "
                    + "AND UPPER(gf.PROGRAMA_EDUCATIVO) = UPPER(?)) ");
            parametros.add(carrera.trim());
        }
        sql.append("ORDER BY v.CREADO_EN DESC");

        return consultarLista(sql.toString(), statement -> bind(statement, parametros));
    }

    public ExpedienteVisita buscarParaDirector(Long idVisita, Long idDivision) {
        return consultarUno(BASE_SELECT
                        + "WHERE v.ID_VISITA = ? AND v.ID_DIVISION_FK = ?",
                statement -> {
                    statement.setLong(1, idVisita);
                    statement.setLong(2, idDivision);
                });
    }

    /**
     * Registra que el docente inició la descarga/impresión de la solicitud sin firmas.
     * El UPDATE también permite volver a descargar sin hacer retroceder un expediente
     * que ya avanzó a otra etapa.
     */
    public boolean marcarSolicitudDescargada(Long idVisita, Long idUsuario) {
        String sql = "UPDATE VISITA SET "
                + "ESTADO = CASE WHEN UPPER(ESTADO) IN ('PENDIENTE','PENDIENTE_DIRECTOR','SOLICITUD_CREADA') "
                + "THEN 'SOLICITUD_DESCARGADA' ELSE ESTADO END, "
                + "ACTUALIZADO_EN = CURRENT_TIMESTAMP "
                + "WHERE ID_VISITA = ? AND ID_USUARIO_FK = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, idVisita);
            statement.setLong(2, idUsuario);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            System.err.println("No fue posible registrar la descarga de la solicitud: " + exception.getMessage());
            return false;
        }
    }

    /**
     * Registra que el docente descargó la Carta responsiva. Sólo cambia de etapa
     * cuando la solicitud firmada ya fue aceptada o la carta requiere corrección.
     */
    public boolean marcarCartaDescargada(Long idVisita, Long idUsuario) {
        String sql = "UPDATE VISITA SET "
                + "ESTADO = CASE WHEN UPPER(ESTADO) IN ('SOLICITUD_APROBADA_ESTADIAS','CARTA_RECHAZADA_ESTADIAS') "
                + "THEN 'CARTA_DESCARGADA' ELSE ESTADO END, "
                + "ACTUALIZADO_EN = CURRENT_TIMESTAMP "
                + "WHERE ID_VISITA = ? AND ID_USUARIO_FK = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, idVisita);
            statement.setLong(2, idUsuario);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            System.err.println("No fue posible registrar la descarga de la carta responsiva: " + exception.getMessage());
            return false;
        }
    }

    public boolean marcarOficioGenerado(Long idVisita, Long idUsuario) {
        String sql = "UPDATE VISITA SET ESTADO = 'OFICIO_GENERADO', ACTUALIZADO_EN = CURRENT_TIMESTAMP "
                + "WHERE ID_VISITA = ? AND ID_USUARIO_FK = ? "
                + "AND UPPER(ESTADO) IN ('CARTA_APROBADA_ESTADIAS','OFICIO_GENERADO')";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, idVisita);
            statement.setLong(2, idUsuario);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            System.err.println("No fue posible registrar el oficio: " + exception.getMessage());
            return false;
        }
    }

    /** Histórico de Estadías: únicamente visitas finalizadas cuyo reporte fue aceptado. */
    public List<ExpedienteVisita> listarHistoricoEstadias(String busqueda) {
        StringBuilder sql = new StringBuilder(BASE_SELECT)
                .append("WHERE UPPER(v.ESTADO) = 'COMPLETADA' ")
                .append("AND UPPER(rep.ESTADO_REPORTE) = 'ACEPTADO' ");
        List<Object> parametros = new ArrayList<>();
        if (busqueda != null && !busqueda.isBlank()) {
            sql.append("AND (TO_CHAR(v.ID_VISITA) LIKE ? OR UPPER(e.NOMBRE_EMPRESA) LIKE ? "
                    + "OR UPPER(d.DIVISION) LIKE ? OR UPPER(g.PROGRAMA_EDUCATIVO) LIKE ?) ");
            String patron = "%" + busqueda.trim().toUpperCase() + "%";
            parametros.add(patron);
            parametros.add(patron);
            parametros.add(patron);
            parametros.add(patron);
        }
        sql.append("ORDER BY v.FECHA_FIN_VISITA DESC, v.CREADO_EN DESC");
        return consultarLista(sql.toString(), statement -> bind(statement, parametros));
    }

    public ExpedienteVisita buscarParaEstadias(Long idVisita) {
        return consultarUno(BASE_SELECT + "WHERE v.ID_VISITA = ?",
                statement -> statement.setLong(1, idVisita));
    }

    public List<GrupoVisita> listarGrupos(Long idVisita) {
        List<GrupoVisita> grupos = new ArrayList<>();
        String sql = "SELECT ID_GRUPO, ID_VISITA_FK, PROGRAMA_EDUCATIVO, SEMESTRE, "
                + "NOMBRE_GRUPO, NUMERO_ESTUDIANTES FROM GRUPO_VISITA "
                + "WHERE ID_VISITA_FK = ? ORDER BY ID_GRUPO";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, idVisita);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    GrupoVisita grupo = new GrupoVisita();
                    grupo.setIdGrupo(resultSet.getLong("ID_GRUPO"));
                    grupo.setIdVisitaFk(resultSet.getLong("ID_VISITA_FK"));
                    grupo.setProgramaEducativo(resultSet.getString("PROGRAMA_EDUCATIVO"));
                    grupo.setSemestre(resultSet.getString("SEMESTRE"));
                    grupo.setNombreGrupo(resultSet.getString("NOMBRE_GRUPO"));
                    grupo.setNumeroEstudiantes(resultSet.getInt("NUMERO_ESTUDIANTES"));
                    grupos.add(grupo);
                }
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible consultar el desglose de alumnos: " + exception.getMessage());
        }
        return grupos;
    }

    /** Compatibilidad con módulos existentes del ZIP 3. */
    public List<Visita> obtenerVisitasPorUsuario(Long idUsuario) {
        List<Visita> visitas = new ArrayList<>();
        for (ExpedienteVisita expediente : listarDelDocente(idUsuario)) {
            Visita visita = new Visita();
            visita.setIdVisita(expediente.getIdVisita());
            visita.setIdUsuarioFk(expediente.getIdUsuario());
            visita.setIdDivisionFk(expediente.getIdDivision());
            visita.setTituloVisita(expediente.getTitulo());
            visita.setAsignaturaAReforzar(expediente.getAsignatura());
            visita.setFechaInicioVisita(expediente.getFechaInicio());
            visita.setFechaFinVisita(expediente.getFechaFin());
            visita.setEstado(expediente.getEstado());
            visita.setCreadoEn(expediente.getCreadoEn());
            visitas.add(visita);
        }
        return visitas;
    }

    private Long insertarOBuscarEmpresa(Connection connection, Empresa empresa) throws SQLException {
        String selectSql = "SELECT ID_EMPRESA FROM EMPRESA WHERE UPPER(NOMBRE_EMPRESA) = UPPER(?)";
        try (PreparedStatement statement = connection.prepareStatement(selectSql)) {
            statement.setString(1, empresa.getNombreEmpresa());
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) return resultSet.getLong("ID_EMPRESA");
            }
        }

        String insertSql = "INSERT INTO EMPRESA (NOMBRE_EMPRESA, DIRECCION, TELEFONO, CORREO) "
                + "VALUES (?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(insertSql, new String[]{"ID_EMPRESA"})) {
            statement.setString(1, empresa.getNombreEmpresa());
            statement.setString(2, empresa.getDireccion());
            statement.setString(3, empresa.getTelefono());
            statement.setString(4, empresa.getCorreo());
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getLong(1);
            }
        }
        throw new SQLException("Oracle no devolvió el ID de la empresa.");
    }

    private Long insertarVisita(Connection connection, Visita visita) throws SQLException {
        String sql = "INSERT INTO VISITA "
                + "(ID_USUARIO_FK, ID_DIVISION_FK, ID_EMPRESA_FK, TITULO_VISITA, "
                + "ASIGNATURA_A_REFORZAR, DOCENTE_ACOMPANANTE, DOCENTE_ENCARGADO, "
                + "PROPOSITO_VISITA, FECHA_INICIO_VISITA, FECHA_FIN_VISITA, ESTADO) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql, new String[]{"ID_VISITA"})) {
            statement.setLong(1, visita.getIdUsuarioFk());
            statement.setLong(2, visita.getIdDivisionFk());
            statement.setLong(3, visita.getIdEmpresaFk());
            statement.setString(4, visita.getTituloVisita());
            statement.setString(5, visita.getAsignaturaAReforzar());
            statement.setString(6, visita.getDocenteAcompanante());
            statement.setString(7, visita.getDocenteEncargado());
            statement.setString(8, visita.getPropositoVisita());
            statement.setDate(9, Date.valueOf(visita.getFechaInicioVisita()));
            statement.setDate(10, Date.valueOf(visita.getFechaFinVisita()));
            statement.setString(11, visita.getEstado());
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getLong(1);
            }
        }
        throw new SQLException("Oracle no devolvió el ID de la visita.");
    }

    private void insertarGrupoVisita(Connection connection, GrupoVisita grupo) throws SQLException {
        String sql = "INSERT INTO GRUPO_VISITA "
                + "(ID_VISITA_FK, PROGRAMA_EDUCATIVO, SEMESTRE, NOMBRE_GRUPO, NUMERO_ESTUDIANTES) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, grupo.getIdVisitaFk());
            statement.setString(2, grupo.getProgramaEducativo());
            statement.setString(3, grupo.getSemestre());
            statement.setString(4, grupo.getNombreGrupo());
            statement.setInt(5, grupo.getNumeroEstudiantes());
            statement.executeUpdate();
        }
    }

    private List<ExpedienteVisita> consultarLista(String sql, SqlBinder binder) {
        List<ExpedienteVisita> resultado = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            binder.bind(statement);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) resultado.add(mapExpediente(resultSet));
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible consultar las visitas: " + exception.getMessage());
        }
        return resultado;
    }

    private ExpedienteVisita consultarUno(String sql, SqlBinder binder) {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            binder.bind(statement);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapExpediente(resultSet) : null;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible consultar la visita: " + exception.getMessage());
            return null;
        }
    }

    private ExpedienteVisita mapExpediente(ResultSet resultSet) throws SQLException {
        ExpedienteVisita item = new ExpedienteVisita();
        item.setIdVisita(resultSet.getLong("ID_VISITA"));
        item.setIdUsuario(resultSet.getLong("ID_USUARIO_FK"));
        item.setIdDivision(resultSet.getLong("ID_DIVISION_FK"));
        item.setDivision(resultSet.getString("NOMBRE_DIVISION"));
        item.setDocente(resultSet.getString("DOCENTE"));
        item.setCorreoDocente(resultSet.getString("CORREO_DOCENTE"));
        item.setTitulo(resultSet.getString("TITULO_VISITA"));
        item.setAsignatura(resultSet.getString("ASIGNATURA_A_REFORZAR"));
        item.setDocenteAcompanante(resultSet.getString("DOCENTE_ACOMPANANTE"));
        item.setProposito(resultSet.getString("PROPOSITO_VISITA"));
        item.setFechaInicio(toLocalDate(resultSet.getDate("FECHA_INICIO_VISITA")));
        item.setFechaFin(toLocalDate(resultSet.getDate("FECHA_FIN_VISITA")));
        item.setEstado(resultSet.getString("ESTADO"));
        item.setMotivoRechazo(resultSet.getString("MOTIVO_RECHAZO"));
        Timestamp creado = resultSet.getTimestamp("CREADO_EN");
        item.setCreadoEn(creado == null ? null : creado.toLocalDateTime());
        item.setEmpresa(resultSet.getString("NOMBRE_EMPRESA"));
        item.setDireccionEmpresa(resultSet.getString("DIRECCION"));
        item.setTelefonoEmpresa(resultSet.getString("TELEFONO"));
        item.setCorreoEmpresa(resultSet.getString("CORREO"));
        item.setCarrera(resultSet.getString("PROGRAMA_EDUCATIVO"));
        item.setSemestre(resultSet.getString("SEMESTRE"));
        item.setGrupo(resultSet.getString("NOMBRE_GRUPO"));
        int estudiantes = resultSet.getInt("NUMERO_ESTUDIANTES");
        item.setNumeroEstudiantes(resultSet.wasNull() ? null : estudiantes);
        item.setEstadoReporte(resultSet.getString("ESTADO_REPORTE"));
        return item;
    }

    private String normalizarEstado(String estado) {
        return switch (estado.trim().toUpperCase()) {
            case "PENDIENTE" -> "SOLICITUD_CREADA";
            case "ENVIADA" -> "SOLICITUD_EN_REVISION";
            case "ACEPTADA" -> "SOLICITUD_APROBADA_ESTADIAS";
            case "RECHAZADA" -> "SOLICITUD_RECHAZADA_ESTADIAS";
            default -> estado.trim().toUpperCase();
        };
    }

    private LocalDate toLocalDate(Date date) {
        return date == null ? null : date.toLocalDate();
    }

    private void bind(PreparedStatement statement, List<Object> values) throws SQLException {
        for (int index = 0; index < values.size(); index++) {
            statement.setObject(index + 1, values.get(index));
        }
    }

    @FunctionalInterface
    private interface SqlBinder {
        void bind(PreparedStatement statement) throws SQLException;
    }
}
