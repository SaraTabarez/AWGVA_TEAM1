
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request   .contextPath}"/>
<c:set var="division" value="${fn:toUpperCase(sessionScope.usuario.nombreDivision)}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nueva solicitud - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        *{box-sizing:border-box}body{margin:0;background:#fff;color:#1e3a5f;font-family:"Segoe UI",Arial,sans-serif}
        .main{margin-left:240px;min-height:100vh;padding:36px 52px}.head{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px}
        h1{font-size:1.75rem;font-weight:800;margin:0}.section{font-size:1.08rem;font-weight:800;margin:24px 0 14px;display:flex;gap:9px;align-items:center}
        .label{font-size:.8rem;font-weight:800;margin-bottom:6px}.field{width:100%;border:1px solid transparent;background:#e5edf5;color:#203a59;border-radius:6px;padding:10px 12px;outline:none}
        .field:focus{background:#fff;border-color:#f59120;box-shadow:0 0 0 3px rgba(245,145,32,.15)}textarea.field{min-height:92px;resize:vertical}
        .division-table{width:100%;border-collapse:collapse}.division-table th,.division-table td{border:1px solid #1e3a5f;text-align:center}.division-table th{padding:7px;font-size:.78rem}.division-table input{width:100%;border:0;background:#e5edf5;text-align:center;padding:9px;outline:none}
        .actions{display:flex;justify-content:space-between;margin-top:28px}.btn-back,.btn-next{border:0;border-radius:7px;padding:10px 22px;font-weight:800;text-decoration:none;display:inline-flex;align-items:center;gap:8px}
        .btn-back{background:#f8fafc;border:1px solid #d7dee8;color:#617086}.btn-next{background:#f59120;color:#fff;box-shadow:0 4px 10px rgba(245,145,32,.25)}
        @media(max-width:800px){.main{margin-left:0;padding:24px 16px}}
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>
<main class="main">
    <div class="head"><h1>SOLICITUD DE VISITAS ACADÉMICAS</h1></div>
    <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>

    <form id="solicitudForm" action="${ctx}/nueva-solicitud" method="post">
        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">

        <div class="section"><i class="bi bi-person-badge"></i> Datos del solicitante</div>
        <div class="row g-3">
            <div class="col-md-6"><label class="label">Nombre completo</label><input class="field" name="solicitanteNombre" value="<c:out value='${sessionScope.usuario.nombreCompleto}'/>" readonly></div>
            <div class="col-md-6"><label class="label">Cargo / Rol</label><input class="field" name="solicitanteCargo" value="DOCENTE" readonly></div>
            <div class="col-md-6"><label class="label">Teléfono de contacto</label><input class="field" type="tel" name="solicitanteTelefono" maxlength="30" value="<c:out value='${borrador.solicitanteTelefono}'/>" required></div>
            <div class="col-md-6"><label class="label">No. de docentes acompañantes</label><input class="field" type="number" name="docentesAcompanantes" min="0" max="3" value="${empty borrador.docentesAcompanantes ? '0' : borrador.docentesAcompanantes}" required></div>
        </div>

        <div class="section"><i class="bi bi-geo-alt"></i> Datos de la visita</div>
        <div class="row g-3">
            <div class="col-md-6"><label class="label">Dirección del lugar a visitar</label><input class="field" name="empresaDireccion" maxlength="250" value="<c:out value='${borrador.empresaDireccion}'/>" required></div>
            <div class="col-md-6"><label class="label">Nombre de la empresa a visitar</label><input class="field" name="empresaNombre" maxlength="150" value="<c:out value='${borrador.empresaNombre}'/>" required></div>
            <div class="col-md-6"><label class="label">Teléfono de la empresa</label><input class="field" type="tel" name="empresaTelefono" maxlength="30" value="<c:out value='${borrador.empresaTelefono}'/>" required></div>
            <div class="col-md-6"><label class="label">Correo electrónico de la empresa</label><input class="field" type="email" name="empresaEmail" maxlength="160" value="<c:out value='${borrador.empresaEmail}'/>" required></div>
            <div class="col-md-4"><label class="label">Fecha de inicio</label><input class="field" type="date" name="fechaInicio" value="<c:out value='${borrador.fechaInicio}'/>" required></div>
            <div class="col-md-4"><label class="label">Fecha de término</label><input class="field" type="date" name="fechaTermino" value="<c:out value='${borrador.fechaTermino}'/>" required></div>
            <div class="col-md-4"><label class="label">Hora de inicio</label><input class="field" type="time" name="horaInicio" value="<c:out value='${borrador.horaInicio}'/>" required></div>
            <div class="col-12"><label class="label">Objetivo de la visita</label><textarea class="field" name="objetivo" maxlength="1000" required><c:out value="${borrador.objetivo}"/></textarea></div>
            <div class="col-md-6"><label class="label">Programa educativo</label>
                <select class="field" name="programaEducativo" required>
                    <option value="">Selecciona tu carrera</option>
                    <c:forEach var="carrera" items="${carreras}"><option value="<c:out value='${carrera}'/>" ${borrador.programaEducativo eq carrera ? 'selected' : ''}><c:out value="${carrera}"/></option></c:forEach>
                </select>
            </div>
            <div class="col-md-3"><label class="label">Cuatrimestre</label><input class="field" name="semestre" maxlength="30" value="<c:out value='${borrador.semestre}'/>" placeholder="Ej. 6°" required></div>
            <div class="col-md-3"><label class="label">Grupo</label><input class="field" name="grupo" maxlength="30" value="<c:out value='${borrador.grupo}'/>" placeholder="Ej. B" required></div>
        </div>

        <div class="section"><i class="bi bi-people"></i> Participantes</div>
        <label class="label">No. de estudiantes participantes por división académica:</label>
        <table class="division-table">
            <thead><tr><th>DACEA</th><th>DATEFI</th><th>DATID</th><th>DAMI</th><th>Total estudiantes</th></tr></thead>
            <tbody><tr>
                <td><input class="division-count" type="number" name="dacea" min="0" max="200" value="${empty borrador.dacea ? '0' : borrador.dacea}" ${fn:contains(division,'DACEA') ? '' : 'readonly'}></td>
                <td><input class="division-count" type="number" name="datefi" min="0" max="200" value="${empty borrador.datefi ? '0' : borrador.datefi}" ${fn:contains(division,'DATEFI') ? '' : 'readonly'}></td>
                <td><input class="division-count" type="number" name="datid" min="0" max="200" value="${empty borrador.datid ? '0' : borrador.datid}" ${fn:contains(division,'DATID') ? '' : 'readonly'}></td>
                <td><input class="division-count" type="number" name="dami" min="0" max="200" value="${empty borrador.dami ? '0' : borrador.dami}" ${fn:contains(division,'DAMI') ? '' : 'readonly'}></td>
                <td><input id="totalEstudiantes" type="number" name="totalEstudiantes" value="${empty borrador.totalEstudiantes ? '0' : borrador.totalEstudiantes}" readonly></td>
            </tr></tbody>
        </table>
        <div class="mt-3"><label class="label">Asignaturas que se reforzarán con la visita</label><textarea class="field" name="asignaturas" maxlength="500" required><c:out value="${borrador.asignaturas}"/></textarea></div>

        <div class="actions">
            <a class="btn-back" href="${ctx}/mis-solicitudes"><i class="bi bi-arrow-left"></i> Atrás</a>
            <button class="btn-next" type="submit">Siguiente <i class="bi bi-arrow-right"></i></button>
        </div>
    </form>
</main>
<script>
    const counts = document.querySelectorAll('.division-count');
    const total = document.getElementById('totalEstudiantes');
    function actualizarTotal(){let suma=0;counts.forEach(i=>suma+=Number(i.value||0));total.value=suma;}
    counts.forEach(i=>i.addEventListener('input',actualizarTotal));actualizarTotal();
</script>
</body>
</html>