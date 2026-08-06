<%--
  Created by IntelliJ IDEA.
  User: pc
  Date: 03/08/2026
  Time: 06:05 a. m.
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    .sidebar {
        width: 240px;
        background-color: #1e3a5f;
        color: #ffffff;
        padding: 40px 24px 30px 24px;
        height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        z-index: 1000;
        margin: 0;
        box-sizing: border-box;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    /* Perfil de Usuario */
    .sidebar .user-profile {
        text-align: center;
        margin-bottom: 45px;
    }
    .sidebar .user-profile .avatar {
        width: 85px;
        height: 85px;
        background-color: #d1d5db;
        color: #4b5563;
        border-radius: 50%;
        margin: 0 auto 16px auto;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 48px;
    }
    .sidebar .user-profile .username {
        font-weight: 700;
        font-size: 1rem;
        letter-spacing: 0.8px;
        color: #ffffff;
    }

    /* Navegación */
    .sidebar nav ul {
        list-style: none;
        padding: 0;
        margin: 0;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .sidebar nav ul li a {
        color: #ffffff;
        text-decoration: none;
        display: flex;
        align-items: center;
        padding: 8px 12px;
        border-radius: 6px;
        font-weight: 700;
        font-size: 0.95rem;
        transition: background-color 0.2s ease, opacity 0.2s ease;
    }
    .sidebar nav ul li a i {
        margin-right: 14px;
        font-size: 1.25rem;
        width: 22px;
        text-align: center;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }

    /* Estados Hover y Activo */
    .sidebar nav ul li a:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }
    .sidebar nav ul li a.active {
        background-color: rgba(255, 255, 255, 0.15);
    }

    /* Cerrar Sesión */
    .sidebar .logout {
        margin-top: auto;
    }
    .sidebar .logout a {
        color: #ffffff;
        text-decoration: none;
        display: flex;
        align-items: center;
        padding: 8px 12px;
        border-radius: 6px;
        font-weight: 700;
        font-size: 0.95rem;
        transition: background-color 0.2s ease;
    }
    .sidebar .logout a:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }
    .sidebar .logout a i {
        margin-right: 14px;
        font-size: 1.25rem;
        width: 22px;
        text-align: center;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }
</style>

<div class="sidebar">
    <div>
        <div class="user-profile">
            <div class="avatar">
                <i class="bi bi-person"></i>
            </div>
            <div class="username">DIRECTOR</div>
        </div>
        <nav>
            <ul>
                <li>
                    <a href="index.jsp" class="${pageContext.request.requestURI.endsWith('index.jsp') ? 'active' : ''}">
                        <i class="bi bi-house"></i>
                        <span>Inicio</span>
                    </a>
                </li>
                <li>
                    <a href="solicitud.jsp" class="${pageContext.request.requestURI.endsWith('solicitud.jsp') ? 'active' : ''}">
                        <i class="bi bi-file-earmark-text"></i>
                        <span>Solicitud</span>
                    </a>
                </li>
                <li>
                    <a href="subir-docs.jsp" class="${pageContext.request.requestURI.endsWith('subir-docs.jsp') ? 'active' : ''}">
                        <i class="bi bi-file-earmark-bar-graph"></i>
                        <span>Reporte</span>
                    </a>
                </li>
                <li>
                    <a href="historico-docente.jsp" class="${pageContext.request.requestURI.endsWith('historico-docente.jsp') ? 'active' : ''}">
                        <i class="bi bi-clock-history"></i>
                        <span>Histórico</span>
                    </a>
                </li>
            </ul>
        </nav>
    </div>
    <div class="logout">
        <a href="logout">
            <i class="bi bi-box-arrow-right"></i>
            <span>Cerrar sesión</span>
        </a>
    </div>
</div>
