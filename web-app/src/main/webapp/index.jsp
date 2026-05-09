<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Rediriger vers le dashboard si connecte, sinon vers login
    if (session.getAttribute("user") != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
    } else {
        response.sendRedirect(request.getContextPath() + "/login");
    }
%>
