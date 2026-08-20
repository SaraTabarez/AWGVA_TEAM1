<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Solicitud firmada enviada - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        *{box-sizing:border-box}body{margin:0;background:#a9bbcf;font-family:"Segoe UI",Arial,sans-serif;color:#111}.screen{min-height:100vh;margin:8px 18px;background:#fff;display:grid;place-items:center;text-align:center;padding:30px}.icon{font-size:4.8rem;color:#55c993;line-height:1}.title{font-size:.95rem;font-weight:900;margin:15px 0 18px}.text{font-size:.82rem;font-weight:650;color:#5e6369;line-height:1.55}.btn{margin-top:28px;display:inline-block;border:0;background:#55c993;color:#fff;border-radius:6px;padding:11px 30px;font-weight:800;font-size:.8rem;cursor:pointer}
    </style>
</head>
<body>
<main class="screen">
    <div>
        <div class="icon"><i class="bi bi-check-square"></i></div>
        <div class="title">SOLICITUD FIRMADA ENVIADA CORRECTAMENTE</div>
        <div class="text">Solicitud de visita firmada enviada. Espere confirmación por parte del departamento correspondiente;<br>se le notificará cuando sea aceptada o rechazada.</div>
        <form method="post" action="${ctx}/detalle-solicitud">
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <input type="hidden" name="ref" value="<c:out value='${referenceToken}'/>">
            <button class="btn" type="submit">Entendido</button>
        </form>
    </div>
</main>
</body>
</html>
