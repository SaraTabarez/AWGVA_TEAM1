<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Recuperar el índice de la solicitud
    String indexParam = request.getParameter("index");
    int indexNum = 0;
    if (indexParam != null) {
        try {
            indexNum = Integer.parseInt(indexParam);
        } catch (NumberFormatException e) {
            indexNum = 0;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carta Responsiva Enviada Correctamente</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --bg-body: #a2b1c6;
            --color-success: #48cd8e;
            --color-success-hover: #3db87d;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-body);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        /* Tarjeta Blanca Centrada */
        .success-card {
            background-color: #ffffff;
            width: 100%;
            max-width: 680px;
            padding: 60px 40px;
            border-radius: 6px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }

        /* Contenedor del ícono Verde */
        .icon-box {
            border: 2px solid var(--color-success);
            border-radius: 12px;
            padding: 18px 26px;
            margin-bottom: 35px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .icon-box i {
            font-size: 42px;
            color: var(--color-success);
        }

        /* Título */
        h1 {
            font-size: 1.5rem;
            font-weight: 800;
            color: #000000;
            margin-bottom: 20px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            line-height: 1.3;
        }

        /* Texto explicativo */
        p {
            font-size: 0.95rem;
            color: #333333;
            margin-bottom: 35px;
            line-height: 1.5;
        }

        /* Botón Entendido */
        .btn-understood {
            background-color: var(--color-success);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 38px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s ease, transform 0.1s ease;
        }

        .btn-understood:hover {
            background-color: var(--color-success-hover);
        }

        .btn-understood:active {
            transform: scale(0.98);
        }
    </style>
</head>
<body>

<div class="success-card">
    <div class="icon-box">
        <i class="fa-solid fa-check"></i>
    </div>

    <h1>CARTA RESPONSIVA ENVIADA<br>CORRECTAMENTE</h1>

    <p>
        La carta responsiva ha sido enviada correctamente.<br>
        Espere la respuesta del departamento al que ha sido enviado.
    </p>

    <button type="button" class="btn-understood" onclick="volverADetalle()">Entendido</button>
</div>

<script>
    function volverADetalle() {
        window.location.href = 'solicitud-detalle.jsp?index=<%= indexNum %>';
    }
</script>

</body>
</html>