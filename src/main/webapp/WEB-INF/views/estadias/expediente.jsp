<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Expediente histórico</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/workflow.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="workflow-main">
    <div class="detail-head">
        <div>
            <h1 class="workflow-title">Expediente histórico</h1>
            <div class="workflow-subtitle"><c:out value="${expediente.empresa}"/> · <c:out value="${expediente.estadoLegible}"/></div>
        </div>
        <button type="button" class="workflow-btn orange" data-post-url="${ctx}/estadias/historico">
            <i class="bi bi-arrow-left"></i> Atrás
        </button>
    </div>

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
                <label class="workflow-label">Carrera</label>
                <div class="detail-value"><c:out value="${expediente.carrera}"/></div>
            </div>
            <div class="detail-field span-2">
                <label class="workflow-label">Empresa</label>
                <div class="detail-value"><c:out value="${expediente.empresa}"/></div>
            </div>
            <div class="detail-field span-2">
                <label class="workflow-label">Fechas</label>
                <div class="detail-value"><c:out value="${expediente.fechaInicio}"/> a <c:out value="${expediente.fechaFin}"/></div>
            </div>
        </div>
    </div>

    <div class="row g-3">
        <c:forEach var="doc" items="${expediente.documentos}">
            <div class="col-12 col-md-6 col-xl-4">
                <div class="workflow-card" style="height:100%">
                    <h3><c:out value="${doc.tipoLegible}"/></h3>
                    <p><c:out value="${doc.nombreArchivo}"/></p>
                    <p><span class="status"><c:out value="${doc.estadoLegible}"/></span></p>
                    <c:if test="${not empty doc.observaciones}">
                        <p><c:out value="${doc.observaciones}"/></p>
                    </c:if>
                    <button type="button" class="workflow-btn navy" data-private-file="<c:out value='${doc.fileToken}'/>">
                        <i class="bi bi-eye"></i> Abrir documento
                    </button>
                    <button type="button" class="workflow-btn light" data-private-file="<c:out value='${doc.fileToken}'/>" data-download>
                        <i class="bi bi-download"></i> Descargar
                    </button>
                </div>
            </div>
        </c:forEach>
        <c:if test="${empty expediente.documentos}">
            <div class="col-12">
                <div class="workflow-card">No hay documentos disponibles.</div>
            </div>
        </c:if>
    </div>
</main>
</body>
</html>