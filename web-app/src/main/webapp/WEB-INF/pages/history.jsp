<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("page","history");
   request.setAttribute("username",session.getAttribute("username")); %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><title>Historique - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body><div class="app">
<%@ include file="sidebar.jsp" %>
<div class="main">
  <div class="topbar"><div>
    <div class="page-title">📋 Historique</div>
    <div class="page-sub">${history.size()} operations</div>
  </div></div>
  <div class="content">
    <div class="card">
      <c:choose>
        <c:when test="${empty history}">
          <div style="text-align:center;padding:40px;color:var(--text-s)">
            <div style="font-size:40px;margin-bottom:12px">📂</div>
            <p>Aucune operation effectuee.</p>
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary"
               style="width:auto;display:inline-flex;margin-top:14px;padding:9px 22px">Commencer</a>
          </div>
        </c:when>
        <c:otherwise>
          <div class="tbl-wrap"><table>
            <thead><tr><th>#</th><th>Type</th><th>Fichier source</th><th>Resultat</th><th>Duree</th><th>Date</th><th>Statut</th></tr></thead>
            <tbody>
              <c:forEach var="op" items="${history}" varStatus="s">
              <tr>
                <td style="color:var(--text-s)">${s.count}</td>
                <td><b>${op.typeLabel}</b></td>
                <td style="max-width:130px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:12px">${op.inputFile}</td>
                <td style="max-width:130px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:12px">${op.outputFile}</td>
                <td>${op.durationMs}ms</td>
                <td><fmt:formatDate value="${op.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                <td><span class="badge ${op.status=='success'?'badge-ok':'badge-err'}">${op.status}</span></td>
              </tr>
              </c:forEach>
            </tbody>
          </table></div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div></div></body></html>
