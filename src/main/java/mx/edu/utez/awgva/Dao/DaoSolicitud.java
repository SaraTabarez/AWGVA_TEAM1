package mx.edu.utez.awgva.Dao;

import mx.edu.utez.awgva.Model.BeanSolicitud;
import java.util.ArrayList;
import java.util.List;

public class DaoSolicitud {

    public List<BeanSolicitud> consultarTodasLasSolicitudes() {
        List<BeanSolicitud> lista = new ArrayList<>();

        // Datos simulados (Mock) para llenar la tabla
        lista.add(new BeanSolicitud("001", "DATID", "NISSAN Morelos", "25-10-2026", "PENDIENTE"));
        lista.add(new BeanSolicitud("002", "DATID", "Planta Ford", "12-11-2026", "RECHAZADA"));
        lista.add(new BeanSolicitud("003", "DAMI", "Softtek CDMX", "02-12-2026", "ACEPTADA"));

        return lista;
    }
}