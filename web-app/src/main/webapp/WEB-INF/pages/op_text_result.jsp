<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("currentPage", "text");
    request.setAttribute("username", session.getAttribute("username"));
    request.setAttribute("corbaConnected", com.pdfservice.util.CORBAClient.isConnected());
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Texte extrait - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <%@ include file="sidebar.jsp" %>
    <div class="main-content">
        <div class="topbar">
            <div>
                <div class="page-title">Texte extrait</div>
                <div class="page-sub">Fichier source : ${filename}</div>
            </div>
        </div>
        <div class="content-area">
            <div class="card">
                <div class="card-title">Contenu extrait du PDF</div>
                <div style="display:flex;gap:10px;margin-bottom:16px;flex-wrap:wrap">
                    <button class="btn btn-secondary" onclick="copyText()" id="copyBtn">
                        Copier le texte
                    </button>
                    <button class="btn btn-secondary" onclick="downloadText()">
                        Telecharger .txt
                    </button>
                    <a href="${pageContext.request.contextPath}/pdf/text" class="btn btn-secondary">
                        Nouvelle extraction
                    </a>
                </div>
                <c:choose>
                    <c:when test="${empty extractedText}">
                        <div class="alert alert-info">Aucun texte extrait. Le PDF est peut-etre une image scannee ou protege.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-result" id="textResult"><c:out value="${extractedText}"/></div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
<script>
function copyText(){const t=document.getElementById('textResult').innerText;navigator.clipboard.writeText(t).then(()=>{const b=document.getElementById('copyBtn');b.textContent='Copie !';setTimeout(()=>b.textContent='Copier le texte',2000);});}
function downloadText(){const t=document.getElementById('textResult').innerText;const b=new Blob([t],{type:'text/plain;charset=utf-8'});const u=URL.createObjectURL(b);const a=document.createElement('a');a.href=u;a.download='texte_extrait.txt';a.click();}
</script>
</body>
</html>
