<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Gestión de Usuarios</title>
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

    .table-header-dark { background-color: #2b2d42; color: white; }
    .btn-custom-dark { background-color: #2b2d42; color: white; border: none; }
    .btn-custom-dark:hover { background-color: #1a1b26; color: white; }
    .btn-custom-orange { background-color: #f39c12; color: white; border: none; font-weight: 600; }
    .btn-custom-orange:hover { background-color: #d68100; color: white; }

    .page-item.active .page-link { background-color: #f39c12; border-color: #f39c12; }
    .page-link { color: #6c757d; }

    .form-check-input:checked {
      background-color: #f39c12;
      border-color: #f39c12;
    }
    .form-check-input:focus {
      border-color: #f39c12;
      box-shadow: 0 0 0 0.25rem rgba(243, 156, 18, 0.25);
    }
    .form-check-input {
      width: 2.5em;
      height: 1.3em;
      cursor: pointer;
    }

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
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold m-0" style="color: #2b2d42;">GESTIÓN DE USUARIOS</h3>
    <a href="${pageContext.request.contextPath}/RegistrarUsuarioServlet" class="btn btn-custom-orange px-4 py-2 rounded shadow-sm">
      <i class="bi bi-person-plus-fill me-2"></i>AGREGAR USUARIO
    </a>
  </div>

  <c:if test="${param.creado == '1'}">
    <div class="alert alert-success" role="alert">Usuario registrado correctamente.</div>
  </c:if>

  <!-- Panel de Filtros -->
  <div class="card border-0 shadow-sm p-3 mb-4">
    <div class="row g-3 align-items-end">
      <div class="col-md-4">
        <label class="form-label fw-bold small">Buscar:</label>
        <div class="input-group">
          <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
          <input type="text" id="busqueda-usuario" class="form-control" placeholder="ID o Nombre...">
        </div>
      </div>

      <div class="col-md-2">
        <label class="form-label fw-bold small">Rol:</label>
        <select id="filtro-rol" class="form-select" onchange="filtrarTabla()">
          <option value="">Todos</option>
          <option value="DOCENTE">DOCENTE</option>
          <option value="ADMIN">ADMIN</option>
          <option value="ESTADIAS">ESTADIAS</option>
          <option value="DIRECTOR">DIRECTOR</option>
        </select>
      </div>

      <div class="col-md-2">
        <label class="form-label fw-bold small">División:</label>
        <select id="filtro-division" class="form-select" onchange="filtrarTabla()">
          <option value="">Todas</option>
          <option value="Sin División">Sin División</option>
          <option value="DAMI">DAMI</option>
          <option value="DATEFI">DATEFI</option>
          <option value="DACEA">DACEA</option>
          <option value="DATID">DATID</option>
        </select>
      </div>

      <div class="col-md-2">
        <label class="form-label fw-bold small">Estado:</label>
        <select id="filtro-estado" class="form-select" onchange="filtrarTabla()">
          <option value="">Todos</option>
          <option value="activo">Activos</option>
          <option value="inactivo">Inactivos</option>
        </select>
      </div>

      <div class="col-md-2 text-end">
        <button type="button" class="btn btn-custom-dark w-100" onclick="limpiarFiltrosUsuarios()">LIMPIAR</button>
      </div>
    </div>
  </div>

  <!-- Tabla Dinámica -->
  <div class="table-responsive bg-white rounded shadow-sm p-3">
    <table class="table table-hover align-middle text-center mb-0" id="tabla-usuarios">
      <thead class="table-header-dark">
      <tr>
        <th>ID</th>
        <th>NOMBRE COMPLETO</th>
        <th>ROL</th>
        <th>DIVISIÓN</th>
        <th>ESTADO</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach var="usr" items="${listaUsuarios}">
        <tr id="usuario-${usr.idUsuario}" data-estado="${usr.estado == 1 ? 'activo' : 'inactivo'}">
          <td>${usr.idUsuario}</td>
          <td><c:out value="${usr.nombreCompleto}"/></td>
          <td>
                        <span class="badge
                            ${usr.nombreRol == 'ADMIN' ? 'bg-primary' :
                              usr.nombreRol == 'DOCENTE' ? 'bg-secondary' :
                              usr.nombreRol == 'DIRECTOR' ? 'bg-dark' : 'bg-info text-dark'}">
                            <c:out value="${usr.nombreRol != null ? usr.nombreRol : 'SIN ROL'}"/>
                        </span>
          </td>
          <td>
            <c:choose>
              <c:when test="${not empty usr.nombreDivision}">
                <c:out value="${usr.nombreDivision}"/>
              </c:when>
              <c:otherwise>
                <span class="text-muted fst-italic">Sin División</span>
              </c:otherwise>
            </c:choose>
          </td>
          <td>
            <div class="form-check form-switch d-flex justify-content-center">
              <input class="form-check-input" type="checkbox"
                ${usr.estado == 1 ? 'checked' : ''}
                     onchange="cambiarEstadoUsuario(${usr.idUsuario}, this)">
            </div>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty listaUsuarios}">
        <tr>
          <td colspan="5" class="text-muted py-3">No hay usuarios registrados en el sistema.</td>
        </tr>
      </c:if>
      </tbody>
    </table>
  </div>

  <!-- Paginación -->
  <div class="d-flex justify-content-between align-items-center mt-4">
    <nav>
      <ul class="pagination mb-0">
        <li class="page-item disabled"><a class="page-link" href="#">Anterior</a></li>
        <li class="page-item active"><a class="page-link" href="#">1</a></li>
        <li class="page-item disabled"><a class="page-link" href="#">Siguiente</a></li>
      </ul>
    </nav>
    <small class="fw-bold text-secondary">Registros cargados desde la Base de Datos</small>
  </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
  document.getElementById("busqueda-usuario").addEventListener("keyup", filtrarTabla);

  function filtrarTabla() {
    let busqueda = document.getElementById("busqueda-usuario").value.toLowerCase();
    let rolSel = document.getElementById("filtro-rol").value.toLowerCase();
    let divSel = document.getElementById("filtro-division").value.toLowerCase();
    let estadoSel = document.getElementById("filtro-estado").value.toLowerCase();

    let filas = document.querySelectorAll("#tabla-usuarios tbody tr");

    filas.forEach(function(fila) {
      if(fila.children.length === 1) return;

      let idText = fila.children[0].textContent.toLowerCase();
      let nombreText = fila.children[1].textContent.toLowerCase();
      let rolText = fila.children[2].textContent.toLowerCase();
      let divText = fila.children[3].textContent.toLowerCase();
      let estadoFila = fila.getAttribute("data-estado");

      let coincideTexto = idText.includes(busqueda) || nombreText.includes(busqueda);
      let coincideRol = (rolSel === "" || rolText.includes(rolSel));
      let coincideDiv = (divSel === "" || divText.includes(divSel));
      let coincideEstado = (estadoSel === "" || estadoFila === estadoSel);

      if (coincideTexto && coincideRol && coincideDiv && coincideEstado) {
        fila.style.display = "";
      } else {
        fila.style.display = "none";
      }
    });
  }

  function limpiarFiltrosUsuarios() {
    document.getElementById('busqueda-usuario').value = '';
    document.getElementById('filtro-rol').value = '';
    document.getElementById('filtro-division').value = '';
    document.getElementById('filtro-estado').value = '';

    let filas = document.querySelectorAll("#tabla-usuarios tbody tr");
    filas.forEach(fila => fila.style.display = "");
  }

  function cambiarEstadoUsuario(idUsuario, checkElement) {
    let fila = document.getElementById("usuario-" + idUsuario);
    let estado = checkElement.checked ? 1 : 0;
    let body = new URLSearchParams({
      idUsuario: idUsuario,
      estado: estado,
      csrfToken: '<c:out value="${sessionScope.csrfToken}"/>'
    });

    checkElement.disabled = true;
    fetch('${pageContext.request.contextPath}/ActualizarEstadoUsuarioServlet', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
      body: body.toString()
    })
      .then(response => response.json().then(data => ({ok: response.ok, data})))
      .then(result => {
        if (!result.ok || !result.data.success) {
          throw new Error(result.data.message || 'No fue posible actualizar el estado.');
        }
        fila.setAttribute('data-estado', estado === 1 ? 'activo' : 'inactivo');
        filtrarTabla();
      })
      .catch(error => {
        checkElement.checked = !checkElement.checked;
        alert(error.message);
      })
      .finally(() => checkElement.disabled = false);
  }
</script>
</body>
</html>
