<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Usuario</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
        }

        .main-layout {
            margin-left: 240px;
            padding: 2.5rem 3rem;
            min-height: 100vh;
        }

        .card-custom {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        .btn-custom-dark { background-color: #2b2d42; color: white; border: none; }
        .btn-custom-dark:hover { background-color: #1a1b26; color: white; }

        .btn-custom-orange { background-color: #f39c12; color: white; border: none; font-weight: 600; }
        .btn-custom-orange:hover { background-color: #d68100; color: white; }

        .required-asterisk { color: #e74c3c; }

        @media (max-width: 768px) {
            .main-layout {
                margin-left: 0;
                padding: 1.5rem;
            }
        }
    </style>
</head>
<body>

<jsp:include page="Layout/sidebar.jsp"/>

<main class="main-layout">
    <div class="d-flex align-items-center mb-4">
        <a href="${pageContext.request.contextPath}/GestionUsuariosServlet" class="btn btn-custom-dark me-3">
            <i class="bi bi-arrow-left"></i> Volver
        </a>
        <h3 class="fw-bold m-0" style="color: #2b2d42;">REGISTRAR NUEVO USUARIO</h3>
    </div>

    <div class="card card-custom bg-white p-4">
        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/RegistrarUsuarioServlet" method="POST" id="form-registrar-usuario">
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>"/>

            <h5 class="fw-bold mb-3 text-secondary border-bottom pb-2">Información Personal</h5>
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <label for="nombres" class="form-label fw-bold small">Nombre(s) <span class="required-asterisk">*</span></label>
                    <input type="text" class="form-control" id="nombres" name="nombres" maxlength="100"
                           value="<c:out value='${nombresValue}'/>" placeholder="Ej. Juan Carlos" required>
                </div>

                <div class="col-md-4">
                    <label for="apellidoPaterno" class="form-label fw-bold small">Apellido Paterno <span class="required-asterisk">*</span></label>
                    <input type="text" class="form-control" id="apellidoPaterno" name="apellidoPaterno" maxlength="100"
                           value="<c:out value='${apellidoPaternoValue}'/>" placeholder="Ej. Pérez" required>
                </div>

                <div class="col-md-4">
                    <label for="apellidoMaterno" class="form-label fw-bold small">Apellido Materno <span class="required-asterisk">*</span></label>
                    <input type="text" class="form-control" id="apellidoMaterno" name="apellidoMaterno" maxlength="100"
                           value="<c:out value='${apellidoMaternoValue}'/>" placeholder="Ej. Gómez" required>
                </div>
            </div>

            <h5 class="fw-bold mb-3 text-secondary border-bottom pb-2">Cuenta y Accesos</h5>
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <label for="correo" class="form-label fw-bold small">Correo Institucional <span class="required-asterisk">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="bi bi-envelope"></i></span>
                        <input type="email" class="form-control" id="correo" name="correo" maxlength="160"
                               value="<c:out value='${correoValue}'/>" placeholder="ejemplo@utez.edu.mx" required>
                    </div>
                </div>

                <div class="col-md-6">
                    <label for="password" class="form-label fw-bold small">Contraseña <span class="required-asterisk">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control" id="password" name="password" minlength="10"
                               maxlength="200" placeholder="••••••••••" required>
                    </div>
                    <div class="form-text">Mínimo 10 caracteres con mayúscula, minúscula, número y símbolo.</div>
                </div>
            </div>

            <h5 class="fw-bold mb-3 text-secondary border-bottom pb-2">Asignación de Rol y División</h5>
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <label for="idRol" class="form-label fw-bold small">Rol <span class="required-asterisk">*</span></label>
                    <select class="form-select" id="idRol" name="idRol" required>
                        <option value="" ${empty idRolValue ? 'selected' : ''} disabled>-- Selecciona un Rol --</option>
                        <c:forEach var="rol" items="${roles}">
                            <option value="${rol.key}" ${idRolValue == rol.key ? 'selected' : ''}>
                                <c:out value="${rol.value}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-6">
                    <label for="idDivision" class="form-label fw-bold small">División</label>
                    <select class="form-select" id="idDivision" name="idDivision">
                        <option value="">Sin División (Opcional)</option>
                        <c:forEach var="division" items="${divisiones}">
                            <option value="${division.key}" ${idDivisionValue == division.key ? 'selected' : ''}>
                                <c:out value="${division.value}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                <a href="${pageContext.request.contextPath}/GestionUsuariosServlet" class="btn btn-light px-4">Cancelar</a>
                <button type="submit" class="btn btn-custom-orange px-4">
                    <i class="bi bi-check-lg me-1"></i> Guardar Usuario
                </button>
            </div>
        </form>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
