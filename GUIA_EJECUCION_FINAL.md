# AWGVA — guía de ejecución de la versión corregida

Esta entrega parte de **Integradora 3**. Se conservaron su carpeta `.git`, configuración, credenciales, vistas existentes y estilos; Integradora 4 no se usó como base.

## 1. Actualizar Oracle

En SQL Developer abre:

`database/actualizacion_flujo_roles.sql`

Ejecútalo con **F5 (Run Script)**. No uses Ctrl+Enter porque el archivo contiene bloques PL/SQL separados por `/`. El script es idempotente: comprueba las columnas antes de agregarlas y usa `MERGE`, por lo que puede ejecutarse aunque ya se haya corrido una versión anterior.

Al final debe mostrar los Docentes y Directores de DATID, DAMI, DATEFI y DACEA.

Después abre `database/admin_usuario.sql` y ejecútalo también con **F5**. Ese script crea o actualiza una sola cuenta ADMIN, la deja activa y la asigna a DATID para que pueda utilizar también las funciones de Docente y Director.

## 2. Abrir y compilar en IntelliJ IDEA

1. Abre la carpeta `AWGVA_integradora`, no una carpeta superior.
2. En la ventana Maven pulsa **Reload All Maven Projects**.
3. En Maven > Lifecycle ejecuta **clean** y después **package**.
4. El proyecto compila para Java 17. Usa un JDK 17 o posterior.

También se incluye `target/awgva.war`, ya ensamblado en esta entrega.

## 3. Configurar Tomcat 10

1. Run > Edit Configurations > Tomcat Server > Local.
2. En **Deployment** agrega `awgva:war exploded` o el archivo `target/awgva.war`.
3. Usa el contexto `/awgva`.
4. URL de inicio: `http://localhost:8080/awgva/login.jsp`.
5. Pulsa **Run**. Si ya había una versión desplegada, usa Clean/Restart del servidor para que Tomcat no conserve JSP o clases antiguas.

Los documentos cargados se guardan fuera del WAR en:

`${catalina.base}/awgva-uploads`

Opcionalmente se puede definir la variable `AWGVA_UPLOAD_DIR` para usar otra carpeta.

## 4. Cuentas de prueba

| Rol | Correos | Contraseña |
|---|---|---|
| Docente | `docente.datid@utez.edu.mx`, `docente.dami@utez.edu.mx`, `docente.datefi@utez.edu.mx`, `docente.dacea@utez.edu.mx` | `Docente#2026!` |
| Director | `director.datid@utez.edu.mx`, `director.dami@utez.edu.mx`, `director.datefi@utez.edu.mx`, `director.dacea@utez.edu.mx` | `Director#2026!` |
| Estadías | `estadias.awgva@utez.edu.mx` | `Estadias#2026!` |
| Admin | `admin.awgva@utez.edu.mx` | `Admin#2026!` |

## 5. Módulo ADMIN

1. Entra con `admin.awgva@utez.edu.mx`.
2. En **Altas de usuario** puedes crear cuentas de Docente, Director o Estadías. El registro se inserta directamente en la tabla `USUARIO`; no se solicita matrícula.
3. En **Eliminar usuarios** se muestran las cuentas cargadas desde Oracle. Al confirmar, se ejecuta un `DELETE` real sobre `USUARIO`, por lo que la cuenta deja de poder iniciar sesión.
4. La cuenta ADMIN y la cuenta que tiene la sesión iniciada están protegidas.
5. Si un usuario ya tiene solicitudes o documentos relacionados, Oracle impedirá el borrado para no destruir el histórico; la pantalla mostrará el motivo. Los usuarios recién creados pueden eliminarse normalmente.
6. El menú ADMIN también contiene los módulos de Docente, Director y Estadías.

## 6. Prueba funcional recomendada

1. Entra como Docente, crea una solicitud y comprueba que aparezca en **Mis solicitudes**.
2. Sube la Solicitud de visita y la Carta responsiva desde su detalle.
3. Entra como Estadías y acepta o rechaza cada documento.
4. Entra como el Director de la misma división y comprueba que sólo vea solicitudes de esa división.
5. Como Docente, abre Reportes, entra en la tarjeta de la visita y envía el PDF con tres evidencias.
6. Como Estadías revisa el reporte. Al aceptarlo, la visita pasa a Completada y aparece en el histórico del Docente.

## 7. Archivos principales añadidos o actualizados

- Controladores nuevos: `DocenteServlet`, `DirectorServlet`, `EstadiasServlet`, `DocumentoWorkflowServlet`, `ArchivoServlet` y `CambiarPasswordServlet`.
- Persistencia real y restricciones: `VisitaDao`, `DocumentoDao`, `VisitaService` y `DocumentoService`.
- Catálogo por división: `CatalogoCarreras`.
- Vistas nuevas: `WEB-INF/views/director`, `WEB-INF/views/estadias` y `WEB-INF/views/cuenta`.
- Estilos de las vistas nuevas: `assets/css/workflow.css`.
- Migración: `database/actualizacion_flujo_roles.sql`.
- Cuenta ADMIN: `database/admin_usuario.sql`.
- Vistas ADMIN: `WEB-INF/views/admin/altas-usuario.jsp` y `WEB-INF/views/admin/bajas-usuario.jsp`.
- Eliminación real de usuarios: `EliminarUsuarioServlet`, `UsuarioService` y `UsuarioDao`.

No es necesario volver a copiar archivos uno por uno; el ZIP contiene el proyecto completo y conserva el repositorio Git original.
