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
    <form class="workflow-card workflow-filters" method="post" action="${ctx}/director/solicitudes">
        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
        <div><label class="workflow-label">Buscar</label><input class="workflow-input" name="q" value="<c:out value='${param.q}'/>" placeholder="Empresa, lugar o docente"></div>
        <div><label class="workflow-label">Carrera</label><select class="workflow-select" name="carrera"><option value="">Todas las carreras</option><c:forEach var="carrera" items="${carreras}"><option value="<c:out value='${carrera}'/>" ${carrera == carreraSeleccionada ? 'selected' : ''}><c:out value="${carrera}"/></option></c:forEach></select></div>
        <div><label class="workflow-label">Lugar</label><input class="workflow-input" name="lugar" value="<c:out value='${param.lugar}'/>" placeholder="Lugar"></div>
        <div><label class="workflow-label">Fecha</label><input class="workflow-input" type="date" name="fecha" value="<c:out value='${param.fecha}'/>"></div>
        <div><label class="workflow-label">Estado</label><select class="workflow-select" name="estado"><option value="">Todos</option><option value="PENDIENTE_DIRECTOR">Pendiente</option><option value="ACEPTADA_DIRECTOR">Aceptada</option><option value="RECHAZADA_DIRECTOR">Rechazada</option><option value="COMPLETADA">Completada</option></select></div>
        <button class="workflow-btn navy"><i class="bi bi-search"></i> Buscar</button>
    </form>
    <div class="workflow-card" style="padding:0;overflow:auto">
        <table class="workflow-table"><thead><tr><th>Empresa</th><th>Lugar</th><th>Fecha</th><th>Carrera</th><th>Grupo</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>
        <c:forEach var="sol" items="${solicitudes}"><tr>
            <td><c:out value="${sol.empresa}"/></td><td><c:out value="${sol.direccionEmpresa}"/></td>
            <td><c:out value="${sol.fechaInicio}"/></td><td><c:out value="${sol.carrera}"/></td><td><c:out value="${sol.semestre}"/> <c:out value="${sol.grupo}"/></td>
            <td><span class="status"><c:out value="${sol.estadoLegible}"/></span></td>
            <td><form action="${ctx}/director/detalle" method="post"><input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>"><input type="hidden" name="ref" value="<c:out value='${sol.referenceToken}'/>"><button class="workflow-btn navy" style="min-height:32px;padding:5px 14px" title="Ver detalles"><i class="bi bi-eye"></i></button></form></td>
        </tr></c:forEach>
        <c:if test="${empty solicitudes}"><tr><td class="empty-row" colspan="7">No hay solicitudes registradas en tu división con esos filtros.</td></tr></c:if>
        </tbody></table>
    </div>
</main></body></html>