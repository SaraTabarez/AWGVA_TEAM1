<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Histórico Director - AWGVA</title><link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet"><link href="${ctx}/assets/css/workflow.css" rel="stylesheet"></head><body>
<jsp:include page="/Layout/sidebar.jsp"/><main class="workflow-main">
    <h1 class="workflow-title">Histórico de solicitudes</h1><div class="workflow-subtitle">Sólo visitas completadas de <c:out value="${sessionScope.usuario.nombreDivision}"/></div>
    <form class="workflow-card workflow-filters" method="post" action="${ctx}/director/historico">
        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
        <div><label class="workflow-label">Carrera</label><select class="workflow-select" name="carrera"><option value="">Todas las carreras de mi división</option><c:forEach var="carrera" items="${carreras}"><option value="<c:out value='${carrera}'/>" ${carrera == carreraSeleccionada ? 'selected' : ''}><c:out value="${carrera}"/></option></c:forEach></select></div>
        <div><label class="workflow-label">Buscar</label><input class="workflow-input" name="q" value="<c:out value='${param.q}'/>" placeholder="ID, empresa o lugar"></div>
        <div><label class="workflow-label">Fecha</label><input class="workflow-input" type="date" name="fecha" value="<c:out value='${param.fecha}'/>"></div>
        <div></div><button class="workflow-btn navy"><i class="bi bi-funnel"></i> Filtrar</button>
    </form>
    <div class="workflow-card" style="padding:0;overflow:auto"><table class="workflow-table"><thead><tr><th>Empresa</th><th>Lugar</th><th>Fecha</th><th>Carrera</th><th>Grupo</th><th>Acciones</th></tr></thead><tbody>
    <c:forEach var="sol" items="${solicitudes}"><tr><td><c:out value="${sol.empresa}"/></td><td><c:out value="${sol.direccionEmpresa}"/></td><td><c:out value="${sol.fechaFin}"/></td><td><c:out value="${sol.carrera}"/></td><td><c:out value="${sol.semestre}"/> <c:out value="${sol.grupo}"/></td><td><form action="${ctx}/director/detalle" method="post"><input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>"><input type="hidden" name="ref" value="<c:out value='${sol.referenceToken}'/>"><input type="hidden" name="origen" value="historico"><button class="workflow-btn navy" style="min-height:32px;padding:5px 14px"><i class="bi bi-eye"></i></button></form></td></tr></c:forEach>
    <c:if test="${empty solicitudes}"><tr><td class="empty-row" colspan="6">No hay visitas completadas para la carrera seleccionada.</td></tr></c:if>
    </tbody></table></div></main></body></html>