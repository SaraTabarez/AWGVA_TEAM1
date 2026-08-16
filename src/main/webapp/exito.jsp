<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Carta responsiva</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body{margin:0;background:#a9bbcf;color:#172f4b;font-family:Arial,sans-serif}
        .main{margin-left:240px;min-height:100vh;padding:24px}.toolbar{max-width:900px;margin:0 auto 14px;display:flex;justify-content:space-between;gap:12px}
        .paper{max-width:900px;margin:auto;background:#fff;padding:48px 58px;box-shadow:0 10px 28px #18324d33}.head{display:flex;justify-content:space-between;align-items:center;border-bottom:3px solid #173b63;padding-bottom:16px}
        .head h1{font-size:1.25rem;font-weight:900;margin:0}.brand{font-weight:900;color:#6b9f3a;font-size:1.3rem}.date{text-align:right;margin:24px 0;font-size:.9rem}.paragraph{line-height:1.75;text-align:justify}
        .data{border:1px solid #b8c2cc;margin:26px 0}.row-data{display:grid;grid-template-columns:220px 1fr;border-bottom:1px solid #b8c2cc}.row-data:last-child{border-bottom:0}.row-data strong,.row-data span{padding:9px 12px}.row-data strong{background:#edf2f7;border-right:1px solid #b8c2cc}
        .signatures{display:grid;grid-template-columns:repeat(3,1fr);gap:36px;margin-top:76px;text-align:center;font-size:.82rem}.signature{border-top:1px solid #172f4b;padding-top:8px}.btn-action{border:0;border-radius:7px;padding:10px 18px;font-weight:800}.btn-back{background:#fff;color:#173b63}.btn-print{background:#f28a22;color:#fff}
        @media(max-width:768px){.main{margin-left:0;padding:10px}.paper{padding:28px 20px}.row-data{grid-template-columns:1fr}.row-data strong{border-right:0}.signatures{grid-template-columns:1fr;gap:60px}.toolbar{padding:0 4px}}
        @media print{body{background:#fff}.sidebar,.toolbar{display:none!important}.main{margin:0;padding:0}.paper{max-width:none;box-shadow:none;padding:12mm}@page{size:A4;margin:8mm}}
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>
<main class="main">
    <div class="toolbar">
        <button type="button" class="btn-action btn-back" data-post-url="${ctx}/detalle-solicitud" data-post-ref="<c:out value='${expediente.referenceToken}'/>"><i class="bi bi-arrow-left"></i> Volver</button>
        <button type="button" class="btn-action btn-print" onclick="registrarEImprimir()"><i class="bi bi-printer"></i> Imprimir / Descargar PDF</button>
    </div>
    <article class="paper">
        <div class="head"><h1>CARTA RESPONSIVA DE VISITA ACADÉMICA</h1><span class="brand">UTEZ</span></div>
        <div class="date">Emiliano Zapata, Morelos, a <c:out value="${expediente.fechaInicio}"/></div>
        <p class="paragraph">Por medio de la presente, quienes participan en la visita académica manifiestan conocer y aceptar las disposiciones institucionales de seguridad, conducta y responsabilidad aplicables durante el traslado y la permanencia en la organización visitada.</p>
        <div class="data">
            <div class="row-data"><strong>Empresa o institución</strong><span><c:out value="${expediente.empresa}"/></span></div>
            <div class="row-data"><strong>Dirección</strong><span><c:out value="${expediente.direccionEmpresa}"/></span></div>
            <div class="row-data"><strong>Fecha de visita</strong><span><c:out value="${expediente.fechaInicio}"/> a <c:out value="${expediente.fechaFin}"/></span></div>
            <div class="row-data"><strong>División</strong><span><c:out value="${expediente.division}"/></span></div>
            <div class="row-data"><strong>Programa y grupo</strong><span><c:out value="${expediente.carrera}"/> · <c:out value="${expediente.semestre}"/> · <c:out value="${expediente.grupo}"/></span></div>
            <div class="row-data"><strong>Participantes</strong><span><c:out value="${expediente.numeroEstudiantes}"/> estudiantes</span></div>
            <div class="row-data"><strong>Docente responsable</strong><span><c:out value="${expediente.docente}"/></span></div>
        </div>
        <p class="paragraph">El docente responsable se compromete a mantener el control del grupo, atender los protocolos de la Universidad y de la empresa receptora, y reportar cualquier incidente a la Jefatura de Estadías.</p>
        <div class="signatures">
            <div class="signature"><c:out value="${firmantes.docenteNombre}"/><br><strong><c:out value="${firmantes.docenteCargo}"/></strong></div>
            <div class="signature"><c:out value="${firmantes.directorNombre}"/><br><strong><c:out value="${firmantes.directorCargo}"/></strong></div>
            <div class="signature"><c:out value="${firmantes.estadiasNombre}"/><br><strong><c:out value="${firmantes.estadiasCargo}"/></strong></div>
        </div>
    </article>
</main>
<script>
    async function registrarEImprimir(){
        const token='<c:out value="${sessionScope.csrfToken}"/>';
        const body=new URLSearchParams({csrfToken:token,ref:'<c:out value="${expediente.referenceToken}"/>',tipo:'CARTA_RESPONSIVA'});
        const response=await fetch('${ctx}/docente/marcar-descarga',{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/x-www-form-urlencoded','X-CSRF-Token':token},body});
        if(response.ok)window.print();else window.alert('No fue posible habilitar la descarga.');
    }
</script>
</body>
</html>