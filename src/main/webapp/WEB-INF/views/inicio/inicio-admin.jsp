<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inicio Administración - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/role-home.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="role-home">
    <header class="role-header">
        <div>
            <div class="role-eyebrow">Administración del sistema</div>
            <h1 class="role-title">Control general de AWGVA</h1>
            <p class="role-subtitle">La cuenta ADMIN reúne las funciones de Docente, Director y Estadías, además de la administración de usuarios.</p>
        </div>
        <span class="role-badge">ADMIN</span>
    </header>

    <section class="action-grid" aria-label="Acciones de Administración">
        <a class="action-card" href="${ctx}/admin/usuarios/alta">
            <span class="action-icon"><i class="bi bi-person-plus-fill"></i></span>
            <h2>Altas de usuario</h2>
            <p>Crea cuentas reales en Oracle para Docente, Director o Estadías.</p>
        </a>
        <a class="action-card" href="${ctx}/admin/usuarios">
            <span class="action-icon"><i class="bi bi-person-x-fill"></i></span>
            <h2>Eliminar usuarios</h2>
            <p>Consulta las cuentas y elimina de la base de datos las que ya no deban acceder.</p>
        </a>

        <a class="action-card" href="${ctx}/nueva-solicitud">
            <span class="action-icon"><i class="bi bi-plus-circle"></i></span>
            <h2>Nueva solicitud</h2>
            <p>Utiliza el flujo operativo de Docente para registrar una visita.</p>
        </a>
        <a class="action-card" href="${ctx}/mis-solicitudes">
            <span class="action-icon"><i class="bi bi-file-earmark-text"></i></span>
            <h2>Solicitudes de Docente</h2>
            <p>Consulta solicitudes, documentos y avance de los trámites creados por ADMIN.</p>
        </a>
        <a class="action-card" href="${ctx}/reportes-docente">
            <span class="action-icon"><i class="bi bi-cloud-arrow-up"></i></span>
            <h2>Reportes de Docente</h2>
            <p>Entrega reportes y evidencias con las mismas funciones del perfil Docente.</p>
        </a>
        <a class="action-card" href="${ctx}/historico-docente">
            <span class="action-icon"><i class="bi bi-clock-history"></i></span>
            <h2>Histórico de Docente</h2>
            <p>Revisa las visitas concluidas vinculadas a la cuenta ADMIN.</p>
        </a>

        <a class="action-card" href="${ctx}/director/solicitudes">
            <span class="action-icon"><i class="bi bi-clipboard-check"></i></span>
            <h2>Solicitudes de Dirección</h2>
            <p>Autoriza o rechaza solicitudes como lo hace el perfil Director.</p>
        </a>
        <a class="action-card" href="${ctx}/director/historico">
            <span class="action-icon"><i class="bi bi-archive"></i></span>
            <h2>Histórico de Dirección</h2>
            <p>Consulta el historial de solicitudes revisadas por la división asignada.</p>
        </a>

        <a class="action-card" href="${ctx}/estadias/documentos">
            <span class="action-icon"><i class="bi bi-folder-check"></i></span>
            <h2>Gestión de archivos</h2>
            <p>Revisa solicitudes, cartas responsivas, reportes y evidencias como Estadías.</p>
        </a>
        <a class="action-card" href="${ctx}/estadias/historico">
            <span class="action-icon"><i class="bi bi-journal-check"></i></span>
            <h2>Histórico de Estadías</h2>
            <p>Consulta expedientes concluidos y su documentación.</p>
        </a>
    </section>

    <div class="summary-strip">
        <i class="bi bi-shield-check"></i>
        <span>La cuenta ADMIN está protegida: no puede eliminarse desde el panel y el formulario no permite crear administradores adicionales.</span>
    </div>
</main>
</body>
</html>
