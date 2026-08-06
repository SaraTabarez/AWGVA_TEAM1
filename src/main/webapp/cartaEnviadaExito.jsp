<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Carta responsiva enviada</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            background: #a9bbcf;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #111;
        }
        .screen {
            min-height: 100vh;
            margin: 8px 18px;
            background: #fff;
            display: grid;
            place-items: center;
            text-align: center;
            padding: 30px;
        }
        .icon {
            font-size: 4.8rem;
            color: #55c993;
            line-height: 1;
        }
        .title {
            font-size: .86rem;
            font-weight: 900;
            margin: 15px 0 24px;
        }
        .text {
            font-size: .74rem;
            font-weight: 650;
            color: #5e6369;
            line-height: 1.5;
        }
        .btn {
            margin-top: 28px;
            display: inline-block;
            background: #55c993;
            color: #fff;
            border-radius: 6px;
            padding: 11px 30px;
            text-decoration: none;
            font-weight: 800;
            font-size: .75rem;
            box-shadow: 0 3px 7px rgba(0,0,0,.12);
        }
    </style>
</head>
<body>
<main class="screen">
    <div>
        <div class="icon">
            <i class="bi bi-check-square"></i>
        </div>
        <div class="title">CARTA RESPONSIVA ENVIADA CORRECTAMENTE</div>
        <div class="text">
            La carta responsiva ha sido enviada correctamente.<br>
            Espera la respuesta del departamento al que ha sido enviado.
        </div>
        <a class="btn" href="${ctx}/detalle-solicitud?id=${param.id}">Entendido</a>
    </div>
</main>
</body>
</html>