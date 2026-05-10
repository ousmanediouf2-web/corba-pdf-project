<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<aside class="sidebar">
  <div class="sidebar-logo">
    <div class="logo-box">📄</div>
    <div>PDF Service<br><small style="font-weight:400;font-size:10px;opacity:.5">CORBA Edition</small></div>
  </div>
  <div class="sidebar-user">
    <div class="avatar">${username.substring(0,1).toUpperCase()}</div>
    <div><div class="uname">${username}</div><div class="urole">${sessionScope.user.role}</div></div>
  </div>
  <nav class="nav">
    <div class="nav-label">Principal</div>
    <a href="${pageContext.request.contextPath}/dashboard" class="${page=='dashboard'?'active':''}">
      <span class="nav-icon">🏠</span> Dashboard</a>
    <a href="${pageContext.request.contextPath}/history" class="${page=='history'?'active':''}">
      <span class="nav-icon">📋</span> Historique</a>
    <div class="nav-label">Operations PDF</div>
    <a href="${pageContext.request.contextPath}/pdf/merge"    class="${page=='merge'?'active':''}"><span class="nav-icon">📎</span> Fusion PDF</a>
    <a href="${pageContext.request.contextPath}/pdf/split"    class="${page=='split'?'active':''}"><span class="nav-icon">✂️</span> Decoupage</a>
    <a href="${pageContext.request.contextPath}/pdf/extract"  class="${page=='extract'?'active':''}"><span class="nav-icon">📑</span> Extraction pages</a>
    <a href="${pageContext.request.contextPath}/pdf/delete"   class="${page=='delete'?'active':''}"><span class="nav-icon">🗑️</span> Suppression pages</a>
    <a href="${pageContext.request.contextPath}/pdf/password" class="${page=='password'?'active':''}"><span class="nav-icon">🔒</span> Mot de passe</a>
    <a href="${pageContext.request.contextPath}/pdf/convert"  class="${page=='convert'?'active':''}"><span class="nav-icon">🖼️</span> PDF → Images</a>
    <a href="${pageContext.request.contextPath}/pdf/text"     class="${page=='text'?'active':''}"><span class="nav-icon">📝</span> Extraction texte</a>
    <a href="${pageContext.request.contextPath}/pdf/create"   class="${page=='create'?'active':''}"><span class="nav-icon">✨</span> Creer PDF</a>
  </nav>
  <div class="sidebar-foot">
    <div class="corba-dot">
      <div class="dot ${corbaOk?'on':'off'}"></div>
      CORBA : ${corbaOk?'En ligne':'Hors ligne'}
    </div>
    <a href="${pageContext.request.contextPath}/logout" class="nav a">
      <span class="nav-icon">🚪</span> Deconnexion</a>
  </div>
</aside>
