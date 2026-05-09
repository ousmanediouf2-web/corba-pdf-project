<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("currentPage", "");
    request.setAttribute("username", session.getAttribute("username"));
    request.setAttribute("corbaConnected", false);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Erreur - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <%@ include file="sidebar.jsp" %>
    <div class="main-content">
        <div class="topbar">
            <div class="page-title">Erreur</div>
        </div>
        <div class="content-area">
            <div class="card" style="max-width:600px">
                <div style="text-align:center;padding:20px">
                    <div style="font-size:48px;margin-bottom:16px">⚠️</div>
                    <h2 style="margin-bottom:12px;color:var(--danger)">Une erreur est survenue</h2>
                    <div class="alert alert-error" style="text-align:left">
                        ${not empty error ? error : 'Une erreur inattendue est survenue.'}
                    </div>
                    <div style="margin-top:20px;display:flex;gap:12px;justify-content:center">
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary" style="width:auto">
                            Retour au tableau de bord
                        </a>
                        <button onclick="history.back()" class="btn btn-secondary">Retour</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
