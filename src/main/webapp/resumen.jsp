<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resumen de Solicitud</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f0f2f5; }
        .sidebar { width: 240px; background-color: #1f3752; color: white; display: flex; flex-direction: column; padding-top: 50px; position: fixed; height: 100%; }
        .user-profile { text-align: center; margin-bottom: 50px; }
        .user-icon { width: 90px; height: 90px; background-color: #cccccc; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 15px auto; }
        .user-icon svg { width: 55px; height: 55px; fill: #111111; }
        .user-role { font-size: 16px; letter-spacing: 1px; font-weight: 800; color: #ffffff; }
        .nav-menu { list-style: none; flex-grow: 1; }
        .nav-menu li { padding: 18px 30px; cursor: pointer; font-size: 16px; display: flex; align-items: center; gap: 15px; font-weight: 400; }
        .nav-menu li:hover { background-color: #2a4365; }
        .nav-menu li.active { font-weight: 700; }
        .nav-menu li svg { width: 20px; height: 20px; fill: #ffffff; }
        .logout { padding: 20px 30px; cursor: pointer; font-size: 14px; display: flex; align-items: center; gap: 15px; }
        .logout svg { width: 20px; height: 20px; fill: #ffffff; }
        .main-content { margin-left: 240px; flex-grow: 1; background-color: #ffffff; padding: 30px 50px; overflow-y: auto; }
        .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; }
        .header h1 { font-size: 22px; font-weight: bold; text-transform: uppercase; }
        .logo-placeholder { width: 120px; height: 50px; background-color: #f4f4f4; display: flex; align-items: center; justify-content: center; font-size: 12px; color: #666; border: 1px dashed #ccc; }
        .section-title { font-size: 16px; margin-bottom: 8px; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 15px; font-size: 12px; }
        th, td { border: 1px solid #333; padding: 6px; text-align: left; }
        th { background-color: #fff; font-weight: bold; width: 25%; }
        td { width: 25%; }
        input[type="text"], input[type="date"], input[type="time"] { width: 100%; border: none; outline: none; background: transparent; font-family: inherit; font-size: 12px; }
        textarea { width: 100%; border: none; outline: none; resize: none; font-family: inherit; font-size: 12px; min-height: 45px; padding-top: 5px; }
        .text-center { text-align: center; }
        .p-text { font-size: 12px; margin-bottom: 8px; }
        .textarea-box { border: 1px solid #333; padding: 8px; min-height: 60px; margin-bottom: 20px; }
        .signatures { display: flex; justify-content: space-around; margin-top: 30px; margin-bottom: 30px; }
        .sig-block { text-align: center; width: 280px; }
        .sig-block h4 { font-size: 15px; margin-bottom: 45px; font-weight: normal; }
        .sig-line { border-top: 1px solid #333; margin-bottom: 8px; }
        .sig-block p { font-size: 12px; color: #333; }
        .actions { display: flex; justify-content: space-between; }
        .btn { padding: 10px 25px; border: none; border-radius: 4px; color: white; font-weight: bold; cursor: pointer; font-size: 14px; }
        .btn-orange { background-color: #f8981d; }
        .btn-orange:hover { background-color: #e08718; }

        /* --- REGLAS DE IMPRESIÓN (PDF) --- */
        @media print {
            @page {
                size: letter portrait;
                margin: 10mm 15mm; /* Reduce márgenes impresos */
            }

            body {
                background-color: #ffffff !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }

            /* Ocultar botones y menú lateral */
            .sidebar, .actions {
                display: none !important;
            }

            .main-content {
                margin-left: 0 !important;
                padding: 0 !important;
                width: 100% !important;
            }

            /* EVITA QUE TABLAS Y FIRMAS SE CORTEN A LA MITAD */
            table, .textarea-box {
                page-break-inside: avoid;
                break-inside: avoid;
            }

            .signatures {
                page-break-inside: avoid !important;
                break-inside: avoid !important;
                margin-top: 40px !important;
            }
        }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="user-profile">
        <div class="user-icon"><svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg></div>
        <div class="user-role">DOCENTE</div>
    </div>
    <ul class="nav-menu">
        <li><svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg> Inicio</li>
        <li class="active"><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg> Solicitud</li>
        <li><svg viewBox="0 0 24 24"><path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg> Reporte</li>
        <li><svg viewBox="0 0 24 24"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/></svg> Histórico</li>
    </ul>
    <div class="logout"><svg viewBox="0 0 24 24"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg> Cerrar sesión</div>
</div>

<div class="main-content">
    <div class="header">
        <h1>SOLICITUD DE VISITAS ACADÉMICAS</h1>
        <div class="logo-placeholder">Logo UTEZ</div>
    </div>

    <h2 class="section-title">Datos del Lugar</h2>
    <table>
        <tr>
            <th colspan="2">Nombre de la empresa:</th>
            <td colspan="2"><input type="text" value="${solicitud.empresaNombre}" readonly></td>
        </tr>
        <tr>
            <th colspan="2">Dirección o lugar</th>
            <td colspan="2"><input type="text" value="${solicitud.empresaDireccion}" readonly></td>
        </tr>
        <tr>
            <th colspan="2">Teléfono de contacto</th>
            <td colspan="2"><input type="text" value="${solicitud.empresaTelefono}" readonly></td>
        </tr>
        <tr>
            <th colspan="2">Correo Electrónico</th>
            <td colspan="2"><input type="text" value="${solicitud.empresaEmail}" readonly></td>
        </tr>
        <tr>
            <th>Fecha de inicio de la visita</th>
            <td><input type="text" value="${solicitud.fechaInicio}" readonly></td>
            <th class="text-center">Hora de inicio:</th>
            <td><input type="text" value="${solicitud.horaInicio}" readonly></td>
        </tr>
        <tr>
            <th colspan="2">Fecha de termino de la visita</th>
            <td colspan="2"><input type="text" value="${solicitud.fechaTermino}" readonly></td>
        </tr>
        <tr>
            <td colspan="4" style="padding: 10px;">
                <strong>Objetivo de la visita:</strong>
                <textarea readonly>${solicitud.objetivo}</textarea>
            </td>
        </tr>
    </table>

    <h2 class="section-title">Datos de los Participantes</h2>
    <table>
        <tr>
            <th colspan="2">Área solicitante:</th>
            <td colspan="2"><input type="text" value="${solicitud.solicitanteCargo}" readonly></td>
        </tr>
        <tr>
            <th colspan="2">Docente responsable:</th>
            <td colspan="2"><input type="text" value="${solicitud.solicitanteNombre}" readonly></td>
        </tr>
        <tr>
            <th>Celular de responsable:</th>
            <td><input type="text" value="${solicitud.solicitanteTelefono}" readonly></td>
            <th class="text-center">Docentes acompañantes:</th>
            <td><input type="text" value="${solicitud.docentesAcompanantes}" readonly></td>
        </tr>
    </table>

    <p class="p-text"><strong>No. de estudiantes participantes por división académica:</strong></p>
    <table>
        <tr>
            <th class="text-center">DACEA</th>
            <th class="text-center">DATEFI</th>
            <th class="text-center">DATID</th>
            <th class="text-center">DAMI</th>
            <th class="text-center">Total estudiantes</th>
        </tr>
        <tr>
            <td><input type="text" class="text-center" value="${solicitud.dacea}" readonly></td>
            <td><input type="text" class="text-center" value="${solicitud.datefi}" readonly></td>
            <td><input type="text" class="text-center" value="${solicitud.datid}" readonly></td>
            <td><input type="text" class="text-center" value="${solicitud.dami}" readonly></td>
            <td><input type="text" class="text-center" value="${solicitud.totalEstudiantes}" readonly></td>
        </tr>
    </table>

    <p class="p-text">Asignaturas que se reforzarán con la visita</p>
    <div class="textarea-box">
        <textarea readonly>${solicitud.asignaturas}</textarea>
    </div>

    <div class="signatures">
        <div class="sig-block">
            <h4>Solicita</h4>
            <div class="sig-line"></div>
            <!-- AQUÍ SE LLENA AUTOMÁTICAMENTE EL NOMBRE DEL SOLICITANTE -->
            <p><strong>${solicitud.solicitanteNombre}</strong><br>Nombre del docente responsable<br>de la visita</p>
        </div>
        <div class="sig-block">
            <h4>Autoriza</h4>
            <div class="sig-line"></div>
            <p>Nombre y cargo del director de<br>carrera/titular de área</p>
        </div>
    </div>

    <div class="actions">
        <button class="btn btn-orange" onclick="window.history.back()">Atrás</button>
        <!-- BOTÓN DE DESCARGA / IMPRESIÓN PDF -->
        <button class="btn btn-orange" onclick="window.print()">Descargar</button>
    </div>

</div>

</body>
</html>