<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="auth-page">
    <div class="auth-card">
        <div class="auth-logo">
            <div class="logo-icon">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6zm4 18H6V4h7v5h5v11z"/></svg>
            </div>
            <h1>CORBA PDF Service</h1>
            <p>Connectez-vous pour accéder à vos outils PDF</p>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-error">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>
                ${error}
            </div>
        </c:if>

        <c:if test="${param.msg == 'registered'}">
            <div class="alert alert-success">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                Compte créé avec succès ! Connectez-vous.
            </div>
        </c:if>

        <c:if test="${param.msg == 'logout'}">
            <div class="alert alert-info">Vous avez été déconnecté.</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/login">
            <div class="form-group">
                <label>Nom d'utilisateur</label>
                <input type="text" name="username" required autofocus
                       placeholder="Votre nom d'utilisateur"
                       value="${param.username}">
            </div>
            <div class="form-group">
                <label>Mot de passe</label>
                <input type="password" name="password" required placeholder="Votre mot de passe">
            </div>
            <button type="submit" class="btn btn-primary" id="loginBtn"
                    onclick="this.classList.add('loading'); this.disabled=true; setTimeout(()=>{this.classList.remove('loading');this.disabled=false;},5000)">
                <span class="btn-text">Se connecter</span>
                <div class="loading-spinner"></div>
            </button>
        </form>

        <div class="auth-link">
            Pas encore de compte ?
            <a href="${pageContext.request.contextPath}/register">Créer un compte</a>
        </div>
    </div>
</div>
</body>
</html>
