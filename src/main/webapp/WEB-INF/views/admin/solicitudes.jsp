<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Solicitudes - Administración</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/admin-users.css" rel="stylesheet">

    <style>
        .status-pill {
            display: inline-flex;
            padding: 6px 10px;
            border-radius: 999px;
            background: #eef3f8;
            color: #263659;
            font-size: .76rem;
            font-weight: 800
        }
        .request-card {
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 18px;
            background: #fff;
            height: 100%
        }
        .request-card h3 {
            font-size: 1rem;
            font-weight: 800;
            color: #263659
        }
        .request-card p {
            margin: 5px 0;
            color: #697386;
            font-size: .87rem
        }
    </style>
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>

<main class="admin-page">
    <div class="admin-title-row">
        <div>
            <div class="admin-breadcrumb">Administración / Solicitudes</div>
            <h1 class="admin-title">Solicitudes</h1>
            <p class="admin-subtitle">Aquí se muestran todas las solicitudes antes de entrar a la etapa de revisión del reporte.</p>
        </div>
        <a class="btn btn-admin-primary px-4" href="${ctx}/nueva-solicitud">
            <i class="bi bi-plus-circle me-2"></i>Nueva solicitud
        </a>
    </div>

    <c:choose>
        <c:when test="${empty solicitudes}">
            <div class="alert alert-info">No hay solicitudes pendientes en esta etapa.</div>
        </c:when>
        <c:otherwise>
            <div class="row g-3">
                <c:forEach var="s" items="${solicitudes}">
                    <div class="col-12 col-lg-6">
                        <article class="request-card">
                            <div class="d-flex justify-content-between gap-3">
                                <h3>Solicitud #<c:out value="${s.idVisita}"/> · <c:out value="${s.empresa}"/></h3>
                                <span class="status-pill"><c:out value="${s.estadoLegible}"/></span>
                            </div>
                            <p><i class="bi bi-person me-2"></i><c:out value="${s.docente}"/> · <c:out value="${s.division}"/></p>
                            <p><i class="bi bi-mortarboard me-2"></i><c:out value="${s.carrera}"/></p>
                            <p><i class="bi bi-calendar3 me-2"></i><c:out value="${s.fechaInicio}"/> a <c:out value="${s.fechaFin}"/></p>
                            <div class="text-end mt-3">
                                <a class="btn btn-admin-secondary" href="${ctx}/admin/solicitud?ref=${s.referenceToken}">Ver solicitud</a>
                            </div>
                        </article>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</main>
</body>
</html>