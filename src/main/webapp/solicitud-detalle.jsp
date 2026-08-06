<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitud de Visita Industrial - Detalles</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        * { box-sizing: border-box; }

        body, html {
            height: 100%;
            margin: 0;
            padding: 0;
            background-color: #9cb0c4;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            overflow-x: hidden;
        }

        .full-screen-wrapper {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            padding: 1rem;
        }

        .dashboard-container {
            flex: 1;
            width: 100%;
            background: #ffffff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            display: flex;
        }

        /* Sidebar Izquierdo */
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

        .sidebar-menu {
            width: 100%;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .sidebar-menu li { margin-bottom: 0.8rem; }

        .sidebar-menu a {
            color: #ffffff;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.95rem;
            font-weight: 500;
            padding: 10px 14px;
            border-radius: 8px;
            transition: all 0.25s ease;
        }

        .sidebar-menu a:hover {
            background-color: rgba(255, 255, 255, 0.15);
            color: #f59e0b;
        }

        .logout-link {
            margin-top: auto;
            width: 100%;
        }

        .logout-link a {
            color: #ffffff;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            padding: 8px 12px;
            border-radius: 6px;
        }

        /* Contenido Principal */
        .main-content {
            flex-grow: 1;
            padding: 2rem 2.5rem;
            position: relative;
            background-color: #ffffff;
            overflow-y: auto;
        }

        .btn-close-custom {
            position: absolute;
            top: 20px;
            right: 25px;
            font-size: 1.4rem;
            color: #64748b;
            text-decoration: none;
            cursor: pointer;
            transition: color 0.2s, transform 0.2s;
        }

        .btn-close-custom:hover {
            color: #ef4444;
            transform: scale(1.15) rotate(90deg);
        }

        .main-title {
            text-align: center;
            font-weight: 700;
            color: #1a202c;
            font-size: 1.5rem;
            margin-bottom: 1.8rem;
        }

        /* Tarjetas de Información */
        .info-card {
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 1.25rem 1.5rem;
            height: 100%;
            background-color: #ffffff;
        }

        .card-header-title {
            font-weight: 600;
            font-size: 1rem;
            color: #1f3a5e;
            margin-bottom: 0.85rem;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .badge-status {
            border: 1px solid #cbd5e1;
            border-radius: 20px;
            padding: 10px 24px;
            font-weight: 700;
            color: #1f3a5e;
            font-size: 0.95rem;
            display: inline-block;
            text-align: center;
            width: 100%;
            background-color: #f8fafc;
        }

        .label-sm {
            font-size: 0.75rem;
            text-transform: uppercase;
            font-weight: 700;
            color: #64748b;
            margin-bottom: 3px;
            display: block;
        }

        .val-text {
            font-weight: 700;
            color: #0f172a;
            font-size: 1rem;
            margin-bottom: 6px;
        }

        .val-subtext {
            color: #475569;
            font-size: 0.9rem;
        }

        .custom-input {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 8px 14px;
            font-size: 0.9rem;
            color: #334155;
            width: 100%;
        }

        /* Botones de Documentos */
        .btn-doc-grey {
            background-color: #b0a8a0;
            color: #ffffff;
            font-weight: 600;
            border: none;
            border-radius: 8px;
            padding: 10px 14px;
            font-size: 0.85rem;
            width: 100%;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.2s ease;
        }

        .btn-doc-grey:hover {
            background-color: #928a82;
            color: #ffffff;
        }

        .btn-doc-navy {
            background-color: #1f3a5e;
            color: #ffffff;
            font-weight: 600;
            border: none;
            border-radius: 8px;
            padding: 10px 14px;
            font-size: 0.85rem;
            width: 100%;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.2s ease;
        }

        .btn-doc-navy:hover {
            background-color: #132742;
            color: #ffffff;
        }

        .btn-orange {
            background-color: #f59e0b;
            color: #ffffff;
            font-weight: 700;
            border: none;
            border-radius: 8px;
            padding: 10px 40px;
            font-size: 0.9rem;
            text-decoration: none;
            display: inline-block;
            transition: all 0.25s ease;
        }

        .btn-orange:hover {
            background-color: #d97706;
            color: #ffffff;
        }
    </style>
</head>
<body>

<div class="full-screen-wrapper">
    <div class="px-2 pb-2 text-secondary fw-semibold" style="font-size: 0.85rem;">Vista de detalles.</div>

    <div class="dashboard-container">
        <!-- BARRA LATERAL (SIDEBAR) -->
        <div class="sidebar">
            <div class="avatar-circle">
                <i class="bi bi-person"></i>
            </div>
            <div class="role-title">DOCENTE</div>

            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/inicio"><i class="bi bi-house-door"></i> Inicio</a></li>
                <li><a href="${pageContext.request.contextPath}/mis-solicitudes"><i class="bi bi-file-earmark-text"></i> Solicitud</a></li>
                <li><a href="${pageContext.request.contextPath}/reportes-docente"><i class="bi bi-camera"></i> Reporte</a></li>
                <li><a href="${pageContext.request.contextPath}/historico-docente"><i class="bi bi-clock-history"></i> Histórico</a></li>
            </ul>

            <div class="logout-link">
                <form action="${pageContext.request.contextPath}/logout" method="post">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <button type="submit" class="btn text-white"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</button>
                </form>
            </div>
        </div>

        <!-- CONTENIDO PRINCIPAL -->
        <div class="main-content">
            <a href="${pageContext.request.contextPath}/mis-solicitudes" class="btn-close-custom" title="Cerrar"><i class="bi bi-x-lg"></i></a>

            <h4 class="main-title">Solicitud de Visita Industrial-División Académica</h4>

            <!-- FILA 1: Dirección Académica y Estado -->
            <div class="row g-3 mb-3">
                <div class="col-md-7">
                    <div class="info-card">
                        <div class="card-header-title">
                            <span>📍</span> Información de la Dirección Académica
                        </div>
                        <div class="val-subtext mb-1">
                            <strong>División:</strong> <c:out value="${expediente.division}"/>
                        </div>
                        <div class="val-subtext">
                            <strong>Cargo:</strong> Directora
                        </div>
                    </div>
                </div>

                <div class="col-md-5 d-flex align-items-center">
                    <div class="badge-status">
                        Estado: <c:out value="${expediente.estadoLegible}"/>
                    </div>
                </div>
            </div>

            <!-- FILA 2: Detalles Principales e Información de la Empresa -->
            <div class="row g-3 mb-3">
                <!-- Detalles Principales -->
                <div class="col-md-6">
                    <div class="info-card">
                        <div class="card-header-title">
                            <span>📍</span> Detalles Principales
                        </div>

                        <span class="label-sm">LUGAR DE VISITA</span>
                        <div class="val-text text-uppercase" style="color: #1f3a5e;">
                            <c:out value="${expediente.empresa}"/>
                        </div>

                        <span class="label-sm mt-2">FECHA DE VISITA</span>
                        <div class="val-text">
                            <c:out value="${expediente.fechaInicio}"/> — <c:out value="${expediente.fechaFin}"/>
                        </div>
                        <div class="val-subtext mb-2">
                            ID de solicitud: <c:out value="${expediente.idVisita}"/>
                        </div>

                        <span class="label-sm">Carrera y Grupo</span>
                        <div class="val-text" style="font-size: 0.95rem;">
                            <c:out value="${expediente.carrera}"/> · <c:out value="${expediente.semestre}"/> <c:out value="${expediente.grupo}"/>
                        </div>
                        <div class="val-subtext">
                            🏫 <strong>Asignaturas: <c:out value="${expediente.asignatura}"/></strong><br>
                            Objetivo: <c:out value="${expediente.proposito}"/>
                        </div>
                    </div>
                </div>

                <!-- Información de la Empresa -->
                <div class="col-md-6">
                    <div class="info-card">
                        <div class="card-header-title">
                            <span>🏢</span> Información de la Empresa
                        </div>

                        <label class="label-sm">Nombre de la Empresa</label>
                        <input type="text" class="custom-input mb-2" value="<c:out value='${expediente.empresa}'/>" readonly>

                        <label class="label-sm">Teléfono</label>
                        <input type="text" class="custom-input mb-2" value="<c:out value='${expediente.telefonoEmpresa}'/>" readonly>

                        <label class="label-sm">Correo Electrónico</label>
                        <input type="text" class="custom-input" value="<c:out value='${expediente.correoEmpresa}'/>" readonly>
                    </div>
                </div>
            </div>

            <!-- FILA 3: Participantes y Documentos -->
            <div class="row g-3">
                <div class="col-12">
                    <div class="info-card">
                        <div class="card-header-title">
                            <span>👥</span> Participantes y Documentos
                        </div>

                        <!-- Campos Participantes -->
                        <div class="row g-2 mb-3">
                            <div class="col-md-3">
                                <label class="label-sm">Área Solicitante</label>
                                <input type="text" class="custom-input" value="<c:out value='${expediente.division}'/>" readonly>
                            </div>
                            <div class="col-md-3">
                                <label class="label-sm">Docente Responsable</label>
                                <input type="text" class="custom-input" value="<c:out value='${expediente.docente}'/>" readonly>
                            </div>
                            <div class="col-md-3">
                                <label class="label-sm">Docentes Acompañantes</label>
                                <input type="text" class="custom-input" value="<c:out value='${expediente.docenteAcompanante}'/>" readonly>
                            </div>
                            <div class="col-md-3">
                                <label class="label-sm">Estudiantes por División</label>
                                <input type="text" class="custom-input" value="<c:out value='${expediente.numeroEstudiantes}'/> Estudiantes" readonly>
                            </div>
                        </div>

                        <!-- ACCIONES Y DOCUMENTACIÓN -->
                        <span class="label-sm mb-2">ACCIONES Y DOCUMENTACIÓN</span>
                        <div class="row g-2 mb-2">
                            <div class="col-md-6">
                                <form action="${pageContext.request.contextPath}/docente/subir-documento" method="post" enctype="multipart/form-data">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="idVisita" value="${expediente.idVisita}">
                                    <input type="hidden" name="tipo" value="SOLICITUD_VISITA">
                                    <input class="form-control form-control-sm mb-1" type="file" name="archivo" accept="application/pdf,.pdf" required>
                                    <button class="btn-doc-navy">Subir solicitud de visita</button>
                                </form>
                            </div>
                            <div class="col-md-6">
                                <form action="${pageContext.request.contextPath}/docente/subir-documento" method="post" enctype="multipart/form-data">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="idVisita" value="${expediente.idVisita}">
                                    <input type="hidden" name="tipo" value="CARTA_RESPONSIVA">
                                    <input class="form-control form-control-sm mb-1" type="file" name="archivo" accept="application/pdf,.pdf" required>
                                    <button class="btn-doc-navy">Subir carta responsiva</button>
                                </form>
                            </div>
                        </div>

                        <div class="row g-2 mt-2">
                            <c:forEach var="doc" items="${expediente.documentos}">
                                <div class="col-md-4">
                                    <a href="${pageContext.request.contextPath}/archivo?id=${doc.idDocumento}" target="_blank" class="btn-doc-grey">
                                        <c:out value="${doc.tipoLegible}"/> · <c:out value="${doc.estadoLegible}"/>
                                    </a>
                                </div>
                            </c:forEach>
                            <div class="col-md-4">
                                <a href="${pageContext.request.contextPath}/reporte-docente?id=${expediente.idVisita}" class="btn-doc-navy">Reporte</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Botón de acción inferior -->
            <div class="text-end mt-4">
                <a href="${pageContext.request.contextPath}/mis-solicitudes" class="btn-orange">Atrás</a>
            </div>

        </div>
    </div>
</div>

</body>
</html>
