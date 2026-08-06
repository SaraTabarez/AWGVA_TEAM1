<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Recuperamos el índice por si viene de la vista previa para no perder la solicitud activa
    String indexParam = request.getParameter("index");
    String urlDetalle = "solicitud-detalle.jsp";
    if (indexParam != null && !indexParam.trim().isEmpty()) {
        urlDetalle += "?index=" + indexParam;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Solicitud Enviada Correctamente</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #A6B5C3;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            font-family: Arial, sans-serif;
        }
        .success-panel {
            background-color: white;
            width: 700px;
            height: 500px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 60px;
            box-sizing: border-box;
            border-radius: 5px;
            box-shadow: 0px 4px 15px rgba(0,0,0,0.1);
        }
        .icon-container {
            border: 2px solid #55CC8A;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 40px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .checkmark {
            font-size: 50px;
            color: #55CC8A;
            font-weight: bold;
        }
        h1 {
            font-size: 24px;
            font-weight: bold;
            color: black;
            margin: 0 0 25px 0;
            text-align: center;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        p {
            font-size: 16px;
            color: black;
            margin: 0 0 45px 0;
            text-align: center;
            line-height: 1.5;
        }
        .understood-button {
            background-color: #55CC8A;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 14px 35px;
            font-size: 18px;
            cursor: pointer;
            text-transform: capitalize;
            transition: background-color 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        .understood-button:hover {
            background-color: #44B878;
        }
    </style>
</head>
<body>
<div class="success-panel">
    <div class="icon-container">
        <span class="checkmark">&#10003;</span>
    </div>
    <h1>SOLICITUD ENVIADA CORRECTAMENTE</h1>
    <p>
        La solicitud ha sido enviado correctamente.<br>
        Espere la respuesta del departamento al que ha sido enviado
    </p>

    <!-- Redirección directa a la pantalla de detalles -->
    <a href="<%= urlDetalle %>" class="understood-button">Entendido</a>
</div>
</body>
</html>