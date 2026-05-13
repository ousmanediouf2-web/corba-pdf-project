<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% request.setAttribute("page","merge");
   request.setAttribute("username",session.getAttribute("username"));
   request.setAttribute("corbaOk", com.pdfservice.util.CORBAClient.isAlive()); %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><title>Fusion PDF - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body><div class="app">
<%@ include file="sidebar.jsp" %>
<div class="main">
  <div class="topbar"><div>
    <div class="page-title">📎 Fusion de PDF</div>
    <div class="page-sub">Combiner deux fichiers PDF en un seul document</div>
  </div></div>
  <div class="content">
    <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
    <c:if test="${not empty param.error}"><div class="alert alert-error">${param.error}</div></c:if>
    <div class="card" style="max-width:680px">
      <div class="card-title">📎 Sélectionnez les deux fichiers à fusionner</div>
      <form method="post" action="${pageContext.request.contextPath}/pdf/merge"
            enctype="multipart/form-data" id="f">
        <div class="form-group">
          <label>Premier fichier PDF <span style="color:red">*</span></label>
          <input type="file" name="files" accept=".pdf" required id="f1"
                 onchange="showFile(this,'n1')">
          <p class="hint" id="n1" style="margin-top:4px">Aucun fichier sélectionné</p>
        </div>
        <div class="form-group">
          <label>Deuxième fichier PDF <span style="color:red">*</span></label>
          <input type="file" name="files" accept=".pdf" required id="f2"
                 onchange="showFile(this,'n2')">
          <p class="hint" id="n2" style="margin-top:4px">Aucun fichier sélectionné</p>
        </div>
        <div style="margin-top:20px">
          <p style="font-size:12px;color:var(--text-s);margin-bottom:6px;font-weight:500">
            ✅ Cliquez sur le bouton ci-dessous pour valider et lancer la fusion
          </p>
          <div style="display:flex;gap:10px;align-items:center">
            <button type="submit" class="btn btn-primary" id="sb"
                    style="width:auto;padding:10px 32px;background:var(--primary)">
              <span class="btn-text">📎 Fusionner les PDF</span>
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
function showFile(input, id) {
  const el = document.getElementById(id);
  if (input.files && input.files[0]) {
    const f = input.files[0];
    const sz = f.size < 1048576 ? (f.size/1024).toFixed(1)+' KB' : (f.size/1048576).toFixed(1)+' MB';
    el.textContent = '📄 ' + f.name + ' (' + sz + ')';
    el.style.color = 'var(--success)';
  }
}
document.getElementById('f').addEventListener('submit', function() {
  const btn = document.getElementById('sb');
  btn.classList.add('loading'); btn.disabled = true;
});
</script>
</body></html>
