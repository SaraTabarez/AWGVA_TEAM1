package mx.edu.utez.awgva.Service;

import mx.edu.utez.awgva.Dao.DaoDetalles;
import mx.edu.utez.awgva.Model.BeanDetalles;

public class ServiceDetalles {

    public BeanDetalles obtenerSolicitud() {
        DaoDetalles miDao = new DaoDetalles();
        return miDao.consultarDetalleSolicitud();
    }
}