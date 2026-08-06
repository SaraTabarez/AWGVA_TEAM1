package mx.edu.utez.awgva.Dao;

import mx.edu.utez.awgva.Model.BeanDetalles;

public class DaoDetalles {

    public BeanDetalles consultarDetalleSolicitud() {
        // Creamos un objeto con datos falsos (mock) directamente en memoria
        BeanDetalles solicitud = new BeanDetalles();

        solicitud.setId(1);
        solicitud.setLugarVisita("NISSAN Morelos");
        solicitud.setFechaVisita("25 de octubre 2026");
        solicitud.setCarrera("Ingeniería en Desarrollo de Software");
        solicitud.setGrupo("6° B");
        solicitud.setEmpresaNombre("Nissan Mexicana S.A. de C.V.");
        solicitud.setEmpresaTelefono("777 362 3811");
        solicitud.setEmpresaCorreo("visitas.academicas@NISSAN.mx");
        solicitud.setDocenteResponsable("Carlos Mendoza Torres");
        solicitud.setDocenteAcompanante("Mtra. Laura Gómez Flores");
        solicitud.setTotalEstudiantes(24);
        solicitud.setEstado("Pendiente de Firma");

        return solicitud;
    }
}




//public class DaoSolicitud {
//}
//package mx.edu.utez.awgva.Dao;

//import mx.edu.utez.awgva.Model.BeanSolicitud;
//import mx.edu.utez.awgva.Utils.Conexion;

//import java.sql.Connection;
//import java.sql.ResultSet;
//import java.sql.Statement;

