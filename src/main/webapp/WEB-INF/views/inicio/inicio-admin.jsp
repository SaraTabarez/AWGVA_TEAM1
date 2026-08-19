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
    <style>
        .request-meta{display:grid;gap:7px;margin-top:14px;color:#68778a;font-size:.84rem}.request-meta span{display:flex;gap:8px;align-items:center}.request-status{display:inline-flex;align-items:center;gap:7px;margin-top:16px;border-radius:999px;background:#eef3f8;color:#1e3a5f;padding:7px 11px;font-size:.75rem;font-weight:800}.request-status i{color:#f38218}.empty-admin{background:#fff;border:1px solid #e1e7ef;border-radius:14px;padding:38px;text-align:center;color:#68778a}.empty-admin i{display:block;font-size:2.2rem;color:#f38218;margin-bottom:10px}
    </style>
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="role-home">
    <header class="role-header">
        <div>
            <div class="role-eyebrow">Administración del sistema</div>
            <h1 class="role-title">Solicitudes en proceso</h1>
            <p class="role-subtitle">Vista general de todas las solicitudes registradas en AWGVA y de la etapa en la que se encuentra cada una.</p>
        </div>
        <span class="role-badge">ADMIN</span>
    </header>

    <c:choose>
        <c:when test="${empty solicitudes}">
            <div class="empty-admin"><i class="bi bi-inbox"></i><strong>No hay solicitudes activas.</strong><div>Las solicitudes finalizadas se encuentran en Histórico.</div></div>
        </c:when>
        <c:otherwise>
            <section class="action-grid" aria-label="Solicitudes activas">
                <c:forEach var="solicitud" items="${solicitudes}">
                    <a class="action-card" href="${ctx}/admin/solicitud?ref=${solicitud.referenceToken}">
                        <span class="action-icon"><i class="bi bi-file-earmark-text"></i></span>
                        <h2>Solicitud #<c:out value="${solicitud.idVisita}"/> · <c:out value="${solicitud.empresa}"/></h2>
                        <div class="request-meta">
                            <span><i class="bi bi-person"></i><c:out value="${solicitud.docente}"/></span>
                            <span><i class="bi bi-diagram-3"></i><c:out value="${solicitud.division}"/></span>
                            <span><i class="bi bi-calendar3"></i><c:out value="${solicitud.fechaInicio}"/> a <c:out value="${solicitud.fechaFin}"/></span>
                        </div>
                        <span class="request-status"><i class="bi bi-hourglass-split"></i><c:out value="${solicitud.estadoLegible}"/></span>
                    </a>
                </c:forEach>
            </section>
        </c:otherwise>
    </c:choose>
</main>
</body>
</html>
