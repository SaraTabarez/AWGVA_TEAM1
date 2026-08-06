<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Acceso denegado - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100">
<main class="card border-0 shadow-sm p-5 text-center" style="max-width: 560px;">
    <div class="display-5 fw-bold text-danger">403</div>
    <h1 class="h3 mt-2">No tienes permiso para entrar aquí</h1>
    <p class="text-secondary">Tu sesión es válida, pero esta función pertenece a otro rol.</p>
    <a class="btn btn-dark" href="${pageContext.request.contextPath}/inicio">Volver a mi inicio</a>
</main>
</body>
</html>
