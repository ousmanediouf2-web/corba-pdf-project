<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - CORBA PDF Service</title>
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
            <h1>Créer un compte</h1>
            <p>Rejoignez CORBA PDF Service</p>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-error">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>
                ${error}
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/register">
            <div class="form-group">
                <label>Nom d'utilisateur <span style="color:#ef4444">*</span></label>
                <input type="text" name="username" required minlength="3"
                       placeholder="Min. 3 caractères" value="${param.username}">
            </div>
            <div class="form-group">
                <label>Adresse email <span style="color:#ef4444">*</span></label>
                <input type="email" name="email" required
                       placeholder="votre@email.com" value="${param.email}">
            </div>
            <div class="form-group">
                <label>Mot de passe <span style="color:#ef4444">*</span></label>
                <input type="password" name="password" required minlength="6"
                       placeholder="Min. 6 caractères" id="pwd">
            </div>
            <div class="form-group">
                <label>Confirmer le mot de passe <span style="color:#ef4444">*</span></label>
                <input type="password" name="confirmPassword" required
                       placeholder="Répétez le mot de passe" id="pwd2">
                <p class="hint" id="pwd-match" style="display:none;color:#ef4444">
                    Les mots de passe ne correspondent pas
                </p>
            </div>
            <button type="submit" class="btn btn-primary" id="regBtn">
                <span class="btn-text">Créer mon compte</span>
                <div class="loading-spinner"></div>
            </button>
        </form>

        <div class="auth-link">
            Déjà un compte ?
            <a href="${pageContext.request.contextPath}/login">Se connecter</a>
        </div>
    </div>
</div>
<script>
    document.getElementById('pwd2').addEventListener('input', function() {
        const match = document.getElementById('pwd-match');
        if (this.value && this.value !== document.getElementById('pwd').value) {
            match.style.display = 'block';
        } else {
            match.style.display = 'none';
        }
    });

    document.getElementById('regBtn').addEventListener('click', function() {
        this.classList.add('loading');
        this.disabled = true;
        setTimeout(() => { this.classList.remove('loading'); this.disabled = false; }, 5000);
    });
</script>
</body>
</html>
