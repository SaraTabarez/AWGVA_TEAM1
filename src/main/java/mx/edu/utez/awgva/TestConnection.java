package mx.edu.utez.awgva;

import mx.edu.utez.awgva.Utils.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/** Prueba manual de conectividad. No crea roles ni usuarios. */
public class TestConnection {

    public static void main(String[] args) {
        String sql = "SELECT 1 FROM DUAL";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            System.out.println(resultSet.next()
                    ? "Conexión a Oracle verificada."
                    : "Oracle no devolvió respuesta.");
        } catch (Exception exception) {
            System.err.println("No fue posible conectar con Oracle: " + exception.getMessage());
        }
    }
}
