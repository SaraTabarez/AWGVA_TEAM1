<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Recuperar el índice de la solicitud para mantener la navegación
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
    <title>Carta Responsiva Visitas Académicas</title>
    <!-- Librería JavaScript para convertir HTML a PDF -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: #A6B5C3;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            padding: 40px 20px;
            min-height: 100vh;
        }

        .document-container {
            background-color: #FFFFFF;
            width: 100%;
            max-width: 1100px;
            padding: 60px 80px;
            position: relative;
            box-shadow: 0px 4px 15px rgba(0,0,0,0.1);
        }

        /* Botón X de cerrar */
        .close-btn {
            position: absolute;
            top: 20px;
            right: 25px;
            font-size: 24px;
            color: #333;
            cursor: pointer;
        }

        /* Encabezado: Descargar */
        .download-section {
            display: inline-flex;
            align-items: center;
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 20px;
            cursor: pointer;
            user-select: none;
            color: #000;
        }

        .download-section:hover {
            color: #0056b3;
        }

        .download-icon {
            width: 24px;
            height: 24px;
            margin-right: 10px;
        }

        /* Textos del documento */
        .doc-title {
            text-align: center;
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 20px;
        }

        .doc-date {
            text-align: right;
            font-size: 14px;
            margin-bottom: 40px;
        }

        .recipient {
            font-size: 14px;
            font-weight: bold;
            line-height: 1.5;
            margin-bottom: 30px;
        }

        .body-text {
            font-size: 14px;
            line-height: 1.6;
            text-align: justify;
            margin-bottom: 15px;
        }

        .bullet-list {
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 15px;
            padding-left: 40px;
        }

        .bullet-list li {
            margin-bottom: 5px;
        }

        .italic-text {
            font-size: 14px;
            font-style: italic;
            text-align: justify;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        /* Tabla de Alumnos */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        th, td {
            border: 1px solid black;
            padding: 12px;
            text-align: center;
            font-size: 14px;
        }

        th {
            font-weight: bold;
            background-color: transparent;
        }

        td {
            height: 40px;
        }

        /* Botón verde para agregar */
        .add-row-container {
            text-align: right;
            margin-top: 15px;
        }

        .add-btn {
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            font-size: 24px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0px 4px 6px rgba(0,0,0,0.2);
            transition: background-color 0.3s, transform 0.1s;
            display: inline-flex;
            justify-content: center;
            align-items: center;
        }

        .add-btn:hover {
            background-color: #45a049;
        }

        .add-btn:active {
            transform: scale(0.95);
        }
    </style>
</head>
<body>

<div class="document-container" id="pdfContent">
    <!-- X Cerrar (Oculto al descargar) -->
    <div class="close-btn no-print" id="btnClose">&#x2715;</div>

    <!-- Descargar para Continuar (Oculto al descargar) -->
    <div class="download-section no-print" id="btnDescargar">
        <svg class="download-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
            <polyline points="7 10 12 15 17 10"></polyline>
            <line x1="12" y1="15" x2="12" y2="3"></line>
        </svg>
        Descargar para Continuar
    </div>

    <div class="doc-title">
        CARTA RESPONSIVA VISITAS ACADÉMICAS
    </div>

    <div class="doc-date">
        Emiliano Zapata, Morelos a _______ de _______________________ del 20_______.
    </div>

    <div class="recipient">
        UNIVERSIDAD TECNOLÓGICA EMILIANO ZAPATA<br>
        DEL ESTADO DE MORELOS.<br>
        P R E S E N T E
    </div>

    <p class="body-text">
        Por este medio, los suscritos estudiantes del programa educativo de ___________________________________________________________ y bajo protesta de decir verdad, confirmamos nuestra participación en la visita a " ___________________________________________________ ", a celebrarse los días _______ y _______ de _______________________ de 20_______, en _______________________________________; bajo el programa anexo al presente documento.
    </p>

    <p class="body-text">
        Conocedores que la actividad se documentará como una visita de estudio de la Universidad Tecnológica Emiliano Zapata del Estado de Morelos (UTEZ) y debido al horario del encuentro ( ________ a ________ hrs.), declaramos que los traslados y gastos derivados a nuestra participación en el evento antes mencionado los realizaremos con nuestros propios medios y recursos, asimismo que conocemos el alcance del seguro de la empresa que se contrató para el traslado.
    </p>

    <p class="body-text">
        Derivado de lo anterior nos obligamos a:
    </p>

    <ul class="bullet-list">
        <li>Respetar las reglas impuestas tanto por la UTEZ, como por los organizadores de la salida.</li>
        <li>Buscar siempre estar informedo de las actividades grupales programadas.</li>
        <li>Abstenerme de cualquier conducta ilegal o inapropiada que pueda denigrar la buena imagen de la UTEZ o que sea perjudicial para sus objetivos y;</li>
        <li>No poner en riesgo mi integridad física ni la de mis compañeros.</li>
    </ul>

    <p class="body-text">
        Estamos de acuerdo en asumir la responsabilidad como ciudadanos y como miembros de la comunidad universitaria, por lo que nos obligamos a realizar las siguientes acciones:
    </p>

    <p class="body-text">
        Adoptar las medidas de seguridad correspondientes de la actividad que desempeñemos en cualquier lugar, tales como uso adecuado de equipo de protección personal, higiene respiratoria, lavado de manos, etc. Así como, seguir los protocolos de prevención emitidos por la Universidad o institución donde esté realizando la actividad de visita de estudio, dentro o fuera del Estado de Morelos.
    </p>

    <p class="body-text">
        Asimismo, manifestamos que la actividad descrita la realizamos bajo nuestra responsabilidad, por lo que deslindamos a la UTEZ y a su personal docente y administrativo de toda responsabilidad en caso de que se presente alguna consecuencia que resulte de la falta de acción, omisión o incumplimiento en la que hayamos incurrido con respecto a los puntos descritos anteriormente, así como del pago de daños y perjuicios y cualquier acción legal, en el entendido que mediante las acciones anteriores la Universidad está protegiendo nuestra integridad y la de los demás miembros de la comunidad universitaria.
    </p>

    <p class="italic-text">
        He leído este documento, entiendo completamente sus términos y por medio del mismo eximo y libero de toda responsabilidad a la UTEZ y a terceros, y me hago único y absoluto responsable de mi persona, en los términos del presente, mismo que suscribo libre y voluntariamente.
    </p>

    <table id="alumnosTable">
        <thead>
        <tr>
            <th style="width: 5%;">No.</th>
            <th style="width: 45%;">Nombre</th>
            <th style="width: 25%;">Grado y Grupo</th>
            <th style="width: 25%;">Firma</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td>1</td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        </tbody>
    </table>

    <!-- Botón + para agregar filas (Oculto al descargar) -->
    <div class="add-row-container no-print">
        <button class="add-btn" id="btnAgregarFila" title="Agregar alumno">+</button>
    </div>

</div>

<!-- SCRIPT JS CORREGIDO CON REDIRECCIÓN -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const btnAgregarFila = document.getElementById('btnAgregarFila');
        const btnDescargar = document.getElementById('btnDescargar');
        const btnClose = document.getElementById('btnClose');
        const tbody = document.querySelector('#alumnosTable tbody');

        // Botón X (cerrar sin descargar) -> regresa a la vista de detalle
        if (btnClose) {
            btnClose.addEventListener('click', function() {
                window.location.href = 'solicitud-detalle.jsp?index=<%= indexNum %>';
            });
        }

        // 1. Agregar filas concatenando cadenas (compatible con JSP)
        btnAgregarFila.addEventListener('click', function() {
            var siguienteNumero = tbody.querySelectorAll('tr').length + 1;

            var nuevaFila = document.createElement('tr');
            nuevaFila.innerHTML =
                '<td>' + siguienteNumero + '</td>' +
                '<td></td>' +
                '<td></td>' +
                '<td></td>';

            tbody.appendChild(nuevaFila);
        });

        // 2. Generar, descargar PDF y REDIRIGIR a los detalles con bandera activada
        btnDescargar.addEventListener('click', function() {
            const elemento = document.getElementById('pdfContent');

            // Ocultar botones e iconos para que NO salgan en el PDF
            const elementosOcultar = document.querySelectorAll('.no-print');
            elementosOcultar.forEach(el => el.style.display = 'none');

            const opciones = {
                margin:       [10, 10, 10, 10],
                filename:     'Carta_Responsiva_Visitas_Academicas.pdf',
                image:        { type: 'jpeg', quality: 0.98 },
                html2canvas:  { scale: 2, useCORS: true },
                jsPDF:        { unit: 'mm', format: 'letter', orientation: 'portrait' }
            };

            // Generar PDF, descargarlo y LUEGO redirigir a los detalles
            html2pdf().set(opciones).from(elemento).save().then(function() {
                // Volver a mostrar elementos por si acaso
                elementosOcultar.forEach(el => el.style.display = '');

                // REDIRECCIÓN AUTOMÁTICA a detalles notificando que ya se descargó
                window.location.href = 'solicitud-detalle.jsp?index=<%= indexNum %>&cartaDescargada=true';
            });
        });
    });
</script>
</body>
</html>