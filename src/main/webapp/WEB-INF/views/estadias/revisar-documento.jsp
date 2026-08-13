<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Revisar documento - Estadías</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/workflow.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="workflow-main">
    <div class="detail-head">
        <div>
            <h1 class="workflow-title">Revisión de <c:out value="${documento.tipoLegible}"/></h1>
            <div class="workflow-subtitle" style="margin:0">Expediente de visita académica</div>
        </div>
        <button type="button" class="workflow-btn orange" data-post-url="${ctx}/estadias/documentos">
            <i class="bi bi-arrow-left"></i> Atrás
        </button>
    </div>

    <c:if test="${not empty error}">
        <div class="workflow-card" style="color:#991b1b">
            <c:out value="${error}"/>
        </div>
    </c:if>

    <div class="workflow-card">
        <div class="detail-grid">
            <div class="detail-field span-2">
                <label class="workflow-label">Docente</label>
                <div class="detail-value"><c:out value="${expediente.docente}"/></div>
            </div>
            <div class="detail-field">
                <label class="workflow-label">División</label>
                <div class="detail-value"><c:out value="${expediente.division}"/></div>
            </div>
            <div class="detail-field">
                <label class="workflow-label">Estado</label>
                <div class="detail-value"><c:out value="${documento.estadoLegible}"/></div>
            </div>
            <div class="detail-field span-2">
                <label class="workflow-label">Empresa</label>
                <div class="detail-value"><c:out value="${expediente.empresa}"/></div>
            </div>
            <div class="detail-field span-2">
                <label class="workflow-label">Carrera y grupo</label>
                <div class="detail-value"><c:out value="${expediente.carrera}"/> · <c:out value="${expediente.semestre}"/> <c:out value="${expediente.grupo}"/></div>
            </div>
            <div class="detail-field span-4">
                <button type="button" class="workflow-btn light" style="width:100%" data-private-file="<c:out value='${documento.fileToken}'/>">
                    <i class="bi bi-file-earmark-pdf"></i> Abrir documento: <c:out value="${documento.nombreArchivo}"/>
                </button>
            </div>
        </div>

        <form class="decision-box" action="${ctx}/estadias/revisar" method="post">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="ref" value="<c:out value='${documento.referenceToken}'/>">
            <div class="grow">
                <label class="workflow-label">Observaciones (obligatorias al rechazar)</label>
                <textarea class="workflow-input" style="height:76px" name="observaciones" maxlength="500"></textarea>
            </div>
            <button class="workflow-btn navy" name="decision" value="ACEPTAR">
                <i class="bi bi-check-lg"></i> Aceptar
            </button>
            <button class="workflow-btn orange" name="decision" value="RECHAZAR">
                <i class="bi bi-x-lg"></i> Rechazar
            </button>
        </form>
    </div>
</main>
</body>
</html>