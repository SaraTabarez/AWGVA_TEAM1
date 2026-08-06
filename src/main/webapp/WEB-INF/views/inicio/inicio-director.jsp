<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inicio Dirección - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/role-home.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="role-home">
    <header class="role-header">
        <div><div class="role-eyebrow">Panel de Dirección</div><h1 class="role-title">Revisión de visitas académicas</h1><p class="role-subtitle">Valida la información académica y autoriza o rechaza las solicitudes enviadas por docentes de tu división.</p></div>
        <span class="role-badge">DIRECTOR</span>
    </header>
    <section class="action-grid" aria-label="Acciones del director">
        <a class="action-card" href="${ctx}/servlet-gestion-solicitudes"><span class="action-icon"><i class="bi bi-clipboard-check"></i></span><h2>Solicitudes pendientes</h2><p>Consulta la bandeja de solicitudes que requieren revisión de Dirección.</p></a>
        <a class="action-card" href="${ctx}/servlet-detalles-solicitud"><span class="action-icon"><i class="bi bi-search"></i></span><h2>Detalle de solicitud</h2><p>Revisa empresa, grupo, fechas y documentación académica del trámite.</p></a>
    </section>
    <div class="summary-strip"><i class="bi bi-shield-check"></i><span>Dirección sólo puede acceder al flujo de revisión; la gestión de usuarios corresponde a <strong>ADMIN</strong>.</span></div>
</main>
</body>
</html>
