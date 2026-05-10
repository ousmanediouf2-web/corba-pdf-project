<%@ page contentType="text/html;charset=UTF-8" %>
<% response.sendRedirect(request.getContextPath() +
   (session.getAttribute("user") != null ? "/dashboard" : "/login")); %>
