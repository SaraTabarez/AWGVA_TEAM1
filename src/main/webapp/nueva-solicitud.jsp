<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Nueva solicitud - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root{--navy:#1f3b5f;--orange:#ff9418;--soft:#e5edf5}body{margin:0;color:var(--navy);background:#fff}.request-main{margin-left:240px;min-height:100vh;padding:28px 38px}.request-title{font-weight:800}.section-title{font-weight:800;font-size:1.05rem;margin:22px 0 12px}.form-label{font-size:.8rem;font-weight:800}.form-control,.form-select{background:var(--soft);border-color:transparent;min-height:42px}.form-control:focus,.form-select:focus{background:#fff;border-color:var(--orange);box-shadow:0 0 0 .2rem rgba(255,148,24,.15)}.btn-navy{background:var(--navy);color:#fff}.btn-orange{background:var(--orange);color:#fff}.btn-navy:hover,.btn-orange:hover{filter:brightness(.92);color:#fff}.group-table th{background:var(--navy);color:#fff;font-size:.78rem;white-space:nowrap}.step-panel.d-none{display:none!important}@media(max-width:800px){.request-main{margin-left:0;padding:22px 14px}}
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>
<main class="request-main">
    <div class="container-fluid px-0">
        <div class="row g-3"><div class="col-12"><h1 class="request-title h3">SOLICITUD DE VISITAS ACADÉMICAS</h1><p class="text-secondary mb-0">Completa todos los campos para continuar.</p></div><div class="col-12"><c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if></div></div>
        <form id="request-form" action="${ctx}/nueva-solicitud" method="post">
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <section class="step-panel" id="step-one">
                <div class="section-title"><i class="bi bi-person-badge me-2"></i>Datos del solicitante</div>
                <div class="row g-3">
                    <div class="col-12 col-lg-6"><label class="form-label">Nombre completo</label><input class="form-control" value="<c:out value='${sessionScope.usuario.nombreCompleto}'/>" readonly></div>
                    <div class="col-12 col-lg-3"><label class="form-label">Cargo / Rol</label><input class="form-control" value="DOCENTE" readonly></div>
                    <div class="col-12 col-lg-3"><label class="form-label" for="docentesAcompanantes">Docentes acompañantes</label><input class="form-control" type="number" id="docentesAcompanantes" name="docentesAcompanantes" min="0" max="3" value="${empty borrador.docentesAcompanantes ? '0' : borrador.docentesAcompanantes}" required></div>
                    <div class="col-12 col-lg-6"><label class="form-label" for="solicitanteTelefono">Teléfono de contacto</label><input class="form-control" type="tel" id="solicitanteTelefono" name="solicitanteTelefono" maxlength="30" value="<c:out value='${borrador.solicitanteTelefono}'/>" required></div>
                </div>
                <div class="section-title"><i class="bi bi-geo-alt me-2"></i>Datos de la visita</div>
                <div class="row g-3">
                    <div class="col-12 col-lg-6"><label class="form-label" for="empresaNombre">Empresa a visitar</label><input class="form-control" id="empresaNombre" name="empresaNombre" maxlength="150" value="<c:out value='${borrador.empresaNombre}'/>" required></div>
                    <div class="col-12 col-lg-6"><label class="form-label" for="empresaDireccion">Dirección</label><input class="form-control" id="empresaDireccion" name="empresaDireccion" maxlength="250" value="<c:out value='${borrador.empresaDireccion}'/>" required></div>
                    <div class="col-12 col-lg-6"><label class="form-label" for="empresaTelefono">Teléfono del lugar</label><input class="form-control" type="tel" id="empresaTelefono" name="empresaTelefono" maxlength="30" value="<c:out value='${borrador.empresaTelefono}'/>" required></div>
                    <div class="col-12 col-lg-6"><label class="form-label" for="empresaEmail">Correo del lugar</label><input class="form-control" type="email" id="empresaEmail" name="empresaEmail" maxlength="160" value="<c:out value='${borrador.empresaEmail}'/>" required></div>
                    <div class="col-12 col-md-4"><label class="form-label" for="fechaInicio">Fecha de inicio</label><input class="form-control" type="date" id="fechaInicio" name="fechaInicio" value="<c:out value='${borrador.fechaInicio}'/>" required></div>
                    <div class="col-12 col-md-4"><label class="form-label" for="fechaTermino">Fecha de término</label><input class="form-control" type="date" id="fechaTermino" name="fechaTermino" value="<c:out value='${borrador.fechaTermino}'/>" required></div>
                    <div class="col-12 col-md-4"><label class="form-label" for="horaInicio">Hora de inicio</label><input class="form-control" type="time" id="horaInicio" name="horaInicio" value="<c:out value='${borrador.horaInicio}'/>" required></div>
                    <div class="col-12"><label class="form-label" for="objetivo">Objetivo de la visita</label><textarea class="form-control" id="objetivo" name="objetivo" rows="3" maxlength="1000" required><c:out value="${borrador.objetivo}"/></textarea></div>
                </div>
                <div class="row g-3 mt-3"><div class="col-6"><button class="btn btn-light border" type="button" id="back-dashboard"><i class="bi bi-arrow-left me-2"></i>Atrás</button></div><div class="col-6 text-end"><button class="btn btn-orange px-4" type="button" id="next-step">Siguiente <i class="bi bi-arrow-right ms-2"></i></button></div></div>
            </section>

            <section class="step-panel d-none" id="step-two">
                <div class="section-title"><i class="bi bi-people me-2"></i>Desglose de alumnos</div>
                <div class="row"><div class="col-12"><p class="text-secondary">Agrega una fila por carrera, cuatrimestre y grupo. El área se toma de tu cuenta institucional.</p></div><div class="col-12"><div class="table-responsive"><table class="table group-table align-middle"><thead><tr><th>Carrera</th><th>Área</th><th>Cuatrimestre</th><th>Grupo</th><th>Cantidad</th><th></th></tr></thead><tbody id="group-body"></tbody><tfoot><tr><th colspan="4" class="text-end">Total de alumnos</th><th><output id="student-total">0</output></th><th></th></tr></tfoot></table></div></div><div class="col-12"><button class="btn btn-outline-secondary" type="button" id="add-group"><i class="bi bi-plus-circle me-2"></i>Agregar grupo</button></div></div>
                <div class="row g-3 mt-2"><div class="col-12"><label class="form-label" for="asignaturas">Asignaturas que se reforzarán</label><textarea class="form-control" id="asignaturas" name="asignaturas" rows="3" maxlength="500" required><c:out value="${borrador.asignaturas}"/></textarea></div></div>
                <div class="row g-3 mt-3"><div class="col-6"><button class="btn btn-navy px-4" type="button" id="previous-step"><i class="bi bi-arrow-left me-2"></i>Anterior</button></div><div class="col-6 text-end"><button class="btn btn-orange px-4" type="submit">Revisar solicitud</button></div></div>
            </section>
        </form>
        <form action="${ctx}/inicio" method="post" id="dashboard-form"><input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>"></form>
    </div>
</main>

<template id="group-template">
    <tr class="group-row">
        <td><select class="form-select" name="carrera" required><option value="">Selecciona</option><c:forEach var="carrera" items="${carreras}"><option value="<c:out value='${carrera}'/>"><c:out value="${carrera}"/></option></c:forEach></select></td>
        <td><input class="form-control" name="area" value="<c:out value='${sessionScope.usuario.nombreDivision}'/>" readonly required></td>
        <td><input class="form-control" name="cuatrimestre" maxlength="30" placeholder="Ej. 6°" required></td>
        <td><input class="form-control" name="grupoNombre" maxlength="30" placeholder="Ej. B" required></td>
        <td><input class="form-control student-count" type="number" name="cantidadAlumnos" min="1" max="200" value="1" required></td>
        <td><button class="btn btn-outline-danger remove-group" type="button" aria-label="Eliminar fila"><i class="bi bi-trash"></i></button></td>
    </tr>
</template>
<div id="saved-groups" class="d-none">
    <c:forEach var="item" items="${borrador.grupos}"><span data-carrera="<c:out value='${item.carrera}'/>" data-cuatrimestre="<c:out value='${item.cuatrimestre}'/>" data-grupo="<c:out value='${item.grupo}'/>" data-cantidad="<c:out value='${item.cantidadAlumnos}'/>"></span></c:forEach>
</div>
<script>
    const stepOne=document.getElementById('step-one');const stepTwo=document.getElementById('step-two');const form=document.getElementById('request-form');const body=document.getElementById('group-body');const template=document.getElementById('group-template');const total=document.getElementById('student-total');function firstInvalid(container){return Array.from(container.querySelectorAll('input,select,textarea')).find(element=>!element.checkValidity())}function updateTotal(){let value=0;document.querySelectorAll('.student-count').forEach(input=>value+=Number(input.value||0));total.value=value}function addGroup(saved){const row=template.content.firstElementChild.cloneNode(true);if(saved){row.querySelector('[name="carrera"]').value=saved.dataset.carrera;row.querySelector('[name="cuatrimestre"]').value=saved.dataset.cuatrimestre;row.querySelector('[name="grupoNombre"]').value=saved.dataset.grupo;row.querySelector('[name="cantidadAlumnos"]').value=saved.dataset.cantidad}row.querySelector('.student-count').addEventListener('input',updateTotal);row.querySelector('.remove-group').addEventListener('click',()=>{if(document.querySelectorAll('.group-row').length>1){row.remove();updateTotal()}});body.appendChild(row);updateTotal()}const saved=Array.from(document.querySelectorAll('#saved-groups span'));if(saved.length)saved.forEach(addGroup);else addGroup();document.getElementById('add-group').addEventListener('click',()=>addGroup());document.getElementById('next-step').addEventListener('click',()=>{const invalid=firstInvalid(stepOne);if(invalid){invalid.reportValidity();invalid.focus();return}if(new Date(document.getElementById('fechaTermino').value)<new Date(document.getElementById('fechaInicio').value)){document.getElementById('fechaTermino').setCustomValidity('La fecha de término no puede ser anterior.');document.getElementById('fechaTermino').reportValidity();document.getElementById('fechaTermino').setCustomValidity('');return}stepOne.classList.add('d-none');stepTwo.classList.remove('d-none');window.scrollTo({top:0,behavior:'smooth'})});document.getElementById('previous-step').addEventListener('click',()=>{stepTwo.classList.add('d-none');stepOne.classList.remove('d-none');window.scrollTo({top:0,behavior:'smooth'})});document.getElementById('back-dashboard').addEventListener('click',()=>document.getElementById('dashboard-form').submit());form.addEventListener('submit',event=>{const invalid=firstInvalid(stepTwo);if(invalid){event.preventDefault();invalid.reportValidity();invalid.focus();return}if(Number(total.value)<1||Number(total.value)>200){event.preventDefault();alert('El total debe estar entre 1 y 200 alumnos.')}});
</script>
</body>
</html>
