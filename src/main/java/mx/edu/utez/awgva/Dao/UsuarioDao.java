package mx.edu.utez.awgva.Dao;

import mx.edu.utez.awgva.Model.Usuario;
import mx.edu.utez.awgva.Utils.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class UsuarioDao {

    private static final String USER_COLUMNS = "u.ID_USUARIO, u.CORREO, u.PASSWORD_HASH, "
            + "u.NOMBRES, u.APELLIDO_PATERNO, u.APELLIDO_MATERNO, "
            + "u.ID_ROL_FK, u.ID_DIVISION_FK, u.ESTADO, u.CREADO_EN, "
            + "u.ACTUALIZADO_EN, u.RESET_TOKEN, u.RESET_TOKEN_EXPIRATION";

    private static final String LIST_COLUMNS = "u.ID_USUARIO, u.CORREO, u.NOMBRES, "
            + "u.APELLIDO_PATERNO, u.APELLIDO_MATERNO, u.ID_ROL_FK, "
            + "u.ID_DIVISION_FK, u.ESTADO, u.CREADO_EN, u.ACTUALIZADO_EN";

    /**
     * Lista de usuarios para Administración. El JOIN evita consultas N+1 para
     * obtener el nombre del rol y la división.
     */
    public List<Usuario> findAll() {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS
                + ", r.ROL AS NOMBRE_ROL, d.DIVISION AS NOMBRE_DIVISION "
                + "FROM USUARIO u "
                + "LEFT JOIN ROL r ON r.ID_ROL = u.ID_ROL_FK "
                + "LEFT JOIN DIVISION d ON d.ID_DIVISION = u.ID_DIVISION_FK "
                + "ORDER BY u.ID_USUARIO DESC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                usuarios.add(mapUsuario(resultSet));
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible listar usuarios: " + exception.getMessage());
        }
        return usuarios;
    }

    public Usuario findByEmail(String correo) {
        String sql = "SELECT " + USER_COLUMNS
                + ", r.ROL AS NOMBRE_ROL, d.DIVISION AS NOMBRE_DIVISION "
                + "FROM USUARIO u "
                + "JOIN ROL r ON r.ID_ROL = u.ID_ROL_FK "
                + "LEFT JOIN DIVISION d ON d.ID_DIVISION = u.ID_DIVISION_FK "
                + "WHERE LOWER(u.CORREO) = LOWER(?) AND u.ESTADO = 1";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, correo);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapUsuario(resultSet) : null;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible autenticar al usuario: " + exception.getMessage());
            return null;
        }
    }

    public Usuario findById(Long idUsuario) {
        if (idUsuario == null) {
            return null;
        }

        String sql = "SELECT " + USER_COLUMNS
                + ", r.ROL AS NOMBRE_ROL, d.DIVISION AS NOMBRE_DIVISION "
                + "FROM USUARIO u "
                + "JOIN ROL r ON r.ID_ROL = u.ID_ROL_FK "
                + "LEFT JOIN DIVISION d ON d.ID_DIVISION = u.ID_DIVISION_FK "
                + "WHERE u.ID_USUARIO = ?";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, idUsuario);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapUsuario(resultSet) : null;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible consultar el usuario: " + exception.getMessage());
            return null;
        }
    }

    public Usuario findByResetToken(String token, String correo) {
        String sql = "SELECT " + USER_COLUMNS
                + ", r.ROL AS NOMBRE_ROL, d.DIVISION AS NOMBRE_DIVISION "
                + "FROM USUARIO u "
                + "JOIN ROL r ON r.ID_ROL = u.ID_ROL_FK "
                + "LEFT JOIN DIVISION d ON d.ID_DIVISION = u.ID_DIVISION_FK "
                + "WHERE u.RESET_TOKEN = ? AND LOWER(u.CORREO) = LOWER(?) "
                + "AND u.RESET_TOKEN_EXPIRATION > CURRENT_TIMESTAMP "
                + "AND u.ESTADO = 1";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, token);
            statement.setString(2, correo);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapUsuario(resultSet) : null;
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible validar el código de recuperación: " + exception.getMessage());
            return null;
        }
    }

    public boolean save(Usuario usuario) {
        String sql = "INSERT INTO USUARIO "
                + "(CORREO, PASSWORD_HASH, NOMBRES, APELLIDO_PATERNO, APELLIDO_MATERNO, "
                + "ID_ROL_FK, ID_DIVISION_FK, ESTADO, CREADO_EN) "
                + "VALUES (LOWER(?), ?, ?, ?, ?, ?, ?, 1, CURRENT_TIMESTAMP)";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, usuario.getCorreo());
            statement.setString(2, usuario.getPasswordHash());
            statement.setString(3, usuario.getNombres());
            statement.setString(4, usuario.getApellidoPaterno());
            statement.setString(5, usuario.getApellidoMaterno());
            setNullableLong(statement, 6, usuario.getIdRolFk());
            setNullableLong(statement, 7, usuario.getIdDivisionFk());
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            System.err.println("No fue posible registrar el usuario: " + exception.getMessage());
            return false;
        }
    }

    public boolean emailExists(String correo) {
        String sql = "SELECT 1 FROM USUARIO WHERE LOWER(CORREO) = LOWER(?) FETCH FIRST 1 ROWS ONLY";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, correo);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible validar el correo: " + exception.getMessage());
            return true;
        }
    }

    public boolean updateEstado(Long idUsuario, int estado) {
        String sql = "UPDATE USUARIO SET ESTADO = ?, ACTUALIZADO_EN = CURRENT_TIMESTAMP "
                + "WHERE ID_USUARIO = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, estado);
            statement.setLong(2, idUsuario);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            System.err.println("No fue posible actualizar el estado: " + exception.getMessage());
            return false;
        }
    }

    public DeleteResult deleteById(Long idUsuario) {
        if (idUsuario == null) {
            return DeleteResult.NOT_FOUND;
        }

        String sql = "DELETE FROM USUARIO WHERE ID_USUARIO = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, idUsuario);
            return statement.executeUpdate() == 1
                    ? DeleteResult.DELETED
                    : DeleteResult.NOT_FOUND;
        } catch (SQLIntegrityConstraintViolationException exception) {
            return DeleteResult.HAS_DEPENDENCIES;
        } catch (SQLException exception) {
            // ORA-02292: existen registros hijos relacionados con el usuario.
            if (exception.getErrorCode() == 2292) {
                return DeleteResult.HAS_DEPENDENCIES;
            }
            System.err.println("No fue posible eliminar el usuario: " + exception.getMessage());
            return DeleteResult.ERROR;
        }
    }

    public boolean updateResetToken(String correo, String token, Timestamp expiration) {
        String sql = "UPDATE USUARIO SET RESET_TOKEN = ?, RESET_TOKEN_EXPIRATION = ?, "
                + "ACTUALIZADO_EN = CURRENT_TIMESTAMP WHERE LOWER(CORREO) = LOWER(?)";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, token);
            statement.setTimestamp(2, expiration);
            statement.setString(3, correo);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            System.err.println("No fue posible actualizar el código de recuperación: " + exception.getMessage());
            return false;
        }
    }

    public boolean updatePassword(String correo, String newPasswordHash) {
        String sql = "UPDATE USUARIO SET PASSWORD_HASH = ?, RESET_TOKEN = NULL, "
                + "RESET_TOKEN_EXPIRATION = NULL, ACTUALIZADO_EN = CURRENT_TIMESTAMP "
                + "WHERE LOWER(CORREO) = LOWER(?)";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, newPasswordHash);
            statement.setString(2, correo);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            System.err.println("No fue posible actualizar la contraseña: " + exception.getMessage());
            return false;
        }
    }

    public boolean updatePasswordHash(Long idUsuario, String newPasswordHash) {
        String sql = "UPDATE USUARIO SET PASSWORD_HASH = ?, ACTUALIZADO_EN = CURRENT_TIMESTAMP "
                + "WHERE ID_USUARIO = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, newPasswordHash);
            statement.setLong(2, idUsuario);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            System.err.println("No fue posible migrar la contraseña: " + exception.getMessage());
            return false;
        }
    }

    public boolean isResetTokenValid(String token, String correo) {
        String sql = "SELECT 1 FROM USUARIO WHERE RESET_TOKEN = ? AND LOWER(CORREO) = LOWER(?) "
                + "AND RESET_TOKEN_EXPIRATION > CURRENT_TIMESTAMP AND ESTADO = 1 "
                + "FETCH FIRST 1 ROWS ONLY";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, token);
            statement.setString(2, correo);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible validar el código: " + exception.getMessage());
            return false;
        }
    }

    public Map<Long, String> findRoles() {
        return findCatalog(
                "SELECT ID_ROL, ROL FROM ROL "
                        + "WHERE UPPER(TRIM(ROL)) <> 'ADMIN' ORDER BY ROL",
                "ID_ROL",
                "ROL"
        );
    }

    public Map<Long, String> findDivisiones() {
        return findCatalog(
                "SELECT ID_DIVISION, DIVISION FROM DIVISION ORDER BY DIVISION",
                "ID_DIVISION",
                "DIVISION"
        );
    }

    public boolean roleExists(Long idRol) {
        return catalogValueExists("ROL", "ID_ROL", idRol);
    }

    public boolean divisionExists(Long idDivision) {
        return idDivision == null || catalogValueExists("DIVISION", "ID_DIVISION", idDivision);
    }

    private Map<Long, String> findCatalog(String sql, String idColumn, String nameColumn) {
        Map<Long, String> values = new LinkedHashMap<>();
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                values.put(resultSet.getLong(idColumn), resultSet.getString(nameColumn));
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible cargar el catálogo: " + exception.getMessage());
        }
        return values;
    }

    private boolean catalogValueExists(String table, String idColumn, Long id) {
        if (id == null) {
            return false;
        }
        // table e idColumn sólo se invocan con constantes internas, no con datos del usuario.
        String sql = "SELECT 1 FROM " + table + " WHERE " + idColumn + " = ? FETCH FIRST 1 ROWS ONLY";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException exception) {
            System.err.println("No fue posible validar el catálogo: " + exception.getMessage());
            return false;
        }
    }

    private Usuario mapUsuario(ResultSet resultSet) throws SQLException {
        Usuario usuario = new Usuario();
        usuario.setIdUsuario(resultSet.getLong("ID_USUARIO"));
        usuario.setCorreo(resultSet.getString("CORREO"));
        usuario.setPasswordHash(optionalString(resultSet, "PASSWORD_HASH"));
        usuario.setNombres(resultSet.getString("NOMBRES"));
        usuario.setApellidoPaterno(resultSet.getString("APELLIDO_PATERNO"));
        usuario.setApellidoMaterno(resultSet.getString("APELLIDO_MATERNO"));
        usuario.setIdRolFk(nullableLong(resultSet, "ID_ROL_FK"));
        usuario.setIdDivisionFk(nullableLong(resultSet, "ID_DIVISION_FK"));
        usuario.setEstado(resultSet.getInt("ESTADO"));
        usuario.setCreadoEn(resultSet.getTimestamp("CREADO_EN"));
        usuario.setActualizadoEn(resultSet.getTimestamp("ACTUALIZADO_EN"));
        usuario.setResetToken(optionalString(resultSet, "RESET_TOKEN"));
        usuario.setResetTokenExpiration(optionalTimestamp(resultSet, "RESET_TOKEN_EXPIRATION"));
        usuario.setNombreRol(optionalString(resultSet, "NOMBRE_ROL"));
        usuario.setNombreDivision(optionalString(resultSet, "NOMBRE_DIVISION"));
        return usuario;
    }

    private Long nullableLong(ResultSet resultSet, String column) throws SQLException {
        long value = resultSet.getLong(column);
        return resultSet.wasNull() ? null : value;
    }

    private String optionalString(ResultSet resultSet, String column) {
        try {
            return resultSet.getString(column);
        } catch (SQLException ignored) {
            return null;
        }
    }

    private Timestamp optionalTimestamp(ResultSet resultSet, String column) {
        try {
            return resultSet.getTimestamp(column);
        } catch (SQLException ignored) {
            return null;
        }
    }

    private void setNullableLong(PreparedStatement statement, int index, Long value) throws SQLException {
        if (value == null) {
            statement.setNull(index, Types.NUMERIC);
        } else {
            statement.setLong(index, value);
        }
    }

    public enum DeleteResult {
        DELETED,
        NOT_FOUND,
        HAS_DEPENDENCIES,
        ERROR
    }
}