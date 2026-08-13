<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Revisión de reporte - Estadías</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/workflow.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="workflow-main">
    <div class="detail-head">
        <div>
            <h1 class="workflow-title">Reporte de Visita Académica</h1>
            <div class="workflow-subtitle" style="margin:0">Revisión del expediente</div>
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
            <div class="section-caption">Datos de los participantes y responsables</div>
            <div class="detail-field">
                <label class="workflow-label">División</label>
                <div class="detail-value"><c:out value="${expediente.division}"/></div>
            </div>
            <div class="detail-field span-2">
                <label class="workflow-label">Docente responsable</label>
                <div class="detail-value"><c:out value="${expediente.docente}"/></div>
            </div>
            <div class="detail-field">
                <label class="workflow-label">Estudiantes</label>
                <div class="detail-value"><c:out value="${expediente.numeroEstudiantes}"/></div>
            </div>
            <div class="detail-field span-2">
                <label class="workflow-label">Programa educativo</label>
                <div class="detail-value"><c:out value="${expediente.carrera}"/></div>
            </div>
            <div class="detail-field">
                <label class="workflow-label">Cuatrimestre</label>
                <div class="detail-value"><c:out value="${expediente.semestre}"/></div>
            </div>
            <div class="detail-field">
                <label class="workflow-label">Grupo</label>
                <div class="detail-value"><c:out value="${expediente.grupo}"/></div>
            </div>

            <div class="section-caption">Datos del lugar a visitar</div>
            <div class="detail-field span-2">
                <label class="workflow-label">Empresa</label>
                <div class="detail-value"><c:out value="${expediente.empresa}"/></div>
            </div>
            <div class="detail-field span-2">
                <label class="workflow-label">Dirección</label>
                <div class="detail-value"><c:out value="${expediente.direccionEmpresa}"/></div>
            </div>
            <div class="detail-field span-4">
                <button type="button" class="workflow-btn light" style="width:100%" data-private-file="<c:out value='${documento.fileToken}'/>">
                    <i class="bi bi-file-earmark-text"></i> Abrir reporte final
                </button>
            </div>
        </div>

        <div class="section-caption">Evidencias de la visita</div>
        <div class="evidence-grid">
            <c:forEach var="evidencia" items="${evidencias}">
                <div class="evidence">
                    <img data-private-image="<c:out value='${evidencia.fileToken}'/>" alt="Evidencia">
                    <button type="button" data-private-file="<c:out value='${evidencia.fileToken}'/>">
                        <c:out value="${evidencia.nombreArchivo}"/>
                    </button>
                </div>
            </c:forEach>
            <c:if test="${empty evidencias}">
                <div class="detail-value">Sin evidencias registradas.</div>
            </c:if>
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