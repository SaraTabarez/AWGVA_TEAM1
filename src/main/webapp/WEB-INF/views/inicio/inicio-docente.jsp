<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inicio Docente - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/role-home.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="role-home">
    <header class="role-header">
        <div><div class="role-eyebrow">Panel docente</div><h1 class="role-title">Bienvenido, <c:out value="${sessionScope.usuario.nombres}"/></h1><p class="role-subtitle">Crea solicitudes de visita, entrega documentos y consulta el avance de tus trámites.</p></div>
        <span class="role-badge">DOCENTE</span>
    </header>
    <section class="action-grid" aria-label="Acciones del docente">
        <a class="action-card" href="${ctx}/nueva-solicitud"><span class="action-icon"><i class="bi bi-plus-circle"></i></span><h2>Nueva solicitud</h2><p>Registra una nueva visita académica con los datos de empresa y grupo.</p></a>
        <a class="action-card" href="${ctx}/mis-solicitudes"><span class="action-icon"><i class="bi bi-file-earmark-text"></i></span><h2>Mis solicitudes</h2><p>Consulta el estado y los documentos asociados a tus solicitudes.</p></a>
        <a class="action-card" href="${ctx}/reportes-docente"><span class="action-icon"><i class="bi bi-cloud-arrow-up"></i></span><h2>Entregar reporte</h2><p>Adjunta el reporte y la evidencia de la visita.</p></a>
        <a class="action-card" href="${ctx}/historico-docente"><span class="action-icon"><i class="bi bi-clock-history"></i></span><h2>Histórico</h2><p>Revisa visitas y trámites concluidos previamente.</p></a>
    </section>
    <div class="summary-strip"><i class="bi bi-info-circle"></i><span>Tienes <strong><c:out value="${totalSolicitudes}"/></strong> solicitudes registradas.</span></div>
</main>
</body>
</html>
