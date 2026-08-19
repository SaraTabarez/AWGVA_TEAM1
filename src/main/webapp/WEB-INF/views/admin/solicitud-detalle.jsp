<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Detalle solicitud - Administración</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/admin-users.css" rel="stylesheet">

    <style>
        .data-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
        }
        .data-box {
            background: #f7f9fc;
            border: 1px solid #e1e7ef;
            border-radius: 9px;
            padding: 13px;
        }
        .data-box small {
            display: block;
            color: #697386;
            font-weight: 700;
            margin-bottom: 4px;
        }
        .doc-row {
            border: 1px solid #e1e7ef;
            border-radius: 10px;
            padding: 14px;
            margin-bottom: 10px;
        }
        .pill {
            display: inline-flex;
            padding: 5px 10px;
            border-radius: 999px;
            background: #eef3f8;
            font-size: .75rem;
            font-weight: 800;
        }
        @media(max-width: 700px) {
            .data-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>

<main class="admin-page">
    <div class="admin-title-row">
        <div>
            <div class="admin-breadcrumb">Administración / Solicitudes / Detalle</div>
            <h1 class="admin-title">Solicitud #<c:out value="${expediente.idVisita}"/></h1>
            <p class="admin-subtitle"><c:out value="${expediente.estadoLegible}"/></p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-admin-secondary" href="${ctx}/admin/solicitudes">Volver</a>
            <c:if test="${not empty ownerRef}">
                <button class="btn btn-admin-primary" type="button" data-post-url="${ctx}/detalle-solicitud" data-post-ref="<c:out value='${ownerRef}'/>">
                    Continuar mi solicitud
                </button>
            </c:if>
        </div>
    </div>

    <section class="admin-card mb-4">
        <div class="admin-card-header">
            <i class="bi bi-info-circle"></i>
            <h2>Datos de la solicitud</h2>
        </div>
        <div class="admin-card-body">
            <div class="data-grid">
                <div class="data-box">
                    <small>Docente responsable</small>
                    <c:out value="${expediente.docente}"/>
                </div>
                <div class="data-box">
                    <small>División</small>
                    <c:out value="${expediente.division}"/>
                </div>
                <div class="data-box">
                    <small>Empresa</small>
                    <c:out value="${expediente.empresa}"/>
                </div>
                <div class="data-box">
                    <small>Programa / grupo</small>
                    <c:out value="${expediente.carrera}"/> · <c:out value="${expediente.semestre}"/> · <c:out value="${expediente.grupo}"/>
                </div>
                <div class="data-box">
                    <small>Fecha</small>
                    <c:out value="${expediente.fechaInicio}"/> a <c:out value="${expediente.fechaFin}"/>
                </div>
                <div class="data-box">
                    <small>Estado actual</small>
                    <strong><c:out value="${expediente.estadoLegible}"/></strong>
                </div>
            </div>
            <div class="data-box mt-3">
                <small>Propósito</small>
                <c:out value="${expediente.proposito}"/>
            </div>
        </div>
    </section>

    <section class="admin-card">
        <div class="admin-card-header">
            <i class="bi bi-folder2-open"></i>
            <h2>Documentos cargados</h2>
        </div>
        <div class="admin-card-body">
            <c:choose>
                <c:when test="${empty expediente.documentos}">
                    <div class="text-secondary">Todavía no hay documentos firmados cargados para esta solicitud.</div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="doc" items="${expediente.documentos}">
                        <div class="doc-row">
                            <div class="d-flex flex-wrap justify-content-between gap-2">
                                <div>
                                    <strong><c:out value="${doc.tipoLegible}"/></strong>
                                    <div class="text-secondary small"><c:out value="${doc.nombreArchivo}"/></div>
                                </div>
                                <span class="pill"><c:out value="${doc.estadoLegible}"/></span>
                            </div>
                            <c:if test="${not empty doc.observaciones}">
                                <div class="alert alert-warning py-2 mt-2 mb-0">
                                    <c:out value="${doc.observaciones}"/>
                                </div>
                            </c:if>
                            <div class="d-flex gap-2 justify-content-end mt-3">
                                <button class="btn btn-sm btn-admin-secondary" type="button" data-private-file="<c:out value='${doc.fileToken}'/>">
                                    <i class="bi bi-eye me-1"></i>Ver
                                </button>
                                <c:if test="${doc.estado == 'PENDIENTE'}">
                                    <form method="post" action="${ctx}${doc.tipoDocumento == 'REPORTE' ? '/estadias/reporte' : '/estadias/documento'}">
                                        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                                        <input type="hidden" name="ref" value="<c:out value='${doc.referenceToken}'/>">
                                        <button class="btn btn-sm btn-admin-primary" type="submit">Revisar</button>
                                    </form>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
</main>
</body>
</html>