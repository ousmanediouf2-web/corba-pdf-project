<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setAttribute("currentPage", "history");
    request.setAttribute("username", session.getAttribute("username"));
    request.setAttribute("corbaConnected", com.pdfservice.util.CORBAClient.isConnected());
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Historique - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <%@ include file="sidebar.jsp" %>
    <div class="main-content">
        <div class="topbar">
            <div>
                <div class="page-title">Historique des operations</div>
                <div class="page-sub">Toutes vos operations PDF</div>
            </div>
        </div>
        <div class="content-area">
            <div class="card">
                <div class="card-title">
                    Operations effectuees
                    <span style="margin-left:auto;font-size:12px;font-weight:400;color:var(--text-secondary)">
                        ${history.size()} entrees
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty history}">
                        <div style="text-align:center;padding:40px;color:var(--text-secondary)">
                            <div style="font-size:40px;margin-bottom:12px">📂</div>
                            <p>Aucune operation effectuee pour le moment.</p>
                            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary"
                               style="width:auto;padding:10px 24px;margin-top:16px;display:inline-flex">
                                Commencer une operation
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrapper">
                            <table>
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Type</th>
                                        <th>Fichier source</th>
                                        <th>Resultat</th>
                                        <th>Taille entree</th>
                                        <th>Taille sortie</th>
                                        <th>Duree</th>
                                        <th>Date</th>
                                        <th>Statut</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="op" items="${history}" varStatus="s">
                                        <tr>
                                            <td style="color:var(--text-secondary)">${s.count}</td>
                                            <td><strong>${op.operationLabel}</strong></td>
                                            <td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:12px">
                                                ${op.inputFilename}
                                            </td>
                                            <td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:12px">
                                                ${op.outputFilename}
                                            </td>
                                            <td style="font-size:12px">
                                                <c:choose>
                                                    <c:when test="${op.inputSize > 1048576}">
                                                        <fmt:formatNumber value="${op.inputSize / 1048576}" maxFractionDigits="1"/> MB
                                                    </c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${op.inputSize / 1024}" maxFractionDigits="1"/> KB
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-size:12px">
                                                <c:choose>
                                                    <c:when test="${op.outputSize > 1048576}">
                                                        <fmt:formatNumber value="${op.outputSize / 1048576}" maxFractionDigits="1"/> MB
                                                    </c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${op.outputSize / 1024}" maxFractionDigits="1"/> KB
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-size:12px">${op.durationMs}ms</td>
                                            <td style="font-size:12px">
                                                <fmt:formatDate value="${op.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td>
                                                <span class="badge ${op.status == 'success' ? 'badge-success' : 'badge-error'}">
                                                    ${op.status == 'success' ? 'Succes' : 'Erreur'}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
</body>
</html>
