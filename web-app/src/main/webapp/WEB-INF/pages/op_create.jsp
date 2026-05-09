<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("currentPage", "create");
    request.setAttribute("username", session.getAttribute("username"));
    request.setAttribute("corbaConnected", com.pdfservice.util.CORBAClient.isConnected());
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Créer PDF - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <%@ include file="sidebar.jsp" %>
    <div class="main-content">
        <div class="topbar">
            <div>
                <div class="page-title">Créer un PDF</div>
                <div class="page-sub">Générez un nouveau document PDF à partir de texte</div>
            </div>
        </div>
        <div class="content-area">
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>

            <div class="card op-form">
                <div class="card-title">✨ Nouveau document PDF</div>

                <form method="post" action="${pageContext.request.contextPath}/pdf/create"
                      id="createForm">
                    <div class="form-group">
                        <label>Titre du document <span style="color:#ef4444">*</span></label>
                        <input type="text" name="title" required
                               placeholder="Ex: Rapport Annuel 2025" value="${param.title}">
                    </div>
                    <div class="form-group">
                        <label>Auteur</label>
                        <input type="text" name="author"
                               placeholder="Votre nom (optionnel)"
                               value="${not empty param.author ? param.author : username}">
                    </div>
                    <div class="form-group">
                        <label>Contenu <span style="color:#ef4444">*</span></label>
                        <textarea name="content" required
                                  placeholder="Saisissez le contenu de votre document ici...&#10;&#10;Utilisez des retours à la ligne pour structurer votre texte."
                                  style="min-height:250px">${param.content}</textarea>
                        <p class="hint">Le contenu sera formaté automatiquement avec titre et pagination.</p>
                    </div>

                    <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
                        <button type="submit" class="btn btn-primary" id="createBtn"
                                style="width:auto;padding:10px 28px">
                            <span class="btn-text">✨ Générer le PDF</span>
                            <div class="loading-spinner"></div>
                        </button>
                        <button type="button" class="btn btn-secondary"
                                onclick="document.getElementById('createForm').reset()">
                            Réinitialiser
                        </button>
                        <span id="charCount" style="font-size:12px;color:var(--text-secondary)">0 caractères</span>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
    const textarea = document.querySelector('textarea[name="content"]');
    const charCount = document.getElementById('charCount');

    textarea.addEventListener('input', () => {
        charCount.textContent = textarea.value.length + ' caractères';
    });

    document.getElementById('createBtn').addEventListener('click', function() {
        this.classList.add('loading');
        this.disabled = true;
        setTimeout(() => { this.classList.remove('loading'); this.disabled = false; }, 10000);
    });

    document.getElementById('createForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const btn = document.getElementById('createBtn');
        btn.classList.add('loading'); btn.disabled = true;

        const formData = new FormData(this);
        fetch('${pageContext.request.contextPath}/pdf/create', {
            method: 'POST',
            body: new URLSearchParams(formData)
        }).then(response => {
            if (response.ok) {
                return response.blob().then(blob => {
                    const url = URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = (document.querySelector('[name=title]').value || 'document') + '.pdf';
                    a.click();
                });
            } else return response.text().then(t => alert('Erreur: ' + t));
        }).catch(err => alert('Erreur: ' + err))
          .finally(() => { btn.classList.remove('loading'); btn.disabled = false; });
    });
</script>
</body>
</html>
