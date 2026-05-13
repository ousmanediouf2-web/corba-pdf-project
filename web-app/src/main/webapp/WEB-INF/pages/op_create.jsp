<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% request.setAttribute("page","create");
   request.setAttribute("username",session.getAttribute("username"));
   request.setAttribute("corbaOk", com.pdfservice.util.CORBAClient.isAlive()); %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><title>Créer PDF - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body><div class="app">
<%@ include file="sidebar.jsp" %>
<div class="main">
  <div class="topbar"><div>
    <div class="page-title">✨ Créer un PDF</div>
    <div class="page-sub">Générer un nouveau document PDF depuis du texte</div>
  </div></div>
  <div class="content">
    <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
    <div class="card" style="max-width:680px">
      <div class="card-title">✨ Nouveau document PDF</div>
      <form method="post" action="${pageContext.request.contextPath}/pdf/create" id="f">
        <div class="form-group">
          <label>Titre du document <span style="color:red">*</span></label>
          <input type="text" name="title" required placeholder="Ex: Rapport 2025">
        </div>
        <div class="form-group">
          <label>Auteur</label>
          <input type="text" name="author" placeholder="Votre nom (optionnel)"
                 value="${username}">
        </div>
        <div class="form-group">
          <label>Contenu <span style="color:red">*</span></label>
          <textarea name="content" required
                    placeholder="Saisissez le contenu de votre document..."></textarea>
        </div>
        <div style="margin-top:20px">
          <p style="font-size:12px;color:var(--text-s);margin-bottom:6px;font-weight:500">
            ✅ Cliquez sur le bouton ci-dessous pour valider et générer votre PDF
          </p>
          <div style="display:flex;gap:10px;align-items:center">
            <button type="submit" class="btn btn-primary" id="sb"
                    style="width:auto;padding:10px 32px">
              <span class="btn-text">✨ Générer le PDF</span>
              <div class="spin"></div>
            </button>
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary">← Retour</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div></div>
<script>
document.getElementById('f').addEventListener('submit', function() {
  document.getElementById('sb').classList.add('loading');
  document.getElementById('sb').disabled = true;
});
</script>
</body></html>
