<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<div class="app-shell">

    <aside class="sidebar">
        <div class="logo-area">
            <div class="logo">
                <span class="logo-dot"></span>
                <span><fmt:message key="app.name"/></span>
            </div>
            <button type="button" class="collapse-btn" title="<fmt:message key='btn.collapse'/>">&#8592;</button>
        </div>

        <c:if test="${sessionScope.role == 'PATIENT'}">
            <div class="nav-section-title"><fmt:message key="nav.patient.title"/></div>
            <nav>
                <a href="${pageContext.request.contextPath}/patient/dashboard"
                   class="${pageRoute == 'patient-dashboard' ? 'active' : ''}">
                    <span class="icon">&#9632;</span> <fmt:message key="nav.patient.dashboard"/>
                </a>
                <a href="${pageContext.request.contextPath}/patient/dossier"
                   class="${pageRoute == 'patient-dossier' ? 'active' : ''}">
                    <span class="icon">&#9636;</span> <fmt:message key="nav.patient.dossier"/>
                </a>
                <a href="${pageContext.request.contextPath}/patient/rdv/hopitaux"
                   class="${pageRoute == 'patient-rdv' ? 'active' : ''}">
                    <span class="icon">&#128197;</span> <fmt:message key="nav.patient.rdv"/>
                </a>
                <a href="${pageContext.request.contextPath}/patient/notifications"
                   class="${pageRoute == 'patient-notifications' ? 'active' : ''}">
                    <span class="icon">&#128276;</span> <fmt:message key="nav.patient.notifications"/>
                    <c:if test="${notifNonLues > 0}"><span class="badge-notif">${notifNonLues}</span></c:if>
                </a>
            </nav>
        </c:if>

        <c:if test="${sessionScope.role == 'MEDECIN'}">
            <div class="nav-section-title"><fmt:message key="nav.medecin.title"/></div>
            <nav>
                <a href="${pageContext.request.contextPath}/medecin/dashboard"
                   class="${pageRoute == 'medecin-dashboard' ? 'active' : ''}">
                    <span class="icon">&#9632;</span> <fmt:message key="nav.medecin.dashboard"/>
                </a>
                <a href="${pageContext.request.contextPath}/medecin/rdv"
                   class="${pageRoute == 'medecin-rdv' ? 'active' : ''}">
                    <span class="icon">&#128197;</span> <fmt:message key="nav.medecin.rdv"/>
                </a>
                <a href="${pageContext.request.contextPath}/medecin/consultations"
                   class="${pageRoute == 'medecin-consultations' ? 'active' : ''}">
                    <span class="icon">&#128221;</span> <fmt:message key="nav.medecin.consultations"/>
                </a>
                <a href="${pageContext.request.contextPath}/medecin/notifications"
                   class="${pageRoute == 'medecin-notifications' ? 'active' : ''}">
                    <span class="icon">&#128276;</span> <fmt:message key="nav.medecin.notifications"/>
                    <c:if test="${notifNonLues > 0}"><span class="badge-notif">${notifNonLues}</span></c:if>
                </a>
                <a href="${pageContext.request.contextPath}/medecin/referenements"
                   class="${pageRoute == 'medecin-referenements' ? 'active' : ''}">
                    <span class="icon">&#128279;</span> <fmt:message key="nav.medecin.referenements"/>
                </a>
                <a href="${pageContext.request.contextPath}/medecin/ordonnances"
                   class="${pageRoute == 'medecin-ordonnances' ? 'active' : ''}">
                    <span class="icon">&#128220;</span> <fmt:message key="nav.medecin.ordonnances"/>
                </a>
                <a href="${pageContext.request.contextPath}/medecin/dossier"
                   class="${pageRoute == 'medecin-dossier' ? 'active' : ''}">
                    <span class="icon">&#128269;</span> <fmt:message key="nav.medecin.dossier"/>
                </a>
                <a href="${pageContext.request.contextPath}/medecin/disponibilite/mes-semaines"
                   class="${pageRoute == 'medecin-disponibilite' ? 'active' : ''}">
                    <span class="icon">&#9201;</span> <fmt:message key="nav.medecin.disponibilites"/>
                </a>
                <a href="${pageContext.request.contextPath}/medecin/conge"
                   class="${pageRoute == 'medecin-conge' ? 'active' : ''}">
                    <span class="icon">&#127796;</span> <fmt:message key="nav.medecin.conges"/>
                </a>
            </nav>
        </c:if>

        <c:if test="${sessionScope.role == 'ADMIN'}">
            <div class="nav-section-title"><fmt:message key="nav.admin.title"/></div>
            <nav>
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="${pageRoute == 'admin-dashboard' ? 'active' : ''}">
                    <span class="icon">&#9632;</span> <fmt:message key="nav.admin.dashboard"/>
                </a>
                <a href="${pageContext.request.contextPath}/admin/medecins"
                   class="${pageRoute == 'admin-medecins' ? 'active' : ''}">
                    <span class="icon">&#128104;&#8205;&#9877;</span> <fmt:message key="nav.admin.medecins"/>
                </a>
                <a href="${pageContext.request.contextPath}/admin/services"
                   class="${pageRoute == 'admin-services' ? 'active' : ''}">
                    <span class="icon">&#127973;</span> <fmt:message key="nav.admin.services"/>
                </a>
                <a href="${pageContext.request.contextPath}/admin/conges"
                   class="${pageRoute == 'admin-conges' ? 'active' : ''}">
                    <span class="icon">&#127796;</span> <fmt:message key="nav.admin.conges"/>
                </a>
                <a href="${pageContext.request.contextPath}/admin/referenements"
                   class="${pageRoute == 'admin-referenements' ? 'active' : ''}">
                    <span class="icon">&#128279;</span> <fmt:message key="nav.admin.referenements"/>
                </a>
                <a href="${pageContext.request.contextPath}/admin/rapport"
                   class="${pageRoute == 'admin-rapport' ? 'active' : ''}">
                    <span class="icon">&#128202;</span> <fmt:message key="nav.admin.rapport"/>
                </a>
            </nav>
        </c:if>

        <c:if test="${sessionScope.role == 'SUPER_ADMIN'}">
            <div class="nav-section-title"><fmt:message key="nav.superadmin.title"/></div>
            <nav>
                <a href="${pageContext.request.contextPath}/superadmin/dashboard"
                   class="${pageRoute == 'superadmin-dashboard' ? 'active' : ''}">
                    <span class="icon">&#9632;</span> <fmt:message key="nav.superadmin.dashboard"/>
                </a>
                <a href="${pageContext.request.contextPath}/superadmin/hopitaux"
                   class="${pageRoute == 'superadmin-hopitaux' ? 'active' : ''}">
                    <span class="icon">&#127973;</span> <fmt:message key="nav.superadmin.hopitaux"/>
                </a>
                <a href="${pageContext.request.contextPath}/superadmin/stats"
                   class="${pageRoute == 'superadmin-stats' ? 'active' : ''}">
                    <span class="icon">&#128202;</span> <fmt:message key="nav.superadmin.stats"/>
                </a>
                <a href="${pageContext.request.contextPath}/superadmin/journal"
                   class="${pageRoute == 'superadmin-journal' ? 'active' : ''}">
                    <span class="icon">&#128203;</span> <fmt:message key="nav.superadmin.journal"/>
                </a>
                <a href="${pageContext.request.contextPath}/superadmin/historique"
                   class="${pageRoute == 'superadmin-historique' ? 'active' : ''}">
                    <span class="icon">&#8634;</span> <fmt:message key="nav.superadmin.historique"/>
                </a>
                <a href="${pageContext.request.contextPath}/superadmin/audit"
                   class="${pageRoute == 'superadmin-audit' ? 'active' : ''}">
                    <span class="icon">&#128203;</span> <fmt:message key="nav.superadmin.audit"/>
                </a>
            </nav>
        </c:if>

        <div class="nav-section-title"><fmt:message key="nav.compte"/></div>
        <nav>
            <a href="?lang=fr" class="${sessionScope.langue == 'fr' || sessionScope.langue == null ? 'active' : ''}">
                <span class="icon">&#127760;</span> Français
            </a>
            <a href="?lang=en" class="${sessionScope.langue == 'en' ? 'active' : ''}">
                <span class="icon">&#127760;</span> English
            </a>
            <a href="${pageContext.request.contextPath}/profil/mon-profil">
                <span class="icon">&#128100;</span> <fmt:message key="btn.profile"/>
            </a>
            <a href="${pageContext.request.contextPath}/auth?action=logout" onclick="return confirm('<fmt:message key="confirm.logout"/>')">
                <span class="icon">&#10148;</span> <fmt:message key="nav.logout"/>
            </a>
        </nav>

        <div class="sidebar-footer">
            <fmt:message key="app.copyright"/>
        </div>
    </aside>

    <div class="main-area">
        <header class="topbar">
            <div class="topbar-left">
                <span class="page-title">${pageTitre}</span>
                <span class="greeting"></span><span class="greeting-sep">, </span><span class="user-name-topbar">${sessionScope.fullName}</span>
            </div>
            <div class="user-zone">
                <a href="${pageContext.request.contextPath}/profil/mon-profil" class="profil-link" title="Mon profil">
                    <span class="user-circle">${fn:substring(sessionScope.fullName, 0, 1)}</span>
                </a>
                <span class="user-name">${sessionScope.fullName}</span>
                <button type="button" class="icon-btn" data-theme-toggle title="<fmt:message key='btn.theme'/>">&#9788;</button>
            </div>
        </header>

        <main class="content">
            <c:if test="${not empty param.erreur}">
                <div class="alerte alerte-erreur">${param.erreur}</div>
            </c:if>
            <c:if test="${not empty requestScope.erreur}">
                <div class="alerte alerte-erreur">${requestScope.erreur}</div>
            </c:if>
            <c:if test="${not empty param.succes or not empty requestScope.succes}">
                <div class="alerte alerte-succes">
                    <c:choose>
                        <c:when test="${not empty requestScope.succes}">${requestScope.succes}</c:when>
                        <c:otherwise><fmt:message key="message.success.operation"/></c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            <c:if test="${not empty param.alerteAllergie}">
                <div class="alerte alerte-erreur">
                    <fmt:message key="message.alert.allergie"/>
                </div>
            </c:if>
