<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes de mis visitas - AWGVA</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
        }

        .main-content {
            margin-left: 240px;
            padding: 30px;
            min-height: 100vh;
        }

        .page-header,
        .cards-section {
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, .1);
        }

        .page-header {
            padding: 20px 30px;
            margin-bottom: 25px;
        }

        .page-header h1 {
            margin: 0;
            color: #1e3a5f;
            font-size: 24px;
            font-weight: 700;
        }

        .cards-section {
            padding: 25px;
        }

        .section-title {
            margin-bottom: 18px;
            color: #1e3a5f;
            font-size: 18px;
            font-weight: 700;
        }

        .reports-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 320px));
            gap: 1.5rem;
        }

        .report-card-button {
            width: 100%;
            border: 0;
            background: transparent;
            padding: 0;
            text-align: left;
            color: inherit;
        }

        .report-card {
            border: 1px solid #d1d5db;
            border-radius: 12px;
            padding: 12px;
            background: #fff;
            box-shadow: 0 2px 8px rgba(0, 0, 0, .04);
            transition: transform .2s ease, box-shadow .2s ease;
        }

        .report-card-button:hover .report-card,
        .report-card-button:focus-visible .report-card {
            transform: translateY(-3px);
            box-shadow: 0 6px 16px rgba(0, 0, 0, .09);
        }

        .company-banner {
            width: 100%;
            height: 110px;
            background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%);
            border-radius: 8px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 12px;
            text-align: center;
        }

        .company-banner h2 {
            color: #fff;
            font-size: 1.1rem;
            font-weight: 800;
            margin: 0;
            text-transform: uppercase;
            word-break: break-word;
        }

        .card-company {
            color: #1e3a5f;
            font-weight: 700;
            font-size: .95rem;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .card-footer-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            margin-top: 8px;
        }

        .card-state {
            color: #94a3b8;
            font-size: .85rem;
            font-weight: 600;
        }

        .report-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            border-radius: 6px;
            padding: 6px 10px;
            font-size: .8rem;
            font-weight: 700;
            color: #fff;
            background: #198754;
            white-space: nowrap;
        }

        .report-badge.pending {
            background: #1e3a5f;
        }

        @media (max-width: 768px) {
            .main-content {
                margin-left: 0;
                padding: 15px;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/Layout/sidebar.jsp"/>

<main class="main-content">
    <div class="container-fluid">
        <header class="page-header">
            <h1>Reportes de mis visitas</h1>
        </header>

        <c:if test="${not empty error}">
            <div class="alert alert-warning mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>
                <c:out value="${error}"/>
            </div>
        </c:if>

        <section class="cards-section">
            <h2 class="section-title">Reportes de mis visitas</h2>

            <div class="reports-grid">
                <c:forEach var="sol" items="${solicitudes}">
                    <button type="button"
                            class="report-card-button"
                            data-post-url="${ctx}/reporte-docente"
                            data-post-ref="<c:out value='${sol.referenceToken}'/>">

                        <article class="report-card">
                            <div class="company-banner">
                                <h2><c:out value="${sol.empresa}"/></h2>
                            </div>

                            <div class="card-company">
                                <span>
                                    <c:out value="${sol.empresa}"/>,
                                    <c:out value="${sol.direccionEmpresa}"/>
                                </span>
                                <i class="bi bi-geo-alt-fill"></i>
                            </div>

                            <div class="card-footer-info">
                                <span class="card-state">
                                    <c:out value="${sol.estadoLegible}"/>
                                </span>

                                <c:choose>
                                    <c:when test="${empty sol.estadoReporte}">
                                        <span class="report-badge pending">
                                            <i class="bi bi-pencil-square"></i>
                                            Capturar reporte
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="report-badge">
                                            <i class="bi bi-file-earmark-check"></i>
                                            <c:out value="${sol.estadoReporte}"/>
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </article>
                    </button>
                </c:forEach>

                <c:if test="${empty solicitudes}">
                    <div class="alert alert-light border text-secondary fw-semibold p-3 text-center rounded-3"
                         style="grid-column: 1 / -1;">
                        <i class="bi bi-folder2-open me-2 text-muted"></i>
                        No tienes reportes habilitados. Una visita aparecerá aquí cuando la Carta Responsiva sea aceptada.
                    </div>
                </c:if>
            </div>
        </section>
    </div>
</main>

</body>
</html>
