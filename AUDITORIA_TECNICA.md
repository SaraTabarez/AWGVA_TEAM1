# Auditoría técnica y división por roles - AWGVA

Fecha de revisión: 3 de agosto de 2026

## 1. Cumplimiento de requerimientos

> El ZIP recibido no incluye el extracto del PRD. Los tres PDF de `evidencias_reportes` tienen 0 bytes. Por ello, esta matriz verifica los requisitos expresos del mensaje y los flujos observables en el código; no es posible certificar puntos de un PRD ausente.

| Requisito o flujo | Estado | Justificación |
|---|---|---|
| Inicio independiente para DOCENTE | APROBADO | `InicioServlet` envía a `inicio-docente.jsp`; conserva acceso a solicitudes, reportes e histórico. |
| Inicio independiente para DIRECTOR | APROBADO | Se creó `inicio-director.jsp` con acceso al módulo de revisión de solicitudes. |
| Inicio independiente para ESTADIAS | APROBADO | Se creó `inicio-estadias.jsp` con documentos, revisión de reportes e histórico. |
| Inicio independiente para ADMIN | APROBADO | Se creó `inicio-admin.jsp`; el filtro permite a ADMIN entrar a todos los módulos. |
| Redirección por rol después del login | APROBADO | El login consulta el nombre real del rol y redirige a `/inicio`; ya no envía todas las sesiones a la vista docente. |
| Bloqueo backend por rol | APROBADO | `FiltroAutenticacion` valida el rol para cada ruta y devuelve 403 ante acceso no autorizado. Ocultar enlaces no es el control de seguridad. |
| Navegación distinta por rol | APROBADO | `Layout/sidebar.jsp` genera el menú desde el rol de la sesión y muestra el usuario autenticado. |
| ADMIN gestiona usuarios | APROBADO CON LÍMITE | Lista, alta y cambio de estado operan contra Oracle. Falta paginación en la base de datos para volúmenes grandes. |
| IDs de roles/divisiones portables | APROBADO | El formulario ya no usa IDs fijos (21, 22, 41, 42); obtiene catálogos desde Oracle. |
| Contraseñas protegidas | APROBADO | Nuevas contraseñas usan PBKDF2-HMAC-SHA256 con sal e iteraciones. Cuentas antiguas en texto plano/SHA-256 migran después de un login válido. |
| Recuperación de contraseña | APROBADO CON PENDIENTE | Se corrigió la incompatibilidad entre acciones/campos JSP y Servlet, se agregó CSRF y límite de intentos. Conviene almacenar el código de recuperación hasheado. |
| Crear solicitud y persistirla | RECHAZADO | El formulario activo envía a `/solicitud`, que guarda `SolicitudVisita` sólo en `HttpSession`. Existe otro Servlet que usa Oracle, pero recibe campos diferentes y no está conectado a esa vista. |
| Bandeja real de solicitudes para Dirección | RECHAZADO | `DaoSolicitud` devuelve tres registros mock; no consulta Oracle ni implementa aprobación/rechazo persistente. |
| Detalle real de solicitud | RECHAZADO | `DaoDetalles` devuelve datos fijos de Nissan; no utiliza el ID solicitado. |
| Gestión documental completa | PARCIAL | Los uploads validan tamaño, extensión, firma binaria, nombre aleatorio y almacenamiento fuera del webroot. Aún hay vistas antiguas que simulan el envío o apuntan a PDF vacíos. |
| Aceptar/rechazar reportes | RECHAZADO | `revisar-reporte.jsp` modifica atributos de sesión; no hay transacción ni actualización de estado en Oracle. |
| Históricos | RECHAZADO | Las vistas filtran del lado cliente y no demuestran consulta paginada/persistente en Oracle. |
| PDF de solicitud, carta y reporte | RECHAZADO | Los tres archivos entregados existen, pero están vacíos (0 bytes). |

## 2. División funcional por rol

| Rol | Acceso asignado |
|---|---|
| DOCENTE | Inicio docente, crear/consultar solicitudes, subir documentos y reportes, histórico docente. |
| DIRECTOR | Inicio de Dirección, bandeja y detalle de solicitudes para revisión. |
| ESTADIAS | Inicio de Estadías, gestión documental, revisión de reportes e histórico de Estadías. |
| ADMIN | Acceso a todos los módulos más registro, consulta y activación/desactivación de usuarios. |

La autorización usa el nombre normalizado del rol (`DOCENTE`, `DIRECTOR`, `ESTADIAS`, `ADMIN`), no su ID numérico.

## 3. ⚠️ Hallazgos Técnicos Críticos

### Seguridad

1. **Token de GitHub incrustado en el repositorio recibido - CRÍTICO.** El remoto de `.git/config` contiene una credencial personal. El ZIP corregido omite `.git`, pero eso no revoca el token ni lo elimina de otros clones. Ruta: revocar el token en GitHub, crear uno nuevo con privilegio mínimo y limpiar el remoto con una URL sin credenciales.

2. **Credenciales de Oracle, contraseña del Wallet y archivos privados versionados - CRÍTICO.** El proyecto original incluye `database.properties` con contraseña, JKS, PKCS12, SSO y una clave PEM. La entrega segura usa variables de entorno y omite los binarios del Wallet. Ruta: cambiar la contraseña de Oracle, descargar un Wallet nuevo, invalidar el anterior si aplica y configurar `DB_URL`, `DB_USER`, `DB_PASSWORD`, `ORACLE_WALLET_DIR` y `ORACLE_WALLET_PASSWORD`.

3. **Autorización sólo por sesión - CORREGIDO.** Antes, cualquier usuario autenticado podía abrir manualmente `/GestionUsuariosServlet` u otra vista. Ahora existe una matriz de rutas por rol con denegación predeterminada y ADMIN como superusuario.

4. **Contraseñas en texto plano y SHA-256 sin sal - CORREGIDO.** Registro y recuperación usaban algoritmos incompatibles. PBKDF2 unifica el almacenamiento; la migración de legado evita bloquear cuentas existentes.

5. **Fijación de sesión y logout mediante GET - CORREGIDO.** El login invalida la sesión previa, crea una nueva y rota el token CSRF. El logout ahora requiere POST y token CSRF.

6. **Path traversal y carga de contenido ejecutable - CORREGIDO EN SERVLETS ACTIVOS.** Los uploads ya no usan el nombre suministrado por el navegador como ruta. Se almacenan fuera del webroot con UUID y se valida la firma binaria.

7. **CSRF - CORREGIDO EN RUTAS MUTABLES IDENTIFICADAS.** Altas, cambio de estado, logout, solicitudes y uploads requieren token de sesión. Toda ruta POST nueva debe agregarse al control central.

8. **XSS almacenado potencial - PENDIENTE ALTO.** Varias JSP antiguas imprimen `${...}` o scriptlets sin `<c:out>`. La gestión de usuarios fue corregida, pero debe aplicarse escape de salida en todas las vistas y evitar construir HTML con datos de usuario mediante `innerHTML`.

9. **Cookie de sesión sin `Secure` - PENDIENTE PARA PRODUCCIÓN.** `web.xml` conserva `secure=false` para permitir Tomcat local por HTTP. En el servidor real debe habilitarse HTTPS, `Secure` y `SameSite=Lax` o `Strict`; de lo contrario la cookie puede viajar sin cifrado.

10. **Código de recuperación visible en base de datos - PENDIENTE MEDIO.** Aunque expira, está ligado al correo y tiene límite de intentos, `RESET_TOKEN` aún almacena el código. La siguiente migración debe guardar sólo un hash del código.

### Rendimiento y eficiencia

1. **Conexiones JDBC compartidas entre hilos - CORREGIDO.** `VisitaDao` y `DocumentoDao` guardaban una `Connection` como atributo durante toda la vida del Servlet. Ahora cada operación abre/cierra su conexión y la transacción de visita usa una sola conexión local.

2. **Sin pool de conexiones - PENDIENTE ALTO.** `DriverManager` crea conexiones físicas para cada operación. En Tomcat debe configurarse un `DataSource` JNDI o HikariCP con límites, timeout y validación.

3. **Listado completo de usuarios y filtros en navegador - PENDIENTE MEDIO.** `findAll()` carga todos los usuarios; la “paginación” visible es estática. Implementar `OFFSET ? ROWS FETCH NEXT ? ROWS ONLY`, `COUNT(*)` y filtros parametrizados en Oracle.

4. **No se detectó N+1 en usuarios - APROBADO.** Rol y división se obtienen con `JOIN` en una consulta. Mantener esta estrategia al construir solicitudes/documentos.

5. **Estado de negocio en `HttpSession` - PENDIENTE ALTO.** Las listas de solicitudes crecen en memoria por usuario, se pierden al cerrar sesión y no funcionan bien con varios nodos. Persistir visitas y cambios de estado en Oracle.

6. **Carrera de concurrencia al crear empresas - PENDIENTE MEDIO.** El patrón SELECT-después-INSERT puede duplicar empresas. Crear restricción única sobre el identificador de empresa y usar `MERGE` o manejar `ORA-00001` dentro de la transacción.

## 4. Arquitectura MVC

Estado general: **PARCIAL / REQUIERE REFACTORIZACIÓN**.

- Correcto: `InicioServlet` selecciona vistas en `WEB-INF`; autorización y autenticación están centralizadas; los DAOs usan `PreparedStatement`; la gestión de usuarios pasa por Service y DAO.
- Incorrecto: existen paquetes `Controller` y `Controllers`, dos `SolicitudServlet`, dos `UploadServlet` y tres modelos de solicitud (`SolicitudVisita`, `Visita`, `BeanSolicitud`).
- Incorrecto: `DaoSolicitud` y `DaoDetalles` son mocks; varios JSP ejecutan lógica de negocio y modifican sesión.
- Incorrecto: algunas vistas son accesibles en la raíz de `webapp` en vez de `WEB-INF`; el filtro reduce el riesgo, pero no sustituye moverlas.

Ruta recomendada: elegir `Visita` como entidad principal, conectar un único `SolicitudController` con `VisitaService`/`VisitaDao`, mover JSP a `WEB-INF/views`, eliminar mocks y unificar paquetes en minúsculas (`controller`, `dao`, `model`, `service`, `util`).

## 5. Usuarios de prueba para Oracle

El script `database/roles_y_usuarios_demo.sql` crea/actualiza los cuatro roles sin depender de IDs y registra estas cuentas:

| Rol | Correo | Contraseña inicial | División |
|---|---|---|---|
| DOCENTE | `docente.awgva@utez.edu.mx` | `Docente#2026!` | DATID |
| DIRECTOR | `director.awgva@utez.edu.mx` | `Director#2026!` | DATID |
| ESTADIAS | `estadias.awgva@utez.edu.mx` | `Estadias#2026!` | Sin división |
| ADMIN | `admin.awgva@utez.edu.mx` | `Admin#2026!` | Sin división |

Las contraseñas se insertan como hashes PBKDF2, no como texto plano. Deben cambiarse después de la primera prueba.

## 6. Verificación realizada

- Sintaxis de todos los archivos Java validada con un parser de Java 17.
- Rutas Servlet revisadas sin nombres ni patrones duplicados.
- Cuatro hashes PBKDF2 del script comprobados contra sus contraseñas.
- Búsqueda de patrones de PAT/contraseñas en el código entregable sin coincidencias.
- Maven Wrapper corregido a saltos de línea Unix.
- El WAR no se recompiló en este entorno porque Maven Central no está accesible. Ejecutar localmente `mvnw.cmd clean package` en Windows o `./mvnw clean package` en Linux/macOS antes de desplegar.
