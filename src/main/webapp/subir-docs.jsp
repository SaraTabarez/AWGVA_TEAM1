<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes de mis visitas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: #f5f5f5; margin: 0; padding: 0; }
        .main-content { margin-left: 250px; padding: 30px; min-height: 100vh; }
        .page-header { background: white; padding: 20px 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px; }
        .page-header h2 { margin: 0; color: #333; font-size: 24px; font-weight: 600; }

        .stepper { display: flex; justify-content: space-between; margin-bottom: 30px; padding: 20px; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .step { display: flex; flex-direction: column; align-items: center; flex: 1; position: relative; }
        .step:not(:last-child)::after { content: ''; position: absolute; top: 20px; left: 50%; width: 100%; height: 2px; background: #e0e0e0; }
        .step.completed:not(:last-child)::after { background: #ff6b35; }
        .step-circle { width: 40px; height: 40px; border-radius: 50%; background: #e0e0e0; display: flex; align-items: center; justify-content: center; font-weight: 600; color: #666; margin-bottom: 8px; z-index: 1; transition: all 0.3s ease; }
        .step.completed .step-circle { background: #ff6b35; color: white; }
        .step.active .step-circle { background: #ff6b35; color: white; box-shadow: 0 0 0 4px rgba(255, 107, 53, 0.2); }
        .step-label { font-size: 11px; text-align: center; color: #666; max-width: 80px; line-height: 1.2; }
        .step.completed .step-label { color: #ff6b35; font-weight: 500; }

        .cards-section { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px; }
        .company-banner { width: 100%; height: 110px; background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%); border-radius: 8px; margin-bottom: 12px; display: flex; align-items: center; justify-content: center; padding: 12px; text-align: center; }
        .company-banner h2 { color: #ffffff; font-size: 1.1rem; font-weight: 800; margin: 0; text-transform: uppercase; word-break: break-word; }

        .upload-section { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px; }
        .section-title { font-size: 18px; font-weight: 600; color: #333; margin-bottom: 10px; }
        .section-subtitle { font-size: 14px; color: #666; margin-bottom: 20px; }
        .upload-area { border: 2px dashed #d0d0d0; border-radius: 8px; padding: 40px; text-align: center; background-color: #fafafa; cursor: pointer; transition: all 0.3s ease; }
        .upload-area:hover { background-color: #f0f0f0; border-color: #ff6b35; }
        .upload-area i { font-size: 48px; color: #ff6b35; margin-bottom: 15px; }
        .upload-area h4 { font-size: 16px; color: #333; margin-bottom: 8px; }
        .upload-area p { font-size: 13px; color: #999; margin-bottom: 5px; }
        .upload-info { display: flex; justify-content: space-between; margin-top: 15px; font-size: 13px; color: #666; }

        .documents-table { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .table { margin-bottom: 0; }
        .table thead th { background-color: #1e3a5f; color: #ffffff; font-weight: 600; font-size: 13px; padding: 12px 15px; border: none; }
        .table tbody td { padding: 12px 15px; font-size: 13px; color: #333; vertical-align: middle; background-color: #f8f9fa; }
        .badge-draft { background-color: #1e3a5f; color: #ffffff; padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 500; }

        /* Ajuste para que los botones y links se vean igual */
        .action-btn {
            background: none;
            border: none;
            color: #333;
            padding: 5px 8px;
            cursor: pointer;
            transition: color 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .action-btn:hover { color: #ff6b35; }

        .navigation-buttons { display: flex; justify-content: space-between; margin-top: 25px; }
        .btn-custom { padding: 10px 35px; border-radius: 6px; font-weight: 600; transition: all 0.3s ease; text-decoration: none; display: inline-flex; align-items: center; }
        .btn-orange { background-color: #ff6b35; border-color: #ff6b35; color: white; }
        .btn-orange:hover { background-color: #e55a2b; border-color: #e55a2b; color: white; }
        .btn-primary-custom { background-color: #ff6b35; border-color: #ff6b35; color: white; border: none; }
        .btn-primary-custom:hover { background-color: #e55a2b; border-color: #e55a2b; color: white; }

        @media (max-width: 768px) {
            .main-content { margin-left: 0; padding: 15px; }
            .stepper { flex-wrap: wrap; }
            .step { min-width: 50%; margin-bottom: 20px; }
        }
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>

<div class="main-content">
    <div class="container-fluid">
        <div class="page-header">
            <h2>Reportes de mis visitas</h2>
        </div>

        <!-- Se conserva la tarjeta original; se eliminan el stepper, la carga genérica,
             la tabla de documentos y sus botones, tal como se solicitó. -->
        <div class="cards-section">
            <h3 class="section-title mb-3">Reportes de mis visitas</h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 320px)); gap: 1.5rem;">
                <c:forEach var="sol" items="${solicitudes}">
                    <button type="button" data-post-url="${pageContext.request.contextPath}/reporte-docente" data-post-ref="<c:out value='${sol.referenceToken}'/>" style="border:0;background:transparent;padding:0;text-align:left;color:inherit;width:100%;">
                        <div style="border: 1px solid #d1d5db; border-radius: 12px; padding: 12px; background-color: #ffffff; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);">
                            <div class="company-banner">
                                <h2><c:out value="${sol.empresa}"/></h2>
                            </div>
                            <div style="color: #1e3a5f; font-weight: 700; font-size: 0.95rem; margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between;">
                                <span><c:out value="${sol.empresa}"/>, <c:out value="${sol.direccionEmpresa}"/></span>
                                <i class="fa-solid fa-location-dot" style="color: #1e3a5f;"></i>
                            </div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 8px;">
                                <span style="color: #94a3b8; font-size: 0.85rem; font-weight: 600;"><c:out value="${sol.estadoLegible}"/></span>
                                <span class="badge ${empty sol.estadoReporte ? 'bg-secondary' : 'bg-success'}" style="font-size: 0.8rem; padding: 6px 10px;">
                            <i class="fa-solid fa-file-lines me-1"></i>
                            <c:out value="${empty sol.estadoReporte ? 'Capturar reporte' : sol.estadoReporte}"/>
                        </span>
                            </div>
                        </div>
                    </button>
                </c:forEach>
                <c:if test="${empty solicitudes}">
                    <div style="grid-column: 1 / -1;" class="alert alert-light border text-secondary fw-semibold p-3 text-center rounded-3">
                        <i class="fa-solid fa-folder-open me-2 text-muted"></i>Aún no has enviado reportes. Cuando envíes uno, la tarjeta aparecerá aquí hasta que Estadías lo acepte.
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>
</body>
</html>
