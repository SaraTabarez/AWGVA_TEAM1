<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Subir carta responsiva con firmas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #a9bbcf;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #1e3a5f;
        }

        .main {
            margin-left: 240px;
            min-height: 100vh;
            padding: 18px;
        }

        .panel {
            max-width: 1050px;
            margin: auto;
            background: #fff;
            min-height: calc(100vh - 36px);
            padding: 28px 34px;
        }

        .stepper {
            display: flex;
            justify-content: space-between;
            position: relative;
            margin-bottom: 35px;
        }

        .stepper:before {
            content: "";
            position: absolute;
            left: 4%;
            right: 4%;
            top: 15px;
            height: 3px;
            background: #c9c4bb;
        }

        .step {
            width: 11%;
            text-align: center;
            z-index: 1;
            font-size: .58rem;
        }

        .circle {
            width: 31px;
            height: 31px;
            border-radius: 50%;
            margin: auto auto 5px;
            background: #c9c4bb;
            color: #fff;
            display: grid;
            place-items: center;
            font-size: .8rem;
        }

        .done .circle,
        .active .circle {
            background: #f59120;
        }

        .title-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .title-row h2 {
            font-size: 1rem;
            margin: 0 0 3px;
        }

        .muted {
            font-size: .7rem;
            color: #7c8795;
        }

        .drop {
            border: 2px dashed #f3a24e;
            min-height: 190px;
            margin-top: 24px;
            display: grid;
            place-items: center;
            text-align: center;
            cursor: pointer;
        }

        .browse {
            background: #1e3a5f;
            color: #fff;
            border: 0;
            border-radius: 5px;
            padding: 10px 36px;
            font-weight: 800;
        }

        .drop strong {
            display: block;
            margin-top: 15px;
            font-size: .8rem;
        }

        .drop small {
            display: block;
            color: #8a93a0;
            margin-top: 7px;
        }

        .table-wrap {
            margin-top: 18px;
            border: 1px solid #d7dee6;
            border-radius: 6px;
            overflow: hidden;
            display: none;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: .72rem;
        }

        th {
            background: #1e3a5f;
            color: #fff;
            padding: 10px;
            border-right: 1px solid #f59120;
        }

        td {
            padding: 12px;
            text-align: center;
            border-bottom: 1px solid #e5e7eb;
        }

        .badge {
            background: #1e3a5f;
            color: #fff;
            border-radius: 10px;
            padding: 3px 9px;
            font-size: .58rem;
        }

        .icon-btn {
            border: 0;
            background: transparent;
            color: #1e3a5f;
            cursor: pointer;
            margin: 0 3px;
        }

        .actions {
            display: flex;
            justify-content: space-between;
            margin-top: 25px;
        }

        .btn {
            border: 0;
            border-radius: 5px;
            padding: 10px 28px;
            background: #1e3a5f;
            color: #fff;
            text-decoration: none;
            font-weight: 800;
            cursor: pointer;
        }

        .btn:disabled {
            opacity: .45;
            cursor: not-allowed;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
            padding: 10px 14px;
            margin: 12px 0;
        }

        .existing {
            background: #e8f4ff;
            border: 1px solid #b7d9f5;
            padding: 10px 14px;
            margin: 12px 0;
            font-size: .75rem;
        }

        @media(max-width: 800px) {
            .main {
                margin-left: 0;
            }

            .stepper {
                overflow: auto;
            }

            .step {
                min-width: 90px;
            }

            .panel {
                padding: 20px 14px;
            }
        }
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>

<main class="main">
    <section class="panel">
        <!-- Stepper -->
        <div class="stepper">
            <div class="step done">
                <div class="circle"><i class="bi bi-file-earmark"></i></div>
                Solicitud creada
            </div>
            <div class="step done">
                <div class="circle"><i class="bi bi-file-earmark-check"></i></div>
                Solicitud enviada
            </div>
            <div class="step done">
                <div class="circle"><i class="bi bi-patch-check"></i></div>
                Solicitud aceptada
            </div>
            <div class="step active">
                <div class="circle"><i class="bi bi-file-text"></i></div>
                Carta enviada
            </div>
            <div class="step">
                <div class="circle"><i class="bi bi-patch-check"></i></div>
                Carta aceptada
            </div>
            <div class="step">
                <div class="circle"><i class="bi bi-truck"></i></div>
                Visita
            </div>
            <div class="step">
                <div class="circle"><i class="bi bi-images"></i></div>
                Reporte enviado
            </div>
            <div class="step">
                <div class="circle"><i class="bi bi-check2"></i></div>
                Reporte aceptado
            </div>
        </div>

        <!-- Header -->
        <div class="title-row">
            <div>
                <h2>Imágenes y Documentos</h2>
                <div class="muted">Adjunta la carta responsiva firmada exclusivamente en formato PDF</div>
            </div>
            <div class="muted" id="counter">
                0 de 1 archivo<br>0 Bytes de 10 MB
            </div>
        </div>

        <!-- Alertas -->
        <c:if test="${not empty error}">
            <div class="error"><c:out value="${error}"/></div>
        </c:if>

        <c:if test="${not empty documentoExistente}">
            <div class="existing">
                <i class="bi bi-info-circle"></i> Ya existe una carta responsiva con firmas:
                <strong><c:out value="${documentoExistente.nombreArchivo}"/></strong>.
                Al enviar otra, será reemplazada.
            </div>
        </c:if>

        <!-- Formulario de subida -->
        <form id="uploadForm" action="${ctx}/docente/subir-documento" method="post" enctype="multipart/form-data">
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <input type="hidden" name="ref" value="<c:out value='${expediente.referenceToken}'/>">
            <input type="hidden" name="tipo" value="CARTA_RESPONSIVA">

            <label class="drop" for="archivo">
                <div>
                    <button class="browse" type="button" onclick="document.getElementById('archivo').click()">Explorar</button>
                    <strong>Arrastra el PDF aquí o selecciónalo</strong>
                    <small>PDF · Máx. 10 MB por archivo</small>
                </div>
            </label>
            <input id="archivo" name="archivo" type="file" accept="application/pdf,.pdf" hidden required>

            <!-- Tabla del archivo cargado -->
            <div class="table-wrap" id="tableWrap">
                <table>
                    <thead>
                    <tr>
                        <th>Tipo</th>
                        <th>Nombre</th>
                        <th>Tamaño</th>
                        <th>Fecha</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td>
                            <i class="bi bi-file-earmark-pdf"></i><br>Carta responsiva
                        </td>
                        <td id="fileName"></td>
                        <td id="fileSize"></td>
                        <td id="fileDate"></td>
                        <td><span class="badge">Borrador</span></td>
                        <td>
                            <button class="icon-btn" type="button" onclick="limpiar()" title="Eliminar">
                                <i class="bi bi-trash"></i>
                            </button>
                            <a class="icon-btn" id="download" download title="Descargar">
                                <i class="bi bi-download"></i>
                            </a>
                            <a class="icon-btn" id="preview" target="_blank" title="Vista previa">
                                <i class="bi bi-eye"></i>
                            </a>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <!-- Botones de Acción -->
            <div class="actions">
                <button class="btn" type="button" data-post-url="${ctx}/detalle-solicitud" data-post-ref="<c:out value='${expediente.referenceToken}'/>">Anterior</button>
                <button class="btn" id="send" type="submit" disabled>Enviar</button>
            </div>
        </form>
    </section>
</main>

<script>
    const input = document.getElementById('archivo');
    const wrap = document.getElementById('tableWrap');
    const send = document.getElementById('send');
    const counter = document.getElementById('counter');
    let objectUrl = null;

    function formatSize(n) {
        return n < 1024
            ? n + ' B'
            : n < 1048576
                ? (n / 1024).toFixed(1) + ' KB'
                : (n / 1048576).toFixed(1) + ' MB';
    }

    function cargar(file) {
        if (!file) return;

        const pdf = file.name.toLowerCase().endsWith('.pdf') && (!file.type || file.type === 'application/pdf');
        if (!pdf) {
            alert('Sólo se permiten archivos PDF.');
            limpiar();
            return;
        }

        if (file.size > 10 * 1024 * 1024) {
            alert('El PDF no debe superar 10 MB.');
            limpiar();
            return;
        }

        if (objectUrl) URL.revokeObjectURL(objectUrl);
        objectUrl = URL.createObjectURL(file);

        document.getElementById('fileName').textContent = file.name;
        document.getElementById('fileSize').textContent = formatSize(file.size);
        document.getElementById('fileDate').textContent = new Date().toLocaleString('es-MX');
        document.getElementById('preview').href = objectUrl;
        document.getElementById('download').href = objectUrl;
        document.getElementById('download').download = file.name;

        counter.innerHTML = '1 de 1 archivo<br>' + formatSize(file.size) + ' de 10 MB';
        wrap.style.display = 'block';
        send.disabled = false;
    }

    function limpiar() {
        input.value = '';
        wrap.style.display = 'none';
        send.disabled = true;
        counter.innerHTML = '0 de 1 archivo<br>0 Bytes de 10 MB';
        if (objectUrl) {
            URL.revokeObjectURL(objectUrl);
            objectUrl = null;
        }
    }

    input.addEventListener('change', () => cargar(input.files[0]));

    const drop = document.querySelector('.drop');
    drop.addEventListener('dragover', e => e.preventDefault());
    drop.addEventListener('drop', e => {
        e.preventDefault();
        if (e.dataTransfer.files.length) {
            const dt = new DataTransfer();
            dt.items.add(e.dataTransfer.files[0]);
            input.files = dt.files;
            cargar(input.files[0]);
        }
    });

    document.getElementById('uploadForm').addEventListener('submit', e => {
        if (!input.files.length) {
            e.preventDefault();
            alert('Selecciona la carta responsiva firmada en PDF.');
        }
    });
</script>
</body>
</html>
