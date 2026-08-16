<%--
  Created by IntelliJ IDEA.
  User: pc
  Date: 27/07/2026
  Time: 06:06 a. m.
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio de sesión - AWGVA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #ffffff;
            overflow-x: hidden;
        }

        .full-screen-container {
            min-height: 100vh;
            width: 100vw;
        }

        /* Lateral Izquierdo */
        .bg-sidebar {
            background-color: #1e3a5f;
            color: #ffffff;
            padding: 4rem 3.5rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .brand-orange {
            color: #f38218;
        }

        .brand-icon-bg {
            background-color: #f38218;
            color: #ffffff;
            width: 28px;
            height: 28px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
        }

        .feature-item {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.95rem;
            font-weight: 600;
        }

        .feature-item i {
            color: #f38218;
            font-size: 1.1rem;
        }

        /* Formulario Derecho */
        .login-section {
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .login-wrapper {
            width: 100%;
            max-width: 460px;
        }

        .form-label-custom {
            font-size: 0.78rem;
            font-weight: 700;
            color: #1e3a5f;
            letter-spacing: 0.5px;
            margin-bottom: 0.4rem;
        }

        /* Custom Inputs estilo pill translúcido */
        .custom-input-group {
            background-color: #e2e8f0;
            border-radius: 6px;
            display: flex;
            align-items: center;
            padding: 0.4rem 0.8rem;
            border: 1px solid transparent;
            transition: all 0.2s ease-in-out;
        }

        .custom-input-group:focus-within {
            background-color: #ffffff;
            border-color: #f38218;
            box-shadow: 0 0 0 0.25rem rgba(243, 130, 24, 0.15);
        }

        .custom-input-group i {
            color: #8a99ad;
            font-size: 1.1rem;
            margin-right: 0.6rem;
        }

        .custom-input-group input {
            background: transparent;
            border: none;
            outline: none;
            width: 100%;
            color: #333333;
            font-size: 0.95rem;
        }

        .custom-input-group input::placeholder {
            color: #94a3b8;
        }

        .btn-toggle-eye {
            background: none;
            border: none;
            padding: 0;
            color: #8a99ad;
            cursor: pointer;
            display: flex;
            align-items: center;
        }

        .btn-toggle-eye:hover {
            color: #1e3a5f;
        }

        /* Botón Ingresar */
        .btn-brand-dark {
            background-color: #1e3a5f;
            color: #ffffff;
            border: none;
            border-radius: 6px;
            padding: 0.65rem;
            font-weight: 500;
            font-size: 0.95rem;
            transition: background-color 0.2s;
        }

        .btn-brand-dark:hover {
            background-color: #152943;
            color: #ffffff;
        }

        .forgot-link {
            color: #334155;
            font-size: 0.88rem;
            text-decoration: none;
            font-weight: 500;
        }

        .forgot-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="container-fluid p-0">
    <div class="row g-0 full-screen-container">

        <!-- Sección Izquierda (Sidebar Azul) -->
        <div class="col-lg-4 col-md-5 bg-sidebar">
            <div>
                <!-- Logo -->
                <div class="d-flex align-items-center gap-2 mb-5">
                    <div class="brand-icon-bg">
                        <i class="bi bi-mortarboard-fill"></i>
                    </div>
                    <span class="fw-bold fs-6 tracking-wide text-white">AWGVA</span>
                </div>

                <!-- Título -->
                <h2 class="fw-bold lh-sm mb-5 fs-3" style="margin-top: 5rem;">
                    Sistema de Gestión de <br>
                    <span class="brand-orange">Visitas Académicas</span>
                </h2>

                <!-- Lista de características -->
                <div class="d-flex flex-column gap-3 mt-4">
                    <div class="feature-item">
                        <i class="bi bi-shield-check"></i>
                        <span>Acceso seguro.</span>
                    </div>
                    <div class="feature-item">
                        <i class="bi bi-people"></i>
                        <span>Gestión de usuarios.</span>
                    </div>
                    <div class="feature-item">
                        <i class="bi bi-file-earmark-text"></i>
                        <span>Formatos de visitas académicas.</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Sección Derecha (Formulario Blanco) -->
        <div class="col-lg-8 col-md-7 login-section">
            <div class="login-wrapper">

                <span class="text-uppercase fw-bold brand-orange" style="font-size: 0.8rem; letter-spacing: 0.5px;">BIENVENIDO</span>
                <h1 class="fw-bold text-dark mb-1 fs-2" style="color: #1e3a5f !important;">Iniciar Sesión</h1>
                <p class="text-secondary mb-4" style="font-size: 0.9rem;">Ingresa tus credenciales.</p>

                <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger py-2 mb-3" role="alert" style="font-size: 0.85rem;">
                    <i class="bi bi-exclamation-circle me-1"></i> <%= request.getAttribute("error") %>
                </div>
                <% } %>

                <% if ("updated".equals(request.getParameter("password"))) { %>
                <div class="alert alert-success py-2 mb-3" role="alert" style="font-size: 0.85rem;">
                    Contraseña actualizada. Ya puedes iniciar sesión.
                </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/login" method="POST" id="loginForm">
                    <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>">

                    <!-- Campo Correo / Matrícula -->
                    <div class="mb-3">
                        <label class="form-label-custom d-block">CORREO ELECTRÓNICO/MATRÍCULA:</label>
                        <div class="custom-input-group">
                            <i class="bi bi-envelope"></i>
                            <input type="email" id="correoInput" name="correo" maxlength="160" placeholder="usuario@utez.edu.mx" pattern="[A-Za-z0-9._%+-]+@utez[.]edu[.]mx" title="Utiliza un correo institucional @utez.edu.mx" required>
                        </div>
                    </div>

                    <!-- Campo Contraseña -->
                    <div class="mb-4">
                        <label class="form-label-custom d-block">CONTRASEÑA:</label>
                        <div class="custom-input-group">
                            <i class="bi bi-lock"></i>
                            <input type="password" id="passwordInput" name="password" maxlength="200" placeholder="********" required>
                            <button class="btn-toggle-eye" type="button" id="togglePassword">
                                <i class="bi bi-eye-slash" id="toggleIcon" style="margin-right: 0;"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Botón Ingresar -->
                    <button type="submit" class="btn btn-brand-dark w-100 mb-4">Ingresar</button>

                    <!-- Enlace Olvidaste tu contraseña -->
                    <div class="text-end">
                        <button type="button" class="forgot-link border-0 bg-transparent p-0" id="forgotPassword">¿Olvidaste tu contraseña?</button>
                    </div>
                </form>
                <form action="<%= request.getContextPath() %>/reset-password" method="post" id="recoveryForm" class="d-none">
                    <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>">
                    <input type="hidden" name="action" value="solicitar">
                    <input type="hidden" name="correo" id="recoveryEmail">
                </form>

            </div>
        </div>

    </div>
</div>

<script>
    const togglePassword = document.querySelector('#togglePassword');
    const password = document.querySelector('#passwordInput');
    const toggleIcon = document.querySelector('#toggleIcon');

    togglePassword.addEventListener('click', function () {
        const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
        password.setAttribute('type', type);
        toggleIcon.classList.toggle('bi-eye');
        toggleIcon.classList.toggle('bi-eye-slash');
    });

    const correoInput = document.querySelector('#correoInput');
    const forgotPassword = document.querySelector('#forgotPassword');
    const recoveryForm = document.querySelector('#recoveryForm');
    const recoveryEmail = document.querySelector('#recoveryEmail');

    forgotPassword.addEventListener('click', function () {
        if (!correoInput.checkValidity()) {
            correoInput.reportValidity();
            correoInput.focus();
            return;
        }
        recoveryEmail.value = correoInput.value.trim().toLowerCase();
        recoveryForm.submit();
    });
</script>

</body>
</html>