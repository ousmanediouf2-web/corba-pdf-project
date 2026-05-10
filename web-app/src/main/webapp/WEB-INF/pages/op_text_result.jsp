<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% request.setAttribute("page","text");
   request.setAttribute("username",session.getAttribute("username")); %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><title>Texte extrait - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body><div class="app">
<%@ include file="sidebar.jsp" %>
<div class="main">
  <div class="topbar"><div>
    <div class="page-title">📝 Texte extrait</div>
    <div class="page-sub">Fichier : ${filename}</div>
  </div></div>
  <div class="content">
    <div class="card">
      <div class="card-title">Contenu extrait</div>
      <div style="display:flex;gap:10px;margin-bottom:14px">
        <button class="btn btn-secondary" onclick="copy()">📋 Copier</button>
        <button class="btn btn-secondary" onclick="dl()">💾 Telecharger</button>
        <a href="${pageContext.request.contextPath}/pdf/text" class="btn btn-secondary">← Nouvelle extraction</a>
      </div>
      <c:choose>
        <c:when test="${empty text}">
          <div class="alert alert-warn">Aucun texte extrait. Le PDF est peut-etre une image scannee.</div>
        </c:when>
        <c:otherwise>
          <div class="text-result" id="tr"><c:out value="${text}"/></div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div></div>
<script>
function copy(){navigator.clipboard.writeText(document.getElementById('tr').innerText)
  .then(()=>{const b=event.target;b.textContent='✅ Copie !';setTimeout(()=>b.textContent='📋 Copier',2000);});}
function dl(){const b=new Blob([document.getElementById('tr').innerText],{type:'text/plain'});
  const a=document.createElement('a');a.href=URL.createObjectURL(b);a.download='texte.txt';a.click();}
</script>
</body></html>
