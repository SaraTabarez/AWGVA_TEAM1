<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="sidebarNombre" value="${not empty sessionScope.nombreUsuario ? sessionScope.nombreUsuario : sessionScope.usuario.nombreCompleto}"/>
<c:set var="sidebarRol" value="${not empty sessionScope.rol ? sessionScope.rol : sessionScope.usuario.nombreRol}"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
    .sidebar {
        width: 240px;
        background-color: #1e3a5f;
        color: #ffffff;
        padding: 32px 20px 24px;
        height: 100vh;
        position: fixed;
        inset: 0 auto 0 0;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        z-index: 1000;
        box-sizing: border-box;
        overflow-y: auto;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    .sidebar .user-profile { text-align: center; margin-bottom: 32px; }
    .sidebar .avatar {
        width: 76px; height: 76px; margin: 0 auto 14px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        background: #dbe4ee; color: #1e3a5f; font-size: 38px;
    }
    .sidebar .user-name { font-weight: 700; font-size: .92rem; line-height: 1.25; }
    .sidebar .user-role { color: #ffad5c; font-size: .76rem; font-weight: 800; letter-spacing: 1px; margin-top: 5px; }
    .sidebar ul { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 7px; }
    .sidebar .nav-link-role, .sidebar .logout-button {
        width: 100%; border: 0; color: #fff; background: transparent; text-decoration: none;
        display: flex; align-items: center; gap: 12px; padding: 10px 12px;
        border-radius: 7px; font-weight: 650; font-size: .91rem; text-align: left;
    }
    .sidebar .nav-link-role:hover, .sidebar .nav-link-role.active, .sidebar .logout-button:hover {
        background: rgba(255, 255, 255, .14); color: #fff;
    }
    .sidebar .nav-link-role i, .sidebar .logout-button i { width: 22px; text-align: center; font-size: 1.12rem; }
    .sidebar .menu-section {
        margin: 14px 12px 4px;
        color: #9fb0c7;
        font-size: .66rem;
        font-weight: 800;
        letter-spacing: .09em;
        text-transform: uppercase;
    }
    .sidebar .logout-form { margin: 18px 0 0; }
    .sidebar .logout-button { cursor: pointer; }
    @media (max-width: 768px) {
        .sidebar { position: static; width: 100%; height: auto; padding: 18px; }
        .sidebar .user-profile { margin-bottom: 16px; }
        .sidebar .avatar { width: 58px; height: 58px; font-size: 28px; }
    }
</style>
<meta name="context-path" content="${pageContext.request.contextPath}">

<aside class="sidebar" aria-label="Navegación principal">
    <div>
        <div class="user-profile">
            <div class="avatar" aria-hidden="true">
                <svg width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" focusable="false" aria-hidden="true">
                    <path d="M20 21a8 8 0 0 0-16 0"/>
                    <circle cx="12" cy="7" r="4"/>
                </svg>
            </div>
            <div class="user-name"><c:out value="${sidebarNombre}"/></div>
            <div class="user-role"><c:out value="${sidebarRol}"/></div>
        </div>

        <nav>
            <ul>
                <c:if test="${sessionScope.rol != 'ESTADIAS'}">
                    <li>
                        <a href="${ctx}/inicio" class="nav-link-role ${fn:endsWith(currentPath, '/inicio') ? 'active' : ''}">
                            <i class="bi bi-house-door"></i><span>Inicio</span>
                        </a>
                    </li>
                </c:if>

                <c:choose>
                    <c:when test="${sessionScope.rol == 'DOCENTE'}">
                        <li><a href="${ctx}/mis-solicitudes" class="nav-link-role ${fn:contains(currentPath, 'solicitud') ? 'active' : ''}"><i class="bi bi-file-earmark-text"></i><span>Solicitudes</span></a></li>
                        <li><a href="${ctx}/reportes-docente" class="nav-link-role ${fn:contains(currentPath, 'reporte') ? 'active' : ''}"><i class="bi bi-cloud-arrow-up"></i><span>Reportes</span></a></li>
                        <li><a href="${ctx}/historico-docente" class="nav-link-role ${fn:contains(currentPath, 'historico') ? 'active' : ''}"><i class="bi bi-clock-history"></i><span>Histórico</span></a></li>
                    </c:when>

                    <c:when test="${sessionScope.rol == 'DIRECTOR'}">
                        <li><a href="${ctx}/director/solicitudes" class="nav-link-role ${fn:contains(currentPath, '/director/solicitudes') ? 'active' : ''}"><i class="bi bi-clipboard-check"></i><span>Solicitudes</span></a></li>
                        <li><a href="${ctx}/director/historico" class="nav-link-role ${fn:contains(currentPath, '/director/historico') ? 'active' : ''}"><i class="bi bi-clock-history"></i><span>Histórico</span></a></li>
                        <li><a href="${ctx}/cambiar-contrasena" class="nav-link-role ${fn:contains(currentPath, 'cambiar-contrasena') ? 'active' : ''}"><i class="bi bi-key"></i><span>Cambiar contraseña</span></a></li>
                    </c:when>

                    <c:when test="${sessionScope.rol == 'ESTADIAS'}">
                        <li><a href="${ctx}/estadias/documentos" class="nav-link-role ${fn:contains(currentPath, '/estadias/document') || fn:contains(currentPath, '/estadias/reporte') ? 'active' : ''}"><i class="bi bi-folder-check"></i><span>Gestión de archivos</span></a></li>
                        <li><a href="${ctx}/estadias/historico" class="nav-link-role ${fn:contains(currentPath, '/estadias/historico') ? 'active' : ''}"><i class="bi bi-clock-history"></i><span>Histórico</span></a></li>
                    </c:when>

                    <c:when test="${sessionScope.rol == 'ADMIN'}">
                        <li><a href="${ctx}/admin/solicitudes" class="nav-link-role ${fn:contains(currentPath, '/admin/solicitud') ? 'active' : ''}"><i class="bi bi-file-earmark-text"></i><span>Solicitudes</span></a></li>
                        <li><a href="${ctx}/admin/reportes" class="nav-link-role ${fn:contains(currentPath, '/admin/reportes') ? 'active' : ''}"><i class="bi bi-clipboard2-check"></i><span>Reporte</span></a></li>
                        <li><a href="${ctx}/admin/usuarios" class="nav-link-role ${fn:contains(currentPath, '/admin/usuarios') ? 'active' : ''}"><i class="bi bi-people-fill"></i><span>Gestión de usuarios</span></a></li>
                        <li><a href="${ctx}/admin/firmantes" class="nav-link-role ${fn:contains(currentPath, '/admin/firmantes') ? 'active' : ''}"><i class="bi bi-pen-fill"></i><span>Firmantes</span></a></li>
                        <li><a href="${ctx}/admin/historico" class="nav-link-role ${fn:contains(currentPath, '/admin/historico') ? 'active' : ''}"><i class="bi bi-clock-history"></i><span>Histórico</span></a></li>
                    </c:when>
                </c:choose>
            </ul>
        </nav>
    </div>

    <form method="post" action="${ctx}/logout" class="logout-form">
        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>"/>
        <button type="submit" class="logout-button">
            <i class="bi bi-box-arrow-left"></i><span>Cerrar sesión</span>
        </button>
    </form>
</aside>
<input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
<script src="${pageContext.request.contextPath}/assets/js/post-navigation.js" defer></script>