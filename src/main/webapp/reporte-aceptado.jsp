<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte Aceptado</title>
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

        .icon-success {
            font-size: 60px;
            color: #2e7d32;
            margin-bottom: 15px;
        }

        .btn-responsiva {
            background-color: #2b6cb0;
            color: white;
            border: none;
            padding: 10px 20px;
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
    <div class="icon-success">✓</div>
    <h1 style="color: #2e7d32;">¡Reporte Aceptado!</h1>
    <p style="margin-top:15px; color:#555;">El reporte de la visita a <strong>${sessionScope.empresa}</strong> ha sido validado satisfactoriamente por la coordinación de Estadías.</p>
    <a href="${pageContext.request.contextPath}/views/reportes/detalles-reporte.jsp" class="btn-responsiva">Volver a Detalles</a>
</div>

</body>
</html>