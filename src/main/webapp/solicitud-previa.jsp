<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="mx.edu.utez.awgva.Model.SolicitudVisita" %>
<%@ page import="java.util.List" %>
<%
  List<SolicitudVisita> lista = (List<SolicitudVisita>) session.getAttribute("listaSolicitudes");
  SolicitudVisita sol = null;

  String indexParam = request.getParameter("index");
  if (lista != null && !lista.isEmpty()) {
    if (indexParam != null) {
      try {
        int idx = Integer.parseInt(indexParam);
        if (idx >= 0 && idx < lista.size()) {
          sol = lista.get(idx);
        }
      } catch (NumberFormatException e) {
        sol = lista.get(lista.size() - 1);
      }
    } else {
      sol = lista.get(lista.size() - 1);
    }
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vista Previa - Solicitud de Visita</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    body { display: flex; min-height: 100vh; background-color: #92a0b1; }

    @media print {
      @page { size: letter portrait; margin: 8mm 10mm !important; }
      html, body { background-color: #fff !important; height: 100% !important; overflow: hidden !important; }
      .sidebar, .buttons, .no-print { display: none !important; }
      .main-container { margin-left: 0 !important; width: 100% !important; padding: 0 !important; }
      .form-wrapper { box-shadow: none !important; max-width: 100% !important; border: none !important; padding: 0 !important; }
    }

    .main-container { margin-left: 240px; flex-grow: 1; padding: 20px; overflow-y: auto; }
    .form-wrapper { background-color: white; padding: 30px 40px; border-radius: 4px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); max-width: 950px; margin: 0 auto; }

    .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 12px; }
    .header h1 { font-size: 18px; font-weight: bold; color: #000; text-transform: uppercase; }
    .logo-box { border: 1px dashed #999; padding: 6px 15px; font-size: 11px; color: #666; font-weight: bold; }

    .section-title { font-size: 13px; font-weight: bold; color: #1e293b; margin-top: 12px; margin-bottom: 6px; }

    table.doc-table { width: 100%; border-collapse: collapse; margin-bottom: 10px; font-size: 12px; }
    table.doc-table th, table.doc-table td { border: 1px solid #000; padding: 4px 8px; vertical-align: middle; }
    table.doc-table th { font-weight: bold; text-align: center; background-color: #f1f5f9; }
    .data-value { font-weight: 600; color: #0f172a; min-height: 18px; }

    .signatures-container { display: flex; justify-content: space-around; margin-top: 25px; text-align: center; }
    .signature-box { width: 40%; display: flex; flex-direction: column; align-items: center; }
    .signature-line { width: 100%; border-top: 1px solid #000; margin-top: 30px; margin-bottom: 4px; }
    .signature-title { font-size: 13px; font-weight: bold; margin-bottom: 15px; }
    .signature-name { font-size: 12px; font-weight: bold; color: #1e293b; }

    .buttons { display: flex; justify-content: space-between; margin-top: 25px; }
    .btn { background-color: #f38218; color: white; border: none; padding: 10px 25px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px; text-decoration: none; }
    .btn:hover { background-color: #d9700f; }
  </style>
</head>
<body>

<jsp:include page="Layout/sidebar.jsp"/>

<div class="main-container">
  <div class="form-wrapper">
    <div class="header">
      <h1>SOLICITUD DE VISITAS ACADÉMICAS</h1>
      <div class="logo-box">UTEZ</div>
    </div>

    <div class="section-title">Datos del Lugar</div>
    <table class="doc-table">
      <tr>
        <td style="width: 25%; font-weight: bold;">Nombre de la empresa:</td>
        <td class="data-value"><%= (sol != null && sol.getEmpresaNombre() != null) ? sol.getEmpresaNombre() : "" %></td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Dirección o lugar:</td>
        <td class="data-value"><%= (sol != null && sol.getEmpresaDireccion() != null) ? sol.getEmpresaDireccion() : "" %></td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Teléfono de contacto:</td>
        <td class="data-value"><%= (sol != null && sol.getEmpresaTelefono() != null) ? sol.getEmpresaTelefono() : "" %></td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Correo Electrónico:</td>
        <td class="data-value"><%= (sol != null && sol.getEmpresaEmail() != null) ? sol.getEmpresaEmail() : "" %></td>
      </tr>
    </table>

    <table class="doc-table">
      <tr>
        <td style="width: 25%; font-weight: bold;">Fecha de inicio:</td>
        <td class="data-value" style="width: 25%;"><%= (sol != null && sol.getFechaInicio() != null) ? sol.getFechaInicio() : "" %></td>
        <td style="width: 25%; font-weight: bold;">Hora de inicio:</td>
        <td class="data-value" style="width: 25%;"><%= (sol != null && sol.getHoraInicio() != null) ? sol.getHoraInicio() : "" %></td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Fecha de término:</td>
        <td class="data-value" colspan="3"><%= (sol != null && sol.getFechaTermino() != null) ? sol.getFechaTermino() : "" %></td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Objetivo:</td>
        <td class="data-value" colspan="3" style="min-height: 35px; vertical-align: top;"><%= (sol != null && sol.getObjetivo() != null) ? sol.getObjetivo() : "" %></td>
      </tr>
    </table>

    <div class="section-title">Datos de los Participantes</div>
    <table class="doc-table">
      <tr>
        <td style="width: 25%; font-weight: bold;">Área solicitante:</td>
        <td class="data-value" colspan="3"><%= (sol != null && sol.getSolicitanteCargo() != null) ? sol.getSolicitanteCargo() : "" %></td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Docente responsable:</td>
        <td class="data-value" colspan="3"><%= (sol != null && sol.getSolicitanteNombre() != null) ? sol.getSolicitanteNombre() : "" %></td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Celular de responsable:</td>
        <td class="data-value"><%= (sol != null && sol.getSolicitanteTelefono() != null) ? sol.getSolicitanteTelefono() : "" %></td>
        <td style="font-weight: bold;">Docentes acompañantes:</td>
        <td class="data-value"><%= (sol != null && sol.getDocentesAcompanantes() != null) ? sol.getDocentesAcompanantes() : "" %></td>
      </tr>
    </table>

    <p style="font-size: 11px; font-weight: bold; margin-bottom: 4px;">No. de estudiantes participantes:</p>
    <table class="doc-table" style="text-align: center;">
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
        <td><%= (sol != null && sol.getDacea() != null) ? sol.getDacea() : "0" %></td>
        <td><%= (sol != null && sol.getDatefi() != null) ? sol.getDatefi() : "0" %></td>
        <td><%= (sol != null && sol.getDatid() != null) ? sol.getDatid() : "0" %></td>
        <td><%= (sol != null && sol.getDami() != null) ? sol.getDami() : "0" %></td>
        <td style="font-weight: bold;"><%= (sol != null && sol.getTotalEstudiantes() != null) ? sol.getTotalEstudiantes() : "0" %></td>
      </tr>
      </tbody>
    </table>

    <div style="margin-top: 8px;">
      <p style="font-size: 11px; font-weight: bold; margin-bottom: 4px;">Asignaturas que se reforzarán</p>
      <div style="border: 1px solid #000; padding: 6px; min-height: 35px; font-size: 12px;">
        <%= (sol != null && sol.getAsignaturas() != null) ? sol.getAsignaturas() : "" %>
      </div>
    </div>

    <!-- AMBAS FIRMAS AL PIE DE PÁGINA -->
    <div class="signatures-container">
      <div class="signature-box">
        <div class="signature-title">Solicita</div>
        <div class="signature-line"></div>
        <div class="signature-name"><%= (sol != null && sol.getSolicitanteNombre() != null) ? sol.getSolicitanteNombre() : "" %></div>
      </div>

      <div class="signature-box">
        <div class="signature-title">Autoriza</div>
        <div class="signature-line"></div>
        <div class="signature-name">&nbsp;</div>
      </div>
    </div>

    <div class="buttons">
      <a href="solicitud.jsp" class="btn">Volver a Solicitudes</a>
      <button type="button" class="btn" onclick="window.print()">Descargar / Imprimir</button>
    </div>

  </div>
</div>

<script>
  // Al descargar/imprimir, redirige automáticamente a solicitudes
  window.onafterprint = function () {
    window.location.href = "solicitud.jsp";
  };
</script>

</body>
</html>