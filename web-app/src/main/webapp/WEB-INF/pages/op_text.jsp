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
    <title>Extraction de texte - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <%@ include file="sidebar.jsp" %>
    <div class="main-content">
        <div class="topbar">
            <div>
                <div class="page-title">📝 Extraction de texte</div>
                <div class="page-sub">Extrayez tout le texte de votre document PDF</div>
            </div>
        </div>
        <div class="content-area">
            <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
            <div class="card op-form">
                <form method="post" action="${pageContext.request.contextPath}/pdf/text"
                      enctype="multipart/form-data" id="opForm">
                    <div class="form-group">
                        <label>Fichier PDF source <span style="color:#ef4444">*</span></label>
                        <div class="upload-zone" id="dropZone">
                            <input type="file" name="file" accept=".pdf" required id="fileInput" onchange="showFile(this)">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="width:28px;height:28px;margin-bottom:8px"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                            <p><strong>Choisir un fichier PDF</strong></p>
                            <p id="selectedFileName" style="font-size:12px;color:var(--text-secondary);margin-top:4px">Aucun fichier sélectionné</p>
                        </div>
                    </div>
                    <div class="alert alert-info">
                        💡 Le texte sera affiché directement sur la page. Votre PDF doit contenir du texte sélectionnable (pas une image scannée).
                    </div>
                    <div style="margin-top:20px;display:flex;gap:12px">
                        <button type="submit" class="btn btn-primary" id="submitBtn" style="width:auto;padding:10px 28px">
                            <span class="btn-text">📝 Extraire le texte</span>
                            <div class="loading-spinner"></div>
                        </button>
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary">← Retour</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
function showFile(i){if(i.files&&i.files[0]){const f=i.files[0];const s=f.size<1024*1024?(f.size/1024).toFixed(1)+' KB':(f.size/(1024*1024)).toFixed(1)+' MB';document.getElementById('selectedFileName').textContent=f.name+' ('+s+')';}}
const dz=document.getElementById('dropZone');
dz.addEventListener('dragover',e=>{e.preventDefault();dz.classList.add('dragover');});
dz.addEventListener('dragleave',()=>dz.classList.remove('dragover'));
dz.addEventListener('drop',e=>{e.preventDefault();dz.classList.remove('dragover');const fi=document.getElementById('fileInput');fi.files=e.dataTransfer.files;showFile(fi);});
document.getElementById('submitBtn').addEventListener('click',function(){this.classList.add('loading');this.disabled=true;});
</script>
</body>
</html>
