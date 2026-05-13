<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% request.setAttribute("page","split");
   request.setAttribute("username",session.getAttribute("username"));
   request.setAttribute("corbaOk", com.pdfservice.util.CORBAClient.isAlive()); %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><title>Découpage PDF - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body><div class="app">
<%@ include file="sidebar.jsp" %>
<div class="main">
  <div class="topbar"><div>
    <div class="page-title">✂️ Découpage PDF</div>
    <div class="page-sub">Extraire une plage de pages</div>
  </div></div>
  <div class="content">
    <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
    <div class="card" style="max-width:680px">
      <div class="card-title">✂️ Découpage PDF</div>
      <form method="post" action="${pageContext.request.contextPath}/pdf/split"
            enctype="multipart/form-data" id="f">
        <div class="form-group">
          <label>Fichier PDF <span style="color:red">*</span></label>
          <div class="upload-zone" id="dz">
            <input type="file" name="file" accept=".pdf" required id="fi"
                   onchange="showFile(this)">
            <div class="icon">📁</div>
            <p><b>Cliquez ici</b> ou glissez votre PDF</p>
            <p id="fn" style="font-size:12px;color:var(--text-s);margin-top:4px">Aucun fichier sélectionné</p>
          </div>
        </div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px">
  <div class="form-group"><label>Page début <span style="color:red">*</span></label>
    <input type="number" name="startPage" min="1" value="1" required></div>
  <div class="form-group"><label>Page fin <span style="color:red">*</span></label>
    <input type="number" name="endPage" min="1" value="5" required></div>
</div>
        <div style="margin-top:20px">
          <p style="font-size:12px;color:var(--text-s);margin-bottom:6px;font-weight:500">
            ✅ Cliquez sur le bouton ci-dessous pour valider et exécuter l'opération
          </p>
          <div style="display:flex;gap:10px;align-items:center">
            <button type="submit" class="btn btn-primary" id="sb"
                    style="width:auto;padding:10px 32px">
              <span class="btn-text">✂️ Découper le PDF</span>
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
function showFile(input) {
  if (input.files && input.files[0]) {
    const f = input.files[0];
    const sz = f.size < 1048576 ? (f.size/1024).toFixed(1)+' KB' : (f.size/1048576).toFixed(1)+' MB';
    document.getElementById('fn').textContent = '📄 ' + f.name + ' (' + sz + ')';
    document.getElementById('fn').style.color = 'var(--success)';
    document.getElementById('dz').style.borderColor = 'var(--success)';
  }
}
const dz = document.getElementById('dz');
dz.addEventListener('dragover', e => { e.preventDefault(); dz.classList.add('over'); });
dz.addEventListener('dragleave', () => dz.classList.remove('over'));
dz.addEventListener('drop', e => {
  e.preventDefault(); dz.classList.remove('over');
  document.getElementById('fi').files = e.dataTransfer.files;
  showFile(document.getElementById('fi'));
});
document.getElementById('f').addEventListener('submit', function() {
  const sb = document.getElementById('sb');
  sb.classList.add('loading'); sb.disabled = true;
});
</script>
</body></html>
