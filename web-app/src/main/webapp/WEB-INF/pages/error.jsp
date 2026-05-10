<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% request.setAttribute("page",""); request.setAttribute("username",session.getAttribute("username")); %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><title>Erreur - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body><div class="app">
<%@ include file="sidebar.jsp" %>
<div class="main">
  <div class="topbar"><div class="page-title">Erreur</div></div>
  <div class="content">
    <div class="card" style="max-width:600px;text-align:center;padding:32px">
      <div style="font-size:48px;margin-bottom:14px">⚠️</div>
      <div class="alert alert-error" style="text-align:left">${not empty error?error:'Erreur inattendue.'}</div>
      <div style="display:flex;gap:10px;justify-content:center;margin-top:16px">
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary" style="width:auto">Dashboard</a>
        <button onclick="history.back()" class="btn btn-secondary">Retour</button>
      </div>
    </div>
  </div>
</div></div></body></html>
