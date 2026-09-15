<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:if test="${empty requestScope.salutationCle}"><c:set scope="request" var="salutationCle" value="greeting.afternoon"/></c:if>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<div class="app-shell">
    <aside class="sidebar">
        <div class="sidebar-logo">
            <span class="dot"></span>
            <span><fmt:message key="app.name"/></span>
            <button type="button" class="sidebar-close icon-btn" aria-label="<fmt:message key='btn.close'/>">&#10005;</button>
        </div>

        <c:if test="${requestScope.roleCode == 'PATIENT'}">
            <nav>
                <ul class="sidebar-nav">
                    <li><a class="sidebar-item ${pageRoute == 'patient-dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/patient/dashboard" aria-label="<fmt:message key='nav.patient.dashboard'/>"><i class="icon" data-lucide="layout-dashboard"></i> <fmt:message key="nav.patient.dashboard"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'patient-dossier' ? 'active' : ''}" href="${pageContext.request.contextPath}/patient/dossier" aria-label="<fmt:message key='nav.patient.dossier'/>"><i class="icon" data-lucide="folder-open"></i> <fmt:message key="nav.patient.dossier"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'patient-rdv' ? 'active' : ''}" href="${pageContext.request.contextPath}/patient/rdv/hopitaux" aria-label="<fmt:message key='nav.patient.rdv'/>"><i class="icon" data-lucide="calendar-check"></i> <fmt:message key="nav.patient.rdv"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'patient-notifications' ? 'active' : ''}" href="${pageContext.request.contextPath}/patient/notifications" aria-label="<fmt:message key='nav.patient.notifications'/>"><i class="icon" data-lucide="bell"></i> <fmt:message key="nav.patient.notifications"/></a></li>
                </ul>
            </nav>
        </c:if>

        <c:if test="${requestScope.roleCode == 'MEDECIN'}">
            <nav>
                <ul class="sidebar-nav">
                    <li><a class="sidebar-item ${pageRoute == 'medecin-dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/dashboard" aria-label="<fmt:message key='nav.medecin.dashboard'/>"><i class="icon" data-lucide="layout-dashboard"></i> <fmt:message key="nav.medecin.dashboard"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'medecin-rdv' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/rdv" aria-label="<fmt:message key='nav.medecin.rdv'/>"><i class="icon" data-lucide="calendar-check"></i> <fmt:message key="nav.medecin.rdv"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'medecin-consultations' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/consultations" aria-label="<fmt:message key='nav.medecin.consultations'/>"><i class="icon" data-lucide="stethoscope"></i> <fmt:message key="nav.medecin.consultations"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'medecin-notifications' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/notifications" aria-label="<fmt:message key='nav.medecin.notifications'/>"><i class="icon" data-lucide="bell"></i> <fmt:message key="nav.medecin.notifications"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'medecin-referenements' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/referenements" aria-label="<fmt:message key='nav.medecin.referenements'/>"><i class="icon" data-lucide="link"></i> <fmt:message key="nav.medecin.referenements"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'medecin-ordonnances' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/ordonnances" aria-label="<fmt:message key='nav.medecin.ordonnances'/>"><i class="icon" data-lucide="file-text"></i> <fmt:message key="nav.medecin.ordonnances"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'medecin-dossier' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/dossier" aria-label="<fmt:message key='nav.medecin.dossier'/>"><i class="icon" data-lucide="search"></i> <fmt:message key="nav.medecin.dossier"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'medecin-disponibilite' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/disponibilite/mes-semaines" aria-label="<fmt:message key='nav.medecin.disponibilites'/>"><i class="icon" data-lucide="clock"></i> <fmt:message key="nav.medecin.disponibilites"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'medecin-conge' ? 'active' : ''}" href="${pageContext.request.contextPath}/medecin/conge" aria-label="<fmt:message key='nav.medecin.conges'/>"><i class="icon" data-lucide="palm-tree"></i> <fmt:message key="nav.medecin.conges"/></a></li>
                </ul>
            </nav>
        </c:if>

        <c:if test="${requestScope.roleCode == 'ADMIN'}">
            <nav>
                <ul class="sidebar-nav">
                    <li><a class="sidebar-item ${pageRoute == 'admin-dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard" aria-label="<fmt:message key='nav.admin.dashboard'/>"><i class="icon" data-lucide="layout-dashboard"></i> <fmt:message key="nav.admin.dashboard"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'admin-medecins' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/medecins" aria-label="<fmt:message key='nav.admin.medecins'/>"><i class="icon" data-lucide="user-round-cog"></i> <fmt:message key="nav.admin.medecins"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'admin-services' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/services" aria-label="<fmt:message key='nav.admin.services'/>"><i class="icon" data-lucide="building-2"></i> <fmt:message key="nav.admin.services"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'admin-conges' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/conges" aria-label="<fmt:message key='nav.admin.conges'/>"><i class="icon" data-lucide="palm-tree"></i> <fmt:message key="nav.admin.conges"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'admin-referenements' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/referenements" aria-label="<fmt:message key='nav.admin.referenements'/>"><i class="icon" data-lucide="link"></i> <fmt:message key="nav.admin.referenements"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'admin-rapport' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/rapport" aria-label="<fmt:message key='nav.admin.rapport'/>"><i class="icon" data-lucide="bar-chart-3"></i> <fmt:message key="nav.admin.rapport"/></a></li>
                </ul>
            </nav>
        </c:if>

        <c:if test="${requestScope.roleCode == 'SUPER_ADMIN'}">
            <nav>
                <ul class="sidebar-nav">
                    <li><a class="sidebar-item ${pageRoute == 'superadmin-dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/superadmin/dashboard" aria-label="<fmt:message key='nav.superadmin.dashboard'/>"><i class="icon" data-lucide="layout-dashboard"></i> <fmt:message key="nav.superadmin.dashboard"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'superadmin-hopitaux' ? 'active' : ''}" href="${pageContext.request.contextPath}/superadmin/hopitaux" aria-label="<fmt:message key='nav.superadmin.hopitaux'/>"><i class="icon" data-lucide="building-2"></i> <fmt:message key="nav.superadmin.hopitaux"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'superadmin-stats' ? 'active' : ''}" href="${pageContext.request.contextPath}/superadmin/stats" aria-label="<fmt:message key='nav.superadmin.stats'/>"><i class="icon" data-lucide="bar-chart-3"></i> <fmt:message key="nav.superadmin.stats"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'superadmin-journal' ? 'active' : ''}" href="${pageContext.request.contextPath}/superadmin/journal" aria-label="<fmt:message key='nav.superadmin.journal'/>"><i class="icon" data-lucide="book-open"></i> <fmt:message key="nav.superadmin.journal"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'superadmin-historique' ? 'active' : ''}" href="${pageContext.request.contextPath}/superadmin/historique" aria-label="<fmt:message key='nav.superadmin.historique'/>"><i class="icon" data-lucide="history"></i> <fmt:message key="nav.superadmin.historique"/></a></li>
                    <li><a class="sidebar-item ${pageRoute == 'superadmin-audit' ? 'active' : ''}" href="${pageContext.request.contextPath}/superadmin/audit" aria-label="<fmt:message key='nav.superadmin.audit'/>"><i class="icon" data-lucide="scroll-text"></i> <fmt:message key="nav.superadmin.audit"/></a></li>
                </ul>
            </nav>
        </c:if>

        <div class="sidebar-footer">
            <a class="profile-chip" href="${pageContext.request.contextPath}/profil/mon-profil" title="<fmt:message key='btn.profile'/>">
                <span class="chip-text">
                    <span class="user-name">${sessionScope.fullName}</span>
                    <span class="role"><c:choose>
                        <c:when test="${requestScope.roleCode == 'SUPER_ADMIN'}"><fmt:message key="role.super_admin"/></c:when>
                        <c:when test="${requestScope.roleCode == 'ADMIN'}"><fmt:message key="role.admin"/></c:when>
                        <c:when test="${requestScope.roleCode == 'MEDECIN'}"><fmt:message key="role.medecin"/></c:when>
                        <c:otherwise><fmt:message key="role.patient"/></c:otherwise>
                    </c:choose></span>
                </span>
            </a>
            <nav>
                <ul class="sidebar-nav">
                    <li><a class="sidebar-item" href="${pageContext.request.contextPath}/auth?action=logout" onclick="return confirmApp(this, event, '<fmt:message key="confirm.logout"/>')" aria-label="<fmt:message key='nav.logout'/>"><i class="icon" data-lucide="log-out"></i> <fmt:message key="nav.logout"/></a></li>
                </ul>
            </nav>
            <div class="copyright"><fmt:message key="app.copyright"/></div>
        </div>
    </aside>

    <div class="sidebar-backdrop" aria-hidden="true"></div>

    <div id="confirm-backdrop" class="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="confirm-title" aria-hidden="true">
        <div class="modal-card">
            <div class="modal-icon">&#9888;</div>
            <h3 id="confirm-title"><fmt:message key="confirm.title"/></h3>
            <p id="confirm-message"></p>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" id="confirm-cancel"><fmt:message key="confirm.cancel"/></button>
                <button type="button" class="btn btn-danger" id="confirm-ok"><fmt:message key="confirm.ok"/></button>
            </div>
        </div>
    </div>

    <div class="main-area">
        <a class="skip-link" href="#main-content"><fmt:message key="nav.skip"/></a>
        <c:choose>
            <c:when test="${requestScope.roleCode == 'PATIENT'}"><c:set var="notifUrl" value="${pageContext.request.contextPath}/patient/notifications"/></c:when>
            <c:otherwise><c:set var="notifUrl" value="${pageContext.request.contextPath}/medecin/notifications"/></c:otherwise>
        </c:choose>

        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="sidebar-toggle-btn" aria-label="<fmt:message key='btn.menu'/>">
                    <i data-lucide="panel-left-close"></i>
                </button>
            </div>

            <div class="topbar-actions">
                <c:if test="${requestScope.roleCode == 'PATIENT' or requestScope.roleCode == 'MEDECIN'}">
                    <a class="icon-btn" href="${notifUrl}" aria-label="<fmt:message key='nav.notifications'/>">
                        <i data-lucide="bell"></i>
                        <c:if test="${notifNonLues > 0}"><span class="dot-alert"></span></c:if>
                    </a>
                </c:if>

                <button type="button" class="icon-btn" id="lang-toggle" title="<fmt:message key='btn.lang'/>" aria-label="<fmt:message key='btn.lang'/>">
                    <i data-lucide="globe"></i><span class="lang-label"></span>
                </button>

                <button type="button" class="icon-btn" id="theme-toggle" title="<fmt:message key='btn.theme'/>" aria-label="<fmt:message key='btn.theme'/>">&#9788;</button>
            </div>
        </header>

        <main id="main-content" class="content">
            <header class="page-header-bloc <c:if test='${not empty requestScope.pageDateJour}'>page-header-with-actions</c:if>">
                <div class="page-header-text">
                    <h1>${pageTitre}</h1>
                    <p class="page-intro"><fmt:message key="${salutationCle}"/>, ${sessionScope.fullName}</p>
                </div>
                <c:if test="${not empty requestScope.pageDateJour}">
                    <div class="page-header-right">
                        <span class="date-today">
                            <i data-lucide="calendar-days"></i>
                            <fmt:formatDate value="${requestScope.pageDateJour}" type="date" dateStyle="long"/>
                        </span>
                        <c:if test="${not empty requestScope.pageHeaderButtonHref}">
                            <a class="btn btn-secondary btn-sm" href="${requestScope.pageHeaderButtonHref}">
                                <i data-lucide="file-bar-chart"></i>
                                ${requestScope.pageHeaderButtonLabel}
                            </a>
                        </c:if>
                    </div>
                </c:if>
            </header>

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
