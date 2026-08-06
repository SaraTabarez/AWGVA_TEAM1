<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Recuperar contraseña - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background: #f4f6f9; min-height: 100vh; }
        .recovery-card { max-width: 540px; border: 0; border-radius: 14px; }
        .btn-awgva { background: #f38218; color: #fff; border: 0; }
        .btn-awgva:hover { background: #d9700f; color: #fff; }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center p-4">
<main class="card recovery-card shadow-sm w-100 p-4 p-md-5">
    <div class="text-center mb-4">
        <i class="bi bi-shield-lock fs-1" style="color:#1e3a5f"></i>
        <h1 class="h3 fw-bold mt-2">Recuperar contraseña</h1>
        <p class="text-secondary mb-0">El código tiene una vigencia de 15 minutos.</p>
    </div>

    <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
    <c:if test="${not empty mensaje}"><div class="alert alert-info"><c:out value="${mensaje}"/></div></c:if>

    <c:choose>
        <c:when test="${step == 'restablecer'}">
            <form action="${ctx}/reset-password" method="post">
                <input type="hidden" name="action" value="restablecer">
                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                <div class="mb-3"><label class="form-label fw-semibold" for="codigo">Código de 8 dígitos</label><input class="form-control" id="codigo" name="codigo" inputmode="numeric" pattern="[0-9]{8}" maxlength="8" required></div>
                <div class="mb-3"><label class="form-label fw-semibold" for="nuevaPassword">Nueva contraseña</label><input class="form-control" type="password" id="nuevaPassword" name="nuevaPassword" minlength="10" maxlength="200" required><div class="form-text">Mayúscula, minúscula, número y símbolo.</div></div>
                <div class="mb-4"><label class="form-label fw-semibold" for="confirmarPassword">Confirmar contraseña</label><input class="form-control" type="password" id="confirmarPassword" name="confirmarPassword" minlength="10" maxlength="200" required></div>
                <button class="btn btn-awgva w-100" type="submit">Actualizar contraseña</button>
            </form>
        </c:when>
        <c:otherwise>
            <form action="${ctx}/reset-password" method="post">
                <input type="hidden" name="action" value="solicitar">
                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                <div class="mb-4"><label class="form-label fw-semibold" for="correo">Correo institucional</label><input class="form-control" type="email" id="correo" name="correo" maxlength="160" placeholder="nombre@utez.edu.mx" required></div>
                <button class="btn btn-awgva w-100" type="submit">Enviar código</button>
            </form>
        </c:otherwise>
    </c:choose>
    <a class="text-center mt-3" href="${ctx}/login.jsp">Volver al inicio de sesión</a>
</main>
</body>
</html>
