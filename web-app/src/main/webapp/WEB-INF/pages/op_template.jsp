<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Template for: split, extract, delete, password, convert, text --%>
<%
    String op = request.getServletPath().replace("/pdf/", "");
    request.setAttribute("currentPage", op);
    request.setAttribute("username", session.getAttribute("username"));
    request.setAttribute("corbaConnected", com.pdfservice.util.CORBAClient.isConnected());

    String title, subtitle, emoji;
    switch(op) {
        case "split":    title = "Découpage PDF";         subtitle = "Extrayez une plage de pages"; emoji = "✂️"; break;
        case "extract":  title = "Extraction de pages";   subtitle = "Sélectionnez des pages spécifiques"; emoji = "📑"; break;
        case "delete":   title = "Suppression de pages";  subtitle = "Supprimez des pages indésirables"; emoji = "🗑️"; break;
        case "password": title = "Protection par mot de passe"; subtitle = "Sécurisez votre PDF"; emoji = "🔒"; break;
        case "convert":  title = "PDF vers Images";       subtitle = "Convertissez en fichiers PNG"; emoji = "🖼️"; break;
        case "text":     title = "Extraction de texte";   subtitle = "Extrayez le contenu textuel"; emoji = "📝"; break;
        default:         title = "Opération PDF"; subtitle = ""; emoji = "📄";
    }
    request.setAttribute("opTitle", title);
    request.setAttribute("opSubtitle", subtitle);
    request.setAttribute("opEmoji", emoji);
    request.setAttribute("opType", op);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>${opTitle} - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <%@ include file="sidebar.jsp" %>
    <div class="main-content">
        <div class="topbar">
            <div>
                <div class="page-title">${opEmoji} ${opTitle}</div>
                <div class="page-sub">${opSubtitle}</div>
            </div>
        </div>
        <div class="content-area">
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>

            <div class="card op-form">
                <div class="card-title">${opEmoji} ${opTitle}</div>

                <form method="post" action="${pageContext.request.contextPath}/pdf/${opType}"
                      enctype="multipart/form-data" id="opForm">

                    <!-- Upload unique PDF -->
                    <div class="form-group">
                        <label>Fichier PDF source <span style="color:#ef4444">*</span></label>
                        <div class="upload-zone" id="dropZone" style="padding:28px">
                            <input type="file" name="file" accept=".pdf" required id="fileInput"
                                   onchange="showFile(this)">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="width:28px;height:28px;margin-bottom:8px">
                                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                                <polyline points="14 2 14 8 20 8"/>
                            </svg>
                            <p><strong>Choisir un fichier PDF</strong></p>
                            <p id="selectedFileName" style="font-size:12px;color:var(--text-secondary);margin-top:4px">Aucun fichier sélectionné</p>
                        </div>
                    </div>

                    <!-- Champs spécifiques selon l'opération -->
                    <c:choose>
                        <c:when test="${opType == 'split'}">
                            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
                                <div class="form-group">
                                    <label>Page de début <span style="color:#ef4444">*</span></label>
                                    <input type="number" name="startPage" min="1" value="1" required>
                                </div>
                                <div class="form-group">
                                    <label>Page de fin <span style="color:#ef4444">*</span></label>
                                    <input type="number" name="endPage" min="1" value="5" required>
                                </div>
                            </div>
                            <p class="hint">Le PDF résultant contiendra les pages de la page de début à la page de fin.</p>
                        </c:when>
                        <c:when test="${opType == 'extract' || opType == 'delete'}">
                            <div class="form-group">
                                <label>Numéros de pages <span style="color:#ef4444">*</span></label>
                                <input type="text" name="pages" required
                                       placeholder="Ex: 1, 3, 5, 7"
                                       pattern="[\d,\s]+" title="Entrez des numéros séparés par des virgules">
                                <p class="hint">
                                    ${opType == 'extract' ? 'Pages à extraire' : 'Pages à supprimer'} — séparées par des virgules. Ex: 1, 3, 5-7
                                </p>
                            </div>
                        </c:when>
                        <c:when test="${opType == 'password'}">
                            <div class="form-group">
                                <label>Mot de passe utilisateur <span style="color:#ef4444">*</span></label>
                                <input type="password" name="userPassword" required
                                       placeholder="Mot de passe pour ouvrir le PDF">
                                <p class="hint">Ce mot de passe sera demandé pour ouvrir le document.</p>
                            </div>
                            <div class="form-group">
                                <label>Mot de passe propriétaire</label>
                                <input type="password" name="ownerPassword"
                                       placeholder="Mot de passe administrateur (optionnel)">
                                <p class="hint">Si vide, le mot de passe utilisateur sera utilisé.</p>
                            </div>
                        </c:when>
                        <c:when test="${opType == 'convert'}">
                            <div class="form-group">
                                <label>Résolution (DPI)</label>
                                <input type="range" name="dpi" min="72" max="300" value="150"
                                       oninput="document.getElementById('dpiVal').textContent=this.value">
                                <p class="hint">
                                    Résolution: <strong id="dpiVal">150</strong> DPI
                                    (72=faible, 150=standard, 300=haute qualité)
                                </p>
                            </div>
                            <div class="alert alert-info" style="margin-top:0">
                                Le résultat sera téléchargé sous forme d'archive ZIP contenant une image PNG par page.
                            </div>
                        </c:when>
                        <c:when test="${opType == 'text'}">
                            <div class="alert alert-info">
                                Le texte extrait sera affiché directement dans le navigateur. Assurez-vous que votre PDF contient du texte sélectionnable (pas une image scannée).
                            </div>
                        </c:when>
                    </c:choose>

                    <div style="margin-top:20px;display:flex;gap:12px">
                        <button type="submit" class="btn btn-primary" id="submitBtn"
                                style="width:auto;padding:10px 28px">
                            <span class="btn-text">${opEmoji} ${opTitle}</span>
                            <div class="loading-spinner"></div>
                        </button>
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary">
                            ← Retour
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
    function showFile(input) {
        if (input.files && input.files[0]) {
            const f = input.files[0];
            const size = f.size < 1024*1024 ? (f.size/1024).toFixed(1)+' KB' : (f.size/(1024*1024)).toFixed(1)+' MB';
            document.getElementById('selectedFileName').textContent = f.name + ' (' + size + ')';
        }
    }

    const dropZone = document.getElementById('dropZone');
    dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.classList.add('dragover'); });
    dropZone.addEventListener('dragleave', () => dropZone.classList.remove('dragover'));
    dropZone.addEventListener('drop', e => {
        e.preventDefault(); dropZone.classList.remove('dragover');
        const fi = document.getElementById('fileInput');
        fi.files = e.dataTransfer.files;
        showFile(fi);
    });

    document.getElementById('opForm').addEventListener('submit', function(e) {
        const opType = '${opType}';
        // For text extraction, let normal form submit (page forward)
        if (opType !== 'text') {
            e.preventDefault();
            const btn = document.getElementById('submitBtn');
            btn.classList.add('loading'); btn.disabled = true;

            const formData = new FormData(this);
            fetch(this.action, { method: 'POST', body: formData })
            .then(response => {
                if (response.ok) {
                    const ct = response.headers.get('content-type');
                    if (ct && ct.includes('application/pdf')) {
                        return response.blob().then(blob => {
                            const url = URL.createObjectURL(blob);
                            const a = document.createElement('a');
                            a.href = url;
                            a.download = 'result.pdf';
                            a.click();
                        });
                    } else if (ct && ct.includes('application/zip')) {
                        return response.blob().then(blob => {
                            const url = URL.createObjectURL(blob);
                            const a = document.createElement('a');
                            a.href = url;
                            a.download = 'images.zip';
                            a.click();
                        });
                    } else {
                        return response.text().then(t => alert('Erreur: ' + t));
                    }
                } else return response.text().then(t => alert('Erreur: ' + t));
            })
            .catch(err => alert('Erreur réseau: ' + err))
            .finally(() => { btn.classList.remove('loading'); btn.disabled = false; });
        } else {
            // Let text extraction forward to result page
            document.getElementById('submitBtn').classList.add('loading');
        }
    });
</script>
</body>
</html>
