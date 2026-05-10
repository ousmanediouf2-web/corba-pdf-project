<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% request.setAttribute("page","text");
   request.setAttribute("username",session.getAttribute("username")); %>
<!DOCTYPE html><html lang="fr"><head>
<meta charset="UTF-8"><title>text - CORBA PDF</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head><body><div class="app">
<%@ include file="sidebar.jsp" %>
<div class="main">
  <div class="topbar"><div>
    <div class="page-title" id="ptitle"></div>
    <div class="page-sub" id="psub"></div>
  </div></div>
  <div class="content">
    <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
    <div class="card" style="max-width:680px" id="formCard">
      <div class="card-title" id="cardTitle"></div>
      <!-- Form injected by JS -->
    </div>
  </div>
</div></div>
<script>
const OP = 'text';
const CONFIG = {
  merge:    {title:'Fusion de PDF',          sub:'Combiner plusieurs PDF en un seul',  emoji:'📎', form:'merge'},
  split:    {title:'Decoupage PDF',           sub:'Extraire une plage de pages',         emoji:'✂️', form:'split'},
  extract:  {title:'Extraction de pages',     sub:'Selectionner des pages specifiques',  emoji:'📑', form:'pages', label:'Pages a extraire'},
  delete:   {title:'Suppression de pages',    sub:'Supprimer des pages indesirables',    emoji:'🗑️', form:'pages', label:'Pages a supprimer'},
  password: {title:'Mot de passe',            sub:'Proteger le PDF par mot de passe',   emoji:'🔒', form:'password'},
  convert:  {title:'PDF vers Images',         sub:'Convertir chaque page en PNG',       emoji:'🖼️', form:'convert'},
  text:     {title:'Extraction de texte',     sub:'Extraire le contenu textuel du PDF', emoji:'📝', form:'text'},
  create:   {title:'Creer un PDF',            sub:'Generer un PDF depuis du texte',     emoji:'✨', form:'create'},
};
const c = CONFIG[OP];
document.getElementById('ptitle').textContent   = c.emoji + ' ' + c.title;
document.getElementById('psub').textContent     = c.sub;
document.getElementById('cardTitle').textContent= c.emoji + ' ' + c.title;

const ctx = '${pageContext.request.contextPath}';
const card = document.getElementById('formCard');

function uploadForm(multi) {
  return `<form method="post" action="${ctx}/pdf/${OP}" enctype="multipart/form-data" id="f">
    <div class="form-group"><label>Fichier(s) PDF *</label>
    <div class="upload-zone" id="dz">
      <input type="file" name="file${multi?'s':''}" accept=".pdf" ${multi?'multiple':''} required id="fi" onchange="showFiles(this.files)">
      <div class="icon">📁</div>
      <p><b>Cliquez</b> ou glissez vos PDF ici</p>
      <p id="fn" style="font-size:12px;color:var(--text-s);margin-top:4px">Aucun fichier</p>
    </div>
    <div class="file-list" id="fl"></div></div>`;
}

function submitBtn(label) {
  return `<div style="margin-top:18px;display:flex;gap:10px">
    <button type="submit" class="btn btn-primary" id="sb" style="width:auto;padding:10px 28px">
      <span class="btn-text">${label}</span><div class="spin"></div></button>
    <a href="${ctx}/dashboard" class="btn btn-secondary">← Retour</a>
  </div></form>`;
}

if (c.form === 'merge') {
  card.insertAdjacentHTML('beforeend',
    uploadForm(true) +
    '<p class="hint">Minimum 2 fichiers PDF. Ils seront fusionnes dans l\'ordre selectionne.</p>' +
    submitBtn('📎 Fusionner'));
} else if (c.form === 'split') {
  card.insertAdjacentHTML('beforeend',
    uploadForm(false) +
    `<div style="display:grid;grid-template-columns:1fr 1fr;gap:14px">
      <div class="form-group"><label>Page debut *</label>
        <input type="number" name="startPage" min="1" value="1" required></div>
      <div class="form-group"><label>Page fin *</label>
        <input type="number" name="endPage" min="1" value="5" required></div>
    </div>` +
    submitBtn('✂️ Decouper'));
} else if (c.form === 'pages') {
  card.insertAdjacentHTML('beforeend',
    uploadForm(false) +
    `<div class="form-group"><label>${c.label} *</label>
      <input type="text" name="pages" required placeholder="Ex: 1, 3, 5">
      <p class="hint">Numeros de pages separes par des virgules</p>
    </div>` +
    submitBtn(c.emoji + ' Executer'));
} else if (c.form === 'password') {
  card.insertAdjacentHTML('beforeend',
    uploadForm(false) +
    `<div class="form-group"><label>Mot de passe utilisateur *</label>
      <input type="password" name="userPassword" required placeholder="Pour ouvrir le PDF"></div>
    <div class="form-group"><label>Mot de passe proprietaire</label>
      <input type="password" name="ownerPassword" placeholder="Optionnel - admin"></div>` +
    submitBtn('🔒 Proteger'));
} else if (c.form === 'convert') {
  card.insertAdjacentHTML('beforeend',
    uploadForm(false) +
    `<div class="form-group"><label>Resolution DPI : <b id="dv">150</b></label>
      <input type="range" name="dpi" min="72" max="300" value="150" style="width:100%;margin-top:6px"
        oninput="document.getElementById('dv').textContent=this.value"></div>
    <div class="alert alert-info">Le resultat sera une archive ZIP contenant une image PNG par page.</div>` +
    submitBtn('🖼️ Convertir'));
} else if (c.form === 'text') {
  card.insertAdjacentHTML('beforeend',
    uploadForm(false) +
    '<div class="alert alert-info">Le texte extrait sera affiche directement sur la page.</div>' +
    submitBtn('📝 Extraire le texte'));
} else if (c.form === 'create') {
  card.innerHTML += `<form method="post" action="${ctx}/pdf/create" id="f">
    <div class="form-group"><label>Titre *</label>
      <input type="text" name="title" required placeholder="Titre du document"></div>
    <div class="form-group"><label>Auteur</label>
      <input type="text" name="author" placeholder="Nom de l\'auteur (optionnel)"></div>
    <div class="form-group"><label>Contenu *</label>
      <textarea name="content" required placeholder="Contenu du document..."></textarea></div>
    <div style="margin-top:18px;display:flex;gap:10px">
      <button type="submit" class="btn btn-primary" id="sb" style="width:auto;padding:10px 28px">
        <span class="btn-text">✨ Generer PDF</span><div class="spin"></div></button>
      <a href="${ctx}/dashboard" class="btn btn-secondary">← Retour</a>
    </div></form>`;
}

function showFiles(files) {
  const fn = document.getElementById('fn');
  const fl = document.getElementById('fl');
  if (!fn) return;
  fn.textContent = files.length + ' fichier(s) selectionne(s)';
  if (fl) {
    fl.innerHTML = '';
    Array.from(files).forEach(f => {
      const sz = f.size < 1048576 ? (f.size/1024).toFixed(1)+' KB' : (f.size/1048576).toFixed(1)+' MB';
      fl.insertAdjacentHTML('beforeend',
        `<div class="file-item"><span>📄</span><span class="fname">${f.name}</span>
          <span class="fsize">${sz}</span></div>`);
    });
  }
}

// Drag & drop
const dz = document.getElementById('dz');
if (dz) {
  dz.addEventListener('dragover', e => { e.preventDefault(); dz.classList.add('over'); });
  dz.addEventListener('dragleave', () => dz.classList.remove('over'));
  dz.addEventListener('drop', e => {
    e.preventDefault(); dz.classList.remove('over');
    showFiles(e.dataTransfer.files);
  });
}

// Submit loading
document.getElementById('f').addEventListener('submit', function() {
  const sb = document.getElementById('sb');
  sb.classList.add('loading'); sb.disabled = true;
});
</script>
</body></html>
