<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Oficio de autorización - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #e5e7eb;
            color: #111;
            font-family: Arial, sans-serif;
        }

        .main {
            margin-left: 240px;
            min-height: 100vh;
            padding: 18px;
        }

        .toolbar {
            max-width: 830px;
            margin: 0 auto 10px;
            display: flex;
            justify-content: flex-end;
            gap: 8px;
        }

        .btn {
            border: 0;
            border-radius: 4px;
            padding: 9px 14px;
            background: #1e3a5f;
            color: #fff;
            text-decoration: none;
            font-weight: 700;
            cursor: pointer;
        }

        .paper {
            width: min(830px, 100%);
            min-height: 1080px;
            background: #fff;
            margin: auto;
            padding: 50px 70px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, .15);
            font-family: "Times New Roman", serif;
            font-size: 13px;
            line-height: 1.5;
        }

        .logos {
            display: flex;
            justify-content: space-between;
            color: #6b8d3d;
            border-bottom: 2px solid #718a4e;
            padding-bottom: 12px;
        }

        .folio {
            text-align: right;
            margin: 22px 0;
        }

        .date {
            text-align: right;
        }

        .recipient {
            margin: 28px 0 20px;
            font-weight: bold;
            text-transform: uppercase;
        }

        .paragraph {
            text-align: justify;
        }

        .facts {
            margin: 22px 0;
        }

        .facts div {
            display: grid;
            grid-template-columns: 190px 1fr;
            padding: 5px 0;
        }

        .facts strong {
            font-weight: bold;
        }

        .signature {
            margin-top: 70px;
        }

        .line {
            width: 340px;
            border-top: 1px solid #111;
            padding-top: 6px;
            font-weight: bold;
        }

        .foot {
            font-size: 8px;
            margin-top: 80px;
            border-top: 1px solid #aaa;
            padding-top: 6px;
        }

        @media print {
            .sidebar,
            .toolbar {
                display: none !important;
            }

            .main {
                margin: 0;
                padding: 0;
            }

            .paper {
                box-shadow: none;
                width: 100%;
                min-height: auto;
                padding: 12mm 17mm;
            }

            @page {
                size: A4;
                margin: 5mm;
            }
        }

        @media(max-width: 800px) {
            .main {
                margin-left: 0;
            }

            .paper {
                padding: 35px 24px;
            }

            .facts div {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>

<main class="main">
    <!-- Barra de Herramientas -->
    <div class="toolbar">
        <button class="btn" type="button" data-post-url="${ctx}/detalle-solicitud" data-post-ref="<c:out value='${expediente.referenceToken}'/>">
            <i class="bi bi-arrow-left"></i> Volver
        </button>
        <button class="btn" onclick="window.print()">
            <i class="bi bi-printer"></i> Imprimir / Descargar PDF
        </button>
    </div>

    <!-- Documento Imprimible -->
    <article class="paper">
        <div class="logos">
            <strong>EDUCACIÓN</strong>
            <strong>UTEZ<br><small>UNIVERSIDAD TECNOLÓGICA EMILIANO ZAPATA</small></strong>
            <strong>ESTADÍAS</strong>
        </div>

        <div class="folio">
            OFICIO DE AUTORIZACIÓN DE VISITA ACADÉMICA
        </div>

        <div class="date">
            Emiliano Zapata, Morelos, a <c:out value="${expediente.fechaInicio}"/>
        </div>

        <div class="recipient">
            DIRECTOR(A) DE LA DIVISIÓN ACADÉMICA<br>
            <c:out value="${expediente.division}"/><br>
            PRESENTE
        </div>

        <p class="paragraph">
            Por medio del presente, comunico a usted que la visita académica registrada en el expediente digital cuenta con la información necesaria para solicitar su autorización. La actividad se realizará conforme a los datos capturados por el docente responsable.
        </p>

        <!-- Datos de la Visita -->
        <div class="facts">
            <div>
                <strong>Empresa:</strong>
                <span><c:out value="${expediente.empresa}"/></span>
            </div>
            <div>
                <strong>Dirección:</strong>
                <span><c:out value="${expediente.direccionEmpresa}"/></span>
            </div>
            <div>
                <strong>Fecha de salida:</strong>
                <span><c:out value="${expediente.fechaInicio}"/></span>
            </div>
            <div>
                <strong>Fecha de término:</strong>
                <span><c:out value="${expediente.fechaFin}"/></span>
            </div>
            <div>
                <strong>Estudiantes asistentes:</strong>
                <span><c:out value="${expediente.numeroEstudiantes}"/></span>
            </div>
            <div>
                <strong>Programa educativo:</strong>
                <span><c:out value="${expediente.carrera}"/></span>
            </div>
            <div>
                <strong>Cuatrimestre / Grupo:</strong>
                <span><c:out value="${expediente.semestre}"/> / <c:out value="${expediente.grupo}"/></span>
            </div>
            <div>
                <strong>Docente responsable:</strong>
                <span><c:out value="${expediente.docente}"/></span>
            </div>
            <div>
                <strong>Docentes acompañantes:</strong>
                <span><c:out value="${expediente.docenteAcompanante}"/></span>
            </div>
            <div>
                <strong>Asignatura(s):</strong>
                <span><c:out value="${expediente.asignatura}"/></span>
            </div>
            <div>
                <strong>Objetivo:</strong>
                <span><c:out value="${expediente.proposito}"/></span>
            </div>
        </div>

        <p class="paragraph">
            Sin otro particular, agradezco la atención prestada y quedo pendiente de la autorización correspondiente.
        </p>

        <div class="signature">
            <strong>ATENTAMENTE</strong><br><br><br>
            <div class="line">
                <c:out value="${firmantes.estadiasNombre}"/><br>
                <c:out value="${firmantes.estadiasCargo}"/>
            </div>
        </div>

        <div class="foot">
            Documento generado por AWGVA con los datos de la solicitud de visita académica.
        </div>
    </article>
</main>
</body>
</html>
