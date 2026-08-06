<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Reporte Rechazado</title>
  <style>
    * {
      box-sizing: border-box;
      font-family: Arial, Helvetica, sans-serif;
      margin: 0;
      padding: 0;
    }

    body {
      background-color: #f4f6f9;
      color: #333;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
    }

    .card-standalone {
      background: white;
      width: 480px;
      padding: 40px;
      border-radius: 8px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.1);
      text-align: center;
    }

    .icon-danger {
      font-size: 60px;
      color: #c62828;
      margin-bottom: 15px;
    }

    .btn-atras {
      background-color: #fca311;
      color: white;
      border: none;
      padding: 10px 25px;
      border-radius: 6px;
      font-weight: bold;
      cursor: pointer;
      text-decoration: none;
      display: inline-block;
      margin-top: 20px;
    }
  </style>
</head>
<body>

<div class="card-standalone">
  <div class="icon-danger">✕</div>
  <h1 style="color: #c62828;">Reporte Rechazado</h1>
  <p style="margin-top:15px; color:#555;"><strong>Motivo:</strong> ${sessionScope.observacionesEstadias}</p>
  <a href="${pageContext.request.contextPath}/views/reportes/corregir-reporte.jsp" class="btn-atras">Ir a Corregir Reporte</a>
</div>

</body>
</html>