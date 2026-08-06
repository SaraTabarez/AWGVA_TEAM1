<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Solicitudes</title>
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- ESTILOS CSS -->
    <style>
        * {
            box-sizing: border-box !important;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }

        html, body {
            width: 100% !important;
            height: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            background-color: #ffffff !important;
            overflow-x: hidden;
        }

        .dashboard-container {
            display: flex !important;
            width: 100vw !important;
            min-height: 100vh !important;
            margin: 0 !important;
            padding: 0 !important;
            background-color: #ffffff;
        }

        /* MENÚ LATERAL (SIDEBAR) */
        .sidebar {
            width: 250px !important;
            background-color: #2b324b !important;
            color: #ffffff;
            display: flex !important;
            flex-direction: column !important;
            padding: 25px 0;
            flex-shrink: 0;
        }

        .profile-section {
            text-align: center;
            padding: 10px 15px 30px 15px;
        }

        .avatar-circle {
            width: 80px;
            height: 80px;
            background-color: #ffffff;
            border-radius: 50%;
            margin: 0 auto 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            color: #2b324b;
        }

        .user-role {
            font-size: 15px;
            font-weight: 700;
        }

        .sidebar-nav ul {
            list-style: none;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 25px;
            color: #ffffff;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: color 0.3s ease, background-color 0.3s ease;
        }

        .nav-item.active,
        .nav-item:hover,
        .nav-item:hover i,
        .logout-btn:hover,
        .logout-btn:hover i {
            color: #f59120 !important;
            background-color: rgba(255, 255, 255, 0.05);
        }

        .logout-container {
            margin-top: auto;
            padding: 20px 25px;
        }

        .logout-btn {
            color: #ffffff;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
            font-weight: 600;
            transition: color 0.3s ease, background-color 0.3s ease;
        }

        /* CONTENIDO PRINCIPAL */
        .main-content {
            flex: 1 !important;
            padding: 40px 50px !important;
            background-color: #ffffff;
            display: flex;
            flex-direction: column;
        }

        .header-container {
            margin-bottom: 30px;
        }

        .page-title {
            font-size: 28px;
            color: #2b324b;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .page-subtitle {
            font-size: 20px;
            color: #f59120;
            font-weight: 700;
        }

        /* TABLA */
        .table-container {
            width: 100%;
            overflow-x: auto;
            margin-bottom: 40px;
        }

        .custom-table {
            width: 100%;
            border-collapse: collapse;
            text-align: center;
        }

        .custom-table th {
            background-color: #2b324b;
            color: #ffffff;
            padding: 12px 15px;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.5px;
            border: 1px solid #a0aec0;
        }

        .custom-table td {
            padding: 10px 15px;
            font-size: 14px;
            color: #2d3748;
            font-weight: 600;
            border: 1px solid #a0aec0 !important;
            height: 52px;
            vertical-align: middle;
        }

        .cell-content {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
        }

        .download-btn {
            color: #2d3748;
            font-size: 16px;
            text-decoration: none;
            transition: color 0.2s;
        }

        .download-btn:hover {
            color: #f59120;
        }

        /* BADGES DE ESTADO */
        .status-badge {
            display: block;
            width: 100%;
            padding: 8px 0;
            font-weight: 700;
            font-size: 13px;
            transition: background-color 0.3s ease, color 0.3s ease;
        }

        .status-pending {
            background-color: #b2a8a4;
            color: #1a202c;
        }

        .status-rejected {
            background-color: #e57373;
            color: #ffffff;
        }

        .status-accepted {
            background-color: #66bb6a;
            color: #ffffff;
        }

        /* BOTONES DE ACCIONES */
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
        }

        .btn-action {
            width: 50px;
            height: 32px;
            border: none;
            border-radius: 6px;
            color: #ffffff;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.2s, opacity 0.2s;
        }

        .btn-action:hover:not(:disabled) {
            transform: translateY(-1px);
            opacity: 0.9;
        }

        .btn-action:active:not(:disabled) {
            transform: scale(0.92);
        }

        /* ESTADO DESHABILITADO PARA BOTONES */
        .btn-action:disabled {
            opacity: 0.35 !important;
            cursor: not-allowed !important;
            transform: none !important;
            box-shadow: none !important;
        }

        .btn-navy {
            background-color: #2b324b;
        }

        .btn-orange {
            background-color: #f59120;
        }

        /* BOTÓN VOLVER AL INICIO */
        .footer-container {
            margin-top: auto;
            display: flex;
            justify-content: flex-end;
        }

        .btn-main-orange {
            background-color: #f59120;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            padding: 12px 35px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-main-orange:hover {
            background-color: #e08110;
        }

        /* MODALES EMERGENTES (POP-UPS) */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background-color: rgba(0, 0, 0, 0.4);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            backdrop-filter: blur(2px);
        }

        .modal-card {
            background-color: #ffffff;
            width: 90%;
            max-width: 480px;
            padding: 40px 30px;
            border-radius: 16px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            animation: popIn 0.25s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        @keyframes popIn {
            from { transform: scale(0.8); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        .icon-accepted-box {
            width: 85px;
            height: 85px;
            border: 3px solid #52c48d;
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 25px;
        }

        .icon-accepted-box i {
            font-size: 42px;
            color: #52c48d;
        }

        .icon-rejected-box {
            font-size: 80px;
            color: #a61c24;
            margin-bottom: 20px;
            line-height: 1;
        }

        .modal-title {
            font-size: 20px;
            font-weight: 800;
            color: #1a1a1a;
            margin-bottom: 16px;
        }

        .modal-message {
            font-size: 15px;
            font-weight: 600;
            color: #555555;
            line-height: 1.4;
            margin-bottom: 30px;
        }

        .modal-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            width: 100%;
        }

        .btn-understood {
            background-color: #52c48d;
            color: #ffffff;
            border: none;
            border-radius: 10px;
            padding: 12px 45px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(82, 196, 141, 0.3);
        }

        .btn-modal-cancel {
            background-color: #ffffff;
            color: #777777;
            border: 1.5px solid #cccccc;
            border-radius: 10px;
            padding: 12px 35px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
        }

        .btn-modal-reject {
            background-color: #a61c24;
            color: #ffffff;
            border: none;
            border-radius: 10px;
            padding: 12px 35px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(166, 28, 36, 0.3);
        }
    </style>
</head>
<body>

<div class="dashboard-container">

    <!-- SIDEBAR / MENÚ LATERAL -->
    <aside class="sidebar">
        <div class="profile-section">
            <div class="avatar-circle">
                <i class="fa-solid fa-user"></i>
            </div>
            <h3 class="user-role">Nombre Usuario</h3>
        </div>

        <nav class="sidebar-nav">
            <ul>
                <li><a href="#" class="nav-item"><i class="fa-solid fa-house"></i> Inicio</a></li>
                <li><a href="#" class="nav-item active"><i class="fa-solid fa-file-lines"></i> Solicitudes</a></li>
                <li><a href="#" class="nav-item"><i class="fa-solid fa-chart-pie"></i> Reporte</a></li>
                <li><a href="#" class="nav-item"><i class="fa-solid fa-clock-rotate-left"></i> Histórico</a></li>
            </ul>
        </nav>

        <div class="logout-container">
            <a href="#" class="logout-btn"><i class="fa-solid fa-right-from-bracket"></i> Cerrar sesión</a>
        </div>
    </aside>

    <!-- CONTENIDO PRINCIPAL -->
    <main class="main-content">

        <div class="header-container">
            <h1 class="page-title">Gestión de solicitudes</h1>
            <h2 class="page-subtitle">Pendientes a revisar</h2>
        </div>

        <!-- TABLA CON DATOS BASE -->
        <div class="table-container">
            <table class="custom-table">
                <thead>
                <tr>
                    <th>ID SOLICITUD</th>
                    <th>DIVISIÓN</th>
                    <th>LUGAR</th>
                    <th>FECHA DE SALIDA</th>
                    <th>ESTADO</th>
                    <th>ACCIONES</th>
                </tr>
                </thead>
                <tbody>

                <!-- FILA 1 -->
                <tr id="fila-001">
                    <td>
                        <div class="cell-content">
                            <a href="#" class="download-btn"><i class="fa-solid fa-arrow-down-to-line"></i></a>
                            <span>001</span>
                        </div>
                    </td>
                    <td>DATID</td>
                    <td>NISSAN Morelos</td>
                    <td>25-10-2026</td>
                    <td><span id="badge-001" class="status-badge status-pending">PENDIENTE</span></td>
                    <td>
                        <div class="action-buttons">
                            <button type="button" class="btn-action btn-navy" title="Aceptar" onclick="solicitarAceptar('001')">
                                <i class="fa-solid fa-calendar-check"></i>
                            </button>
                            <button type="button" class="btn-action btn-orange" title="Rechazar" onclick="solicitarRechazar('001')">
                                <i class="fa-solid fa-calendar-xmark"></i>
                            </button>
                        </div>
                    </td>
                </tr>

                <!-- FILA 2 -->
                <tr id="fila-002">
                    <td>
                        <div class="cell-content">
                            <a href="#" class="download-btn"><i class="fa-solid fa-arrow-down-to-line"></i></a>
                            <span>002</span>
                        </div>
                    </td>
                    <td>DATID</td>
                    <td>Planta Ford</td>
                    <td>12-11-2026</td>
                    <td><span id="badge-002" class="status-badge status-rejected">RECHAZADA</span></td>
                    <td>
                        <div class="action-buttons">
                            <button type="button" class="btn-action btn-navy" title="Aceptar" onclick="solicitarAceptar('002')" disabled>
                                <i class="fa-solid fa-calendar-check"></i>
                            </button>
                            <button type="button" class="btn-action btn-orange" title="Rechazar" onclick="solicitarRechazar('002')" disabled>
                                <i class="fa-solid fa-calendar-xmark"></i>
                            </button>
                        </div>
                    </td>
                </tr>

                <!-- FILA 3 -->
                <tr id="fila-003">
                    <td>
                        <div class="cell-content">
                            <a href="#" class="download-btn"><i class="fa-solid fa-arrow-down-to-line"></i></a>
                            <span>003</span>
                        </div>
                    </td>
                    <td>DAMI</td>
                    <td>Softtek CDMX</td>
                    <td>02-12-2026</td>
                    <td><span id="badge-003" class="status-badge status-accepted">ACEPTADA</span></td>
                    <td>
                        <div class="action-buttons">
                            <button type="button" class="btn-action btn-navy" title="Aceptar" onclick="solicitarAceptar('003')" disabled>
                                <i class="fa-solid fa-calendar-check"></i>
                            </button>
                            <button type="button" class="btn-action btn-orange" title="Rechazar" onclick="solicitarRechazar('003')" disabled>
                                <i class="fa-solid fa-calendar-xmark"></i>
                            </button>
                        </div>
                    </td>
                </tr>

                </tbody>
            </table>
        </div>

        <div class="footer-container">
            <a href="#" class="btn btn-main-orange" style="text-decoration: none;">Volver al inicio</a>
        </div>

    </main>
</div>

<!-- MODAL 1: ACEPTADA -->
<div id="modalAceptada" class="modal-overlay">
    <div class="modal-card">
        <div class="icon-accepted-box">
            <i class="fa-solid fa-check"></i>
        </div>
        <h2 class="modal-title">¡Solicitud Aceptada!</h2>
        <p class="modal-message">
            La solicitud ha sido aceptada correctamente y enviada al historial.
        </p>
        <button type="button" class="btn-understood" onclick="cerrarModal('modalAceptada')">Entendido</button>
    </div>
</div>

<!-- MODAL 2: CONFIRMAR RECHAZO -->
<div id="modalRechazar" class="modal-overlay">
    <div class="modal-card">
        <div class="icon-rejected-box">
            <i class="fa-solid fa-xmark"></i>
        </div>
        <h2 class="modal-title">¿Rechazar solicitud?</h2>
        <p class="modal-message">
            Se notificará al docente que la solicitud fue rechazada.<br>
            Esta acción no se puede deshacer.
        </p>
        <div class="modal-buttons">
            <button type="button" class="btn-modal-cancel" onclick="cerrarModal('modalRechazar')">Cancelar</button>
            <button type="button" class="btn-modal-reject" onclick="confirmarRechazo()">Rechazar</button>
        </div>
    </div>
</div>

<!-- SCRIPT JS -->
<script>
    let solicitudSeleccionada = null;

    function solicitarAceptar(idSolicitud) {
        cambiarEstadoTabla(idSolicitud, 'ACEPTADA');
        document.getElementById('modalAceptada').style.display = 'flex';
    }

    function solicitarRechazar(idSolicitud) {
        solicitudSeleccionada = idSolicitud;
        document.getElementById('modalRechazar').style.display = 'flex';
    }

    function confirmarRechazo() {
        if (solicitudSeleccionada) {
            cambiarEstadoTabla(solicitudSeleccionada, 'RECHAZADA');
            cerrarModal('modalRechazar');
            solicitudSeleccionada = null;
        }
    }

    function cambiarEstadoTabla(idSolicitud, nuevoEstado) {
        const badge = document.getElementById('badge-' + idSolicitud);
        if (badge) {
            badge.innerText = nuevoEstado;
            badge.classList.remove('status-pending', 'status-rejected', 'status-accepted');

            if (nuevoEstado === 'ACEPTADA') {
                badge.classList.add('status-accepted');
            } else if (nuevoEstado === 'RECHAZADA') {
                badge.classList.add('status-rejected');
            } else {
                badge.classList.add('status-pending');
            }

            // Lógica para bloquear los dos botones de la fila modificada
            const fila = document.getElementById('fila-' + idSolicitud);
            if (fila) {
                const botones = fila.querySelectorAll('.btn-action');
                botones.forEach(btn => btn.disabled = true);
            }
        }
    }

    function cerrarModal(idModal) {
        document.getElementById(idModal).style.display = 'none';
    }
</script>

</body>
</html>