<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte Enviado</title>
    <style>
        body, html {
            height: 100%;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #ffffff; /* Fondo blanco completo */
        }

        .success-container {
            text-align: center;
            max-width: 500px;
            padding: 20px;
        }

        /* Icono de palomita verde */
        .icon-box {
            width: 85px;
            height: 85px;
            border: 3px solid #52c48b;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px auto;
        }

        .icon-box svg {
            width: 45px;
            height: 45px;
            stroke: #52c48b;
            stroke-width: 4;
            stroke-linecap: round;
            stroke-linejoin: round;
            fill: none;
        }

        h2 {
            color: #1a202c;
            font-size: 1.1rem;
            font-weight: 800;
            margin-bottom: 25px;
            letter-spacing: 0.5px;
        }

        p {
            color: #4a5568;
            font-size: 0.95rem;
            font-weight: 600;
            line-height: 1.4;
            margin-bottom: 40px;
        }

        .btn-entendido {
            background-color: #52c48b;
            color: #ffffff;
            border: none;
            padding: 12px 35px;
            font-size: 1rem;
            font-weight: bold;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            transition: background-color 0.2s;
            display: inline-block;
        }

        .btn-entendido:hover {
            background-color: #43a373;
        }
    </style>
</head>
<body>

<div class="success-container">
    <!-- Icono SVG idéntico al de Figma -->
    <div class="icon-box">
        <svg viewBox="0 0 24 24">
            <polyline points="20 6 9 17 4 12"></polyline>
        </svg>
    </div>

    <h2>REPORTE ENVIADO CORRECTAMENTE</h2>

    <p>El reporte ha sido enviado correctamente.<br>
        Espere la respuesta del departamento al que ha sido enviado</p>

    <!-- Redirige de vuelta a la página principal de solicitudes -->
    <a href="solicitud.jsp" class="btn-entendido">Entendido</a>
</div>

</body>
</html>