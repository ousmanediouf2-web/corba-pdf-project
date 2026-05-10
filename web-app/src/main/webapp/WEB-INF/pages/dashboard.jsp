<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("page","dashboard");
   request.setAttribute("username",session.getAttribute("username")); %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><title>Dashboard - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body><div class="app">
<%@ include file="sidebar.jsp" %>
<div class="main">
  <div class="topbar">
    <div><div class="page-title">Tableau de bord</div>
         <div class="page-sub">Bienvenue, ${username} !</div></div>
  </div>
  <div class="content">
    <c:if test="${!corbaOk}">
      <div class="alert alert-warn">⚠️ Serveur CORBA hors ligne. Les operations PDF ne sont pas disponibles.</div>
    </c:if>
    <!-- Stats -->
    <div class="stats">
      <div class="stat">
        <div class="stat-icon" style="background:#eff6ff">📄</div>
        <div><div class="stat-val">${totalOps}</div><div class="stat-lbl">Operations effectuees</div></div>
      </div>
      <div class="stat">
        <div class="stat-icon" style="background:${corbaOk?'#f0fdf4':'#fef2f2'}">${corbaOk?'✅':'❌'}</div>
        <div><div class="stat-val" style="font-size:16px">${corbaOk?'En ligne':'Hors ligne'}</div>
             <div class="stat-lbl">Serveur CORBA</div></div>
      </div>
    </div>
    <!-- Operations -->
    <div class="card">
      <div class="card-title">Operations disponibles</div>
      <div class="ops-grid">
        <a href="${pageContext.request.contextPath}/pdf/merge"    class="op-card"><div class="op-emoji">📎</div><h3>Fusion PDF</h3><p>Combiner plusieurs PDF en un</p></a>
        <a href="${pageContext.request.contextPath}/pdf/split"    class="op-card"><div class="op-emoji">✂️</div><h3>Decoupage</h3><p>Extraire une plage de pages</p></a>
        <a href="${pageContext.request.contextPath}/pdf/extract"  class="op-card"><div class="op-emoji">📑</div><h3>Extraction pages</h3><p>Selectionner des pages specifiques</p></a>
        <a href="${pageContext.request.contextPath}/pdf/delete"   class="op-card"><div class="op-emoji">🗑️</div><h3>Suppression pages</h3><p>Supprimer des pages</p></a>
        <a href="${pageContext.request.contextPath}/pdf/password" class="op-card"><div class="op-emoji">🔒</div><h3>Mot de passe</h3><p>Proteger un PDF</p></a>
        <a href="${pageContext.request.contextPath}/pdf/convert"  class="op-card"><div class="op-emoji">🖼️</div><h3>PDF vers Images</h3><p>Convertir en PNG (ZIP)</p></a>
        <a href="${pageContext.request.contextPath}/pdf/text"     class="op-card"><div class="op-emoji">📝</div><h3>Extraction texte</h3><p>Extraire le contenu texte</p></a>
        <a href="${pageContext.request.contextPath}/pdf/create"   class="op-card"><div class="op-emoji">✨</div><h3>Creer PDF</h3><p>Generer un PDF depuis texte</p></a>
      </div>
    </div>
    <!-- Recents -->
    <c:if test="${not empty recentOps}">
    <div class="card">
      <div class="card-title">Activite recente</div>
      <div class="tbl-wrap"><table>
        <thead><tr><th>Operation</th><th>Fichier</th><th>Duree</th><th>Date</th><th>Statut</th></tr></thead>
        <tbody>
          <c:forEach var="op" items="${recentOps}">
          <tr>
            <td><b>${op.typeLabel}</b></td>
            <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${op.inputFile}</td>
            <td>${op.durationMs}ms</td>
            <td><fmt:formatDate value="${op.createdAt}" pattern="dd/MM HH:mm"/></td>
            <td><span class="badge ${op.status=='success'?'badge-ok':'badge-err'}">${op.status}</span></td>
          </tr>
          </c:forEach>
        </tbody>
      </table></div>
      <div style="text-align:right;margin-top:10px">
        <a href="${pageContext.request.contextPath}/history" class="btn btn-secondary" style="width:auto">Voir tout →</a>
      </div>
    </div>
    </c:if>
  </div>
</div></div></body></html>
