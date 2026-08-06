<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Inicio Director - AWGVA</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
<link href="${ctx}/assets/css/workflow.css" rel="stylesheet"></head><body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="workflow-main">
    <h1 class="workflow-title">Solicitudes Recibidas</h1>
    <div class="workflow-subtitle">División <c:out value="${sessionScope.usuario.nombreDivision}"/></div>
    <form class="workflow-card workflow-filters" method="get" action="${ctx}/director/solicitudes">
        <div><label class="workflow-label">Buscar</label><input class="workflow-input" name="q" value="<c:out value='${param.q}'/>" placeholder="Buscar por ID, empresa o carrera"></div>
        <div><label class="workflow-label">Lugar</label><input class="workflow-input" name="lugar" value="<c:out value='${param.lugar}'/>" placeholder="Lugar"></div>
        <div><label class="workflow-label">Fecha</label><input class="workflow-input" type="date" name="fecha" value="<c:out value='${param.fecha}'/>"></div>
        <div><label class="workflow-label">Estado</label><select class="workflow-select" name="estado"><option value="">Todos</option><option value="PENDIENTE_DIRECTOR">Pendiente</option><option value="ACEPTADA_DIRECTOR">Aceptada</option><option value="RECHAZADA_DIRECTOR">Rechazada</option><option value="COMPLETADA">Completada</option></select></div>
        <button class="workflow-btn navy"><i class="bi bi-search"></i> Buscar</button>
    </form>
    <div class="workflow-card" style="padding:0;overflow:auto">
        <table class="workflow-table"><thead><tr><th>ID</th><th>Empresa</th><th>Lugar</th><th>Fecha</th><th>Carrera</th><th>Grupo</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>
        <c:forEach var="sol" items="${solicitudes}"><tr>
            <td><c:out value="${sol.idVisita}"/></td><td><c:out value="${sol.empresa}"/></td><td><c:out value="${sol.direccionEmpresa}"/></td>
            <td><c:out value="${sol.fechaInicio}"/></td><td><c:out value="${sol.carrera}"/></td><td><c:out value="${sol.semestre}"/> <c:out value="${sol.grupo}"/></td>
            <td><span class="status"><c:out value="${sol.estadoLegible}"/></span></td>
            <td><a class="workflow-btn navy" style="min-height:32px;padding:5px 14px" href="${ctx}/director/detalle?id=${sol.idVisita}" title="Ver detalles"><i class="bi bi-eye"></i></a></td>
        </tr></c:forEach>
        <c:if test="${empty solicitudes}"><tr><td class="empty-row" colspan="8">No hay solicitudes registradas en tu división con esos filtros.</td></tr></c:if>
        </tbody></table>
    </div>
</main></body></html>
