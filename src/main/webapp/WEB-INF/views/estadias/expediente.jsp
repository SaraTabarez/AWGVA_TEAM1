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

    <section class="workflow-card" style="margin-top:18px">
        <h3 style="margin-bottom:14px">Evidencias del reporte</h3>
        <c:choose>
            <c:when test="${not empty evidencias}">
                <div class="row g-3">
                    <c:forEach var="evidencia" items="${evidencias}">
                        <div class="col-12 col-md-4">
                            <div style="border:1px solid #d7dee7;border-radius:8px;overflow:hidden;height:100%">
                                <img data-private-image="<c:out value='${evidencia.fileToken}'/>"
                                     alt="<c:out value='${evidencia.tipoLegible}'/>"
                                     style="width:100%;height:210px;object-fit:cover;background:#eef3f8">
                                <div style="padding:12px">
                                    <strong><c:out value="${evidencia.tipoLegible}"/></strong><br>
                                    <small><c:out value="${evidencia.nombreArchivo}"/></small>
                                    <div style="margin-top:10px;display:flex;gap:8px;flex-wrap:wrap">
                                        <button type="button" class="workflow-btn navy" data-private-file="<c:out value='${evidencia.fileToken}'/>"><i class="bi bi-eye"></i> Abrir</button>
                                        <button type="button" class="workflow-btn light" data-private-file="<c:out value='${evidencia.fileToken}'/>" data-download><i class="bi bi-download"></i> Descargar</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="detail-value">No hay evidencias fotográficas disponibles para este expediente.</div>
            </c:otherwise>
        </c:choose>
    </section>
</main>
</body>
</html>