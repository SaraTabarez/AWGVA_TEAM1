<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vista Histórico Estadías</title>
    <!-- Integración de Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <!-- Integración de Flatpickr (Calendario) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .sidebar { background-color: #1a2a40; min-height: 100vh; color: white; padding-top: 2rem; }
        .sidebar-link { color: white; text-decoration: none; display: block; padding: 10px 20px; margin-bottom: 5px; cursor: pointer; }
        .sidebar-link:hover { background-color: #2c3e50; color: #f39c12; }
        .sidebar-link.active { color: #f39c12; font-weight: bold; }
        .table-header-dark { background-color: #2b2d42; color: white; }
        .btn-custom-dark { background-color: #2b2d42; color: white; border: none; }
        .btn-custom-dark:hover { background-color: #1a1b26; color: white; }
        .page-item.active .page-link { background-color: #f39c12; border-color: #f39c12; }
        .page-link { color: #6c757d; }
        /* Estilo para que el ícono parezca clickeable */
        .date-icon { cursor: pointer; }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Menú Lateral -->
        <nav class="col-md-2 d-none d-md-block sidebar text-center position-relative">
            <div class="mb-4">
                <i class="bi bi-person-circle display-4"></i>
                <h6 class="mt-2 fw-bold">ESTADÍAS</h6>
            </div>
            <div class="text-start px-3">
                <a class="sidebar-link" onclick="navegarMenu('Inicio')"><i class="bi bi-house-door me-2"></i> Inicio</a>
                <a class="sidebar-link" onclick="navegarMenu('Solicitud')"><i class="bi bi-file-earmark-text me-2"></i> Solicitud</a>
                <a class="sidebar-link" onclick="navegarMenu('Reporte')"><i class="bi bi-bar-chart me-2"></i> Reporte</a>
                <a class="sidebar-link active" onclick="navegarMenu('Histórico')"><i class="bi bi-clock-history me-2"></i> Histórico</a>
            </div>
            <div class="position-absolute bottom-0 start-0 w-100 p-3 text-start">
                <a class="sidebar-link text-white" onclick="cerrarSesion()"><i class="bi bi-box-arrow-left me-2"></i> Cerrar sesión</a>
            </div>
        </nav>

        <!-- Contenido Principal -->
        <main class="col-md-10 px-md-4 pt-4">
            <h3 class="mb-4 fw-bold" style="color: #2b2d42;">HISTORIAL DE ESTADÍAS</h3>

            <!-- Filtros -->
            <div class="row mb-4 align-items-end">
                <div class="col-md-5">
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                        <input type="text" id="busqueda-estadias" class="form-control" placeholder="Buscar por ID, Lugar....">
                    </div>
                </div>
                <div class="col-md-5">
                    <label class="form-label fw-bold small">Fecha:</label>
                    <!-- Estructura de Calendario actualizada -->
                    <div class="input-group">
                        <input type="text" class="form-control date-picker" placeholder="Desde" id="fecha-desde-estadias">
                        <span class="input-group-text bg-white date-icon" onclick="document.getElementById('fecha-desde-estadias')._flatpickr.open()"><i class="bi bi-calendar3"></i></span>

                        <input type="text" class="form-control date-picker" placeholder="Hasta" id="fecha-hasta-estadias">
                        <span class="input-group-text bg-white date-icon" onclick="document.getElementById('fecha-hasta-estadias')._flatpickr.open()"><i class="bi bi-calendar3"></i></span>
                    </div>
                </div>
                <div class="col-md-2 text-end">
                    <button type="button" class="btn btn-custom-dark w-100" onclick="limpiarFiltrosEstadias()">LIMPIAR FILTROS</button>
                </div>
            </div>

            <!-- Tabla -->
            <div class="table-responsive">
                <table class="table table-hover align-middle text-center">
                    <thead class="table-header-dark">
                    <tr>
                        <th>ID</th>
                        <th>EMPRESA</th>
                        <th>LUGAR</th>
                        <th>FECHA</th>
                        <th>CARRERA</th>
                        <th>GRUPO</th>
                        <th>ACCIONES</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr id="fila-2010">
                        <td>2010</td><td>CEMEX</td><td>MONTERREY</td><td>15-05-26</td><td>INGENIERÍA CIVIL</td><td>9°A</td>
                        <td><button class="btn btn-custom-dark btn-sm px-4" onclick="verDetalle('2010')"><i class="bi bi-eye"></i></button></td>
                    </tr>
                    <tr id="fila-2011">
                        <td>2011</td><td>SOFTTEK</td><td>GUADALAJARA</td><td>10-06-26</td><td>INGENIERÍA SISTEMAS</td><td>9°B</td>
                        <td><button class="btn btn-custom-dark btn-sm px-4" onclick="verDetalle('2011')"><i class="bi bi-eye"></i></button></td>
                    </tr>
                    <tr id="fila-2012">
                        <td>2012</td><td>TELMEX</td><td>CIUDAD DE MÉXICO</td><td>20-06-26</td><td>INGENIERÍA TELECOMUNICACIONES</td><td>9°A</td>
                        <td><button class="btn btn-custom-dark btn-sm px-4" onclick="verDetalle('2012')"><i class="bi bi-eye"></i></button></td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <!-- Paginación -->
            <div class="d-flex justify-content-between align-items-center mt-3">
                <nav>
                    <ul class="pagination mb-0">
                        <li class="page-item disabled"><a class="page-link" href="#">Anterior</a></li>
                        <li class="page-item active"><a class="page-link" href="#">1</a></li>
                        <li class="page-item"><a class="page-link" href="#">2</a></li>
                        <li class="page-item"><a class="page-link" href="#">3</a></li>
                        <li class="page-item disabled"><a class="page-link" href="#">...</a></li>
                        <li class="page-item"><a class="page-link" href="#">Siguiente</a></li>
                    </ul>
                </nav>
                <small class="fw-bold">Mostrando 1 de 10 de 125 solicitudes</small>
            </div>
        </main>
    </div>
</div>

<!-- Modal Dinámico para Detalle de Solicitud de Estadías -->
<div class="modal fade" id="modalDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title" id="modalDetalleTitulo">Detalle de Estadías</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="modalDetalleCuerpo">
                <!-- El contenido se genera con JavaScript -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts de Bootstrap y Flatpickr -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/es.js"></script>

<script>
    // 1. Inicializar calendarios guardados en variables
    const fpDesde = flatpickr("#fecha-desde-estadias", { locale: "es", dateFormat: "d-m-Y", allowInput: true, onChange: filtrarTabla });
    const fpHasta = flatpickr("#fecha-hasta-estadias", { locale: "es", dateFormat: "d-m-Y", allowInput: true, onChange: filtrarTabla });

    // 2. Evento para Búsqueda por Texto
    document.getElementById("busqueda-estadias").addEventListener("keyup", filtrarTabla);

    // 3. Función Principal de Filtrado (Texto + Fechas)
    function filtrarTabla() {
        let texto = document.getElementById("busqueda-estadias").value.toLowerCase();
        let fechaDesdeVal = document.getElementById("fecha-desde-estadias").value;
        let fechaHastaVal = document.getElementById("fecha-hasta-estadias").value;

        let filas = document.querySelectorAll("tbody tr");

        filas.forEach(function(fila) {
            let textoFila = fila.textContent.toLowerCase();
            let fechaFilaTexto = fila.children[3].textContent.trim(); // Columna FECHA

            let coincideTexto = textoFila.includes(texto);
            let coincideFecha = true;

            if (fechaDesdeVal || fechaHastaVal) {
                let partes = fechaFilaTexto.split('-');
                let anio = parseInt(partes[2]) < 100 ? 2000 + parseInt(partes[2]) : parseInt(partes[2]);
                let fechaFila = new Date(anio, parseInt(partes[1]) - 1, parseInt(partes[0]));

                if (fechaDesdeVal) {
                    let pD = fechaDesdeVal.split('-');
                    let fD = new Date(pD[2], pD[1] - 1, pD[0]);
                    if (fechaFila < fD) coincideFecha = false;
                }
                if (fechaHastaVal) {
                    let pH = fechaHastaVal.split('-');
                    let fH = new Date(pH[2], pH[1] - 1, pH[0]);
                    if (fechaFila > fH) coincideFecha = false;
                }
            }

            if (coincideTexto && coincideFecha) {
                fila.style.display = "";
            } else {
                fila.style.display = "none";
            }
        });
    }

    // 4. Limpiar Filtros
    function limpiarFiltrosEstadias() {
        document.getElementById('busqueda-estadias').value = '';
        fpDesde.clear();
        fpHasta.clear();
        let filas = document.querySelectorAll("tbody tr");
        filas.forEach(fila => fila.style.display = "");
    }

    // 5. Ver Detalle de la Solicitud (Extrae datos de la fila seleccionada)
    function verDetalle(id) {
        let fila = document.getElementById("fila-" + id);
        let c = fila.children;

        document.getElementById("modalDetalleTitulo").innerText = "Detalle de Estadía #" + id;

        let modalCuerpo = document.getElementById("modalDetalleCuerpo");
        modalCuerpo.innerHTML = `
            <p><strong>ID Estadía:</strong> ${c[0].textContent}</p>
            <p><strong>Empresa:</strong> ${c[1].textContent}</p>
            <p><strong>Ubicación:</strong> ${c[2].textContent}</p>
            <p><strong>Fecha de Registro:</strong> ${c[3].textContent}</p>
            <p><strong>Programa Educativo:</strong> ${c[4].textContent}</p>
            <p><strong>Grupo:</strong> ${c[5].textContent}</p>
            <p><strong>Estado:</strong> <span class="badge bg-success">Concluida / Histórico</span></p>
        `;

        let modal = new bootstrap.Modal(document.getElementById('modalDetalle'));
        modal.show();
    }

    // 6. Navegación del Menú Lateral
    function navegarMenu(seccion) {
        alert("Navegando hacia la sección: " + seccion);
    }

    // 7. Cerrar Sesión
    function cerrarSesion() {
        if(confirm("¿Estás seguro de que deseas cerrar sesión?")) {
            alert("Sesión cerrada correctamente.");
        }
    }
</script>
</body>
</html>