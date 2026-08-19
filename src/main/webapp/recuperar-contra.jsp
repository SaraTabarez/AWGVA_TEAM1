<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Recuperar contraseña - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root{--navy:#1f3b5f;--orange:#ff9418;--soft:#e4edf6}body{min-height:100vh;background:#f4f7fa;color:var(--navy)}.shell{min-height:100vh}.card-reset{max-width:620px;border:1px solid #b7c7d8;border-radius:14px;box-shadow:0 8px 22px rgba(31,59,95,.09)}.code-input{width:58px;height:58px;text-align:center;font-size:1.45rem;font-weight:700;border:1px solid #9baabc}.btn-navy{background:var(--navy);color:#fff}.btn-orange{background:var(--orange);color:#fff}.btn-navy:hover,.btn-orange:hover{filter:brightness(.92);color:#fff}.email-box{background:var(--soft);border-radius:6px;padding:12px;font-weight:700}.form-control{min-height:48px;background:var(--soft);border-color:transparent}.form-control:focus{background:#fff;border-color:var(--orange);box-shadow:0 0 0 .2rem rgba(255,148,24,.15)}.password-wrap{position:relative}.password-wrap .form-control{padding-right:48px}.eye-btn{position:absolute;right:7px;top:50%;transform:translateY(-50%);border:0;background:transparent;color:var(--navy);z-index:3}
    </style>
</head>
<body>
<main class="container-fluid shell d-flex align-items-center justify-content-center p-4">
    <div class="row w-100 justify-content-center">
        <div class="col-12 col-md-10 col-lg-7 col-xl-6">
            <h1 class="h3 text-center fw-bold mb-4">
                <c:choose><c:when test="${step == 'cambiar'}">Cambiar contraseña</c:when><c:otherwise>Enviar código de seguridad</c:otherwise></c:choose>
            </h1>
            <section class="card card-reset mx-auto p-4 p-md-5">
                <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
                <c:if test="${not empty mensaje}"><div class="alert alert-info"><c:out value="${mensaje}"/></div></c:if>

                <c:choose>
                    <c:when test="${step == 'codigo'}">
                        <h2 class="h5 text-center fw-bold mb-3">Se envió un código al correo:</h2>
                        <div class="email-box text-center mb-4"><c:out value="${correoRecuperacion}"/></div>
                        <form action="${ctx}/reset-password" method="post" id="code-form">
                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                            <input type="hidden" name="action" value="validar">
                            <input type="hidden" name="codigo" id="codigo">
                            <div class="d-flex flex-wrap justify-content-center gap-2 mb-4" id="code-boxes">
                                <input class="code-input" inputmode="numeric" maxlength="1" aria-label="Dígito 1" required>
                                <input class="code-input" inputmode="numeric" maxlength="1" aria-label="Dígito 2" required>
                                <input class="code-input" inputmode="numeric" maxlength="1" aria-label="Dígito 3" required>
                                <input class="code-input" inputmode="numeric" maxlength="1" aria-label="Dígito 4" required>
                                <input class="code-input" inputmode="numeric" maxlength="1" aria-label="Dígito 5" required>
                                <input class="code-input" inputmode="numeric" maxlength="1" aria-label="Dígito 6" required>
                            </div>
                            <div class="row g-2">
                                <div class="col-12 col-md-6"><button class="btn btn-navy w-100" type="submit" name="action" value="cancelar" formnovalidate>Regresar</button></div>
                                <div class="col-12 col-md-6"><button class="btn btn-orange w-100" type="submit"><i class="bi bi-shield-check me-2"></i>Confirmar código</button></div>
                            </div>
                        </form>
                        <form action="${ctx}/reset-password" method="post" class="text-center mt-3">
                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                            <input type="hidden" name="action" value="reenviar">
                            <button class="btn btn-link" type="submit">Reenviar código</button>
                        </form>
                    </c:when>

                    <c:when test="${step == 'cambiar'}">
                        <h2 class="h5 text-center fw-bold mb-4">Modifica tu nueva contraseña</h2>
                        <form action="${ctx}/reset-password" method="post" id="password-form">
                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                            <input type="hidden" name="action" value="cambiar">
                            <div class="mb-3"><label class="form-label fw-bold" for="nuevaPassword">Nueva contraseña</label><div class="password-wrap"><input class="form-control" type="password" id="nuevaPassword" name="nuevaPassword" minlength="10" maxlength="200" pattern="(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{10,200}" title="Mínimo 10 caracteres con mayúscula, minúscula, número y símbolo." autocomplete="new-password" required><button class="eye-btn" type="button" data-eye-target="nuevaPassword" aria-label="Mostrar u ocultar nueva contraseña"><i class="bi bi-eye-slash"></i></button></div><div class="form-text">Mínimo 10 caracteres con mayúscula, minúscula, número y símbolo.</div></div>
                            <div class="mb-4"><label class="form-label fw-bold" for="confirmarPassword">Confirmar contraseña</label><div class="password-wrap"><input class="form-control" type="password" id="confirmarPassword" name="confirmarPassword" minlength="10" maxlength="200" pattern="(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{10,200}" title="Mínimo 10 caracteres con mayúscula, minúscula, número y símbolo." autocomplete="new-password" required><button class="eye-btn" type="button" data-eye-target="confirmarPassword" aria-label="Mostrar u ocultar confirmación"><i class="bi bi-eye-slash"></i></button></div></div>
                            <div class="text-end"><button class="btn btn-orange px-4" type="submit">Cambiar contraseña</button></div>
                        </form>
                    </c:when>

                    <c:otherwise>
                        <div class="text-center"><i class="bi bi-person-x display-4 text-warning"></i><h2 class="h5 fw-bold mt-3">Cuenta no localizada</h2><p class="text-secondary">Revisa el mensaje mostrado o comunícate con Administración para dar de alta o reactivar tu cuenta.</p>
                            <form action="${ctx}/reset-password" method="post"><input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>"><input type="hidden" name="action" value="cancelar"><button class="btn btn-navy px-4" type="submit">Volver al inicio</button></form>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
    </div>
</main>
<script>
    const codeForm=document.getElementById('code-form');
    if(codeForm){const boxes=Array.from(document.querySelectorAll('.code-input'));boxes.forEach((box,index)=>{box.addEventListener('input',()=>{box.value=box.value.replace(/\D/g,'').slice(0,1);if(box.value&&index<boxes.length-1)boxes[index+1].focus()});box.addEventListener('keydown',event=>{if(event.key==='Backspace'&&!box.value&&index>0)boxes[index-1].focus()});box.addEventListener('paste',event=>{event.preventDefault();const digits=event.clipboardData.getData('text').replace(/\D/g,'').slice(0,6);digits.split('').forEach((digit,i)=>{if(boxes[i])boxes[i].value=digit})})});codeForm.addEventListener('submit',event=>{const submitter=event.submitter;if(submitter&&submitter.value==='cancelar')return;const code=boxes.map(box=>box.value).join('');if(!/^\d{6}$/.test(code)){event.preventDefault();boxes.find(box=>!box.value)?.focus();return}document.getElementById('codigo').value=code})}
    document.querySelectorAll('[data-eye-target]').forEach(button=>button.addEventListener('click',()=>{const input=document.getElementById(button.dataset.eyeTarget);const icon=button.querySelector('i');const show=input.type==='password';input.type=show?'text':'password';icon.classList.toggle('bi-eye',show);icon.classList.toggle('bi-eye-slash',!show)}));
    const passwordForm=document.getElementById('password-form');if(passwordForm){passwordForm.addEventListener('submit',event=>{const a=document.getElementById('nuevaPassword');const b=document.getElementById('confirmarPassword');if(a.value!==b.value){event.preventDefault();b.setCustomValidity('Las contraseñas no coinciden.');b.reportValidity()}else{b.setCustomValidity('')}});document.getElementById('confirmarPassword').addEventListener('input',event=>event.target.setCustomValidity(''))}
</script>
</body>
</html>
