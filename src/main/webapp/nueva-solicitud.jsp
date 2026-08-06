<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nueva Solicitud - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background-color: #ffffff; color: #1e3a5f; min-height: 100vh; }
        .main-layout { margin-left: 240px; padding: 2.5rem 4rem; background-color: #ffffff; min-height: 100vh; }
        .header-title-container { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .main-title { color: #1e3a5f; font-weight: 800; font-size: 1.8rem; letter-spacing: -0.5px; margin: 0; }
        .utez-logo { height: 45px; object-fit: contain; }
        .section-header { color: #1e3a5f; font-weight: 700; font-size: 1.2rem; display: flex; align-items: center; gap: 10px; margin-top: 1.5rem; margin-bottom: 1.2rem; }
        .form-label-custom { font-size: 0.85rem; font-weight: 700; color: #1e3a5f; margin-bottom: 0.4rem; display: block; }
        .custom-input { background-color: #e2e8f0; border: 1px solid transparent; border-radius: 6px; padding: 0.55rem 0.8rem; width: 100%; color: #333333; font-size: 0.9rem; outline: none; transition: all 0.2s ease-in-out; }
        .custom-input:focus { background-color: #ffffff; border-color: #f38218; box-shadow: 0 0 0 0.2rem rgba(243, 130, 24, 0.15); }
        .input-icon-wrapper { position: relative; display: flex; align-items: center; }
        .input-icon-wrapper i { position: absolute; left: 12px; color: #8a99ad; }
        .input-icon-wrapper .custom-input { padding-left: 2.2rem; }
        .custom-table { width: 100%; border-collapse: collapse; margin-top: 0.5rem; }
        .custom-table th { border: 1px solid #1e3a5f; color: #1e3a5f; font-size: 0.85rem; font-weight: 700; text-align: center; padding: 6px 8px; background-color: #ffffff; }
        .custom-table td { border: 1px solid #1e3a5f; padding: 0; background-color: #e2e8f0; }
        .custom-table td input { width: 100%; border: none; background: transparent; padding: 8px; text-align: center; outline: none; font-size: 0.9rem; color: #333; }
        .btn-submit { background-color: #f38218; color: #ffffff; border: none; border-radius: 8px; padding: 0.65rem 2.2rem; font-weight: 700; font-size: 0.95rem; cursor: pointer; box-shadow: 0 3px 6px rgba(243, 130, 24, 0.25); display: inline-flex; align-items: center; gap: 8px; transition: all 0.25s ease; }
        .btn-submit:hover { background-color: #d9700f; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(217, 112, 15, 0.35); }
        .btn-cancel { color: #64748b; text-decoration: none; font-size: 0.9rem; font-weight: 600; padding: 0.6rem 1.4rem; border-radius: 8px; border: 1px solid #cbd5e1; background-color: #f8fafc; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s ease; }
        .btn-cancel:hover { background-color: #e2e8f0; color: #1e3a5f; border-color: #94a3b8; }
    </style>
</head>
<body>

<jsp:include page="Layout/sidebar.jsp"/>

<main class="main-layout">
    <div class="header-title-container">
        <h1 class="main-title">SOLICITUD DE VISITAS ACADÉMICAS</h1>
        <img src="https://upload.wikimedia.org/wikipedia/commons/b/b3/Logo-utez.png" alt="UTEZ Logo" class="utez-logo" onerror="this.style.display='none'">
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger"><c:out value="${error}"/></div>
    </c:if>

    <form id="solicitudForm" action="${pageContext.request.contextPath}/nueva-solicitud" method="post">
        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

        <!-- SECCIÓN 1: Datos del Solicitante -->
        <div class="section-header">
            <i class="bi bi-person-badge"></i>
            <span>Datos del Solicitante</span>
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-6">
                <label class="form-label-custom">Nombre Completo</label>
                <input type="text" class="custom-input" id="docenteEncargado" name="solicitanteNombre" value="<c:out value='${sessionScope.usuario.nombreCompleto}'/>" readonly required>
            </div>
            <div class="col-md-6">
                <label class="form-label-custom">Cargo / Rol</label>
                <input type="text" class="custom-input" id="tituloVisita" name="solicitanteCargo" value="DOCENTE" readonly>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <label class="form-label-custom">Teléfono de contacto</label>
                <div class="input-icon-wrapper">
                    <i class="bi bi-telephone"></i>
                    <input type="tel" class="custom-input" id="telefonoDocente" name="solicitanteTelefono" placeholder="Teléfono del Solicitante" required>
                </div>
            </div>
            <div class="col-md-6">
                <label class="form-label-custom">No. de Docentes acompañantes</label>
                <input type="number" class="custom-input" id="docenteAcompanante" name="docentesAcompanantes" placeholder="Máximo 3 acompañantes" min="0" max="3" value="0" required>
            </div>
        </div>

        <!-- SECCIÓN 2: Datos de la visita -->
        <div class="section-header">
            <i class="bi bi-geo-alt"></i>
            <span>Datos de la visita</span>
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-6">
                <label class="form-label-custom">Dirección del lugar a visitar</label>
                <input type="text" class="custom-input" id="direccionEmpresa" name="empresaDireccion" placeholder="Ubicación del lugar de la visita" required>
            </div>
            <div class="col-md-6">
                <label class="form-label-custom">Nombre de la empresa a visitar</label>
                <input type="text" class="custom-input" id="nombreEmpresa" name="empresaNombre" placeholder="Nombre del lugar a visitar" required>
            </div>
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-6">
                <label class="form-label-custom">Teléfono de contacto</label>
                <div class="input-icon-wrapper">
                    <i class="bi bi-telephone"></i>
                    <input type="tel" class="custom-input" id="contacto" name="empresaTelefono" placeholder="Teléfono del lugar a visitar" required>
                </div>
            </div>
            <div class="col-md-6">
                <label class="form-label-custom">Correo electrónico del lugar de la visita</label>
                <input type="email" class="custom-input" id="correoEmpresa" name="empresaEmail" placeholder="empresa@com.mx" required>
            </div>
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-4">
                <label class="form-label-custom">Fecha de inicio</label>
                <input type="date" class="custom-input" id="fechaInicio" name="fechaInicio" required>
            </div>
            <div class="col-md-4">
                <label class="form-label-custom">Fecha de término</label>
                <input type="date" class="custom-input" id="fechaFin" name="fechaTermino" required>
            </div>
            <div class="col-md-4">
                <label class="form-label-custom">Hora inicio</label>
                <input type="time" class="custom-input" id="horaInicio" name="horaInicio">
            </div>
        </div>

        <div class="mb-4">
            <label class="form-label-custom">Objetivo de la visita</label>
            <textarea class="custom-input" id="proposito" name="objetivo" rows="3" placeholder="Describir detalladamente el objetivo para la visita" required></textarea>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <label class="form-label-custom">Programa educativo</label>
                <select class="custom-input" name="programaEducativo" required>
                    <option value="">Selecciona tu carrera</option>
                    <c:forEach var="carrera" items="${carreras}">
                        <option value="<c:out value='${carrera}'/>"><c:out value="${carrera}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label-custom">Cuatrimestre</label>
                <input class="custom-input" name="semestre" placeholder="Ej. 6°" required>
            </div>
            <div class="col-md-3">
                <label class="form-label-custom">Grupo</label>
                <input class="custom-input" name="grupo" placeholder="Ej. B" required>
            </div>
        </div>

        <!-- Tabla Estudiantes por División -->
        <div class="mb-4">
            <label class="form-label-custom">No. de estudiantes participantes por división académica:</label>
            <table class="custom-table">
                <thead>
                <tr>
                    <th>DACEA</th>
                    <th>DATEFI</th>
                    <th>DATID</th>
                    <th>DAMI</th>
                    <th>Total estudiantes</th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td><input type="number" id="dacea" name="dacea" min="0" value="0" ${sessionScope.usuario.nombreDivision == 'DACEA' ? '' : 'disabled'}></td>
                    <td><input type="number" id="datefi" name="datefi" min="0" value="0" ${sessionScope.usuario.nombreDivision == 'DATEFI' ? '' : 'disabled'}></td>
                    <td><input type="number" id="datid" name="datid" min="0" value="0" ${sessionScope.usuario.nombreDivision == 'DATID' ? '' : 'disabled'}></td>
                    <td><input type="number" id="dami" name="dami" min="0" value="0" ${sessionScope.usuario.nombreDivision == 'DAMI' ? '' : 'disabled'}></td>
                    <td><input type="number" id="totalEstudiantes" name="totalEstudiantes" readonly style="font-weight: bold;" value="0"></td>
                </tr>
                </tbody>
            </table>
        </div>

        <div class="mb-5">
            <label class="form-label-custom">Asignaturas que se reforzarán con la visita</label>
            <textarea class="custom-input" id="asignatura" name="asignaturas" rows="3" placeholder="Escriba las asignaturas correspondientes..." required></textarea>
        </div>

        <!-- Botones Inferiores -->
        <div class="d-flex justify-content-between align-items-center pt-3 pb-5">
            <a href="${pageContext.request.contextPath}/inicio" class="btn-cancel">
                <i class="bi bi-arrow-left"></i> Atrás
            </a>
            <button type="submit" id="btnSubmit" class="btn-submit">
                Siguiente <i class="bi bi-arrow-right-short fs-5"></i>
            </button>
        </div>

    </form>
</main>

<script>
    const inputsDivision = [
        document.getElementById('dacea'),
        document.getElementById('datefi'),
        document.getElementById('datid'),
        document.getElementById('dami')
    ];
    const totalInput = document.getElementById('totalEstudiantes');

    function calcularTotal() {
        let suma = 0;
        inputsDivision.forEach(input => {
            if (input) {
                const val = parseInt(input.value) || 0;
                suma += val;
            }
        });
        if (totalInput) {
            totalInput.value = suma;
        }
    }

    inputsDivision.forEach(input => {
        if (input) input.addEventListener('input', calcularTotal);
    });
</script>

</body>
</html>
