<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Recuperar el índice de la solicitud
    String indexParam = request.getParameter("index");
    int indexNum = 0;
    if (indexParam != null) {
        try {
            indexNum = Integer.parseInt(indexParam);
        } catch (NumberFormatException e) {
            indexNum = 0;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subir Carta Responsiva - Docente</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --bg-body: #a2b1c6;
            --bg-sidebar: #223754;
            --bg-main: #ffffff;
            --color-primary: #f59e0b;
            --color-secondary: #243c5a;
            --color-text-dark: #333333;
            --color-text-muted: #6b7280;
            --color-inactive-btn: #c4c0b6;
            --color-border: #e5e7eb;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
        body { background-color: var(--bg-body); height: 100vh; display: flex; justify-content: center; align-items: center; padding: 20px; }

        .app-window { display: flex; width: 100%; max-width: 1280px; height: 90vh; background-color: var(--bg-main); border-radius: 8px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.15); position: relative; }

        /* Sidebar */
        .sidebar { width: 260px; background-color: var(--bg-sidebar); color: white; display: flex; flex-direction: column; padding: 2.5rem 0; flex-shrink: 0; }
        .user-profile { text-align: center; margin-bottom: 3rem; }
        .user-profile i { font-size: 4rem; color: #cbd5e1; margin-bottom: 1rem; }
        .user-profile h3 { font-size: 0.9rem; font-weight: 700; letter-spacing: 1px; }
        .nav-menu { list-style: none; flex-grow: 1; }
        .nav-menu li { padding: 1rem 2rem; display: flex; align-items: center; gap: 15px; cursor: pointer; font-weight: 600; font-size: 0.95rem; }
        .nav-menu li.active { background-color: rgba(255,255,255,0.1); }
        .sidebar-footer { padding: 1rem 2rem; margin-top: auto; }
        .logout-btn { display: flex; align-items: center; gap: 15px; color: white; text-decoration: none; font-weight: 600; font-size: 0.95rem; }

        /* Main Content */
        .main-content { flex-grow: 1; padding: 2.5rem 4rem; display: flex; flex-direction: column; position: relative; overflow-y: auto; }
        .close-btn { position: absolute; top: 1.5rem; right: 1.5rem; font-size: 1.2rem; color: var(--color-text-muted); cursor: pointer; border: none; background: none; }
        .close-btn:hover { color: #ef4444; }

        /* Stepper */
        .stepper-container { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 2rem; position: relative; padding: 0 1rem; }
        .step { display: flex; flex-direction: column; align-items: center; z-index: 2; width: 80px; position: relative; }
        .step-icon { width: 40px; height: 40px; border-radius: 50%; background-color: #d1d5db; color: white; display: flex; justify-content: center; align-items: center; font-size: 1.2rem; margin-bottom: 0.5rem; }
        .step.active .step-icon { background-color: var(--color-primary); }
        .step-label { font-size: 0.65rem; text-align: center; color: var(--color-text-dark); font-weight: 500; line-height: 1.2; }
        .stepper-line { position: absolute; top: 20px; left: 50px; right: 50px; height: 3px; background-color: #d1d5db; z-index: 1; }

        .upload-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 1rem; }
        .upload-title h2 { font-size: 1.1rem; color: var(--color-text-dark); margin-bottom: 0.2rem; }
        .upload-title p, .upload-stats p { font-size: 0.8rem; color: var(--color-text-muted); }
        .upload-stats { text-align: right; }

        .dropzone { border: 2px dashed var(--color-primary); border-radius: 12px; padding: 2.5rem 2rem; display: flex; flex-direction: column; align-items: center; justify-content: center; background-color: #fefdf8; margin-bottom: 1.5rem; cursor: pointer; }
        .btn-browse { background-color: var(--color-secondary); color: white; border: none; padding: 0.6rem 2.5rem; border-radius: 6px; font-size: 0.95rem; font-weight: 500; cursor: pointer; margin-bottom: 0.8rem; }
        .dropzone-text { font-size: 0.95rem; color: var(--color-text-dark); font-weight: 600; margin-bottom: 0.4rem; }
        .dropzone-text span { color: #047857; text-decoration: underline; }

        .table-container { margin-bottom: auto; overflow-x: auto; display: none; }
        .doc-table { width: 100%; border-collapse: separate; border-spacing: 0; border: 1px solid var(--color-border); border-radius: 8px; overflow: hidden; }
        .doc-table th { background-color: var(--bg-sidebar); color: white; padding: 12px 15px; text-align: left; font-size: 0.85rem; font-weight: 600; }
        .doc-table td { padding: 15px; border-bottom: 1px solid var(--color-border); font-size: 0.9rem; color: var(--color-text-dark); font-weight: 600; vertical-align: middle; }
        .badge-status { background-color: var(--bg-sidebar); color: white; padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 600; display: inline-block; }

        .action-icons { display: flex; gap: 15px; justify-content: center; font-size: 1.1rem; color: var(--color-text-dark); }
        .action-icons i { cursor: pointer; transition: color 0.2s; }
        .action-icons i:hover { color: var(--color-primary); }

        .action-buttons { display: flex; justify-content: space-between; margin-top: 1.5rem; padding-top: 1rem; }
        .btn-action { background-color: var(--color-secondary); color: white; border: none; padding: 0.8rem 2rem; border-radius: 6px; font-size: 0.95rem; font-weight: 600; cursor: pointer; min-width: 120px; }
        .btn-action:disabled { background-color: var(--color-inactive-btn); cursor: not-allowed; }
    </style>
</head>
<body>

<div class="app-window">
    <aside class="sidebar">
        <div class="user-profile">
            <i class="fa-solid fa-circle-user"></i>
            <h3>DOCENTE</h3>
        </div>
        <ul class="nav-menu">
            <li><i class="fa-solid fa-house"></i> Inicio</li>
            <li class="active"><i class="fa-regular fa-file-lines"></i> Solicitud</li>
            <li><i class="fa-solid fa-list-check"></i> Reporte</li>
            <li><i class="fa-solid fa-clock-rotate-left"></i> Histórico</li>
        </ul>
        <div class="sidebar-footer">
            <a href="#" class="logout-btn"><i class="fa-solid fa-arrow-right-from-bracket"></i> Cerrar sesión</a>
        </div>
    </aside>

    <main class="main-content">
        <!-- Botón X para salir sin subir nada -->
        <button type="button" class="close-btn" onclick="volverADetalle()"><i class="fa-solid fa-xmark"></i></button>

        <!-- STEPPER CORREGIDO: Únicamente los primeros 4 están activos -->
        <div class="stepper-container">
            <div class="stepper-line"></div>
            <div class="step active"><div class="step-icon"><i class="fa-regular fa-file-lines"></i></div><div class="step-label">Solicitud<br>creada</div></div>
            <div class="step active"><div class="step-icon"><i class="fa-solid fa-file-export"></i></div><div class="step-label">Solicitud<br>enviada</div></div>
            <div class="step active"><div class="step-icon"><i class="fa-solid fa-file-circle-check"></i></div><div class="step-label">Solicitud<br>aceptada</div></div>
            <div class="step active"><div class="step-icon"><i class="fa-solid fa-file-signature"></i></div><div class="step-label">Carta<br>responsiva</div></div>

            <!-- Paso 5: Carta aceptada (EN GRIS) -->
            <div class="step"><div class="step-icon"><i class="fa-solid fa-file-circle-check"></i></div><div class="step-label">Carta<br>aceptada</div></div>

            <div class="step"><div class="step-icon"><i class="fa-solid fa-bus"></i></div><div class="step-label">Visita en<br>curso</div></div>
            <div class="step"><div class="step-icon"><i class="fa-solid fa-clipboard-list"></i></div><div class="step-label">Reporte<br>enviado</div></div>
            <div class="step"><div class="step-icon"><i class="fa-solid fa-clipboard-check"></i></div><div class="step-label">Reporte<br>aceptado</div></div>
            <div class="step"><div class="step-icon"><i class="fa-solid fa-circle-check"></i></div><div class="step-label">Visita<br>concretada</div></div>
        </div>

        <div class="upload-header">
            <div class="upload-title">
                <h2>Imágenes y Documentos</h2>
                <p>Adjunta imágenes (PNG, JPG, WEBP) y documentos (PDF)</p>
            </div>
            <div class="upload-stats">
                <strong id="files-count">0 de 5 archivos</strong>
                <p id="files-size">0 Bytes de 100 MB</p>
            </div>
        </div>

        <input type="file" id="real-file-input" accept=".pdf,.png,.jpg,.jpeg,.webp" style="display: none;">

        <div class="dropzone" id="dropzone-area">
            <button class="btn-browse" type="button" onclick="document.getElementById('real-file-input').click()">Explorar</button>
            <p class="dropzone-text">Arrastra archivos aquí o <span onclick="document.getElementById('real-file-input').click()">selecciona</span></p>
            <p class="dropzone-hint">PNG, JPG, WEBP, PDF • Máx. 10 MB por archivo</p>
        </div>

        <div class="table-container" id="table-container">
            <table class="doc-table">
                <thead>
                <tr>
                    <th width="10%">Tipo</th>
                    <th width="25%">Nombre</th>
                    <th width="15%">Tamaño</th>
                    <th width="20%">Fecha</th>
                    <th width="15%">Estado</th>
                    <th width="15%" style="text-align:center;">Acciones</th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td class="td-icon" id="doc-type-icon"><i class="fa-regular fa-file-pdf"></i></td>
                    <td id="doc-name">Carta_Responsiva_Firmada.pdf</td>
                    <td id="doc-size">0 KB</td>
                    <td id="doc-date">--/--/----</td>
                    <td><span class="badge-status">Borrador</span></td>
                    <td>
                        <div class="action-icons">
                            <i class="fa-solid fa-trash-can" title="Eliminar" onclick="eliminarArchivo()"></i>
                            <i class="fa-solid fa-download" title="Descargar" onclick="descargarArchivo()"></i>
                            <i class="fa-solid fa-eye" title="Ver archivo" onclick="verArchivo()"></i>
                        </div>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>

        <form id="uploadForm" action="cartaEnviadaExito.jsp?index=<%= indexNum %>" method="POST">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <footer class="action-buttons">
                <!-- Botón Anterior para salir sin subir nada -->
                <button type="button" class="btn-action" onclick="volverADetalle()">Anterior</button>
                <button type="submit" class="btn-action" id="btn-enviar" disabled>Enviar</button>
            </footer>
        </form>
    </main>
</div>

<script>
    const fileInput = document.getElementById('real-file-input');
    const tableContainer = document.getElementById('table-container');
    const btnEnviar = document.getElementById('btn-enviar');

    let archivoSeleccionado = null;

    function volverADetalle() {
        window.location.href = 'solicitud-detalle.jsp?index=<%= indexNum %>';
    }

    fileInput.addEventListener('change', function(e) {
        if (this.files && this.files[0]) {
            archivoSeleccionado = this.files[0];
            cargarInformacionArchivo(archivoSeleccionado);
        }
    });

    function cargarInformacionArchivo(file) {
        document.getElementById('doc-name').textContent = file.name;

        const sizeInKB = (file.size / 1024).toFixed(1);
        const sizeFormatted = sizeInKB > 1024 ? (sizeInKB / 1024).toFixed(2) + ' MB' : sizeInKB + ' KB';
        document.getElementById('doc-size').textContent = sizeFormatted;

        const ahora = new Date();
        const fechaFormatted = ahora.toLocaleDateString() + ', ' + ahora.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
        document.getElementById('doc-date').textContent = fechaFormatted;

        const ext = file.name.split('.').pop().toLowerCase();
        const iconElement = document.getElementById('doc-type-icon');
        if (ext === 'pdf') {
            iconElement.innerHTML = '<i class="fa-regular fa-file-pdf" style="color: #e11d48;"></i>';
        } else {
            iconElement.innerHTML = '<i class="fa-regular fa-file-image" style="color: #2563eb;"></i>';
        }

        document.getElementById('files-count').textContent = '1 de 5 archivos';
        document.getElementById('files-size').textContent = sizeFormatted + ' de 100 MB';

        tableContainer.style.display = 'block';

        // Habilitar únicamente el botón enviar, SIN modificar los pasos del Stepper
        btnEnviar.disabled = false;
    }

    function eliminarArchivo() {
        fileInput.value = '';
        archivoSeleccionado = null;
        tableContainer.style.display = 'none';
        btnEnviar.disabled = true;

        document.getElementById('files-count').textContent = '0 de 5 archivos';
        document.getElementById('files-size').textContent = '0 Bytes de 100 MB';
    }

    function verArchivo() {
        if (archivoSeleccionado) {
            const fileURL = URL.createObjectURL(archivoSeleccionado);
            window.open(fileURL, '_blank');
        }
    }

    function descargarArchivo() {
        if (archivoSeleccionado) {
            const a = document.createElement('a');
            a.href = URL.createObjectURL(archivoSeleccionado);
            a.download = archivoSeleccionado.name;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        }
    }
</script>
</body>
</html>
