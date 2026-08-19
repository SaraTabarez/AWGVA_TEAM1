<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="esAdmin" value="${sessionScope.rol == 'ADMIN'}"/>
<c:set var="volverPath" value="${esAdmin ? '/admin/solicitudes' : '/estadias/documentos'}"/>
<c:set var="volverTexto" value="${esAdmin ? 'Volver a Gestión de solicitudes' : 'Volver a Gestión de archivos'}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Documento aceptado</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/workflow.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="result-shell">
    <div class="result-card">
        <div class="result-icon">
            <i class="bi bi-check-lg"></i>
        </div>
        <h1>Documento aceptado</h1>
        <p>La <strong><c:out value="${documento.tipoLegible}"/></strong> fue aceptada correctamente.</p>
        <a class="workflow-btn orange" href="${ctx}${volverPath}"><c:out value="${volverTexto}"/></a>
    </div>
</main>
</body>
</html>