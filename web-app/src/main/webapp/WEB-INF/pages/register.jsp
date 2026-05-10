<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Inscription - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body>
<div class="auth-wrap"><div class="auth-box">
  <div class="auth-logo">
    <div class="auth-icon">📄</div>
    <h1>Creer un compte</h1>
    <p>CORBA PDF Service</p>
  </div>
  <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
  <form method="post" action="${pageContext.request.contextPath}/register">
    <div class="form-group"><label>Username *</label>
      <input type="text" name="username" required minlength="3" placeholder="Min. 3 caracteres"></div>
    <div class="form-group"><label>Email *</label>
      <input type="email" name="email" required placeholder="votre@email.com"></div>
    <div class="form-group"><label>Mot de passe *</label>
      <input type="password" name="password" id="p1" required minlength="6" placeholder="Min. 6 caracteres"></div>
    <div class="form-group"><label>Confirmer *</label>
      <input type="password" name="confirmPassword" id="p2" required placeholder="Repetez le mot de passe">
      <p class="hint" id="mismatch" style="display:none;color:var(--danger)">Mots de passe differents</p></div>
    <button type="submit" class="btn btn-primary" id="btn">
      <span class="btn-text">Creer mon compte</span><div class="spin"></div>
    </button>
  </form>
  <div class="auth-link">Deja un compte ? <a href="${pageContext.request.contextPath}/login">Se connecter</a></div>
</div></div>
<script>
document.getElementById('p2').oninput=function(){
  document.getElementById('mismatch').style.display=
    this.value&&this.value!==document.getElementById('p1').value?'block':'none';};
document.querySelector('form').onsubmit=()=>{document.getElementById('btn').classList.add('loading');}
</script>
</body></html>
