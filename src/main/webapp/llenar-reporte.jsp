<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="reporteRechazado" value="${not empty reporte and fn:toUpperCase(reporte.estado) eq 'RECHAZADO'}"/>
<c:set var="estadoFlujo" value="${fn:toUpperCase(expediente.estado)}"/>
<c:set var="reporteEnviado" value="${not empty reporte or estadoFlujo == 'REPORTE_EN_REVISION' or estadoFlujo == 'REPORTE_RECHAZADO' or estadoFlujo == 'COMPLETADA'}"/>
<c:set var="reporteAceptado" value="${(not empty reporte and fn:toUpperCase(reporte.estado) == 'ACEPTADO') or estadoFlujo == 'COMPLETADA'}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reporte de visita académica</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #fff;
            color: #1e3a5f;
            font-family: "Segoe UI", Arial, sans-serif;
        }

        .main {
            margin-left: 240px;
            min-height: 100vh;
            padding: 26px 36px;
        }

        .top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .top h1 {
            font-size: 1.3rem;
            margin: 0;
        }

        .steps {
            display: flex;
            gap: 15px;
        }

        .step {
            text-align: center;
            font-size: .55rem;
            color: #7a8490;
        }

        .step i {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #c8c2b9;
            color: #fff;
            display: grid;
            place-items: center;
            margin: auto auto 4px;
        }

        .step.done i,
        .step.active i {
            background: #f59120;
        }

        .date {
            font-size: .65rem;
            text-align: right;
        }

        .section {
            border: 1px solid #d6dee7;
            border-radius: 5px;
            margin-top: 18px;
            padding: 15px;
        }

        .section-title {
            font-size: .8rem;
            font-weight: 850;
            margin-bottom: 10px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
        }

        .field label {
            display: block;
            font-size: .58rem;
            font-weight: 800;
            margin-bottom: 3px;
        }

        .value {
            min-height: 29px;
            padding: 6px 8px;
            background: #e9f0f7;
            border: 1px solid #d6e0ea;
            font-size: .68rem;
        }

        .span2 {
            grid-column: span 2;
        }

        .upload-title {
            color: #f59120;
            font-size: .78rem;
            font-weight: 850;
        }

        .upload-grid {
            display: grid;
            grid-template-columns: repeat(3, 130px);
            gap: 14px;
            margin-top: 13px;
        }

        .photo {
            height: 110px;
            background: #e9f0f7;
            border: 1px solid #d9e1ea;
            border-radius: 4px;
            position: relative;
            overflow: hidden;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            font-size: .62rem;
            font-weight: 700;
        }

        .photo i {
            display: block;
            font-size: 1.3rem;
            color: #f59120;
            margin-bottom: 5px;
        }

        .photo img {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .photo span {
            z-index: 2;
            background: rgba(255, 255, 255, .82);
            padding: 4px;
        }

        .actions {
            display: flex;
            justify-content: space-between;
            margin-top: 22px;
        }

        .btn {
            border: 0;
            border-radius: 5px;
            padding: 10px 22px;
            background: #1e3a5f;
            color: #fff;
            text-decoration: none;
            font-weight: 800;
            cursor: pointer;
        }

        .send {
            background: #f59120;
        }

        .send:disabled {
            opacity: .45;
        }

        .alert {
            padding: 11px 14px;
            margin: 12px 0;
            border-radius: 5px;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
        }

        .info {
            background: #e8f4ff;
            color: #174b73;
        }

        .rejected {
            background: #fff1f2;
            color: #9f1239;
        }

        .evidence-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
        }

        .evidence {
            border: 1px solid #d7dee7;
            border-radius: 6px;
            overflow: hidden;
        }

        .evidence img {
            width: 100%;
            height: 180px;
            object-fit: cover;
            display: block;
        }

        .evidence div {
            padding: 8px;
            font-size: .7rem;
            text-align: center;
        }

        @media(max-width: 850px) {
            .main {
                margin-left: 0;
                padding: 20px 14px;
            }

            .top {
                display: block;
            }

            .steps {
                overflow: auto;
                margin-top: 15px;
            }

            .grid {
                grid-template-columns: 1fr 1fr;
            }

            .upload-grid,
            .evidence-grid {
                grid-template-columns: 1fr;
            }

            .photo {
                width: 100%;
            }

            .span2 {
                grid-column: span 2;
            }
        }
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>

<main class="main">
    <!-- Encabezado y Stepper -->
    <div class="top">
        <div>
            <h1>REPORTE DE VISITA ACADÉMICA</h1>
        </div>
        <div class="steps">
            <div class="step done"><i class="bi bi-file-earmark"></i>Solicitud creada</div>
            <div class="step done"><i class="bi bi-send"></i>Solicitud enviada</div>
            <div class="step done"><i class="bi bi-check2"></i>Solicitud aceptada</div>
            <div class="step done"><i class="bi bi-file-text"></i>Carta enviada</div>
            <div class="step done"><i class="bi bi-check2"></i>Carta aceptada</div>
            <div class="step done"><i class="bi bi-truck"></i>Visita</div>
            <div class="step ${reporteEnviado ? 'done' : ''}"><i class="bi bi-images"></i>Reporte enviado</div>
            <div class="step ${reporteAceptado ? 'done' : ''}"><i class="bi bi-check2-all"></i>Reporte aceptado</div>
        </div>
        <div class="date">Expediente de visita</div>
    </div>

    <!-- Alertas -->
    <c:if test="${not empty error}">
        <div class="alert error"><c:out value="${error}"/></div>
    </c:if>

    <c:if test="${reporteRechazado}">
        <div class="alert rejected">
            <strong>Reporte con correcciones:</strong> <c:out value="${reporte.observaciones}"/>. Puedes volver a enviar las tres fotografías.
        </div>
    </c:if>

    <!-- Información de la Visita -->
    <section class="section">
        <div class="section-title">Datos de los participantes y responsables</div>
        <div class="grid">
            <div class="field">
                <label>ÁREA DEL SOLICITANTE</label>
                <div class="value"><c:out value="${expediente.division}"/></div>
            </div>
            <div class="field span2">
                <label>DOCENTE RESPONSABLE</label>
                <div class="value"><c:out value="${expediente.docente}"/></div>
            </div>
            <div class="field">
                <label>TELÉFONO / CORREO</label>
                <div class="value"><c:out value="${expediente.correoDocente}"/></div>
            </div>
            <div class="field span2">
                <label>PROGRAMA EDUCATIVO</label>
                <div class="value"><c:out value="${expediente.carrera}"/></div>
            </div>
            <div class="field">
                <label>CUATRIMESTRE</label>
                <div class="value"><c:out value="${expediente.semestre}"/></div>
            </div>
            <div class="field">
                <label>GRUPO / ESTUDIANTES</label>
                <div class="value"><c:out value="${expediente.grupo}"/> · <c:out value="${expediente.numeroEstudiantes}"/></div>
            </div>
        </div>

        <div class="section-title" style="margin-top:14px">Datos del lugar a visitar</div>
        <div class="grid">
            <div class="field span2">
                <label>EMPRESA</label>
                <div class="value"><c:out value="${expediente.empresa}"/></div>
            </div>
            <div class="field span2">
                <label>LUGAR O DIRECCIÓN</label>
                <div class="value"><c:out value="${expediente.direccionEmpresa}"/></div>
            </div>
            <div class="field">
                <label>TELÉFONO</label>
                <div class="value"><c:out value="${expediente.telefonoEmpresa}"/></div>
            </div>
            <div class="field">
                <label>CORREO</label>
                <div class="value"><c:out value="${expediente.correoEmpresa}"/></div>
            </div>
            <div class="field">
                <label>FECHA DE INICIO</label>
                <div class="value"><c:out value="${expediente.fechaInicio}"/></div>
            </div>
            <div class="field">
                <label>FECHA DE TÉRMINO</label>
                <div class="value"><c:out value="${expediente.fechaFin}"/></div>
            </div>
            <div class="field span2">
                <label>OBJETIVO</label>
                <div class="value"><c:out value="${expediente.proposito}"/></div>
            </div>
            <div class="field span2">
                <label>ASIGNATURAS</label>
                <div class="value"><c:out value="${expediente.asignatura}"/></div>
            </div>
        </div>
    </section>

    <!-- Subida o Visualización de Reportes -->
    <c:choose>
        <c:when test="${empty reporte or reporteRechazado}">
            <form id="reportForm" action="${ctx}/docente/subir-reporte" method="post" enctype="multipart/form-data">
                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                <input type="hidden" name="ref" value="<c:out value='${expediente.referenceToken}'/>">

                <section class="section">
                    <div class="upload-title">Subida de evidencias</div>
                    <div style="font-size:.65rem">Agrega exactamente tres fotografías de la visita. Formatos: PNG, JPG, JPEG o WEBP. Máximo 10 MB por foto.</div>
                    <div class="upload-grid">
                        <c:forEach begin="1" end="3" var="n">
                            <label class="photo" for="evidencia${n}">
                                <div><i class="bi bi-image"></i>Foto ${n}</div>
                                <img id="preview${n}" alt="Vista previa" hidden>
                                <span id="name${n}" hidden></span>
                            </label>
                            <input hidden class="evidence-input" type="file" id="evidencia${n}" name="evidencia${n}" accept="image/png,image/jpeg,image/webp,.png,.jpg,.jpeg,.webp" required>
                        </c:forEach>
                    </div>
                </section>

                <div class="actions">
                    <button class="btn" type="button" data-post-url="${ctx}/detalle-solicitud" data-post-ref="<c:out value='${expediente.referenceToken}'/>">Atrás</button>
                    <button class="btn send" id="send" type="submit" disabled>Enviar reporte</button>
                </div>
            </form>
        </c:when>
        <c:otherwise>
            <div class="alert info">
                <strong>Reporte enviado.</strong> Se encuentra en estado: <c:out value="${reporte.estado}"/>. La solicitud permanecerá en Reportes hasta que Estadías la acepte.
            </div>
            <section class="section">
                <div class="section-title">Tres evidencias enviadas</div>
                <div class="evidence-grid">
                    <c:forEach var="doc" items="${expediente.documentos}">
                        <div class="evidence">
                            <img data-private-image="<c:out value='${doc.fileToken}'/>" alt="Evidencia">
                            <div><c:out value="${doc.nombreArchivo}"/></div>
                        </div>
                    </c:forEach>
                </div>
            </section>
            <div class="actions">
                <a class="btn" href="${ctx}/reportes-docente">Atrás</a>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<script>
    const inputs = [...document.querySelectorAll('.evidence-input')];
    const send = document.getElementById('send');

    function validar() {
        if (!send) return;
        const edicion = ${not empty reporte ? 'true' : 'false'};
        send.disabled = edicion ? !inputs.some(i => i.files.length === 1) : !inputs.every(i => i.files.length === 1);
    }

    inputs.forEach((input, index) => input.addEventListener('change', () => {
        const file = input.files[0];
        if (!file) {
            validar();
            return;
        }

        const ok = /\.(png|jpe?g|webp)$/i.test(file.name) && file.size <= 10 * 1024 * 1024;
        if (!ok) {
            alert('Cada evidencia debe ser una imagen PNG, JPG, JPEG o WEBP de máximo 10 MB.');
            input.value = '';
            validar();
            return;
        }

        const n = index + 1;
        const img = document.getElementById('preview' + n);
        const name = document.getElementById('name' + n);

        img.src = URL.createObjectURL(file);
        img.hidden = false;
        name.textContent = file.name;
        name.hidden = false;

        validar();
    }));

    const form = document.getElementById('reportForm');
    if (form) {
        form.addEventListener('submit', e => {
            if (!inputs.every(i => i.files.length)) {
                e.preventDefault();
                alert('Selecciona las tres fotografías del reporte.');
            }
        });
    }
</script>
</body>
</html>