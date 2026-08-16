<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Documento rechazado</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/workflow.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="result-shell">
    <div class="result-card">
        <div class="result-icon rejected">
            <i class="bi bi-x-lg"></i>
        </div>
        <h1>Documento rechazado</h1>
        <p>La <strong><c:out value="${documento.tipoLegible}"/></strong> fue rechazada. El docente recibió las observaciones y podrá sustituir únicamente ese archivo.</p>
        <button type="button" class="workflow-btn orange" data-post-url="${ctx}/estadias/documentos">Volver a Gestión de archivos</button>
    </div>
</main>
</body>
</html>