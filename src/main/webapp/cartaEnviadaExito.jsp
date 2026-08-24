<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carta responsiva enviada</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        * {
            box-sizing: border-box;
        }

        html,
        body {
            margin: 0;
            padding: 0;
            width: 100%;
            min-height: 100%;
        }

        body {
            min-height: 100vh;
            min-height: 100dvh;
            background: #ffffff;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #111111;
            overflow-x: hidden;
        }

        .screen {
            width: 100%;
            min-height: 100vh;
            min-height: 100dvh;
            margin: 0;
            padding: 30px;
            background: #ffffff;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
        }

        .content {
            width: 100%;
            max-width: 760px;
            margin: 0 auto;
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
            border: 0;
            background: #55c993;
            color: #ffffff;
            border-radius: 6px;
            padding: 11px 30px;
            font-weight: 800;
            font-size: .75rem;
            cursor: pointer;
            box-shadow: 0 3px 7px rgba(0,0,0,.12);
            transition: background-color .2s ease, transform .15s ease;
        }

        .btn:hover {
            background: #45b984;
        }

        .btn:active {
            transform: scale(.98);
        }

        @media (max-width: 768px) {
            .screen {
                padding: 20px;
            }

            .icon {
                font-size: 4rem;
            }

            .title {
                font-size: .82rem;
            }

            .text {
                font-size: .78rem;
            }
        }
    </style>
</head>
<body>

<main class="screen">
    <div class="content">
        <div class="icon">
            <i class="bi bi-check-square"></i>
        </div>

        <div class="title">
            CARTA RESPONSIVA ENVIADA CORRECTAMENTE
        </div>

        <div class="text">
            La carta responsiva ha sido enviada correctamente.<br>
            Espera la respuesta del departamento al que ha sido enviado.
        </div>

        <form method="post" action="${ctx}/detalle-solicitud">
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <input type="hidden" name="ref" value="<c:out value='${referenceToken}'/>">
            <button class="btn" type="submit">Entendido</button>
        </form>
    </div>
</main>

</body>
</html>