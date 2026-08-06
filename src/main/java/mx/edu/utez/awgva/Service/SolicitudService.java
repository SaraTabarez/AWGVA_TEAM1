package mx.edu.utez.awgva.Service;

import mx.edu.utez.awgva.Dao.SolicitudDao;
import mx.edu.utez.awgva.Model.SolicitudVisita;

public class SolicitudService {
    private SolicitudDao dao = new SolicitudDao();

    public boolean procesarSolicitud(SolicitudVisita solicitud) {
        if (solicitud.getSolicitanteNombre() == null || solicitud.getSolicitanteNombre().isEmpty()) {
            return false;
        }
        return dao.guardarSolicitud(solicitud);
    }
}