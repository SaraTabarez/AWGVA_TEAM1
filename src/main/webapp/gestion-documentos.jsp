<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="32kb" autoFlush="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Documentos - Carta Responsiva</title>
    <!-- Bootstrap 5 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        body { background-color: #9cb0c5; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        /* Sidebar */
        .sidebar { background-color: #1c3150; min-height: 100vh; color: white; padding-top: 2.5rem; }
        .sidebar-link { color: white; text-decoration: none; display: block; padding: 12px 25px; margin-bottom: 8px; cursor: pointer; border-radius: 4px; font-weight: 500; }
        .sidebar-link:hover { background-color: #2c4468; color: #f39c12; }
        .sidebar-link.active { color: white; font-weight: bold; }

        /* Contenedor Principal */
        .main-card {
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            overflow: hidden;
            min-height: 90vh;
        }

        /* Stepper / Línea de tiempo */
        .stepper-wrapper {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            position: relative;
            margin-bottom: 2rem;
            padding: 0 20px;
        }
        .stepper-wrapper::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 40px;
            right: 40px;
            height: 3px;
            background-color: #c2bebe;
            z-index: 1;
        }
        .step-item {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            width: 85px;
        }
        .step-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #d1cca0;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            border: 3px solid #ffffff;
        }
        .step-item.completed .step-icon {
            background-color: #e67e22 !important;
        }
        .step-title {
            font-size: 0.7rem;
            color: #4a4a4a;
            margin-top: 6px;
            line-height: 1.1;
            font-weight: 600;
        }

        /* Zona de Carga Drag & Drop */
        .upload-area {
            border: 2px dashed #f39c12;
            border-radius: 12px;
            padding: 2.5rem 1.5rem;
            text-align: center;
            background-color: #ffffff;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        .upload-area:hover {
            background-color: #fffcf7;
        }
        .btn-browse {
            background-color: #1c3150;
            color: white;
            padding: 8px 36px;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            font-size: 0.95rem;
        }

        /* Categorías (Botones vista sin archivos) */
        .btn-category {
            padding: 14px 20px;
            border-radius: 10px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            border: none;
            font-size: 0.95rem;
        }
        .btn-category-orange { background-color: #e67e22; color: white; }
        .btn-category-beige { background-color: #d1cca0; color: #333; }

        /* TABLA ESTILO TARJETAS */
        .custom-table {
            border-collapse: separate;
            border-spacing: 12px 10px;
            width: 100%;
        }
        .custom-table th {
            background-color: #1c3150;
            color: white;
            padding: 10px 15px;
            font-size: 0.85rem;
            font-weight: 600;
            border: none;
            border-radius: 6px;
            text-align: center;
        }
        .custom-table td {
            background-color: #d1cca0;
            padding: 12px 15px;
            font-size: 0.88rem;
            border: none;
            vertical-align: middle;
            text-align: center;
            color: #222;
        }
        .custom-table tr td:first-child { border-top-left-radius: 6px; border-bottom-left-radius: 6px; }
        .custom-table tr td:last-child { border-top-right-radius: 6px; border-bottom-right-radius: 6px; }

        .badge-borrador {
            background-color: #1c3150;
            color: white;
            padding: 4px 16px;
            border-radius: 12px;
            font-weight: 500;
            font-size: 0.78rem;
            display: inline-block;
        }
        .action-icon {
            cursor: pointer;
            font-size: 1.15rem;
            color: #1c3150;
            margin: 0 4px;
            transition: color 0.2s;
        }
        .action-icon:hover { color: #e67e22; }

        /* Botones Inferiores */
        .btn-dark-navy {
            background-color: #1c3150;
            color: white;
            border-radius: 8px;
            padding: 9px 38px;
            font-weight: bold;
            border: none;
        }
        .btn-dark-navy:hover { background-color: #2c4468; color: white; }

        /* ESTILOS DEL MODAL DE ÉXITO */
        .success-panel {
            background-color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 40px 20px;
            text-align: center;
        }
        .icon-container {
            border: 2px solid #55CC8A;
            border-radius: 12px;
            width: 80px;
            height: 80px;
            margin-bottom: 25px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .checkmark {
            font-size: 45px;
            color: #55CC8A;
            font-weight: bold;
            line-height: 1;
        }
        .modal-success-title {
            font-size: 18px;
            font-weight: bold;
            color: black;
            margin-bottom: 15px;
            text-transform: uppercase;
        }
        .modal-success-text {
            font-size: 14px;
            color: #333;
            margin-bottom: 30px;
            line-height: 1.5;
        }
        .understood-button {
            background-color: #55CC8A;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 40px;
            font-size: 15px;
            cursor: pointer;
            font-weight: 600;
        }
    </style>
</head>
<body>

<p class="text-secondary fw-semibold px-4 pt-3 mb-1 fs-6" id="tituloEncabezado">Sin documentos subidos/responsiva</p>

<div class="container-fluid px-4 pb-4">
    <div class="row">
        <!-- Sidebar -->
        <nav class="col-md-2 d-none d-md-block sidebar text-center position-relative rounded-start-3">
            <div class="mb-5 mt-3">
                <i class="bi bi-person-circle display-3"></i>
                <h6 class="mt-3 fw-bold tracking-wide">DOCENTE</h6>
            </div>
            <div class="text-start px-2">
                <a class="sidebar-link"><i class="bi bi-house-door me-3"></i> Inicio</a>
                <a class="sidebar-link active"><i class="bi bi-file-earmark-text me-3"></i> Solicitud</a>
                <a class="sidebar-link"><i class="bi bi-bar-chart me-3"></i> Reporte</a>
                <a class="sidebar-link"><i class="bi bi-clock-history me-3"></i> Histórico</a>
            </div>
            <div class="position-absolute bottom-0 start-0 w-100 p-3 text-start">
                <a class="sidebar-link text-white"><i class="bi bi-box-arrow-left me-3"></i> Cerrar sesión</a>
            </div>
        </nav>

        <!-- Main Content -->
        <main class="col-md-10 p-4 bg-white rounded-end-3">
            <div class="main-card p-2 position-relative d-flex flex-column justify-content-between">
                <div>
                    <button type="button" class="btn-close position-absolute top-0 end-0 m-2"></button>

                    <!-- Stepper -->
                    <div class="stepper-wrapper my-3">
                        <div class="step-item completed"><div class="step-icon"><i class="bi bi-file-earmark-text"></i></div><div class="step-title">Solicitud creada</div></div>
                        <div class="step-item completed"><div class="step-icon"><i class="bi bi-file-earmark-check"></i></div><div class="step-title">Solicitud enviada</div></div>
                        <div class="step-item completed"><div class="step-icon"><i class="bi bi-file-earmark-arrow-up"></i></div><div class="step-title">Solicitud aceptada</div></div>
                        <div class="step-item completed"><div class="step-icon"><i class="bi bi-file-earmark-medical"></i></div><div class="step-title">Carta responsiva enviada</div></div>
                        <div class="step-item completed"><div class="step-icon"><i class="bi bi-file-earmark-ruled"></i></div><div class="step-title">Carta responsiva aceptada</div></div>
                        <div class="step-item completed"><div class="step-icon"><i class="bi bi-bus-front"></i></div><div class="step-title">Visita en curso</div></div>
                        <div class="step-item"><div class="step-icon"><i class="bi bi-journal-text"></i></div><div class="step-title">Reporte enviado</div></div>
                        <div class="step-item"><div class="step-icon"><i class="bi bi-journal-check"></i></div><div class="step-title">Reporte aceptado</div></div>
                        <div class="step-item"><div class="step-icon"><i class="bi bi-check-circle"></i></div><div class="step-title">Visita concretada</div></div>
                    </div>

                    <!-- Header de Archivos -->
                    <div class="d-flex justify-content-between align-items-center mb-2 px-2 mt-4">
                        <div>
                            <h6 class="fw-bold mb-0" style="color: #2b2d42;">Imágenes y Documentos</h6>
                            <small class="text-muted">Adjunta imágenes (PNG, JPG, WEBP) y documentos (PDF)</small>
                        </div>
                        <div class="text-end">
                            <span class="fw-bold fs-6" id="contador-archivos">0 de 10 archivos</span><br>
                            <small class="text-muted" id="peso-archivos">0 Bytes de 100 MB</small>
                        </div>
                    </div>

                    <!-- INPUT OCULTO -->
                    <input type="file" id="fileInput" multiple style="display: none;" accept=".pdf,.png,.jpg,.jpeg,.webp">

                    <!-- Zona Carga -->
                    <div class="upload-area mb-4" id="uploadZone">
                        <button type="button" class="btn btn-browse mb-2" id="btnBrowse">Explore</button>
                        <p class="mb-1 text-dark fw-medium">Arrastra archivos aquí o <span class="text-success text-decoration-underline fw-bold">selecciona</span></p>
                        <small class="text-muted">PNG, JPG, WEBP, PDF • Max. 10 MB por archivo</small>
                    </div>

                    <!-- ESTADO 1: CATEGORÍAS (Visibles cuando NO hay archivos) -->
                    <div id="seccionCategorias" class="row g-4 my-3 px-2">
                        <div class="col-md-4">
                            <button class="btn btn-category btn-category-beige w-100"><i class="bi bi-file-earmark-text fs-4"></i> Solicitud</button>
                        </div>
                        <div class="col-md-4">
                            <button class="btn btn-category btn-category-orange w-100"><i class="bi bi-file-earmark-medical fs-4"></i> Carta Responsiva</button>
                        </div>
                        <div class="col-md-4">
                            <button class="btn btn-category btn-category-beige w-100"><i class="bi bi-journal-text fs-4"></i> Reporte</button>
                        </div>
                    </div>

                    <!-- ESTADO 2: TABLA DE DOCUMENTOS (Visible cuando SÍ hay archivos) -->
                    <div id="seccionTabla" class="table-responsive mb-4" style="display: none;">
                        <table class="custom-table">
                            <thead>
                            <tr>
                                <th style="width: 8%;">Tipo</th>
                                <th style="width: 32%;">Nombre</th>
                                <th style="width: 12%;">Tamaño</th>
                                <th style="width: 20%;">Fecha</th>
                                <th style="width: 13%;">Estado</th>
                                <th style="width: 15%;">Acciones</th>
                            </tr>
                            </thead>
                            <tbody id="cuerpoTabla">
                            <!-- Filas dinámicas -->
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Botones Inferiores -->
                <div class="d-flex justify-content-between align-items-center pt-3 mt-4 border-top">
                    <button type="button" class="btn btn-dark-navy">Anterior</button>
                    <button type="button" class="btn btn-dark-navy" id="btnContinuar">Continuar</button>
                </div>

            </div>
        </main>
    </div>
</div>

<!-- Modal Éxito -->
<div class="modal fade" id="modalExito" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-body p-0">
                <div class="success-panel">
                    <div class="icon-container">
                        <span class="checkmark">&#10003;</span>
                    </div>
                    <div class="modal-success-title">DOCUMENTOS ENVIADOS CORRECTAMENTE</div>
                    <p class="modal-success-text">
                        Los documentos han sido enviados correctamente.<br>
                        Espere la respuesta del departamento correspondiente.
                    </p>
                    <button type="button" class="understood-button" data-bs-dismiss="modal">Entendido</button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Visor -->
<div class="modal fade" id="modalVisor" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title" id="visorTitulo">Vista Previa</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center p-3" id="visorCuerpo"></div>
        </div>
    </div>
</div>

<!-- Script Bootstrap -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- JAVASCRIPT COMPLETO Y DINÁMICO -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        let listaArchivos = [];

        const fileInput = document.getElementById('fileInput');
        const uploadZone = document.getElementById('uploadZone');
        const btnBrowse = document.getElementById('btnBrowse');
        const cuerpoTabla = document.getElementById('cuerpoTabla');
        const seccionCategorias = document.getElementById('seccionCategorias');
        const seccionTabla = document.getElementById('seccionTabla');
        const tituloEncabezado = document.getElementById('tituloEncabezado');
        const btnContinuar = document.getElementById('btnContinuar');

        // Abrir selector de archivos
        btnBrowse.addEventListener('click', (e) => {
            e.stopPropagation();
            fileInput.click();
        });

        uploadZone.addEventListener('click', (e) => {
            if (e.target !== btnBrowse) {
                fileInput.click();
            }
        });

        fileInput.addEventListener('change', (e) => {
            if (e.target.files && e.target.files.length > 0) {
                agregarArchivos(e.target.files);
                fileInput.value = '';
            }
        });

        // Eventos Drag & Drop
        uploadZone.addEventListener('dragover', (e) => {
            e.preventDefault();
            e.stopPropagation();
            uploadZone.style.backgroundColor = '#fff7e6';
        });

        uploadZone.addEventListener('dragleave', (e) => {
            e.preventDefault();
            e.stopPropagation();
            uploadZone.style.backgroundColor = '#ffffff';
        });

        uploadZone.addEventListener('drop', (e) => {
            e.preventDefault();
            e.stopPropagation();
            uploadZone.style.backgroundColor = '#ffffff';
            if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
                agregarArchivos(e.dataTransfer.files);
            }
        });

        function agregarArchivos(files) {
            for (let file of files) {
                if (listaArchivos.length >= 10) {
                    alert('Límite de 10 archivos alcanzado');
                    break;
                }
                listaArchivos.push(file);
            }
            renderizar();
        }

        function renderizar() {
            cuerpoTabla.innerHTML = '';
            let bytesTotales = 0;

            // Cambio dinámico de Vista según la presencia de archivos
            if (listaArchivos.length > 0) {
                seccionCategorias.style.display = 'none';
                seccionTabla.style.display = 'block';
                tituloEncabezado.innerText = 'Documentos subidos/responsiva';
            } else {
                seccionCategorias.style.display = 'flex';
                seccionTabla.style.display = 'none';
                tituloEncabezado.innerText = 'Sin documentos subidos/responsiva';
            }

            listaArchivos.forEach((file, index) => {
                bytesTotales += file.size;
                const pesoFormat = (file.size / 1024).toFixed(1) + ' KB';
                const fechaFormat = obtenerFecha();

                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><i class="bi bi-file-earmark-text fs-4" style="color: #1c3150;"></i></td>
                    <td class="fw-bold text-start ps-3">\${file.name}</td>
                    <td class="fw-bold">\${pesoFormat}</td>
                    <td class="fw-bold">\${fechaFormat}</td>
                    <td><span class="badge-borrador">Borrador</span></td>
                    <td>
                        <i class="bi bi-eye action-icon ver-doc" title="Ver" data-index="\${index}"></i>
                        <i class="bi bi-download action-icon descargar-doc" title="Descargar" data-index="\${index}"></i>
                        <i class="bi bi-trash action-icon delete" title="Eliminar" data-index="\${index}"></i>
                    </td>
                `;
                cuerpoTabla.appendChild(tr);
            });

            // Actualizar textos superiores
            document.getElementById('contador-archivos').innerText = `\${listaArchivos.length} de 10 archivos`;

            if (bytesTotales >= 1048576) {
                document.getElementById('peso-archivos').innerText = `\${(bytesTotales / 1048576).toFixed(1)} MB de 100 MB`;
            } else {
                document.getElementById('peso-archivos').innerText = `\${(bytesTotales / 1024).toFixed(1)} KB de 100 MB`;
            }

            // Asignar eventos
            document.querySelectorAll('.delete').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    const idx = e.target.getAttribute('data-index');
                    listaArchivos.splice(idx, 1);
                    renderizar();
                });
            });

            document.querySelectorAll('.ver-doc').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    const idx = e.target.getAttribute('data-index');
                    verArchivo(listaArchivos[idx]);
                });
            });

            document.querySelectorAll('.descargar-doc').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    const idx = e.target.getAttribute('data-index');
                    descargarArchivo(listaArchivos[idx]);
                });
            });
        }

        function verArchivo(file) {
            const url = URL.createObjectURL(file);
            const visorCuerpo = document.getElementById('visorCuerpo');
            document.getElementById('visorTitulo').innerText = file.name;

            if (file.type.includes('image')) {
                visorCuerpo.innerHTML = `<img src="\${url}" class="img-fluid rounded" style="max-height: 70vh;">`;
            } else {
                visorCuerpo.innerHTML = `<embed src="\${url}" type="application/pdf" width="100%" height="450px"/>`;
            }

            const modalVisor = new bootstrap.Modal(document.getElementById('modalVisor'));
            modalVisor.show();
        }

        function descargarArchivo(file) {
            const url = URL.createObjectURL(file);
            const a = document.createElement('a');
            a.href = url;
            a.download = file.name;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }

        function obtenerFecha() {
            const now = new Date();
            const d = String(now.getDate()).padStart(2, '0');
            const m = String(now.getMonth() + 1).padStart(2, '0');
            const y = now.getFullYear();
            let h = now.getHours();
            const min = String(now.getMinutes()).padStart(2, '0');
            const ampm = h >= 12 ? 'p.m.' : 'a.m.';
            h = h % 12 || 12;
            return `\${d}/\${m}/\${y}, \${h}:\${min} \${ampm}`;
        }

        // Continuar
        btnContinuar.addEventListener('click', () => {
            if (listaArchivos.length === 0) {
                alert('Debes adjuntar al menos un archivo antes de continuar.');
                return;
            }
            const modalExito = new bootstrap.Modal(document.getElementById('modalExito'));
            modalExito.show();
        });
    });
</script>

</body>
</html>