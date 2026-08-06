<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Compatibilidad con enlaces antiguos: el controlador selecciona la vista
    // de inicio correcta según el rol guardado en la sesión.
    response.sendRedirect(request.getContextPath() + "/inicio");
%>
