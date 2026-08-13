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
        <div class="col-12"><div class="admin-breadcrumb">Administración / Firmantes oficiales</div><h1 class="admin-title">Firmantes oficiales</h1><p class="admin-subtitle">Los nombres configurados se usarán en solicitudes, cartas y oficios.</p></div>
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
                            <div class="col-12"><hr><h3 class="h5 fw-bold">Docente Responsable</h3></div>
                            <div class="col-12 col-lg-6"><label class="form-label" for="docenteNombre">Nombre completo</label><input class="form-control" id="docenteNombre" name="docenteNombre" maxlength="180" value="<c:out value='${firmantes.docenteNombre}'/>" required></div>
                            <div class="col-12 col-lg-6"><label class="form-label" for="docenteCargo">Cargo oficial</label><input class="form-control" id="docenteCargo" name="docenteCargo" maxlength="180" value="<c:out value='${firmantes.docenteCargo}'/>" required></div>
                            <div class="col-12"><hr><h3 class="h5 fw-bold">Jefatura de Estadías</h3></div>
                            <div class="col-12 col-lg-6"><label class="form-label" for="estadiasNombre">Nombre completo</label><input class="form-control" id="estadiasNombre" name="estadiasNombre" maxlength="180" value="<c:out value='${firmantes.estadiasNombre}'/>" required></div>
                            <div class="col-12 col-lg-6"><label class="form-label" for="estadiasCargo">Cargo oficial</label><input class="form-control" id="estadiasCargo" name="estadiasCargo" maxlength="180" value="<c:out value='${firmantes.estadiasCargo}'/>" required></div>
                            <div class="col-12 text-end"><button class="btn btn-admin-primary px-4" type="submit"><i class="bi bi-save me-2"></i>Guardar firmantes</button></div>
                        </div>
                    </form>
                </div>
            </section>
        </div>
    </div>
</main>
</body>
</html>