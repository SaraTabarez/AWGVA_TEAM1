
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Firmantes oficiales - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/admin-users.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="admin-page">
    <div class="row g-4">
        <div class="col-12"><div class="admin-breadcrumb">Administración / Firmantes</div><h1 class="admin-title">Firmantes</h1><p class="admin-subtitle">Dirección y Estadías se configuran aquí. El docente se toma automáticamente del usuario propietario de cada solicitud para evitar nombres equivocados al imprimir.</p></div>
        <div class="col-12">
            <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
            <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
        </div>
        <div class="col-12">
            <section class="admin-card">
                <div class="admin-card-header"><i class="bi bi-pen-fill"></i><h2>Configuración de firmas</h2></div>
                <div class="admin-card-body">
                    <form action="${ctx}/admin/firmantes" method="post">
                        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                        <div class="row g-4">
                            <div class="col-12"><h3 class="h5 fw-bold">Director de Carrera</h3></div>
                            <div class="col-12 col-lg-6"><label class="form-label" for="directorNombre">Nombre completo</label><input class="form-control" id="directorNombre" name="directorNombre" maxlength="180" value="<c:out value='${firmantes.directorNombre}'/>" required></div>
                            <div class="col-12 col-lg-6"><label class="form-label" for="directorCargo">Cargo oficial</label><input class="form-control" id="directorCargo" name="directorCargo" maxlength="180" value="<c:out value='${firmantes.directorCargo}'/>" required></div>
                            <input type="hidden" name="docenteNombre" value="<c:out value='${firmantes.docenteNombre}'/>">
                            <input type="hidden" name="docenteCargo" value="<c:out value='${firmantes.docenteCargo}'/>">
                            <div class="col-12"><hr><h3 class="h5 fw-bold">Jefatura de Estadías</h3></div>
                            <div class="col-12 col-lg-6"><label class="form-label" for="estadiasNombre">Nombre completo</label><input class="form-control" id="estadiasNombre" name="estadiasNombre" maxlength="180" value="<c:out value='${firmantes.estadiasNombre}'/>" required></div>
                            <div class="col-12 col-lg-6"><label class="form-label" for="estadiasCargo">Cargo oficial</label><input class="form-control" id="estadiasCargo" name="estadiasCargo" maxlength="180" value="<c:out value='${firmantes.estadiasCargo}'/>" required></div>
                            <div class="col-12 text-end"><button class="btn btn-admin-primary px-4" type="submit"><i class="bi bi-save me-2"></i>Guardar firmantes</button></div>
                        </div>
                    </form>
                </div>
            </section>
        </div>
        <div class="col-12">
            <section class="admin-card">
                <div class="admin-card-header"><i class="bi bi-person-badge-fill"></i><h2>Docentes registrados para firma automática</h2></div>
                <div class="admin-card-body">
                    <div class="admin-help mb-3">El nombre que aparecerá en la solicitud y en la carta responsiva se toma automáticamente de la cuenta que creó la visita. Si necesitas agregar otro docente, regístralo en Gestión de usuarios con rol DOCENTE.</div>
                    <div class="table-responsive"><table class="table users-table align-middle"><thead><tr><th>Docente</th><th>Correo</th><th>División</th></tr></thead><tbody>
                    <c:forEach var="docente" items="${docentes}"><tr><td><strong><c:out value="${docente.nombreCompleto}"/></strong></td><td><c:out value="${docente.correo}"/></td><td><c:out value="${docente.nombreDivision}"/></td></tr></c:forEach>
                    <c:if test="${empty docentes}"><tr><td colspan="3" class="text-center text-secondary py-4">No hay docentes activos registrados.</td></tr></c:if>
                    </tbody></table></div>
                    <div class="text-end"><a class="btn btn-admin-secondary" href="${ctx}/admin/usuarios"><i class="bi bi-person-plus me-2"></i>Registrar o administrar docentes</a></div>
                </div>
            </section>
        </div>
    </div>
</main>
</body>
</html>