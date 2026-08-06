<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Altas de usuario - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/admin-users.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>

<main class="admin-page">
    <div class="admin-breadcrumb">Gestión de usuarios / Altas de usuario / Admin</div>
    <div class="admin-title-row">
        <div>
            <h1 class="admin-title">Altas de usuario</h1>
            <p class="admin-subtitle">Crea una cuenta real en Oracle y asigna el rol que utilizará dentro del sistema.</p>
        </div>
        <a href="${ctx}/admin/usuarios" class="btn btn-admin-secondary px-4">
            <i class="bi bi-person-x me-2"></i>Eliminar usuarios
        </a>
    </div>

    <section class="admin-card" aria-labelledby="titulo-formulario-alta">
        <div class="admin-card-header">
            <i class="bi bi-person-plus-fill" aria-hidden="true"></i>
            <h2 id="titulo-formulario-alta">Datos del nuevo usuario</h2>
        </div>
        <div class="admin-card-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <i class="bi bi-exclamation-circle me-2"></i><c:out value="${error}"/>
                </div>
            </c:if>

            <div class="admin-help mb-4">
                <i class="bi bi-info-circle me-2"></i>
                El ID, el estado activo y la fecha de registro se generan automáticamente. El formulario no utiliza matrícula.
            </div>

            <form action="${ctx}/admin/usuarios/alta" method="post" id="form-alta-usuario" autocomplete="off">
                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>"/>

                <div class="row g-3">
                    <div class="col-md-4">
                        <label for="nombres" class="form-label">Nombre(s) <span class="required-mark">*</span></label>
                        <input type="text" class="form-control" id="nombres" name="nombres" maxlength="100"
                               value="<c:out value='${nombresValue}'/>" required autocomplete="given-name">
                    </div>
                    <div class="col-md-4">
                        <label for="apellidoPaterno" class="form-label">Apellido paterno <span class="required-mark">*</span></label>
                        <input type="text" class="form-control" id="apellidoPaterno" name="apellidoPaterno" maxlength="100"
                               value="<c:out value='${apellidoPaternoValue}'/>" required autocomplete="family-name">
                    </div>
                    <div class="col-md-4">
                        <label for="apellidoMaterno" class="form-label">Apellido materno <span class="required-mark">*</span></label>
                        <input type="text" class="form-control" id="apellidoMaterno" name="apellidoMaterno" maxlength="100"
                               value="<c:out value='${apellidoMaternoValue}'/>" required>
                    </div>

                    <div class="col-md-6">
                        <label for="correo" class="form-label">Correo institucional <span class="required-mark">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="bi bi-envelope"></i></span>
                            <input type="email" class="form-control" id="correo" name="correo" maxlength="160"
                                   value="<c:out value='${correoValue}'/>" placeholder="usuario@utez.edu.mx"
                                   required autocomplete="email">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label for="password" class="form-label">Contraseña inicial <span class="required-mark">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="bi bi-lock"></i></span>
                            <input type="password" class="form-control" id="password" name="password"
                                   minlength="10" maxlength="200" required autocomplete="new-password">
                            <button class="btn btn-outline-secondary" type="button" id="mostrar-password"
                                    aria-label="Mostrar u ocultar contraseña">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                        <div class="form-text">Mínimo 10 caracteres, con mayúscula, minúscula, número y símbolo.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="idRol" class="form-label">Rol <span class="required-mark">*</span></label>
                        <select class="form-select" id="idRol" name="idRol" required>
                            <option value="" disabled ${empty idRolValue ? 'selected' : ''}>Selecciona un rol</option>
                            <c:forEach var="rol" items="${roles}">
                                <option value="${rol.key}" data-role="${rol.value}"
                                        ${idRolValue == rol.key ? 'selected' : ''}>
                                    <c:out value="${rol.value}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <div class="form-text">Por seguridad, este formulario no crea cuentas ADMIN.</div>
                    </div>
                    <div class="col-md-6">
                        <label for="idDivision" class="form-label">División <span id="division-required" class="required-mark d-none">*</span></label>
                        <select class="form-select" id="idDivision" name="idDivision">
                            <option value="">Sin división</option>
                            <c:forEach var="division" items="${divisiones}">
                                <option value="${division.key}" ${idDivisionValue == division.key ? 'selected' : ''}>
                                    <c:out value="${division.value}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <div class="form-text">Es obligatoria para Docente y Director.</div>
                    </div>
                </div>

                <div class="d-flex flex-wrap justify-content-end gap-2 mt-4 pt-4 border-top">
                    <a href="${ctx}/inicio" class="btn btn-light px-4">Cancelar</a>
                    <button type="submit" class="btn btn-admin-primary px-4">
                        <i class="bi bi-person-check-fill me-2"></i>Crear usuario
                    </button>
                </div>
            </form>
        </div>
    </section>
</main>

<script>
    const roleSelect = document.getElementById('idRol');
    const divisionSelect = document.getElementById('idDivision');
    const divisionRequired = document.getElementById('division-required');
    const passwordInput = document.getElementById('password');
    const passwordButton = document.getElementById('mostrar-password');

    function updateDivisionRequirement() {
        const option = roleSelect.options[roleSelect.selectedIndex];
        const role = option ? (option.dataset.role || '').toUpperCase() : '';
        const required = role === 'DOCENTE' || role === 'DIRECTOR';
        divisionSelect.required = required;
        divisionRequired.classList.toggle('d-none', !required);
    }

    roleSelect.addEventListener('change', updateDivisionRequirement);
    updateDivisionRequirement();

    passwordButton.addEventListener('click', function () {
        const hidden = passwordInput.type === 'password';
        passwordInput.type = hidden ? 'text' : 'password';
        passwordButton.innerHTML = hidden ? '<i class="bi bi-eye-slash"></i>' : '<i class="bi bi-eye"></i>';
    });
</script>
</body>
</html>
