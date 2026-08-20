<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inicio Dirección - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/role-home.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="role-home">
    <header class="role-header">
        <div>
            <div class="role-eyebrow">Panel de Dirección</div>
            <h1 class="role-title">Inicio</h1>
            <p class="role-subtitle">Consulta las solicitudes creadas por docentes de tu división académica. Dirección tiene acceso únicamente de lectura.</p>
        </div>
        <span class="role-badge">DIRECTOR</span>
    </header>

    <section class="action-grid" aria-label="Acciones del director">
        <a class="action-card" href="${ctx}/director/solicitudes">
            <span class="action-icon"><i class="bi bi-file-earmark-text"></i></span>
            <h2>Solicitudes</h2>
            <p>Visualiza las solicitudes de visita correspondientes a tu división y consulta sus datos y documentos.</p>
        </a>
    </section>

    <div class="summary-strip">
        <i class="bi bi-eye"></i>
        <span>Rol de consulta: <strong>Dirección no aprueba ni rechaza solicitudes o documentos.</strong></span>
    </div>
</main>
</body>
</html>
