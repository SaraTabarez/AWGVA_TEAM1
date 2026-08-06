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
        * {
            box-sizing: border-box;
        }

        body, html {
            height: 100%;
            margin: 0;
            padding: 0;
            background-color: #9cb0c4;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            overflow-x: hidden;
        }

        /* Envoltorio para pantalla completa */
        .full-screen-wrapper {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            padding: 1rem;
        }

        /* Contenedor Principal Dashboard */
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
            transition: transform 0.2s ease;
        }

        .avatar-circle:hover {
            transform: scale(1.05);
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

        .sidebar-menu li {
            margin-bottom: 0.8rem;
        }

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
            transform: translateX(4px);
        }

        .sidebar-menu a:hover i {
            color: #f59e0b;
        }

        /* Opción opcional: Efecto para 'Cerrar sesión' */
        .logout-link a {
            color: #ffffff;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            padding: 8px 12px;
            border-radius: 6px;
            transition: all 0.25s ease;
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
            transition: background 0.2s;
        }

        .logout-link a:hover {
            background-color: rgba(245, 158, 11, 0.15);
            color: #f59e0b;
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
            transition: box-shadow 0.25s ease;
        }

        .info-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
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

        /* Etiquetas y valores */
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
            transition: border-color 0.2s;
        }

        .custom-input:focus {
            outline: none;
            border-color: #1f3a5e;
        }

        /* --- EFECTOS HOVER PARA BOTONES --- */
        .btn-doc-grey {
            background-color: #b0a8a0;
            color: #ffffff;
            font-weight: 600;
            border: none;
            border-radius: 8px;
            padding: 10px 14px;
            font-size: 0.85rem;
            width: 100%;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(0,0,0,0.08);
        }

        .btn-doc-grey:hover {
            background-color: #928a82;
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
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
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(0,0,0,0.08);
        }

        .btn-doc-navy:hover {
            background-color: #132742;
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.18);
        }

        .btn-orange {
            background-color: #f59e0b;
            color: #ffffff;
            font-weight: 700;
            border: none;
            border-radius: 8px;
            padding: 10px 40px;
            font-size: 0.9rem;
            transition: all 0.25s ease;
            box-shadow: 0 3px 6px rgba(245, 158, 11, 0.3);
        }

        .btn-orange:hover {
            background-color: #d97706;
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(217, 119, 6, 0.4);
        }

        .btn-orange:active, .btn-doc-grey:active, .btn-doc-navy:active {
            transform: translateY(0);
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
                <li><a href="#"><i class="bi bi-house-door"></i> Inicio</a></li>
                <li><a href="#"><i class="bi bi-file-earmark-text"></i> Solicitud</a></li>
                <li><a href="#"><i class="bi bi-gear"></i> Gestión</a></li>
                <li><a href="#"><i class="bi bi-clock-history"></i> Histórico</a></li>
            </ul>

            <div class="logout-link">
                <a href="#">
                    <i class="bi bi-box-arrow-right"></i> Cerrar sesión
                </a>
            </div>
        </div>

        <!-- CONTENIDO PRINCIPAL -->
        <div class="main-content">
            <a href="${pageContext.request.contextPath}/" class="btn-close-custom" title="Cerrar"><i class="bi bi-x-lg"></i></a>

            <h4 class="main-title">Solicitud de Visita Industrial-División Académica</h4>

            <!-- FILA 1: Dirección Académica y Estado -->
            <div class="row g-3 mb-3">
                <div class="col-md-7">
                    <div class="info-card">
                        <div class="card-header-title">
                            <span>📍</span> Información de la Dirección Académica
                        </div>
                        <div class="val-subtext mb-1">
                            <strong>Director(A):</strong> Dra. Martha Fabiola Wences Díaz.
                        </div>
                        <div class="val-subtext">
                            <strong>Cargo:</strong> Directora
                        </div>
                    </div>
                </div>

                <div class="col-md-5 d-flex align-items-center">
                    <div class="badge-status">
                        Estado: ${solicitud.estado}
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
                        <div class="val-text text-uppercase" style="color: #1f3a5e;">${solicitud.lugarVisita}</div>

                        <span class="label-sm mt-2">FECHA DE VISITA</span>
                        <div class="val-text">${solicitud.fechaVisita}</div>
                        <div class="val-subtext mb-2">
                            ⏱️ Duración aprox: 4 horas (Rango: 09:00 - 13:00)
                        </div>

                        <span class="label-sm">Carrera y Grupo</span>
                        <div class="val-text" style="font-size: 0.95rem;">${solicitud.carrera}</div>
                        <div class="val-subtext">
                            🏫 <strong>Grupo: ${solicitud.grupo}</strong><br>
                            Carreras: Ingeniería/Licenciatura
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
                        <input type="text" class="custom-input mb-2" value="${solicitud.empresaNombre}" readonly>

                        <label class="label-sm">Teléfono</label>
                        <input type="text" class="custom-input mb-2" value="${solicitud.empresaTelefono}" readonly>

                        <label class="label-sm">Correo Electrónico</label>
                        <input type="text" class="custom-input" value="${solicitud.empresaCorreo}" readonly>
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
                                <input type="text" class="custom-input" value="DATID" readonly>
                            </div>
                            <div class="col-md-3">
                                <label class="label-sm">Docente Responsable</label>
                                <input type="text" class="custom-input" value="${solicitud.docenteResponsable}" readonly>
                            </div>
                            <div class="col-md-3">
                                <label class="label-sm">Docentes Acompañantes</label>
                                <input type="text" class="custom-input" value="${solicitud.docenteAcompanante}" readonly>
                            </div>
                            <div class="col-md-3">
                                <label class="label-sm">Estudiantes por División</label>
                                <input type="text" class="custom-input" value="${solicitud.totalEstudiantes} Estudiantes" readonly>
                            </div>
                        </div>

                        <!-- Acciones y Documentación -->
                        <span class="label-sm mb-2">ACCIONES Y DOCUMENTACIÓN</span>
                        <div class="row g-2 mb-2">
                            <div class="col-md-4">
                                <button class="btn-doc-grey">Sol. c/firmas</button>
                            </div>
                            <div class="col-md-4">
                                <button class="btn-doc-grey">Carta resp c/firmas</button>
                            </div>
                            <div class="col-md-4">
                                <button class="btn-doc-grey">Oficio de autorización</button>
                            </div>
                        </div>
                        <div class="row g-2">
                            <div class="col-md-4">
                                <button class="btn-doc-navy">Sol. s/firmas</button>
                            </div>
                            <div class="col-md-4">
                                <button class="btn-doc-navy">Carta resp s/firmas</button>
                            </div>
                            <div class="col-md-4">
                                <button class="btn-doc-navy">Reporte</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Botón de acción inferior -->
            <div class="text-end mt-4">
                <a href="${pageContext.request.contextPath}/" class="btn btn-orange">Atras</a>
            </div>

        </div>
    </div>
</div>

</body>
</html>