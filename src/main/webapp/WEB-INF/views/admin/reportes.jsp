<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Reportes - Administración</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/admin-users.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>

<main class="admin-page">
    <div class="admin-title-row">
        <div>
            <div class="admin-breadcrumb">Administración / Reporte</div>
            <h1 class="admin-title">Revisión de reportes</h1>
            <p class="admin-subtitle">Los expedientes llegan aquí cuando el docente adjunta su reporte. Al aceptarlo, la visita pasa automáticamente a Histórico.</p>
        </div>
    </div>

    <section class="admin-card">
        <div class="admin-card-header">
            <i class="bi bi-clipboard2-check"></i>
            <h2>Reportes por revisar o corregir</h2>
        </div>
        <div class="admin-card-body">
            <c:choose>
                <c:when test="${empty reportes}">
                    <div class="text-center text-secondary py-4">No hay reportes pendientes.</div>
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
                                <th>Estado</th>
                                <th></th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="doc" items="${reportes}">
                                <tr>
                                    <td>#<c:out value="${doc.idVisitaFk}"/></td>
                                    <td><c:out value="${doc.docente}"/></td>
                                    <td><c:out value="${doc.empresa}"/></td>
                                    <td><c:out value="${doc.division}"/></td>
                                    <td>
                                        <c:out value="${doc.estadoLegible}"/>
                                        <c:if test="${not empty doc.observaciones}">
                                            <div class="small text-danger">
                                                <c:out value="${doc.observaciones}"/>
                                            </div>
                                        </c:if>
                                    </td>
                                    <td class="text-end">
                                        <c:choose>
                                            <c:when test="${doc.estado == 'PENDIENTE'}">
                                                <form method="post" action="${ctx}/estadias/reporte">
                                                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                                                    <input type="hidden" name="ref" value="<c:out value='${doc.referenceToken}'/>">
                                                    <button class="btn btn-admin-primary btn-sm" type="submit">Revisar</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-secondary small">Esperando corrección</span>
                                            </c:otherwise>
                                        </c:choose>
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