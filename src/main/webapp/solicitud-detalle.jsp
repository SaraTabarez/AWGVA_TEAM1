<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Detalle de solicitud - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #a9bbcf;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #1e3a5f;
        }

        .main {
            margin-left: 240px;
            min-height: 100vh;
            padding: 20px;
        }

        .panel {
            max-width: 1050px;
            margin: auto;
            background: #fff;
            min-height: calc(100vh - 40px);
            padding: 24px 30px;
            position: relative;
        }

        .close {
            position: absolute;
            right: 18px;
            top: 12px;
            color: #6b7280;
            text-decoration: none;
            font-size: 1.3rem;
        }

        h1 {
            text-align: center;
            font-size: 1.35rem;
            font-weight: 850;
            margin: 0 0 15px;
        }

        .status-row {
            display: flex;
            justify-content: space-between;
            gap: 14px;
            align-items: center;
            margin-bottom: 16px;
        }

        .info-title {
            font-size: .82rem;
            color: #e84a5f;
            font-weight: 800;
        }

        .status {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 999px;
            padding: 6px 24px;
            font-size: .75rem;
            font-weight: 800;
            box-shadow: 0 2px 7px rgba(0, 0, 0, .05);
        }

        .grid {
            display: grid;
            grid-template-columns: 1.35fr .9fr;
            gap: 18px;
        }

        .box {
            border: 1px solid #dce3eb;
            border-radius: 10px;
            padding: 13px;
            box-shadow: 0 2px 7px rgba(30, 58, 95, .05);
        }

        .box-title {
            font-size: .78rem;
            font-weight: 850;
            margin-bottom: 9px;
            display: flex;
            gap: 6px;
            align-items: center;
        }

        .field {
            margin-bottom: 9px;
        }

        .field label {
            font-size: .63rem;
            font-weight: 800;
            display: block;
            margin-bottom: 3px;
        }

        .value {
            background: #eef3f8;
            border: 1px solid #d8e1eb;
            border-radius: 4px;
            min-height: 28px;
            padding: 6px 8px;
            font-size: .72rem;
            overflow-wrap: anywhere;
        }

        .participants {
            grid-column: 1/-1;
        }

        .participant-grid {
            display: grid;
            grid-template-columns: 1fr 1.5fr 1.3fr 1fr;
            gap: 12px;
        }

        .actions-title {
            font-size: .65rem;
            font-weight: 800;
            margin: 18px 0 8px;
        }

        .action-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 10px;
        }

        .action {
            border: 0;
            border-radius: 5px;
            min-height: 38px;
            padding: 9px 10px;
            text-decoration: none;
            font-size: .72rem;
            font-weight: 850;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            text-align: center;
        }

        .blue {
            background: #1e3a5f;
            color: #fff;
        }

        .disabled {
            background: #b9b4ab;
            color: #fff;
            cursor: not-allowed;
        }

        .orange {
            background: #f59120;
            color: #fff;
        }

        .footer {
            display: flex;
            justify-content: flex-end;
            margin-top: 18px;
        }

        .notice {
            background: #fff7e8;
            border: 1px solid #ffd89c;
            color: #8a5200;
            padding: 9px 12px;
            border-radius: 6px;
            margin-bottom: 12px;
            font-size: .78rem;
        }

        .doc-ok {
            font-size: .65rem;
            color: #16803b;
            margin-top: 4px;
            text-align: center;
            font-weight: 700;
        }

        @media(max-width: 850px) {
            .main {
                margin-left: 0;
            }

            .grid {
                grid-template-columns: 1fr;
            }

            .participant-grid,
            .action-grid {
                grid-template-columns: 1fr;
            }

            .panel {
                padding: 22px 16px;
            }
        }
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>

<main class="main">
    <section class="panel">
        <a class="close" href="${ctx}/mis-solicitudes" aria-label="Cerrar">×</a>

        <h1>Solicitud de Visita Industrial-División Académica</h1>

        <div class="status-row">
            <div class="info-title">
                <i class="bi bi-geo-alt-fill"></i> Información de la Dirección Académica<br>
                <small style="color:#1e3a5f">Director(a): Dirección de <c:out value="${expediente.division}"/></small>
            </div>
            <span class="status">Estado: <c:out value="${expediente.estadoLegible}"/></span>
        </div>

        <c:if test="${param.pendienteCarta == '1'}">
            <div class="notice">
                Primero descarga la carta responsiva sin firmas para habilitar su carga y el oficio de autorización.
            </div>
        </c:if>

        <div class="grid">
            <!-- Detalles principales -->
            <div class="box">
                <div class="box-title"><i class="bi bi-geo-alt-fill"></i> Detalles principales</div>
                <div class="field">
                    <label>LUGAR DE VISITA</label>
                    <div class="value"><c:out value="${expediente.empresa}"/></div>
                </div>
                <div class="field">
                    <label>FECHA DE VISITA</label>
                    <div class="value"><c:out value="${expediente.fechaInicio}"/> a <c:out value="${expediente.fechaFin}"/></div>
                </div>
                <div class="field">
                    <label>CARRERA Y GRUPO</label>
                    <div class="value"><c:out value="${expediente.carrera}"/> · <c:out value="${expediente.semestre}"/> · Grupo <c:out value="${expediente.grupo}"/></div>
                </div>
                <div class="field">
                    <label>OBJETIVO</label>
                    <div class="value"><c:out value="${expediente.proposito}"/></div>
                </div>
            </div>

            <!-- Información de la empresa -->
            <div class="box">
                <div class="box-title"><i class="bi bi-building-fill"></i> Información de la empresa</div>
                <div class="field">
                    <label>NOMBRE DE LA EMPRESA</label>
                    <div class="value"><c:out value="${expediente.empresa}"/></div>
                </div>
                <div class="field">
                    <label>DIRECCIÓN</label>
                    <div class="value"><c:out value="${expediente.direccionEmpresa}"/></div>
                </div>
                <div class="field">
                    <label>TELÉFONO</label>
                    <div class="value"><c:out value="${expediente.telefonoEmpresa}"/></div>
                </div>
                <div class="field">
                    <label>CORREO ELECTRÓNICO</label>
                    <div class="value"><c:out value="${expediente.correoEmpresa}"/></div>
                </div>
            </div>

            <!-- Participantes y documentos -->
            <div class="box participants">
                <div class="box-title"><i class="bi bi-people-fill"></i> Participantes y documentos</div>

                <div class="participant-grid">
                    <div class="field">
                        <label>ÁREA SOLICITANTE</label>
                        <div class="value"><c:out value="${expediente.division}"/></div>
                    </div>
                    <div class="field">
                        <label>DOCENTE RESPONSABLE</label>
                        <div class="value"><c:out value="${expediente.docente}"/></div>
                    </div>
                    <div class="field">
                        <label>DOCENTES ACOMPAÑANTES</label>
                        <div class="value"><c:out value="${expediente.docenteAcompanante}"/></div>
                    </div>
                    <div class="field">
                        <label>ESTUDIANTES</label>
                        <div class="value"><c:out value="${expediente.numeroEstudiantes}"/> estudiantes</div>
                    </div>
                </div>

                <div class="actions-title">ACCIONES Y DOCUMENTACIÓN</div>

                <!-- Fila de acciones 1 -->
                <div class="action-grid">
                    <a class="action blue" href="${ctx}/subir-solicitud-firmada?id=${expediente.idVisita}">
                        <i class="bi bi-file-earmark-arrow-up"></i> Sol. c/firmas
                    </a>
                    <c:choose>
                        <c:when test="${cartaDescargada}">
                            <a class="action blue" href="${ctx}/subir-carta-firmada?id=${expediente.idVisita}">
                                <i class="bi bi-file-earmark-arrow-up"></i> Carta resp c/firmas
                            </a>
                        </c:when>
                        <c:otherwise>
                                <span class="action disabled" title="Descarga primero la carta responsiva">
                                    <i class="bi bi-lock"></i> Carta resp c/firmas
                                </span>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${cartaDescargada}">
                            <a class="action blue" href="${ctx}/oficio-autorizacion?id=${expediente.idVisita}">
                                <i class="bi bi-file-earmark-text"></i> Oficio de autorización
                            </a>
                        </c:when>
                        <c:otherwise>
                                <span class="action disabled" title="Descarga primero la carta responsiva">
                                    <i class="bi bi-lock"></i> Oficio de autorización
                                </span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Fila de acciones 2 -->
                <div class="action-grid">
                    <a class="action blue" href="${ctx}/solicitud-previa?id=${expediente.idVisita}">
                        <i class="bi bi-download"></i> Sol. s/firmas
                    </a>
                    <a class="action blue" href="${ctx}/carta-responsiva?id=${expediente.idVisita}">
                        <i class="bi bi-download"></i> Carta resp s/firmas
                    </a>
                    <a class="action blue" href="${ctx}/reporte-docente?id=${expediente.idVisita}">
                        <i class="bi bi-images"></i> Reporte
                    </a>
                </div>

                <!-- Estado de documentos -->
                <div class="action-grid">
                    <div class="doc-ok">
                        <c:if test="${not empty solicitudFirmada}">
                            Solicitud con firmas cargada: <c:out value="${solicitudFirmada.nombreArchivo}"/>
                        </c:if>
                    </div>
                    <div class="doc-ok">
                        <c:if test="${not empty cartaFirmada}">
                            Carta con firmas cargada: <c:out value="${cartaFirmada.nombreArchivo}"/>
                        </c:if>
                    </div>
                    <div></div>
                </div>
            </div>
        </div>

        <div class="footer">
            <a class="action orange" href="${ctx}/mis-solicitudes">
                <i class="bi bi-arrow-left"></i> Atrás
            </a>
        </div>
    </section>
</main>
</body>
</html>