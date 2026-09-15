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
</head>
<body class="flex flex-col min-vh-100 mc-page">
<header class="topbar flex items-center justify-between gap-16 px-24">
<div class="flex items-center gap-10 fw-700 fs-18">
<span class="dot"></span>
<fmt:message key="app.name"/>
</div>
<nav class="flex gap-20 fs-14 fw-500">
<a class="nav-link" href="${pageContext.request.contextPath}/accueil"><fmt:message key="landing.nav.accueil"/></a>
<a class="nav-link" href="#features"><fmt:message key="landing.nav.features"/></a>
<a class="nav-link" href="#contact"><fmt:message key="landing.nav.contact"/></a>
</nav>
<div class="flex items-center gap-10">
<button type="button" class="icon-btn lang-toggle" id="lang-toggle" title="<fmt:message key='btn.lang'/>" aria-label="<fmt:message key='btn.lang'/>"><i data-lucide="globe"></i><span class="lang-label"></span></button>
<button type="button" class="icon-btn theme-toggle" data-theme-toggle title="<fmt:message key='btn.theme'/>" aria-label="<fmt:message key='btn.theme'/>">
<span class="theme-icon">&#9788;</span>
</button>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/auth"><fmt:message key="auth.login.title"/></a>
<a class="btn btn-primary" href="${pageContext.request.contextPath}/auth?action=register"><fmt:message key="auth.register.submit"/></a>
</div>
</header>

<section class="landing-hero flex-grow">
<div class="landing-hero-inner">
<span class="landing-badge"><fmt:message key="landing.badge"/></span>
<h1 class="fs-40 lh-12 mb-16 mt-0"><fmt:message key="landing.hero.title"/>
<span class="text-brand"><fmt:message key="landing.hero.title.highlight"/></span></h1>
<div class="ecg-line mx-auto" aria-hidden="true"></div>
<p class="fs-16 text-secondary lh-16 mb-0 mt-24"><fmt:message key="landing.hero.description"/></p>
<div class="landing-cta">
<a class="btn btn-primary" href="${pageContext.request.contextPath}/auth"><fmt:message key="auth.login.title"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/auth?action=register"><fmt:message key="auth.register.submit"/></a>
</div>
<div class="landing-chips">
<span class="landing-chip"><i data-lucide="calendar-check"></i><fmt:message key="landing.feature.rdv.title"/></span>
<span class="landing-chip"><i data-lucide="file-text"></i><fmt:message key="landing.feature.dossier.title"/></span>
<span class="landing-chip"><i data-lucide="shield-check"></i><fmt:message key="landing.feature.patient.title"/></span>
</div>
</div>
</section>

<section class="py-48 px-32">
<div class="mx-auto maxw-1080">
<div class="card p-0 reveal">
<div class="landing-stats">
<div class="landing-stat reveal">
<span class="landing-stat-value"><fmt:message key="landing.stats.hopitaux"/></span>
<span class="landing-stat-label"><fmt:message key="landing.stats.hopitaux.label"/></span>
</div>
<div class="landing-stat reveal">
<span class="landing-stat-value"><fmt:message key="landing.stats.medecins"/></span>
<span class="landing-stat-label"><fmt:message key="landing.stats.medecins.label"/></span>
</div>
<div class="landing-stat reveal">
<span class="landing-stat-value"><fmt:message key="landing.stats.patients"/></span>
<span class="landing-stat-label"><fmt:message key="landing.stats.patients.label"/></span>
</div>
<div class="landing-stat reveal">
<span class="landing-stat-value"><fmt:message key="landing.stats.rdv"/></span>
<span class="landing-stat-label"><fmt:message key="landing.stats.rdv.label"/></span>
</div>
</div>
</div>
</div>
</section>

<section class="py-48 px-32" id="features">
<div class="mx-auto maxw-1080">
<div class="text-center mb-32">
<h2 class="fs-26 text-primary mb-8 mt-0"><fmt:message key="landing.how.title"/></h2>
<p class="text-secondary mb-0 mt-0"><fmt:message key="landing.how.subtitle"/></p>
</div>
<div class="grid-3">
<div class="card reveal">
<div class="step-num">1</div>
<i data-lucide="user-plus" class="text-brand icon-36 mt-12"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.how.step1.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.how.step1.desc"/></p>
</div>
<div class="card reveal">
<div class="step-num">2</div>
<i data-lucide="calendar-check" class="text-brand icon-36 mt-12"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.how.step2.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.how.step2.desc"/></p>
</div>
<div class="card reveal">
<div class="step-num">3</div>
<i data-lucide="file-text" class="text-brand icon-36 mt-12"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.how.step3.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.how.step3.desc"/></p>
</div>
</div>
</div>
</section>

<section class="py-48 px-32">
<div class="mx-auto maxw-1080">
<div class="text-center mb-32">
<h2 class="fs-26 text-primary mb-8 mt-0"><fmt:message key="landing.features.title"/></h2>
<p class="text-secondary mb-0 mt-0"><fmt:message key="landing.features.subtitle"/></p>
</div>
<div class="grid-3">
<div class="card reveal">
<i data-lucide="calendar-check" class="text-brand icon-36"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.feature.rdv.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.feature.rdv.desc"/></p>
</div>
<div class="card reveal">
<i data-lucide="file-text" class="text-brand icon-36"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.feature.dossier.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.feature.dossier.desc"/></p>
</div>
<div class="card reveal">
<i data-lucide="shield-check" class="text-brand icon-36"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.feature.patient.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.feature.patient.desc"/></p>
</div>
<div class="card reveal">
<i data-lucide="stethoscope" class="text-brand icon-36"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.feature.medecin.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.feature.medecin.desc"/></p>
</div>
<div class="card reveal">
<i data-lucide="building-2" class="text-brand icon-36"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.feature.admin.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.feature.admin.desc"/></p>
</div>
<div class="card reveal">
<i data-lucide="bar-chart-3" class="text-brand icon-36"></i>
<h3 class="fs-17 mt-12 mb-6"><fmt:message key="landing.feature.stats.title"/></h3>
<p class="text-secondary fs-14 lh-16 mb-0"><fmt:message key="landing.feature.stats.desc"/></p>
</div>
</div>
</div>
</section>

<section class="py-48 px-32">
<div class="mx-auto maxw-1080">
<div class="card cta-card reveal">
<h2 class="fs-26 text-primary mb-8 mt-0"><fmt:message key="landing.cta.title"/></h2>
<p class="text-secondary mb-24 mt-0"><fmt:message key="landing.cta.subtitle"/></p>
<a class="btn btn-primary" href="${pageContext.request.contextPath}/auth?action=register"><fmt:message key="landing.cta.button"/></a>
</div>
</div>
</section>

<footer id="contact" class="py-24 px-32 text-center text-secondary fs-14 border-top">
<p class="mb-0">
<fmt:message key="app.copyright"/> &mdash;
<a href="#" class="text-brand nowrap"><fmt:message key="landing.legal"/></a> &middot;
<a href="#" class="text-brand nowrap"><fmt:message key="landing.nav.contact"/></a> &middot;
<a href="mailto:contact@burundihealthconnect.bi" class="text-brand nowrap">contact@burundihealthconnect.bi</a>
</p>
</footer>
<script src="${pageContext.request.contextPath}/js/app.js?v=4"></script>
<script>if(window.lucide) lucide.createIcons();</script>
</body>
</html>
