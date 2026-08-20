package mx.edu.utez.awgva.Listeners;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import mx.edu.utez.awgva.Utils.DatabaseConnection;

/** Precalienta y cierra de forma ordenada el pool de conexiones de AWGVA. */
@WebListener
public class DatabasePoolListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            DatabaseConnection.warmUp();
            sce.getServletContext().log("AWGVA: pool Oracle listo. Conexiones físicas: "
                    + DatabaseConnection.physicalConnections());
        } catch (Exception exception) {
            // No impide que Tomcat arranque: el primer DAO volverá a intentar la conexión.
            sce.getServletContext().log("AWGVA: no fue posible precalentar Oracle: "
                    + exception.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DatabaseConnection.closePool();
    }
}
