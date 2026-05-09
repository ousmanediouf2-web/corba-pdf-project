<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setAttribute("currentPage", "dashboard");
    request.setAttribute("username", session.getAttribute("username"));
    request.setAttribute("corbaConnected", request.getAttribute("corbaConnected"));
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - CORBA PDF Service</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="app-layout">
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="topbar">
            <div>
                <div class="page-title">Tableau de bord</div>
                <div class="page-sub">Bienvenue, ${username} !</div>
            </div>
            <div style="font-size:12px;color:var(--text-secondary)">
                <fmt:formatDate value="<%= new java.util.Date() %>" pattern="EEEE d MMMM yyyy" />
            </div>
        </div>

        <div class="content-area">

            <!-- Alerte CORBA -->
            <c:if test="${!corbaConnected}">
                <div class="alert alert-error" style="margin-bottom:20px">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>
                    <strong>Serveur CORBA hors ligne.</strong> Démarrez le serveur CORBA pour utiliser les opérations PDF.
                </div>
            </c:if>

            <!-- Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        </svg>
                    </div>
                    <div>
                        <div class="stat-value">${totalOps}</div>
                        <div class="stat-label">Opérations effectuées</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                            <polyline points="22 4 12 14.01 9 11.01"/>
                        </svg>
                    </div>
                    <div>
                        <div class="stat-value" style="color:${corbaConnected ? 'var(--secondary)' : 'var(--danger)'}">
                            ${corbaConnected ? 'En ligne' : 'Hors ligne'}
                        </div>
                        <div class="stat-label">Statut serveur CORBA</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon purple">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                    </div>
                    <div>
                        <div class="stat-value">${username}</div>
                        <div class="stat-label">Connecté en tant que</div>
                    </div>
                </div>
            </div>

            <!-- Opérations disponibles -->
            <div class="card">
                <div class="card-title">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    Opérations disponibles
                </div>
                <div class="ops-grid">
                    <a href="${pageContext.request.contextPath}/pdf/merge" class="op-card">
                        <div class="op-icon" style="background:#eff6ff">📄</div>
                        <div>
                            <h3>Fusion de PDF</h3>
                            <p>Combinez plusieurs fichiers PDF en un seul document</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/pdf/split" class="op-card">
                        <div class="op-icon" style="background:#faf5ff">✂️</div>
                        <div>
                            <h3>Découpage</h3>
                            <p>Extrayez une plage de pages de votre PDF</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/pdf/extract" class="op-card">
                        <div class="op-icon" style="background:#f0fdf4">📑</div>
                        <div>
                            <h3>Extraction de pages</h3>
                            <p>Sélectionnez des pages spécifiques à extraire</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/pdf/delete" class="op-card">
                        <div class="op-icon" style="background:#fef2f2">🗑️</div>
                        <div>
                            <h3>Suppression de pages</h3>
                            <p>Supprimez des pages indésirables de votre PDF</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/pdf/password" class="op-card">
                        <div class="op-icon" style="background:#fffbeb">🔒</div>
                        <div>
                            <h3>Mot de passe</h3>
                            <p>Protégez votre PDF avec un mot de passe</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/pdf/convert" class="op-card">
                        <div class="op-icon" style="background:#f0fdf4">🖼️</div>
                        <div>
                            <h3>PDF → Images</h3>
                            <p>Convertissez chaque page PDF en image PNG</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/pdf/text" class="op-card">
                        <div class="op-icon" style="background:#eff6ff">📝</div>
                        <div>
                            <h3>Extraction de texte</h3>
                            <p>Extrayez tout le texte de votre document PDF</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/pdf/create" class="op-card">
                        <div class="op-icon" style="background:#faf5ff">✨</div>
                        <div>
                            <h3>Créer un PDF</h3>
                            <p>Générez un nouveau PDF à partir de texte</p>
                        </div>
                    </a>
                </div>
            </div>

            <!-- Activité récente -->
            <c:if test="${not empty recentOps}">
                <div class="card">
                    <div class="card-title">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
                            <path d="M3 3v5h5"/><path d="M12 7v5l4 2"/>
                        </svg>
                        Activité récente
                    </div>
                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th>Opération</th>
                                    <th>Fichier source</th>
                                    <th>Résultat</th>
                                    <th>Durée</th>
                                    <th>Date</th>
                                    <th>Statut</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="op" items="${recentOps}">
                                    <tr>
                                        <td><strong>${op.operationLabel}</strong></td>
                                        <td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${op.inputFilename}</td>
                                        <td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${op.outputFilename}</td>
                                        <td>${op.durationMs}ms</td>
                                        <td><fmt:formatDate value="${op.createdAt}" pattern="dd/MM HH:mm"/></td>
                                        <td>
                                            <span class="badge ${op.status == 'success' ? 'badge-success' : 'badge-error'}">
                                                ${op.status == 'success' ? '✓ Succès' : '✗ Erreur'}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div style="margin-top:12px;text-align:right">
                        <a href="${pageContext.request.contextPath}/history" class="btn btn-secondary" style="font-size:12px">
                            Voir tout l'historique →
                        </a>
                    </div>
                </div>
            </c:if>

        </div>
    </div>
</div>
</body>
</html>
