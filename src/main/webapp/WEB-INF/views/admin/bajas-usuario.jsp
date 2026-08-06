<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Eliminar usuarios - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/admin-users.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>

<main class="admin-page">
    <div class="admin-breadcrumb">Gestión de usuarios / Eliminar usuarios / Admin</div>
    <div class="admin-title-row">
        <div>
            <h1 class="admin-title">Eliminar usuarios</h1>
            <p class="admin-subtitle">Las cuentas mostradas se consultan directamente desde Oracle. Al confirmar, la cuenta se elimina físicamente y ya no puede iniciar sesión.</p>
        </div>
        <a href="${ctx}/admin/usuarios/alta" class="btn btn-admin-primary px-4">
            <i class="bi bi-person-plus-fill me-2"></i>Altas de usuario
        </a>
    </div>

    <c:if test="${param.creado == '1'}">
        <div class="alert alert-success" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>El usuario fue creado correctamente en la base de datos.
        </div>
    </c:if>

    <c:choose>
        <c:when test="${param.resultado == 'eliminado'}">
            <div class="alert alert-success" role="alert"><i class="bi bi-check-circle-fill me-2"></i>El usuario fue eliminado de la base de datos.</div>
        </c:when>
        <c:when test="${param.resultado == 'con-registros'}">
            <div class="alert alert-warning" role="alert"><i class="bi bi-exclamation-triangle-fill me-2"></i>No se eliminó porque el usuario tiene solicitudes o documentos relacionados. Esto protege el histórico del sistema.</div>
        </c:when>
        <c:when test="${param.resultado == 'cuenta-propia'}">
            <div class="alert alert-warning" role="alert"><i class="bi bi-shield-lock-fill me-2"></i>No puedes eliminar la cuenta con la que tienes la sesión iniciada.</div>
        </c:when>
        <c:when test="${param.resultado == 'admin-protegido'}">
            <div class="alert alert-warning" role="alert"><i class="bi bi-shield-lock-fill me-2"></i>La cuenta ADMIN está protegida y no puede eliminarse desde este módulo.</div>
        </c:when>
        <c:when test="${param.resultado == 'no-encontrado'}">
            <div class="alert alert-secondary" role="alert"><i class="bi bi-info-circle-fill me-2"></i>El usuario ya no existe o el identificador no es válido.</div>
        </c:when>
        <c:when test="${param.resultado == 'sin-permiso'}">
            <div class="alert alert-danger" role="alert"><i class="bi bi-x-circle-fill me-2"></i>No tienes permiso para realizar esta operación.</div>
        </c:when>
        <c:when test="${param.resultado == 'error'}">
            <div class="alert alert-danger" role="alert"><i class="bi bi-x-circle-fill me-2"></i>Oracle no pudo completar la eliminación. Revisa la conexión y vuelve a intentarlo.</div>
        </c:when>
    </c:choose>

    <section class="admin-card" aria-labelledby="titulo-listado-usuarios">
        <div class="admin-card-header">
            <i class="bi bi-people-fill" aria-hidden="true"></i>
            <h2 id="titulo-listado-usuarios">Usuarios registrados</h2>
        </div>
        <div class="admin-card-body">
            <div class="users-toolbar">
                <div class="input-group users-search">
                    <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                    <input type="search" id="buscar-usuario" class="form-control"
                           placeholder="Buscar por ID, nombre, correo, rol o división">
                </div>
                <span class="text-secondary small"><strong id="contador-usuarios">0</strong> usuarios visibles</span>
            </div>

            <div class="table-responsive">
                <table class="table users-table align-middle mb-0" id="tabla-usuarios">
                    <thead>
                    <tr>
                        <th>ID usuario</th>
                        <th>Nombre</th>
                        <th>Apellidos</th>
                        <th>Correo</th>
                        <th>Rol</th>
                        <th>División</th>
                        <th class="text-center">Acciones</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="usr" items="${listaUsuarios}">
                        <tr class="user-row">
                            <td>#<c:out value="${usr.idUsuario}"/></td>
                            <td class="user-name"><c:out value="${usr.nombres}"/></td>
                            <td class="user-lastnames"><c:out value="${usr.apellidoPaterno}"/> <c:out value="${usr.apellidoMaterno}"/></td>
                            <td class="user-email"><c:out value="${usr.correo}"/></td>
                            <td>
                                <span class="role-badge ${usr.nombreRol == 'ADMIN' ? 'admin' : ''}">
                                    <c:out value="${usr.nombreRol}"/>
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty usr.nombreDivision}"><c:out value="${usr.nombreDivision}"/></c:when>
                                    <c:otherwise><span class="text-muted">Sin división</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${usr.nombreRol == 'ADMIN' || usr.idUsuario == sessionScope.usuario.idUsuario}">
                                        <span class="protected-label"><i class="bi bi-lock-fill"></i>Protegido</span>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="button" class="btn delete-button"
                                                data-bs-toggle="modal" data-bs-target="#modal-eliminar-usuario"
                                                data-user-id="${usr.idUsuario}"
                                                aria-label="Eliminar usuario">
                                            <i class="bi bi-trash3-fill"></i>
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty listaUsuarios}">
                        <tr id="sin-usuarios">
                            <td colspan="7" class="empty-state text-center">
                                <i class="bi bi-people fs-2 d-block mb-2"></i>No hay usuarios registrados.
                            </td>
                        </tr>
                    </c:if>
                    <tr id="sin-resultados" class="d-none">
                        <td colspan="7" class="empty-state text-center">
                            <i class="bi bi-search fs-2 d-block mb-2"></i>No se encontraron usuarios con ese criterio.
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</main>

<div class="modal fade delete-modal" id="modal-eliminar-usuario" tabindex="-1" aria-labelledby="titulo-modal-eliminar" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body p-4 p-md-5 text-center">
                <div class="warning-icon mb-3"><i class="bi bi-exclamation-lg"></i></div>
                <h2 class="h5 fw-bold" id="titulo-modal-eliminar">¿Estás seguro de eliminar el usuario?</h2>
                <p class="text-secondary mb-1">Se eliminará permanentemente la cuenta de:</p>
                <p class="fw-bold mb-0" id="usuario-a-eliminar"></p>
                <p class="small text-secondary" id="correo-a-eliminar"></p>
                <p class="small text-secondary mb-4">Después de confirmar, la persona ya no podrá acceder al sistema.</p>

                <form action="${ctx}/admin/usuarios/eliminar" method="post">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>"/>
                    <input type="hidden" name="idUsuario" id="id-usuario-eliminar">
                    <div class="d-flex justify-content-center gap-2">
                        <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-confirm-delete px-4">Aceptar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const searchInput = document.getElementById('buscar-usuario');
    const userRows = Array.from(document.querySelectorAll('.user-row'));
    const countLabel = document.getElementById('contador-usuarios');
    const noResults = document.getElementById('sin-resultados');

    function filterUsers() {
        const term = searchInput.value.trim().toLowerCase();
        let visible = 0;
        userRows.forEach(function (row) {
            const show = row.textContent.toLowerCase().includes(term);
            row.classList.toggle('d-none', !show);
            if (show) visible++;
        });
        countLabel.textContent = visible;
        noResults.classList.toggle('d-none', visible !== 0 || userRows.length === 0);
    }

    searchInput.addEventListener('input', filterUsers);
    filterUsers();

    const deleteModal = document.getElementById('modal-eliminar-usuario');
    deleteModal.addEventListener('show.bs.modal', function (event) {
        const button = event.relatedTarget;
        const row = button.closest('tr');
        const name = row.querySelector('.user-name').textContent.trim();
        const lastnames = row.querySelector('.user-lastnames').textContent.trim();
        document.getElementById('id-usuario-eliminar').value = button.dataset.userId;
        document.getElementById('usuario-a-eliminar').textContent = (name + ' ' + lastnames).trim();
        document.getElementById('correo-a-eliminar').textContent = row.querySelector('.user-email').textContent.trim();
    });
</script>
</body>
</html>
