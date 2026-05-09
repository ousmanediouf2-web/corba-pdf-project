<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("currentPage", "merge");
    request.setAttribute("username", session.getAttribute("username"));
    request.setAttribute("corbaConnected", com.pdfservice.util.CORBAClient.isConnected());
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fusion PDF - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <%@ include file="sidebar.jsp" %>
    <div class="main-content">
        <div class="topbar">
            <div>
                <div class="page-title">Fusion de PDF</div>
                <div class="page-sub">Combinez plusieurs fichiers PDF en un seul document</div>
            </div>
        </div>
        <div class="content-area">
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>

            <div class="card op-form">
                <div class="card-title">
                    📄 Sélectionnez les fichiers PDF à fusionner
                </div>

                <form method="post" action="${pageContext.request.contextPath}/pdf/merge"
                      enctype="multipart/form-data" id="mergeForm">

                    <div class="upload-zone" id="dropZone">
                        <input type="file" name="files" accept=".pdf" multiple id="fileInput"
                               onchange="handleFiles(this.files)">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                            <polyline points="17 8 12 3 7 8"/>
                            <line x1="12" y1="3" x2="12" y2="15"/>
                        </svg>
                        <p><strong>Cliquez</strong> ou glissez vos fichiers PDF ici</p>
                        <p style="font-size:12px;margin-top:6px">Minimum 2 fichiers PDF · Max 50MB par fichier</p>
                    </div>

                    <div class="file-list" id="fileList"></div>

                    <div style="margin-top:20px;display:flex;align-items:center;gap:12px">
                        <button type="submit" class="btn btn-primary" id="submitBtn"
                                style="width:auto;padding:10px 28px">
                            <span class="btn-text">🔗 Fusionner les PDF</span>
                            <div class="loading-spinner"></div>
                        </button>
                        <span id="fileCount" style="font-size:13px;color:var(--text-secondary)">
                            Aucun fichier sélectionné
                        </span>
                    </div>

                    <!-- Ordre des fichiers (drag to reorder hint) -->
                    <p class="hint" style="margin-top:12px">
                        💡 Les fichiers seront fusionnés dans l'ordre affiché. Supprimez et re-ajoutez pour changer l'ordre.
                    </p>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    let selectedFiles = [];

    function handleFiles(files) {
        for (let f of files) {
            if (f.type === 'application/pdf' || f.name.endsWith('.pdf')) {
                selectedFiles.push(f);
            }
        }
        renderFileList();
        updateCount();
    }

    function renderFileList() {
        const list = document.getElementById('fileList');
        list.innerHTML = '';
        selectedFiles.forEach((f, i) => {
            const item = document.createElement('div');
            item.className = 'file-item';
            item.innerHTML = `
                <svg viewBox="0 0 24 24" fill="currentColor"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6zm4 18H6V4h7v5h5v11z"/></svg>
                <span class="file-name">${f.name}</span>
                <span class="file-size">${formatSize(f.size)}</span>
                <button type="button" class="remove-btn" onclick="removeFile(${i})">×</button>
            `;
            list.appendChild(item);
        });
    }

    function removeFile(index) {
        selectedFiles.splice(index, 1);
        renderFileList();
        updateCount();
    }

    function updateCount() {
        const count = selectedFiles.length;
        document.getElementById('fileCount').textContent =
            count === 0 ? 'Aucun fichier sélectionné' :
            count === 1 ? '1 fichier sélectionné (min. 2 requis)' :
            `${count} fichiers sélectionnés`;
    }

    function formatSize(bytes) {
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1024*1024) return (bytes/1024).toFixed(1) + ' KB';
        return (bytes/(1024*1024)).toFixed(1) + ' MB';
    }

    // Drag & drop
    const dropZone = document.getElementById('dropZone');
    dropZone.addEventListener('dragover', (e) => { e.preventDefault(); dropZone.classList.add('dragover'); });
    dropZone.addEventListener('dragleave', () => dropZone.classList.remove('dragover'));
    dropZone.addEventListener('drop', (e) => {
        e.preventDefault();
        dropZone.classList.remove('dragover');
        handleFiles(e.dataTransfer.files);
    });

    // Submit - rebuild FormData with selected files
    document.getElementById('mergeForm').addEventListener('submit', function(e) {
        e.preventDefault();
        if (selectedFiles.length < 2) {
            alert('Veuillez sélectionner au moins 2 fichiers PDF.');
            return;
        }
        const btn = document.getElementById('submitBtn');
        btn.classList.add('loading');
        btn.disabled = true;

        const formData = new FormData();
        selectedFiles.forEach(f => formData.append('files', f));

        fetch('${pageContext.request.contextPath}/pdf/merge', {
            method: 'POST',
            body: formData
        }).then(response => {
            if (response.ok && response.headers.get('content-type') === 'application/pdf') {
                return response.blob().then(blob => {
                    const url = URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = 'merged.pdf';
                    a.click();
                    btn.classList.remove('loading');
                    btn.disabled = false;
                });
            } else {
                return response.text().then(t => { alert('Erreur: ' + t); btn.classList.remove('loading'); btn.disabled = false; });
            }
        }).catch(err => { alert('Erreur réseau: ' + err); btn.classList.remove('loading'); btn.disabled = false; });
    });
</script>
</body>
</html>
