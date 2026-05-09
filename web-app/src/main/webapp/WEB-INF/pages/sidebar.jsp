<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-logo">
            <div class="logo-box">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6zm4 18H6V4h7v5h5v11z"/></svg>
            </div>
            <div>
                <span>PDF Service</span>
                <small>CORBA Edition</small>
            </div>
        </a>
    </div>

    <div class="sidebar-user">
        <div class="user-info">
            <div class="user-avatar">${username.substring(0,1).toUpperCase()}</div>
            <div>
                <div class="user-name">${username}</div>
                <div class="user-role">${sessionScope.user.role}</div>
            </div>
        </div>
    </div>

    <nav>
        <div class="nav-section">
            <div class="nav-section-label">Principal</div>
            <a href="${pageContext.request.contextPath}/dashboard"
               class="nav-item ${currentPage == 'dashboard' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
                    <rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/>
                </svg>
                Tableau de bord
            </a>
            <a href="${pageContext.request.contextPath}/history"
               class="nav-item ${currentPage == 'history' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
                    <path d="M3 3v5h5"/><path d="M12 7v5l4 2"/>
                </svg>
                Historique
            </a>
        </div>

        <div class="nav-section">
            <div class="nav-section-label">Opérations PDF</div>
            <a href="${pageContext.request.contextPath}/pdf/merge"
               class="nav-item ${currentPage == 'merge' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M8 6H5a2 2 0 0 0-2 2v10c0 1.1.9 2 2 2h3"/>
                    <path d="M16 6h3a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-3"/>
                    <path d="M12 2v20M8 9l4-4 4 4"/>
                </svg>
                Fusion de PDF
            </a>
            <a href="${pageContext.request.contextPath}/pdf/split"
               class="nav-item ${currentPage == 'split' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                    <polyline points="7 10 12 15 17 10"/>
                    <line x1="12" y1="15" x2="12" y2="3"/>
                </svg>
                Découpage
            </a>
            <a href="${pageContext.request.contextPath}/pdf/extract"
               class="nav-item ${currentPage == 'extract' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/>
                    <line x1="16" y1="17" x2="8" y2="17"/>
                    <polyline points="10 9 9 9 8 9"/>
                </svg>
                Extraction pages
            </a>
            <a href="${pageContext.request.contextPath}/pdf/delete"
               class="nav-item ${currentPage == 'delete' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polyline points="3 6 5 6 21 6"/>
                    <path d="M19 6l-1 14H6L5 6"/>
                    <path d="M10 11v6M14 11v6"/>
                </svg>
                Suppression pages
            </a>
            <a href="${pageContext.request.contextPath}/pdf/password"
               class="nav-item ${currentPage == 'password' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
                Mot de passe
            </a>
            <a href="${pageContext.request.contextPath}/pdf/convert"
               class="nav-item ${currentPage == 'convert' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                    <circle cx="8.5" cy="8.5" r="1.5"/>
                    <polyline points="21 15 16 10 5 21"/>
                </svg>
                PDF → Images
            </a>
            <a href="${pageContext.request.contextPath}/pdf/text"
               class="nav-item ${currentPage == 'text' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="17" y1="10" x2="3" y2="10"/>
                    <line x1="21" y1="6" x2="3" y2="6"/>
                    <line x1="21" y1="14" x2="3" y2="14"/>
                    <line x1="17" y1="18" x2="3" y2="18"/>
                </svg>
                Extraction texte
            </a>
            <a href="${pageContext.request.contextPath}/pdf/create"
               class="nav-item ${currentPage == 'create' ? 'active' : ''}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="12" y1="5" x2="12" y2="19"/>
                    <line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
                Créer un PDF
            </a>
        </div>
    </nav>

    <div class="sidebar-footer">
        <div class="corba-status">
            <div class="status-dot ${corbaConnected ? 'online' : 'offline'}"></div>
            Serveur CORBA: ${corbaConnected ? 'En ligne' : 'Hors ligne'}
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                <polyline points="16 17 21 12 16 7"/>
                <line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
            Déconnexion
        </a>
    </div>
</aside>
