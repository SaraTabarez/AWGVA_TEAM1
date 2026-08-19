<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Vista previa de solicitud - AWGVA</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
  <style>
    *{box-sizing:border-box}
    body{margin:0;
      background:#a9bbcf;
      font-family:Arial,sans-serif;
      color:#111}

    .shell{margin-left:240px;
      padding:26px;
      min-height:100vh}

    .paper{width:min(820px,100%);
      margin:auto;
      background:#fff;
      padding:34px 38px;
      box-shadow:0 8px 28px rgba(0,0,0,.2)}

    .doc-head{display:flex;
      justify-content:space-between;
      align-items:center;
      border-bottom:2px solid #1e3a5f;
      padding-bottom:10px;
      margin-bottom:12px}

    .doc-head h1{font-size:1.12rem;
      margin:0}

    .logo{font-size:1.2rem;
      font-weight:900;
      color:#679b3b}

    .section{font-weight:800;
      font-size:.78rem;
      margin:14px 0 5px}

    .grid{display:grid;
      grid-template-columns:180px 1fr;
      border:1px solid #9aa4ad;
      border-bottom:0}

    .grid div{padding:6px 8px;
      border-bottom:1px solid #9aa4ad;
      font-size:.72rem}

    .grid div:nth-child(odd){font-weight:700;
      border-right:1px solid #9aa4ad}

    table{width:100%;
      border-collapse:collapse;
      font-size:.7rem;
      margin-top:5px}

    th,td{border:1px solid #9aa4ad;
      padding:6px;
      text-align:center}

    .objective{border:1px solid #9aa4ad;
      min-height:58px;
      padding:8px;
      font-size:.72rem}

    .signatures{display:grid;
      grid-template-columns:1fr 1fr;
      gap:70px;
      margin:58px 40px 18px;
      text-align:center;
      font-size:.7rem}

    .line{border-top:1px solid #222;
      padding-top:7px}

    .actions{display:flex;
      justify-content:space-between;
      margin-top:22px}

    .btn{border:0;border-radius:5px;padding:9px 18px;font-weight:800;text-decoration:none;cursor:pointer}.back{background:#f3f4f6;color:#1e3a5f}.download{background:#f59120;color:#fff}
    .alert{background:#fee2e2;color:#991b1b;padding:10px;margin-bottom:12px}
    @media print{body{background:#fff}.shell{margin:0;padding:0}.sidebar,.actions,.alert{display:none!important}.paper{width:100%;box-shadow:none;padding:15mm}.signatures{margin-top:42px}@page{size:A4;margin:8mm}}
    @media(max-width:800px){.shell{margin-left:0;padding:10px}.paper{padding:20px}.grid{grid-template-columns:130px 1fr}}
  </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>
<div class="shell"><article class="paper">
  <c:if test="${not empty error}"><div class="alert"><c:out value="${error}"/></div></c:if>
  <div class="doc-head"><h1>SOLICITUD DE VISITAS ACADÉMICAS</h1><span class="logo">UTEZ</span></div>

  <div class="section">Datos del lugar</div>
  <div class="grid">
    <div>Nombre de la empresa</div><div><c:out value="${solicitud.empresaNombre}"/></div>
    <div>Dirección o lugar</div><div><c:out value="${solicitud.empresaDireccion}"/></div>
    <div>Teléfono de contacto</div><div><c:out value="${solicitud.empresaTelefono}"/></div>
    <div>Correo electrónico</div><div><c:out value="${solicitud.empresaEmail}"/></div>
    <div>Fecha de inicio / término</div>
    <div><c:out value="${solicitud.fechaInicio}"/>
      al <c:out value="${solicitud.fechaTermino}"/>
      · Hora: <c:out value="${solicitud.horaInicio}"/>
    </div>
  </div>
  <div class="section">Objetivo de la visita</div><div class="objective"><c:out value="${solicitud.objetivo}"/></div>

  <div class="section">Datos de los participantes</div>
  <div class="grid">
    <div>Área solicitante</div><div><c:out value="${divisionDocente}"/></div>
    <div>Docente responsable</div><div><c:out value="${solicitud.solicitanteNombre}"/></div>
    <div>Teléfono del solicitante</div><div><c:out value="${solicitud.solicitanteTelefono}"/></div>
    <div>Docentes acompañantes</div><div><c:out value="${solicitud.docentesAcompanantes}"/></div>
  </div>
  <table>
    <thead>
    <tr>
      <th>DACEA</th>
      <th>DATEFI</th>
      <th>DATID</th>
      <th>DAMI</th>
      <th>Total</th>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td><c:out value="${solicitud.dacea}"/></td>
      <td><c:out value="${solicitud.datefi}"/></td>
      <td><c:out value="${solicitud.datid}"/></td>
      <td><c:out value="${solicitud.dami}"/></td>
      <td><c:out value="${solicitud.totalEstudiantes}"/></td>
    </tr>
    </tbody>
  </table>
  <div class="section">Información académica</div>
  <table>
    <thead>
    <tr>
      <th>Programa educativo</th>
      <th>Cuatrimestre</th>
      <th>Grupo</th>
      <th>No. estudiantes</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="grupo" items="${solicitud.grupos}">
      <tr>
        <td><c:out value="${grupo.carrera}"/> - <c:out value="${grupo.area}"/></td>
        <td><c:out value="${grupo.cuatrimestre}"/></td>
        <td><c:out value="${grupo.grupo}"/></td>
        <td><c:out value="${grupo.cantidadAlumnos}"/></td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
  <div class="section">Asignaturas que se reforzarán con la visita</div>
  <div class="objective"><c:out value="${solicitud.asignaturas}"/></div>

  <div class="signatures">
    <div><strong>Solicita</strong>
      <div class="line"><c:out value="${solicitud.solicitanteNombre}"/><br><c:out value="${solicitud.solicitanteCargo}"/></div>
    </div>
    <div>
      <strong>Autoriza</strong>
      <div class="line"><c:out value="${firmantes.directorNombre}"/><br><c:out value="${firmantes.directorCargo}"/> - <c:out value="${divisionDocente}"/></div>
    </div>
  </div>

  <div class="actions">
    <c:choose><c:when test="${empty referenceToken}">
      <button class="btn back" type="button" data-post-url="${ctx}/nueva-solicitud?editar=1">Atrás</button>
    </c:when>
      <c:otherwise>
        <button class="btn back" type="button" data-post-url="${ctx}/detalle-solicitud" data-post-ref="<c:out value='${referenceToken}'/>">Atrás</button>
      </c:otherwise>
    </c:choose>

    <c:choose>
      <c:when test="${empty referenceToken}">
        <form action="${ctx}/confirmar-solicitud" method="post">
          <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
          <button class="btn download" type="submit">Descargar</button>
        </form>
      </c:when>

      <c:otherwise>
        <button class="btn download" type="button" onclick="descargarExistente()">Descargar</button>
      </c:otherwise>
    </c:choose>
  </div>
</article>
</div>
<script>
  const ctx='${ctx}', referenceToken='<c:out value="${referenceToken}"/>', csrf='<c:out value="${sessionScope.csrfToken}"/>';
  let redirectAfterPrint=false;
  function imprimir(){redirectAfterPrint=true;window.print();}
  async function descargarExistente(){
    const body=new URLSearchParams({csrfToken:csrf,ref:referenceToken,tipo:'SOLICITUD_VISITA'});
    try{await fetch(ctx+'/docente/marcar-descarga',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body});}catch(e){}
    imprimir();
  }
  window.addEventListener('afterprint',()=>{if(redirectAfterPrint&&referenceToken)window.awgvaPost(ctx+'/detalle-solicitud',{ref:referenceToken});});
  <c:if test="${autoPrint}">window.addEventListener('load',()=>setTimeout(imprimir,300));</c:if>
</script>
</body>
</html>
