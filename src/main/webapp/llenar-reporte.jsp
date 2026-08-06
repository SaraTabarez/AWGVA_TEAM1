<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Visita Académica</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body, html {
            height: 100%;
            margin: 0;
            background-color: #9cb0c4;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .full-wrapper {
            min-height: 100vh;
            display: flex;
            padding: 1rem;
        }
        .app-container {
            flex: 1;
            background: #ffffff;
            display: flex;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        }

        /* SIDEBAR IDENTICO AL ORIGINAL */
        .sidebar {
            width: 240px;
            background-color: #1f3a5e;
            color: #ffffff;
            padding: 2rem 1rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            flex-shrink: 0;
        }
        .avatar-circle {
            width: 75px;
            height: 75px;
            background-color: #e2e8f0;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #1f3a5e;
            font-size: 2.4rem;
            margin-bottom: 0.5rem;
        }
        .role-title {
            font-weight: 700;
            font-size: 0.95rem;
            letter-spacing: 1px;
            margin-bottom: 2.5rem;
        }
        .sidebar-menu { width: 100%; list-style: none; padding: 0; margin: 0; }
        .sidebar-menu li { margin-bottom: 0.8rem; }
        .sidebar-menu a {
            color: #ffffff; text-decoration: none; display: flex; align-items: center;
            gap: 12px; font-size: 0.95rem; font-weight: 500; padding: 10px 14px; border-radius: 8px;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background-color: rgba(255,255,255,0.15); }
        .logout-link { margin-top: auto; width: 100%; }
        .logout-link a { color: #ffffff; text-decoration: none; display: flex; align-items: center; gap: 8px; }

        /* CONTENIDO PRINCIPAL */
        .main-content {
            flex-grow: 1;
            padding: 2rem 3rem;
            overflow-y: auto;
            background-color: #ffffff;
        }

        /* BARRA DE PROGRESO SIMULADA */
        .progress-tracker {
            display: flex;
            justify-content: center;
            align-items: flex-start;
            margin-bottom: 2rem;
            gap: 15px;
            text-align: center;
        }
        .step { display: flex; flex-direction: column; align-items: center; width: 70px; }
        .step-icon {
            width: 35px; height: 35px; border-radius: 50%; background-color: #f59e0b; color: white;
            display: flex; align-items: center; justify-content: center; margin-bottom: 5px; font-size: 0.9rem;
        }
        .step-icon.pending { background-color: #cbd5e1; color: #64748b; }
        .step-text { font-size: 0.65rem; color: #475569; line-height: 1.1; font-weight: 600; }

        .header-title {
            color: #0f172a; font-weight: bold; font-size: 1.6rem; margin-bottom: 2rem;
            display: flex; justify-content: space-between; align-items: center;
        }
        .section-title {
            color: #1f3a5e; font-size: 1.2rem; font-weight: 600; margin-bottom: 1rem; margin-top: 1.5rem;
        }

        /* INPUTS ESTILO FIGMA */
        .custom-label {
            font-size: 0.85rem; font-weight: 700; color: #1f3a5e; margin-bottom: 0.3rem;
        }
        .input-readonly {
            background-color: #e2e8f0; border: none; border-radius: 4px; padding: 6px 12px;
            font-size: 0.9rem; color: #64748b; width: 100%; font-weight: 500; outline: none;
        }

        /* CAJA DE SUBIDA DE ARCHIVOS */
        .upload-box {
            border: 1px solid #94a3b8; border-radius: 8px; padding: 1.5rem; margin-top: 1rem;
        }
        .upload-title { color: #f59e0b; font-weight: bold; font-size: 1.1rem; margin-bottom: 1rem; }
        .file-upload-wrapper { display: flex; gap: 15px; flex-wrap: wrap; }

        .upload-square {
            width: 120px; height: 120px; background-color: #e2e8f0; border-radius: 6px;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            cursor: pointer; transition: background 0.2s; text-align: center;
        }
        .upload-square:hover { background-color: #cbd5e1; }
        .upload-square span { font-size: 1.5rem; color: #64748b; margin-bottom: 5px; }
        .upload-square .foto-text { font-weight: bold; color: #0f172a; font-size: 0.9rem; margin: 0;}
        .upload-square .sel-text { color: #f59e0b; font-weight: bold; font-size: 0.8rem; }
        input[type="file"] { display: none; }

        /* BOTONES FINALES */
        .btn-atras {
            background-color: #f59e0b; color: white; font-weight: bold; border: none;
            padding: 10px 30px; border-radius: 6px; text-decoration: none;
        }
        .btn-enviar {
            background-color: #f59e0b; color: white; font-weight: bold; border: none;
            padding: 10px; border-radius: 6px; width: 100%; max-width: 400px;
        }
    </style>
</head>
<body>

<div class="full-wrapper">
    <div class="app-container">

        <!-- SIDEBAR -->
        <div class="sidebar">
            <div class="avatar-circle"><i class="bi bi-person"></i></div>
            <div class="role-title">DOCENTE</div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/inicio"><i class="bi bi-house-door"></i> Inicio</a></li>
                <li><a href="${pageContext.request.contextPath}/mis-solicitudes"><i class="bi bi-file-earmark-text"></i> Solicitud</a></li>
                <li><a href="${pageContext.request.contextPath}/reportes-docente" class="active"><i class="bi bi-camera"></i> Reporte</a></li>
                <li><a href="${pageContext.request.contextPath}/historico-docente"><i class="bi bi-clock-history"></i> Histórico</a></li>
            </ul>
            <div class="logout-link">
                <form action="${pageContext.request.contextPath}/logout" method="post">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <button type="submit" class="btn text-white"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</button>
                </form>
            </div>
        </div>

        <!-- MAIN CONTENT -->
        <div class="main-content">

            <!-- Simulador de Barra de Progreso -->
            <div class="progress-tracker">
                <div class="step"><div class="step-icon"><i class="bi bi-file-earmark-text"></i></div><div class="step-text">Solicitud creada</div></div>
                <div class="step"><div class="step-icon"><i class="bi bi-send"></i></div><div class="step-text">Solicitud enviada</div></div>
                <div class="step"><div class="step-icon"><i class="bi bi-check-circle"></i></div><div class="step-text">Solicitud aceptada</div></div>
                <div class="step"><div class="step-icon"><i class="bi bi-envelope-paper"></i></div><div class="step-text">Carta responsiva enviada</div></div>
                <div class="step"><div class="step-icon"><i class="bi bi-check2-all"></i></div><div class="step-text">Carta responsiva aceptada</div></div>
                <div class="step"><div class="step-icon"><i class="bi bi-bus-front"></i></div><div class="step-text">Visita en curso</div></div>
                <div class="step"><div class="step-icon"><i class="bi bi-camera"></i></div><div class="step-text">Reporte enviado</div></div>
                <div class="step"><div class="step-icon pending"><i class="bi bi-shield-check"></i></div><div class="step-text">Reporte aceptado</div></div>
                <div class="step"><div class="step-icon pending"><i class="bi bi-flag"></i></div><div class="step-text">Visita concretada</div></div>
            </div>

            <!-- Cabecera -->
            <div class="header-title">
                REPORTE DE VISITA ACADÉMICA
                <div style="text-align: right; font-size: 0.8rem; color: #0f172a; font-weight: bold;">
                    FO-UTEZ-EST-08<br>rev.08
                </div>
            </div>

            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="custom-label">Fecha de solicitud:</div>
                    <input type="text" class="input-readonly" value="<c:out value='${expediente.creadoEn}'/>" readonly>
                </div>
            </div>

            <!-- INICIO DEL FORMULARIO - Modificado para ir directo a la vista de éxito -->
            <form action="${pageContext.request.contextPath}/docente/subir-reporte" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="idVisita" value="${expediente.idVisita}">

                <!-- SECCIÓN 1 -->
                <div class="section-title">Datos de los participantes y Responsables</div>

                <div class="row g-3 mb-3">
                    <div class="col-md-4">
                        <div class="custom-label">Área del solicitante:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.division}'/>" readonly>
                    </div>
                    <div class="col-md-4">
                        <div class="custom-label">Docente responsable:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.docente}'/>" readonly>
                    </div>
                    <div class="col-md-4">
                        <div class="custom-label">Teléfono de contacto:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.correoDocente}'/>" readonly>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <div class="custom-label">Docente acompañante:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.docenteAcompanante}'/>" readonly>
                    </div>
                    <div class="col-md-6">
                        <div class="custom-label">División o área del participante:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.division}'/>" readonly>
                    </div>
                </div>

                <div class="row g-3 mb-2">
                    <div class="col-md-3">
                        <div class="custom-label">Programa educativo:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.carrera}'/>" readonly>
                    </div>
                    <div class="col-md-3">
                        <div class="custom-label">Cuatrimestre:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.semestre}'/>" readonly>
                    </div>
                    <div class="col-md-3">
                        <div class="custom-label">Grupo:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.grupo}'/>" readonly>
                    </div>
                    <div class="col-md-3">
                        <div class="custom-label">Nu. de Estudiantes:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.numeroEstudiantes}'/>" readonly>
                    </div>
                </div>

                <!-- SECCIÓN 2 -->
                <div class="section-title">Datos del lugar a visitar</div>

                <div class="row g-3 mb-3">
                    <div class="col-md-4">
                        <div class="custom-label">Nombre de la empresa o actividad:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.empresa}'/>" readonly>
                    </div>
                    <div class="col-md-4">
                        <div class="custom-label">Lugar o dirección:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.direccionEmpresa}'/>" readonly>
                    </div>
                    <div class="col-md-4">
                        <div class="custom-label">Teléfono de contacto:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.telefonoEmpresa}'/>" readonly>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <div class="custom-label">Correo electrónico:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.correoEmpresa}'/>" readonly>
                    </div>
                    <div class="col-md-4">
                        <div class="custom-label">Objetivo de la visita:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.proposito}'/>" readonly>
                    </div>
                    <div class="col-md-2">
                        <div class="custom-label">Fecha de inicio:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.fechaInicio}'/>" readonly>
                    </div>
                    <div class="col-md-2">
                        <div class="custom-label">Fecha de término:</div>
                        <input type="text" class="input-readonly" value="<c:out value='${expediente.fechaFin}'/>" readonly>
                    </div>
                </div>

                <!-- SECCIÓN 3: EVIDENCIAS -->
                <div class="upload-box">
                    <div class="upload-title">Subida de Documentos y Evidencias</div>
                    <div class="custom-label text-dark mb-3"><i class="bi bi-camera-fill text-warning"></i> Asignatura que se refuerza con la visita:</div>

                    <div class="file-upload-wrapper">
                        <label class="upload-square" for="reportePdf">
                            <span><i class="bi bi-file-earmark-pdf"></i></span>
                            <p class="foto-text">Reporte PDF</p>
                            <p class="sel-text">Seleccionar</p>
                            <input type="file" id="reportePdf" name="reporte" accept="application/pdf,.pdf" required onchange="actualizarTexto(this, 0)">
                        </label>
                        <!-- Foto 1 -->
                        <label class="upload-square" for="foto1">
                            <span>+</span>
                            <p class="foto-text">Foto 1</p>
                            <p class="sel-text">Seleccionar</p>
                            <input type="file" id="foto1" name="evidencia1" accept=".png,.jpg,.jpeg,.webp" required onchange="actualizarTexto(this, 1)">
                        </label>

                        <!-- Foto 2 -->
                        <label class="upload-square" for="foto2">
                            <span>+</span>
                            <p class="foto-text">Foto 2</p>
                            <p class="sel-text">Seleccionar</p>
                            <input type="file" id="foto2" name="evidencia2" accept=".png,.jpg,.jpeg,.webp" required onchange="actualizarTexto(this, 2)">
                        </label>

                        <!-- Foto 3 -->
                        <label class="upload-square" for="foto3">
                            <span>+</span>
                            <p class="foto-text">Foto 3</p>
                            <p class="sel-text">Seleccionar</p>
                            <input type="file" id="foto3" name="evidencia3" accept=".png,.jpg,.jpeg,.webp" required onchange="actualizarTexto(this, 3)">
                        </label>
                    </div>
                </div>

                <!-- BOTONES DE ACCIÓN -->
                <div class="d-flex justify-content-between align-items-center mt-4">
                    <a href="${pageContext.request.contextPath}/detalle-solicitud?id=${expediente.idVisita}" class="btn-atras">Atrás</a>
                    <button type="submit" class="btn-enviar">[Enviar Reporte a Revisión]</button>
                </div>

            </form>
        </div>
    </div>
</div>

<script>
    // Script sencillo para que cuando seleccionen la foto, el cuadro avise que ya se cargó
    function actualizarTexto(input, num) {
        if (input.files && input.files[0]) {
            let label = input.parentElement;
            label.style.backgroundColor = '#dcfce3'; // Cambia a un tonito verde
            label.querySelector('.sel-text').textContent = 'Cargada ✓';
            label.querySelector('.sel-text').style.color = '#166534';
        }
    }
</script>

</body>
</html>
