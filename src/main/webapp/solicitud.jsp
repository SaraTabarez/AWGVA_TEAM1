<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitudes - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #ffffff;
            min-height: 100vh;
        }
        .main-layout {
            margin-left: 240px;
            padding: 2.5rem 4rem;
            min-height: 100vh;
            background-color: #ffffff;
        }
        .top-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2.5rem;
        }
        .page-title { color: #1e3a5f; font-size: 2rem; font-weight: 800; margin: 0; }
        .page-subtitle { color: #f38218; font-size: 1.1rem; font-weight: 700; margin-top: 0.2rem; }

        .btn-new-request {
            background-color: #f38218; color: #ffffff; border: none; border-radius: 8px;
            padding: 0.65rem 1.6rem; font-weight: 700; font-size: 0.95rem; text-decoration: none;
            display: inline-flex; align-items: center; gap: 8px;
            box-shadow: 0 3px 6px rgba(243, 130, 24, 0.25); transition: all 0.2s ease;
        }
        .btn-new-request:hover { background-color: #d9700f; color: #ffffff; transform: translateY(-1px); }

        .requests-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 320px));
            gap: 2rem;
        }
        .request-card {
            border: 1px solid #d1d5db; border-radius: 12px; padding: 12px;
            background-color: #ffffff; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .request-card:hover { transform: translateY(-3px); box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08); }

        .company-banner {
            width: 100%; height: 130px;
            background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%);
            border-radius: 8px; margin-bottom: 12px; display: flex;
            align-items: center; justify-content: center; padding: 12px; text-align: center;
        }
        .company-banner h2 { color: #ffffff; font-size: 1.2rem; font-weight: 800; margin: 0; text-transform: uppercase; word-break: break-word; }
        .request-card .card-company {
            color: #1e3a5f; font-weight: 700; font-size: 0.95rem;
            display: flex; align-items: center; gap: 6px; margin-bottom: 12px; min-height: 24px;
        }
        .request-card .card-footer-info { display: flex; justify-content: space-between; align-items: center; margin-top: 8px; }
        .request-card .card-id { color: #94a3b8; font-size: 0.85rem; font-weight: 600; }

        .btn-details {
            border: 1px solid #f38218; color: #f38218; background-color: transparent;
            border-radius: 6px; padding: 0.35rem 1.2rem; font-size: 0.85rem;
            font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s ease;
        }
        .btn-details:hover { background-color: #f38218; color: #ffffff; }
    </style>
</head>
<body>

<jsp:include page="Layout/sidebar.jsp"/>

<main class="main-layout">

    <div class="top-header">
        <div>
            <h1 class="page-title">Solicitudes</h1>
            <div class="page-subtitle">Solicitudes activas sin reporte enviado</div>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/nueva-solicitud" class="btn-new-request">
                <i class="bi bi-plus-circle"></i> Nueva solicitud
            </a>
        </div>
    </div>

    <div class="requests-grid">
        <c:forEach var="sol" items="${solicitudes}">
            <div class="request-card">
                <div class="company-banner">
                    <h2><c:out value="${sol.empresa}"/></h2>
                </div>

                <div class="card-company">
                    <span><c:out value="${sol.empresa}"/>, <c:out value="${sol.direccionEmpresa}"/></span>
                    <i class="bi bi-geo-alt" style="font-size: 0.95rem; color: #1e3a5f;"></i>
                </div>

                <div class="card-footer-info">
                    <span class="card-id"><c:out value="${sol.estadoLegible}"/></span>
                    <button type="button" data-post-url="${pageContext.request.contextPath}/detalle-solicitud" data-post-ref="<c:out value='${sol.referenceToken}'/>" class="btn-details">
                        <i class="bi bi-eye"></i> Detalles
                    </button>
                </div>
            </div>
        </c:forEach>
        <c:if test="${empty solicitudes}">
            <div style="grid-column: 1 / -1;" class="alert alert-light border text-secondary fw-semibold p-4 text-center rounded-3">
                <i class="bi bi-inbox fs-3 d-block mb-2 text-muted"></i>
                No tienes solicitudes activas. Las solicitudes con reporte enviado se encuentran en el apartado Reportes.
            </div>
        </c:if>
    </div>

</main>

</body>
</html>
