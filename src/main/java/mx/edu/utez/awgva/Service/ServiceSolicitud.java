package mx.edu.utez.awgva.Service;

import mx.edu.utez.awgva.Dao.DaoSolicitud;
import mx.edu.utez.awgva.Model.BeanSolicitud;
import java.util.List;

public class ServiceSolicitud {

    public List<BeanSolicitud> obtenerSolicitudes() {
        DaoSolicitud dao = new DaoSolicitud();
        return dao.consultarTodasLasSolicitudes();
    }
}