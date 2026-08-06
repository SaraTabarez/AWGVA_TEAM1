package mx.edu.utez.awgva.Dao;

import mx.edu.utez.awgva.Model.Documento;
import mx.edu.utez.awgva.Utils.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/** Persistencia de documentos y evidencias, con un archivo vigente por tipo y visita. */
public class DocumentoDao {

    private static final String SELECT_COLUMNS = "d.ID_DOCUMENTO, d.ID_VISITA_FK, "
            + "d.TIPO_DOCUMENTO, d.RUTA_ARCHIVO, d.NOMBRE_ARCHIVO, d.TAMANO_ARCHIVO, "
            + "d.SUBIDO_EN, d.ESTADO, d.OBSERVACIONES, d.ID_REVISOR_FK, d.REVISADO_EN, "
            + "v.ID_USUARIO_FK, v.ID_DIVISION_FK, e.NOMBRE_EMPRESA, "
            + "TRIM(u.NOMBRES || ' ' || u.APELLIDO_PATERNO || ' ' || NVL(u.APELLIDO_MATERNO, '')) AS DOCENTE, "
            + "div.DIVISION AS NOMBRE_DIVISION, g.PROGRAMA_EDUCATIVO ";

    private static final String JOINS = "FROM DOCUMENTO d "
            + "JOIN VISITA v ON v.ID_VISITA = d.ID_VISITA_FK "
            + "JOIN USUARIO u ON u.ID_USUARIO = v.ID_USUARIO_FK "
            + "JOIN DIVISION div ON div.ID_DIVISION = v.ID_DIVISION_FK "
            + "JOIN EMPRESA e ON e.ID_EMPRESA = v.ID_EMPRESA_FK "
            + "LEFT JOIN GRUPO_VISITA g ON g.ID_VISITA_FK = v.ID_VISITA ";

    private static final String MERGE_SQL = "MERGE INTO DOCUMENTO destino "
            + "USING (SELECT ? AS ID_VISITA_FK, ? AS TIPO_DOCUMENTO FROM DUAL) origen "
            + "ON (destino.ID_VISITA_FK = origen.ID_VISITA_FK "
            + "AND UPPER(destino.TIPO_DOCUMENTO) = UPPER(origen.TIPO_DOCUMENTO)) "
            + "WHEN MATCHED THEN UPDATE SET destino.RUTA_ARCHIVO = ?, destino.NOMBRE_ARCHIVO = ?, "
            + "destino.TAMANO_ARCHIVO = ?, destino.ESTADO = 'PENDIENTE', "
            + "destino.OBSERVACIONES = NULL, destino.ID_REVISOR_FK = NULL, "
            + "destino.REVISADO_EN = NULL, destino.SUBIDO_EN = CURRENT_TIMESTAMP "
            + "WHEN NOT MATCHED THEN INSERT (ID_VISITA_FK, TIPO_DOCUMENTO, RUTA_ARCHIVO, "
            + "NOMBRE_ARCHIVO, TAMANO_ARCHIVO, ESTADO, SUBIDO_EN) "
            + "VALUES (?, ?, ?, ?, ?, 'PENDIENTE', CURRENT_TIMESTAMP)";

    public boolean guardarDocumento(Documento documento) {
        return guardarLote(List.of(documento));
    }

    public boolean guardarLote(List<Documento> documentos) {
        if (documentos == null || documentos.isEmpty()) return false;
        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                boolean contieneReporte = false;
                Long visitaId = documentos.get(0).getIdVisitaFk();
                for (Documento documento : documentos) {
                    if (!visitaId.equals(documento.getIdVisitaFk())) {
                        throw new SQLException("Todos los documentos deben pertenecer a la misma visita.");
                    }
                    ejecutarMerge(connection, documento);
                    if ("REPORTE".equalsIgnoreCase(documento.getTipoDocumento())) contieneReporte = true;
                }
                if (contieneReporte) actualizarEstadoVisita(connection, visitaId, "REPORTE_EN_REVISION");
                connection.commit();
                return true;
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible guardar los documentos: " + exception.getMessage());
            return false;
        }
    }

    public List<Documento> listarPorVisita(Long idVisita) {
        String sql = "SELECT " + SELECT_COLUMNS + JOINS
                + "WHERE d.ID_VISITA_FK = ? AND UPPER(d.TIPO_DOCUMENTO) "
                + "IN ('SOLICITUD_VISITA','CARTA_RESPONSIVA','REPORTE') "
                + "ORDER BY CASE UPPER(d.TIPO_DOCUMENTO) WHEN 'SOLICITUD_VISITA' THEN 1 "
                + "WHEN 'CARTA_RESPONSIVA' THEN 2 ELSE 3 END";
        return consultarLista(sql, statement -> statement.setLong(1, idVisita));
    }

    public List<Documento> listarEvidenciasReporte(Long idVisita) {
        String sql = "SELECT " + SELECT_COLUMNS + JOINS
                + "WHERE d.ID_VISITA_FK = ? AND UPPER(d.TIPO_DOCUMENTO) "
                + "IN ('EVIDENCIA_1','EVIDENCIA_2','EVIDENCIA_3') "
                + "ORDER BY UPPER(d.TIPO_DOCUMENTO)";
        return consultarLista(sql, statement -> statement.setLong(1, idVisita));
    }

    /** Bandeja de Estadías: únicamente solicitud, carta y reporte. */
    public List<Documento> listarParaEstadias(String busqueda, String tipo) {
        StringBuilder sql = new StringBuilder("SELECT ").append(SELECT_COLUMNS).append(JOINS)
                .append("WHERE UPPER(d.TIPO_DOCUMENTO) IN ('SOLICITUD_VISITA','CARTA_RESPONSIVA','REPORTE') ");
        List<Object> parametros = new ArrayList<>();
        if (tipo != null && !tipo.isBlank()) {
            sql.append("AND UPPER(d.TIPO_DOCUMENTO) = ? ");
            parametros.add(tipo.trim().toUpperCase());
        }
        if (busqueda != null && !busqueda.isBlank()) {
            sql.append("AND (TO_CHAR(v.ID_VISITA) LIKE ? OR UPPER(e.NOMBRE_EMPRESA) LIKE ? "
                    + "OR UPPER(div.DIVISION) LIKE ? OR UPPER(g.PROGRAMA_EDUCATIVO) LIKE ? "
                    + "OR UPPER(d.NOMBRE_ARCHIVO) LIKE ?) ");
            String patron = "%" + busqueda.trim().toUpperCase() + "%";
            parametros.add(patron);
            parametros.add(patron);
            parametros.add(patron);
            parametros.add(patron);
            parametros.add(patron);
        }
        sql.append("ORDER BY d.SUBIDO_EN DESC");
        return consultarLista(sql.toString(), statement -> bind(statement, parametros));
    }

    public Documento buscarPorId(Long idDocumento) {
        String sql = "SELECT " + SELECT_COLUMNS + JOINS + "WHERE d.ID_DOCUMENTO = ?";
        return consultarUno(sql, statement -> statement.setLong(1, idDocumento));
    }

    public Documento buscarPorVisitaYTipo(Long idVisita, String tipo) {
        String sql = "SELECT " + SELECT_COLUMNS + JOINS
                + "WHERE d.ID_VISITA_FK = ? AND UPPER(d.TIPO_DOCUMENTO) = UPPER(?) "
                + "FETCH FIRST 1 ROWS ONLY";
        return consultarUno(sql, statement -> {
            statement.setLong(1, idVisita);
            statement.setString(2, tipo);
        });
    }

    public boolean revisar(Long idDocumento, String estado, String observaciones, Long idRevisor) {
        String consulta = "SELECT ID_VISITA_FK, UPPER(TIPO_DOCUMENTO) AS TIPO_DOCUMENTO "
                + "FROM DOCUMENTO WHERE ID_DOCUMENTO = ?";
        String actualizacion = "UPDATE DOCUMENTO SET ESTADO = ?, OBSERVACIONES = ?, "
                + "ID_REVISOR_FK = ?, REVISADO_EN = CURRENT_TIMESTAMP WHERE ID_DOCUMENTO = ?";

        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                Long visitaId;
                String tipo;
                try (PreparedStatement statement = connection.prepareStatement(consulta)) {
                    statement.setLong(1, idDocumento);
                    try (ResultSet resultSet = statement.executeQuery()) {
                        if (!resultSet.next()) return false;
                        visitaId = resultSet.getLong("ID_VISITA_FK");
                        tipo = resultSet.getString("TIPO_DOCUMENTO");
                    }
                }

                try (PreparedStatement statement = connection.prepareStatement(actualizacion)) {
                    statement.setString(1, estado);
                    statement.setString(2, observaciones);
                    statement.setLong(3, idRevisor);
                    statement.setLong(4, idDocumento);
                    if (statement.executeUpdate() != 1) return false;
                }

                if ("REPORTE".equals(tipo)) {
                    actualizarEstadoVisita(connection, visitaId,
                            "ACEPTADO".equals(estado) ? "COMPLETADA" : "REPORTE_RECHAZADO");
                } else if ("RECHAZADO".equals(estado)) {
                    actualizarEstadoVisita(connection, visitaId, "DOCUMENTACION_RECHAZADA");
                } else if (documentosBaseAceptados(connection, visitaId)) {
                    actualizarEstadoVisita(connection, visitaId, "DOCUMENTACION_APROBADA");
                }

                connection.commit();
                return true;
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible revisar el documento: " + exception.getMessage());
            return false;
        }
    }

    private void ejecutarMerge(Connection connection, Documento documento) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(MERGE_SQL)) {
            statement.setLong(1, documento.getIdVisitaFk());
            statement.setString(2, documento.getTipoDocumento());
            statement.setString(3, documento.getRutaArchivo());
            statement.setString(4, documento.getNombreArchivo());
            statement.setLong(5, documento.getTamanoArchivo());
            statement.setLong(6, documento.getIdVisitaFk());
            statement.setString(7, documento.getTipoDocumento());
            statement.setString(8, documento.getRutaArchivo());
            statement.setString(9, documento.getNombreArchivo());
            statement.setLong(10, documento.getTamanoArchivo());
            statement.executeUpdate();
        }
    }

    private boolean documentosBaseAceptados(Connection connection, Long visitaId) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT UPPER(TIPO_DOCUMENTO)) AS TOTAL FROM DOCUMENTO "
                + "WHERE ID_VISITA_FK = ? AND UPPER(TIPO_DOCUMENTO) "
                + "IN ('SOLICITUD_VISITA','CARTA_RESPONSIVA') AND UPPER(ESTADO) = 'ACEPTADO'";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, visitaId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() && resultSet.getInt("TOTAL") == 2;
            }
        }
    }

    private void actualizarEstadoVisita(Connection connection, Long visitaId, String estado) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "UPDATE VISITA SET ESTADO = ?, ACTUALIZADO_EN = CURRENT_TIMESTAMP WHERE ID_VISITA = ?")) {
            statement.setString(1, estado);
            statement.setLong(2, visitaId);
            statement.executeUpdate();
        }
    }

    private List<Documento> consultarLista(String sql, SqlBinder binder) {
        List<Documento> documentos = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            binder.bind(statement);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) documentos.add(mapDocumento(resultSet));
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible listar los documentos: " + exception.getMessage());
        }
        return documentos;
    }

    private Documento consultarUno(String sql, SqlBinder binder) {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            binder.bind(statement);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapDocumento(resultSet) : null;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible consultar el documento: " + exception.getMessage());
            return null;
        }
    }

    private Documento mapDocumento(ResultSet resultSet) throws SQLException {
        Documento documento = new Documento();
        documento.setIdDocumento(resultSet.getLong("ID_DOCUMENTO"));
        documento.setIdVisitaFk(resultSet.getLong("ID_VISITA_FK"));
        documento.setTipoDocumento(resultSet.getString("TIPO_DOCUMENTO"));
        documento.setRutaArchivo(resultSet.getString("RUTA_ARCHIVO"));
        documento.setNombreArchivo(resultSet.getString("NOMBRE_ARCHIVO"));
        documento.setTamanoArchivo(resultSet.getLong("TAMANO_ARCHIVO"));
        Timestamp subido = resultSet.getTimestamp("SUBIDO_EN");
        documento.setSubidoEn(subido == null ? null : subido.toLocalDateTime());
        documento.setEstado(resultSet.getString("ESTADO"));
        documento.setObservaciones(resultSet.getString("OBSERVACIONES"));
        long revisor = resultSet.getLong("ID_REVISOR_FK");
        documento.setIdRevisorFk(resultSet.wasNull() ? null : revisor);
        Timestamp revisado = resultSet.getTimestamp("REVISADO_EN");
        documento.setRevisadoEn(revisado == null ? null : revisado.toLocalDateTime());
        documento.setIdPropietario(resultSet.getLong("ID_USUARIO_FK"));
        documento.setIdDivision(resultSet.getLong("ID_DIVISION_FK"));
        documento.setEmpresa(resultSet.getString("NOMBRE_EMPRESA"));
        documento.setDocente(resultSet.getString("DOCENTE"));
        documento.setDivision(resultSet.getString("NOMBRE_DIVISION"));
        documento.setCarrera(resultSet.getString("PROGRAMA_EDUCATIVO"));
        return documento;
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
