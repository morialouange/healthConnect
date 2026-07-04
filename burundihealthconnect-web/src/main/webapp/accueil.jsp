<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="app.name"/> — <fmt:message key="landing.title.suffix"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<header class="landing-header">
    <div class="logo">&#10010; <fmt:message key="app.name"/></div>
    <nav>
        <a href="${pageContext.request.contextPath}/accueil"><fmt:message key="landing.nav.accueil"/></a>
        <a href="#features"><fmt:message key="landing.nav.features"/></a>
        <a href="#contact"><fmt:message key="landing.nav.contact"/></a>
    </nav>
    <div class="header-btns">
        <button type="button" class="icon-btn" data-theme-toggle title="<fmt:message key='btn.theme'/>" style="color:rgba(255,255,255,0.7);">&#9788;</button>
        <a href="${pageContext.request.contextPath}/auth" class="btn-outline-light"><fmt:message key="auth.login.title"/></a>
        <a href="${pageContext.request.contextPath}/auth?action=register" class="btn-light"><fmt:message key="auth.register.submit"/></a>
    </div>
</header>

<section class="landing-hero">
    <div class="hero-inner">
        <div class="hero-text">
            <h1><fmt:message key="landing.hero.title"/> <span><fmt:message key="landing.hero.title.highlight"/></span></h1>
            <p><fmt:message key="landing.hero.description"/></p>
            <div class="hero-btns">
                <a href="${pageContext.request.contextPath}/auth" class="btn-primary"><fmt:message key="auth.login.title"/></a>
                <a href="${pageContext.request.contextPath}/auth?action=register" class="btn-outline"><fmt:message key="auth.register.submit"/></a>
            </div>
        </div>
        <div class="hero-image">
            <svg width="100%" height="280" viewBox="0 0 480 280" fill="none" xmlns="http://www.w3.org/2000/svg" style="border-radius:16px;box-shadow:0 8px 30px rgba(0,0,0,0.1);">
                <rect width="480" height="280" rx="16" fill="url(#hero-grad)"/>
                <defs>
                    <linearGradient id="hero-grad" x1="0" y1="0" x2="480" y2="280" gradientUnits="userSpaceOnUse">
                        <stop stop-color="#EAF1FD"/>
                        <stop offset="1" stop-color="#C7D9F7"/>
                    </linearGradient>
                </defs>
                <circle cx="350" cy="100" r="60" fill="rgba(30,95,217,0.08)"/>
                <circle cx="350" cy="100" r="40" fill="rgba(30,95,217,0.12)"/>
                <circle cx="350" cy="100" r="20" fill="rgba(30,95,217,0.2)"/>
                <rect x="60" y="170" width="160" height="14" rx="7" fill="rgba(30,95,217,0.15)"/>
                <rect x="60" y="192" width="120" height="10" rx="5" fill="rgba(30,95,217,0.1)"/>
                <rect x="60" y="210" width="140" height="10" rx="5" fill="rgba(30,95,217,0.08)"/>
                <rect x="60" y="234" width="80" height="28" rx="6" fill="rgba(30,95,217,0.15)"/>
            </svg>
        </div>
    </div>
</section>

<section class="landing-features" id="features">
    <h2><fmt:message key="landing.features.title"/></h2>
    <p><fmt:message key="landing.features.subtitle"/></p>
    <div class="feat-grid">
        <div class="feat-card reveal">
            <div class="feat-icon">&#128197;</div>
            <h3><fmt:message key="landing.feature.rdv.title"/></h3>
            <p><fmt:message key="landing.feature.rdv.desc"/></p>
        </div>
        <div class="feat-card reveal">
            <div class="feat-icon">&#128220;</div>
            <h3><fmt:message key="landing.feature.dossier.title"/></h3>
            <p><fmt:message key="landing.feature.dossier.desc"/></p>
        </div>
        <div class="feat-card reveal">
            <div class="feat-icon">&#128101;</div>
            <h3><fmt:message key="landing.feature.patient.title"/></h3>
            <p><fmt:message key="landing.feature.patient.desc"/></p>
        </div>
        <div class="feat-card reveal">
            <div class="feat-icon">&#9877;</div>
            <h3><fmt:message key="landing.feature.medecin.title"/></h3>
            <p><fmt:message key="landing.feature.medecin.desc"/></p>
        </div>
        <div class="feat-card reveal">
            <div class="feat-icon">&#127973;</div>
            <h3><fmt:message key="landing.feature.admin.title"/></h3>
            <p><fmt:message key="landing.feature.admin.desc"/></p>
        </div>
        <div class="feat-card reveal">
            <div class="feat-icon">&#128202;</div>
            <h3><fmt:message key="landing.feature.stats.title"/></h3>
            <p><fmt:message key="landing.feature.stats.desc"/></p>
        </div>
    </div>
</section>

<footer class="landing-footer" id="contact">
    <p>
        <fmt:message key="app.copyright"/> &mdash; 
        <a href="#"><fmt:message key="landing.legal"/></a> &middot; 
        <a href="#"><fmt:message key="landing.nav.contact"/></a> &middot; 
        <a href="mailto:contact@burundihealthconnect.bi">contact@burundihealthconnect.bi</a>
    </p>
</footer>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>