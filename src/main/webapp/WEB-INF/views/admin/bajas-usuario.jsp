<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Gestión de usuarios - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/admin-users.css" rel="stylesheet">
    <style>.floating-add{position:fixed;right:32px;bottom:32px;width:58px;height:58px;border-radius:50%;z-index:20}.status-label{min-width:78px;display:inline-block}.form-check-input:checked{background-color:#198754;border-color:#198754}</style>
</head>
<body>
<jsp:include page="/Layout/sidebar.jsp"/>
<main class="admin-page">
    <div class="row g-4">
        <div class="col-12"><div class="admin-breadcrumb">Menú / Gestión de usuarios / Admin</div><h1 class="admin-title">Gestión de usuarios</h1><p class="admin-subtitle">Consulta, registra, activa o desactiva cuentas sin eliminar su histórico.</p></div>
        <div class="col-12"><c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if><c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if><div class="alert d-none" id="operation-alert"></div></div>
        <div class="col-12">
            <section class="admin-card">
                <div class="admin-card-header"><i class="bi bi-people-fill"></i><h2>Usuarios registrados</h2></div>
                <div class="admin-card-body">
                    <div class="row g-3 align-items-center mb-4"><div class="col-12 col-lg-8"><div class="input-group"><span class="input-group-text bg-white"><i class="bi bi-search"></i></span><input class="form-control" type="search" id="user-search" placeholder="Buscar por nombre, correo, rol o división"></div></div><div class="col-12 col-lg-4 text-lg-end text-secondary"><strong id="visible-count">0</strong> usuarios visibles</div></div>
                    <div class="table-responsive">
                        <table class="table users-table align-middle" id="users-table">
                            <thead><tr><th>Nombre</th><th>Correo institucional</th><th>Rol</th><th>División</th><th class="text-center">Estado</th></tr></thead>
                            <tbody>
                            <c:forEach var="usr" items="${listaUsuarios}">
                                <tr class="user-row">
                                    <td><strong><c:out value="${usr.nombreCompleto}"/></strong></td>
                                    <td><c:out value="${usr.correo}"/></td>
                                    <td><span class="role-badge ${usr.nombreRol == 'ADMIN' ? 'admin' : ''}"><c:out value="${usr.nombreRol}"/></span></td>
                                    <td><c:choose><c:when test="${not empty usr.nombreDivision}"><c:out value="${usr.nombreDivision}"/></c:when><c:otherwise><span class="text-muted">Sin división</span></c:otherwise></c:choose></td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${usr.nombreRol == 'ADMIN' || usr.idUsuario == sessionScope.usuario.idUsuario}"><span class="protected-label"><i class="bi bi-lock-fill"></i> Protegido</span></c:when>
                                            <c:otherwise><div class="d-inline-flex align-items-center gap-2"><span class="status-label ${usr.estado == 1 ? 'text-success' : 'text-secondary'}">${usr.estado == 1 ? 'Activo' : 'Inactivo'}</span><div class="form-check form-switch m-0"><input class="form-check-input user-status" type="checkbox" role="switch" data-user-ref="<c:out value='${usr.referenceToken}'/>" ${usr.estado == 1 ? 'checked' : ''} aria-label="Cambiar estado de ${usr.nombreCompleto}"></div></div></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty listaUsuarios}"><tr><td colspan="5" class="text-center py-5 text-secondary">No hay usuarios registrados.</td></tr></c:if>
                            <tr id="no-results" class="d-none"><td colspan="5" class="text-center py-5 text-secondary">No se encontraron resultados.</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>
    </div>
</main>

<button class="btn btn-admin-primary floating-add shadow" type="button" data-bs-toggle="modal" data-bs-target="#add-user-modal" aria-label="Agregar usuario"><i class="bi bi-person-plus-fill fs-4"></i></button>

<div class="modal fade" id="add-user-modal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered"><div class="modal-content"><div class="modal-header"><h2 class="modal-title h5 fw-bold">Agregar usuario</h2><button class="btn-close" type="button" data-bs-dismiss="modal"></button></div><div class="modal-body p-4">
        <form action="${ctx}/admin/usuarios/alta" method="post" id="add-user-form">
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <div class="row g-3">
                <div class="col-12 col-md-4"><label class="form-label" for="nombres">Nombre(s)</label><input class="form-control" id="nombres" name="nombres" maxlength="100" value="<c:out value='${nombresValue}'/>" required></div>
                <div class="col-12 col-md-4"><label class="form-label" for="apellidoPaterno">Apellido paterno</label><input class="form-control" id="apellidoPaterno" name="apellidoPaterno" maxlength="100" value="<c:out value='${apellidoPaternoValue}'/>" required></div>
                <div class="col-12 col-md-4"><label class="form-label" for="apellidoMaterno">Apellido materno</label><input class="form-control" id="apellidoMaterno" name="apellidoMaterno" maxlength="100" value="<c:out value='${apellidoMaternoValue}'/>" required></div>
                <div class="col-12 col-md-6"><label class="form-label" for="correo">Correo institucional</label><input class="form-control" type="email" id="correo" name="correo" maxlength="160" pattern="[A-Za-z0-9._%+-]+@utez[.]edu[.]mx" value="<c:out value='${correoValue}'/>" placeholder="usuario@utez.edu.mx" required></div>
                <div class="col-12 col-md-6"><label class="form-label" for="password">Contraseña inicial</label><div class="input-group"><input class="form-control" type="password" id="password" name="password" minlength="10" maxlength="200" pattern="(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{10,200}" title="Mínimo 10 caracteres con mayúscula, minúscula, número y símbolo." autocomplete="new-password" required><button class="btn btn-outline-secondary" type="button" id="toggle-admin-password" aria-label="Mostrar u ocultar contraseña"><i class="bi bi-eye-slash" id="toggle-admin-password-icon"></i></button></div><div class="form-text">Mínimo 10 caracteres: mayúscula, minúscula, número y símbolo.</div></div>
                <div class="col-12 col-md-6"><label class="form-label" for="idRol">Rol</label><select class="form-select" id="idRol" name="idRol" required><option value="" selected disabled>Selecciona</option><c:forEach var="rol" items="${roles}"><option value="${rol.key}" data-role="${rol.value}" ${idRolValue == rol.key ? 'selected' : ''}><c:out value="${rol.value}"/></option></c:forEach></select></div>
                <div class="col-12 col-md-6"><label class="form-label" for="idDivision">División</label><select class="form-select" id="idDivision" name="idDivision"><option value="">Sin división</option><c:forEach var="division" items="${divisiones}"><option value="${division.key}" ${idDivisionValue == division.key ? 'selected' : ''}><c:out value="${division.value}"/></option></c:forEach></select></div>
                <div class="col-12 text-end"><button class="btn btn-light me-2" type="button" data-bs-dismiss="modal">Cancelar</button><button class="btn btn-admin-primary" type="submit">Crear usuario</button></div>
            </div>
        </form>
    </div></div></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const csrfToken='<c:out value="${sessionScope.csrfToken}"/>';const search=document.getElementById('user-search');const rows=Array.from(document.querySelectorAll('.user-row'));const visibleCount=document.getElementById('visible-count');const noResults=document.getElementById('no-results');const alertBox=document.getElementById('operation-alert');function filterRows(){const term=search.value.trim().toLowerCase();let count=0;rows.forEach(row=>{const visible=row.textContent.toLowerCase().includes(term);row.classList.toggle('d-none',!visible);if(visible)count++});visibleCount.textContent=count;noResults.classList.toggle('d-none',count!==0||rows.length===0)}search.addEventListener('input',filterRows);filterRows();function showAlert(message,success){alertBox.textContent=message;alertBox.className='alert '+(success?'alert-success':'alert-danger')}
    document.querySelectorAll('.user-status').forEach(toggle=>toggle.addEventListener('change',async function(){const desired=this.checked?1:0;this.disabled=true;const data=new URLSearchParams({csrfToken:csrfToken,userRef:this.dataset.userRef,estado:String(desired)});try{const response=await fetch('${ctx}/admin/usuarios/estado',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8','X-CSRF-Token':csrfToken},body:data});const result=await response.json();if(!response.ok||!result.success)throw new Error(result.message||'No fue posible actualizar.');const label=this.closest('td').querySelector('.status-label');label.textContent=desired===1?'Activo':'Inactivo';label.classList.toggle('text-success',desired===1);label.classList.toggle('text-secondary',desired===0);showAlert(result.message,true)}catch(error){this.checked=!this.checked;showAlert(error.message,false)}finally{this.disabled=false}}));
    const adminPassword=document.getElementById('password');const adminPasswordButton=document.getElementById('toggle-admin-password');const adminPasswordIcon=document.getElementById('toggle-admin-password-icon');adminPasswordButton.addEventListener('click',()=>{const show=adminPassword.type==='password';adminPassword.type=show?'text':'password';adminPasswordIcon.classList.toggle('bi-eye',show);adminPasswordIcon.classList.toggle('bi-eye-slash',!show)});
    const role=document.getElementById('idRol');const division=document.getElementById('idDivision');function divisionRule(){const selected=role.options[role.selectedIndex];const name=selected?(selected.dataset.role||'').toUpperCase():'';division.required=name==='DOCENTE'||name==='DIRECTOR'}role.addEventListener('change',divisionRule);divisionRule();
    <c:if test="${modalAltaAbierto}">bootstrap.Modal.getOrCreateInstance(document.getElementById('add-user-modal')).show();</c:if>
</script>
</body>
</html>