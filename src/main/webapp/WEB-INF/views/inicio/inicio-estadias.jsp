<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inicio Estadías - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/role-home.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="role-home">
    <header class="role-header">
        <div><div class="role-eyebrow">Panel de Estadías</div><h1 class="role-title">Control documental y reportes</h1><p class="role-subtitle">Verifica documentos firmados, revisa reportes finales y consulta el histórico de visitas.</p></div>
        <span class="role-badge">ESTADÍAS</span>
    </header>
    <section class="action-grid" aria-label="Acciones de Estadías">
        <a class="action-card" href="${ctx}/gestion-documentos.jsp"><span class="action-icon"><i class="bi bi-folder-check"></i></span><h2>Gestión de documentos</h2><p>Controla solicitudes, cartas responsivas y archivos entregados.</p></a>
        <a class="action-card" href="${ctx}/revisar-reporte.jsp"><span class="action-icon"><i class="bi bi-journal-check"></i></span><h2>Revisar reportes</h2><p>Acepta el reporte de visita o solicita correcciones al docente.</p></a>
        <a class="action-card" href="${ctx}/historico-estadias.jsp"><span class="action-icon"><i class="bi bi-clock-history"></i></span><h2>Histórico</h2><p>Consulta expedientes de visitas concluidas y sus evidencias.</p></a>
    </section>
    <div class="summary-strip"><i class="bi bi-info-circle"></i><span>Estadías administra la etapa documental posterior a la autorización de <strong>Dirección</strong>.</span></div>
</main>
</body>
</html>
