<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Histórico - Administración</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/admin-users.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>

<main class="admin-page">
    <div class="admin-title-row">
        <div>
            <div class="admin-breadcrumb">Administración / Histórico</div>
            <h1 class="admin-title">Histórico</h1>
            <p class="admin-subtitle">Solicitudes finalizadas cuyo reporte ya fue aceptado.</p>
        </div>
    </div>

    <section class="admin-card">
        <div class="admin-card-header">
            <i class="bi bi-clock-history"></i>
            <h2>Expedientes concluidos</h2>
        </div>
        <div class="admin-card-body">
            <c:choose>
                <c:when test="${empty solicitudes}">
                    <div class="text-center text-secondary py-4">
                        Todavía no hay expedientes concluidos.
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table users-table align-middle">
                            <thead>
                            <tr>
                                <th>Solicitud</th>
                                <th>Docente</th>
                                <th>Empresa</th>
                                <th>División</th>
                                <th>Fecha</th>
                                <th></th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="s" items="${solicitudes}">
                                <tr>
                                    <td>#<c:out value="${s.idVisita}"/></td>
                                    <td><c:out value="${s.docente}"/></td>
                                    <td><c:out value="${s.empresa}"/></td>
                                    <td><c:out value="${s.division}"/></td>
                                    <td><c:out value="${s.fechaInicio}"/> a <c:out value="${s.fechaFin}"/></td>
                                    <td class="text-end">
                                        <a class="btn btn-admin-secondary btn-sm" href="${ctx}/admin/solicitud?ref=${s.referenceToken}">
                                            Ver expediente
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
</main>
</body>
</html>