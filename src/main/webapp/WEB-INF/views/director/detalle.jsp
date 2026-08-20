<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Detalle de solicitud - Director</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/workflow.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="workflow-main">
    <div class="detail-head">
        <div>
            <h1 class="workflow-title">Solicitud de Visita Industrial</h1>
            <div class="workflow-subtitle" style="margin:0">División Académica <c:out value="${expediente.division}"/> · Consulta únicamente</div>
        </div>
        <form action="${volverHistorico ? ctx.concat('/director/historico') : ctx.concat('/director/solicitudes')}" method="post">
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <button class="workflow-btn orange"><i class="bi bi-arrow-left"></i> Atrás</button>
        </form>
    </div>

    <c:if test="${not empty error}"><div class="workflow-card" style="color:#991b1b"><c:out value="${error}"/></div></c:if>

    <div class="workflow-card"><div class="detail-grid">
        <div class="section-caption">Datos de la solicitud</div>
        <div class="detail-field"><label class="workflow-label">Estado</label><div class="detail-value"><c:out value="${expediente.estadoLegible}"/></div></div>
        <div class="detail-field span-2"><label class="workflow-label">Docente responsable</label><div class="detail-value"><c:out value="${expediente.docente}"/> · <c:out value="${expediente.correoDocente}"/></div></div>
        <div class="detail-field span-2"><label class="workflow-label">Empresa</label><div class="detail-value"><c:out value="${expediente.empresa}"/></div></div>
        <div class="detail-field span-2"><label class="workflow-label">Dirección</label><div class="detail-value"><c:out value="${expediente.direccionEmpresa}"/></div></div>
        <div class="detail-field"><label class="workflow-label">Inicio</label><div class="detail-value"><c:out value="${expediente.fechaInicio}"/></div></div>
        <div class="detail-field"><label class="workflow-label">Término</label><div class="detail-value"><c:out value="${expediente.fechaFin}"/></div></div>
        <div class="detail-field"><label class="workflow-label">Teléfono empresa</label><div class="detail-value"><c:out value="${expediente.telefonoEmpresa}"/></div></div>
        <div class="detail-field"><label class="workflow-label">Correo empresa</label><div class="detail-value"><c:out value="${expediente.correoEmpresa}"/></div></div>
        <div class="detail-field span-2"><label class="workflow-label">Programa educativo</label><div class="detail-value"><c:out value="${expediente.carrera}"/></div></div>
        <div class="detail-field"><label class="workflow-label">Cuatrimestre / grupo</label><div class="detail-value"><c:out value="${expediente.semestre}"/> <c:out value="${expediente.grupo}"/></div></div>
        <div class="detail-field"><label class="workflow-label">Estudiantes</label><div class="detail-value"><c:out value="${expediente.numeroEstudiantes}"/></div></div>
        <div class="detail-field span-4"><label class="workflow-label">Objetivo de la visita</label><div class="detail-value"><c:out value="${expediente.proposito}"/></div></div>
        <div class="detail-field span-4"><label class="workflow-label">Asignaturas que se reforzarán</label><div class="detail-value"><c:out value="${expediente.asignatura}"/></div></div>
        <c:if test="${not empty expediente.motivoRechazo}"><div class="detail-field span-4"><label class="workflow-label">Observaciones registradas</label><div class="detail-value"><c:out value="${expediente.motivoRechazo}"/></div></div></c:if>

        <div class="section-caption">Documentos (consulta únicamente)</div>
        <c:forEach var="doc" items="${expediente.documentos}">
            <div class="detail-field">
                <label class="workflow-label"><c:out value="${doc.tipoLegible}"/></label>
                <button type="button" class="workflow-btn light" data-private-file="<c:out value='${doc.fileToken}'/>">
                    <i class="bi bi-eye"></i> Ver · <c:out value="${doc.estadoLegible}"/>
                </button>
            </div>
        </c:forEach>
        <c:if test="${empty expediente.documentos}"><div class="detail-field span-4"><div class="detail-value">El docente aún no ha entregado documentos.</div></div></c:if>
    </div></div>
</main>
</body>
</html>
