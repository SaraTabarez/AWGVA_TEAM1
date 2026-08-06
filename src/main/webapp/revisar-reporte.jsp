<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String accion = request.getParameter("accion");
        if ("APROBAR".equals(accion)) {
            session.setAttribute("estatusReporte", "ACEPTADO");
            response.sendRedirect(request.getContextPath() + "/views/reportes/reporte-aceptado.jsp");
            return;
        } else if ("RECHAZAR".equals(accion)) {
            session.setAttribute("estatusReporte", "RECHAZADO");
            session.setAttribute("observacionesEstadias", request.getParameter("observacionesEstadias"));
            response.sendRedirect(request.getContextPath() + "/views/reportes/reporte-rechazado.jsp");
            return;
        }
    }

    class Helper {
        String val(HttpSession s, String key) {
            Object v = s.getAttribute(key);
            return (v != null) ? v.toString() : "";
        }
    }
    Helper h = new Helper();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Revisar Reporte - Dirección / Estadías</title>
    <style>
        * { box-sizing: border-box; font-family: Arial, Helvetica, sans-serif; margin: 0; padding: 0; }
        body { display: flex; background-color: #f4f6f9; color: #333; }

        .main-container {
            width: 100%;
            background-color: #ffffff;
            padding: 20px 40px 40px 40px;
            min-height: 100vh;
        }

        .location-badge-error {
            background-color: #fef2f2;
            color: #991b1b;
            font-size: 12px;
            font-weight: bold;
            padding: 6px 12px;
            border-radius: 4px;
            display: inline-block;
            margin-bottom: 15px;
            border-left: 4px solid #ef4444;
        }

        .header-section { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; }
        .header-title { font-size: 22px; font-weight: bold; color: #1e3a5f; text-transform: uppercase; }
        .logo-utez { text-align: right; font-weight: bold; font-size: 20px; color: #002b49; font-style: italic; }
        .logo-sub { font-size: 8px; display: block; color: #555; font-style: normal; }

        .section-box-error {
            border: 2px solid #ef4444;
            border-radius: 4px;
            padding: 15px;
            margin-bottom: 25px;
        }

        .section-title { font-size: 18px; color: #2c4a6f; margin-bottom: 12px; font-weight: bold; }

        .form-grid { display: grid; gap: 12px 15px; margin-bottom: 10px; }
        .grid-2 { grid-template-columns: 2fr 1fr; }
        .grid-3 { grid-template-columns: 1fr 1fr 1fr; }
        .grid-4 { grid-template-columns: 2fr 1fr 1fr 1fr; }

        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 12px; font-weight: bold; color: #1e3a5f; margin-bottom: 4px; }
        .form-group input {
            background-color: #e3ebf3; border: 1px solid #c0d1e3; border-radius: 4px;
            padding: 8px 12px; font-size: 13px; color: #333; outline: none;
        }

        .evidence-box { border: 1px solid #777; padding: 15px; margin-top: 20px; margin-bottom: 30px; display: flex; gap: 20px; }
        .evidence-title { font-weight: bold; color: #e59339; font-size: 15px; margin-bottom: 10px; }
        .photos-container { display: flex; gap: 12px; margin-top: 10px; }

        .photo-preview-box {
            width: 120px; height: 80px; border: 1px dashed #0099ff; border-radius: 4px;
            background: #f0f7ff; display: flex; align-items: center; justify-content: center;
            position: relative; overflow: hidden;
        }
        .photo-preview-box img { width: 100%; height: 100%; object-fit: cover; }

        .bottom-bar { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; }

        .btn-rechazar {
            background-color: #a61c1c; color: white; border: none; padding: 10px 20px;
            border-radius: 6px; font-weight: bold; cursor: pointer; margin-right: 10px;
        }

        .btn-aprobar {
            background-color: #48bb78; color: white; border: none; padding: 10px 20px;
            border-radius: 6px; font-weight: bold; cursor: pointer;
        }

        /* Modales */
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: none; justify-content: center;
            align-items: center; z-index: 1000;
        }

        .modal-card {
            background: white; border-radius: 12px; padding: 30px; width: 420px;
            text-align: center; box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }

        .icon-check {
            width: 60px; height: 60px; border: 3px solid #48bb78; border-radius: 12px;
            display: flex; align-items: center; justify-content: center; margin: 0 auto 15px auto;
            color: #48bb78; font-size: 32px; font-weight: bold;
        }

        .icon-cross {
            width: 60px; height: 60px; border: 2px dashed #a61c1c;
            display: flex; align-items: center; justify-content: center; margin: 0 auto 15px auto;
            color: #a61c1c; font-size: 32px; font-weight: bold;
        }

        .btn-modal-green { background-color: #48bb78; color: white; border: none; padding: 10px 30px; border-radius: 6px; font-weight: bold; cursor: pointer; width: 100%; }
        .btn-modal-red { background-color: #a61c1c; color: white; border: none; padding: 10px 25px; border-radius: 6px; font-weight: bold; cursor: pointer; }
        .btn-modal-cancel { background-color: transparent; border: 1px solid #ccc; color: #555; padding: 10px 25px; border-radius: 6px; font-weight: bold; cursor: pointer; margin-right: 10px; }
    </style>
</head>
<body>

<div class="main-container">
    <div class="location-badge-error">🛡️ Módulo Administrativo: Revisión de Reporte Enviado por Docente</div>

    <div class="header-section">
        <div>
            <h1 class="header-title">REVISIÓN DE REPORTE DE VISITA ACADÉMICA</h1>
        </div>
        <div class="logo-utez">
            UTEZ
            <span class="logo-sub">UNIVERSIDAD TECNOLÓGICA DEL ESTADO DE MORELOS</span>
        </div>
    </div>

    <div class="section-box-error">
        <div class="section-title">Datos Generales Registrados</div>
        <div class="form-grid grid-3">
            <div class="form-group"><label>Área Solicitante:</label><input type="text" value="<%= h.val(session, "areaSolicitante") %>" readonly></div>
            <div class="form-group"><label>Docente Responsable:</label><input type="text" value="<%= h.val(session, "docenteResponsable") %>" readonly></div>
            <div class="form-group"><label>Empresa Visitada:</label><input type="text" value="<%= h.val(session, "empresa") %>" readonly></div>
        </div>
    </div>

    <div class="evidence-box">
        <div style="flex:1;">
            <div class="evidence-title">Evidencias Fotográficas Adjuntas</div>
            <div class="photos-container">
                <div class="photo-preview-box"><img src="<%= h.val(session, "foto1Base64") %>" alt="Foto 1"></div>
                <div class="photo-preview-box"><img src="<%= h.val(session, "foto2Base64") %>" alt="Foto 2"></div>
                <div class="photo-preview-box"><img src="<%= h.val(session, "foto3Base64") %>" alt="Foto 3"></div>
            </div>
        </div>
        <div style="flex:1;">
            <div class="evidence-title">Carta Responsiva Firmada</div>
            <div class="photo-preview-box" style="width: 100%; height: 80px;">
                <img src="<%= h.val(session, "reporteFirmadoBase64") %>" alt="Responsiva Firmada">
            </div>
        </div>
    </div>

    <div class="bottom-bar">
        <button type="button" class="btn-modal-cancel" onclick="window.history.back()">Volver</button>
        <div>
            <button type="button" class="btn-rechazar" onclick="document.getElementById('modalRechazo').style.display='flex'">Rechazar Reporte</button>
            <button type="button" class="btn-aprobar" onclick="document.getElementById('modalAprobacion').style.display='flex'">Aprobar Reporte</button>
        </div>
    </div>
</div>

<!-- Modal Aprobar -->
<div id="modalAprobacion" class="modal-overlay">
    <div class="modal-card">
        <div class="icon-check">✓</div>
        <h2>¿Aprobar Reporte?</h2>
        <p style="font-size: 13px; color:#666; margin: 10px 0 20px 0;">El reporte pasará al histórico como finalizado correctamente.</p>
        <form method="post" action="${pageContext.request.contextPath}/revisar-reporte.jsp">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="accion" value="APROBAR">
            <button type="submit" class="btn-modal-green">Confirmar Aprobación</button>
        </form>
    </div>
</div>

<!-- Modal Rechazar -->
<div id="modalRechazo" class="modal-overlay">
    <div class="modal-card">
        <div class="icon-cross">✕</div>
        <h2>Rechazar Reporte</h2>
        <form method="post" action="${pageContext.request.contextPath}/revisar-reporte.jsp">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="accion" value="RECHAZAR">
            <textarea name="observacionesEstadias" placeholder="Escribe aquí las correcciones solicitadas..." style="width: 100%; height: 80px; margin: 15px 0; padding: 8px;" required></textarea>
            <div>
                <button type="button" class="btn-modal-cancel" onclick="document.getElementById('modalRechazo').style.display='none'">Cancelar</button>
                <button type="submit" class="btn-modal-red">Confirmar Rechazo</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>
