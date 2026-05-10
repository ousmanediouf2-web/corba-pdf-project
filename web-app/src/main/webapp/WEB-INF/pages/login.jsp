<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Connexion - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body>
<div class="auth-wrap"><div class="auth-box">
  <div class="auth-logo">
    <div class="auth-icon">📄</div>
    <h1>CORBA PDF Service</h1>
    <p>Connectez-vous pour acceder</p>
  </div>
  <c:if test="${not empty error}">
    <div class="alert alert-error">${error}</div>
  </c:if>
  <c:if test="${param.msg == 'registered'}">
    <div class="alert alert-success">Compte cree ! Connectez-vous.</div>
  </c:if>
  <c:if test="${param.msg == 'logout'}">
    <div class="alert alert-info">Deconnecte avec succes.</div>
  </c:if>
  <form method="post" action="${pageContext.request.contextPath}/login">
    <div class="form-group">
      <label>Nom d'utilisateur</label>
      <input type="text" name="username" required autofocus placeholder="Votre username">
    </div>
    <div class="form-group">
      <label>Mot de passe</label>
      <input type="password" name="password" required placeholder="Votre mot de passe">
    </div>
    <button type="submit" class="btn btn-primary" id="btn">
      <span class="btn-text">Se connecter</span><div class="spin"></div>
    </button>
  </form>
  <div class="auth-link">Pas de compte ? <a href="${pageContext.request.contextPath}/register">Creer un compte</a></div>
</div></div>
<script>document.querySelector('form').onsubmit=()=>{document.getElementById('btn').classList.add('loading');}</script>
</body></html>
