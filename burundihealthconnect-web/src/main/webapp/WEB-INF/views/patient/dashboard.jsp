<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="patient-dashboard"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.dashboard"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.dashboard"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

<c:if test="${completudeProfil < 100}">
<div class="card alert-card reveal">
<div class="alert-title"><fmt:message key="patient.dashboard.profil_incomplet_title"/></div>
<div class="alert-items">
<div class="alert-row">
<span>&#128100;</span>
<span><strong>${completudeProfil}%</strong> — <fmt:message key="patient.dashboard.profil_complete_desc"/></span>
<a class="alert-link" href="${pageContext.request.contextPath}/profil/mon-profil"><fmt:message key="patient.dashboard.action.completer_profil"/></a>
</div>
</div>
</div>
</c:if>

<div class="kpi-grid">
<a class="kpi-card stat-box reveal" href="#prochain-rdv">
<div class="kpi-icon"><i data-lucide="calendar-check"></i></div>
<div class="kpi-label"><fmt:message key="patient.dashboard.prochain_rdv"/></div>
<div class="kpi-value">
<c:choose>
<c:when test="${not empty stats.prochainRdv}">${stats.prochainRdv}</c:when>
<c:otherwise>&mdash;</c:otherwise>
</c:choose>
</div>
</a>
<a class="kpi-card stat-box reveal" href="#historique-rdv">
<div class="kpi-icon alert"><i data-lucide="clock"></i></div>
<div class="kpi-label"><fmt:message key="patient.dashboard.rdv_attente"/></div>
<div class="kpi-value">${stats.rdvEnAttenteConfirmation}</div>
<c:set var="t" value="${stats.trendRdvEnAttenteConfirmation}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</a>
<a class="kpi-card stat-box reveal" href="${pageContext.request.contextPath}/patient/dossier">
<div class="kpi-icon"><i data-lucide="file-text"></i></div>
<div class="kpi-label"><fmt:message key="patient.dashboard.ordonnances"/></div>
<div class="kpi-value">${stats.ordonnancesDisponibles}</div>
<c:set var="t" value="${stats.trendOrdonnances}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</a>
<a class="kpi-card stat-box reveal" href="${pageContext.request.contextPath}/patient/dossier">
<div class="kpi-icon"><i data-lucide="stethoscope"></i></div>
<div class="kpi-label"><fmt:message key="stats.consultations_versees"/></div>
<div class="kpi-value">${stats.consultationsVersees}</div>
<c:set var="t" value="${stats.trendConsultationsVersees}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</a>
</div>

<div class="patient-hero-grid">
<section id="prochain-rdv" class="card card-fill reveal">
<div class="card-header-row">
<h2><fmt:message key="patient.dashboard.mon_prochain_passage"/></h2>
<a class="link-muted" href="${pageContext.request.contextPath}/patient/rdv/hopitaux"><fmt:message key="patient.dashboard.action.rdv"/></a>
</div>
<c:choose>
<c:when test="${not empty stats.prochainRdvDetail}">
<c:set var="rdv" value="${stats.prochainRdvDetail}" />
<div class="rdv-hero">
<div class="rdv-hero-icone"><i data-lucide="calendar-check"></i></div>
<div class="rdv-hero-date">
<span class="rdv-hero-jour">${rdv.date}</span>
<span class="rdv-hero-heure">${rdv.heure}</span>
</div>
<dl class="detail-grid">
<div class="detail-item">
<dt><fmt:message key="table.medecin"/></dt>
<dd>${rdv.medecin}</dd>
</div>
<div class="detail-item">
<dt><fmt:message key="patient.dashboard.specialite"/></dt>
<dd><c:choose><c:when test="${not empty rdv.specialite}">${rdv.specialite}</c:when><c:otherwise>&mdash;</c:otherwise></c:choose></dd>
</div>
<div class="detail-item">
<dt><fmt:message key="table.etablissement"/></dt>
<dd>${rdv.hopital}</dd>
</div>
<div class="detail-item">
<dt><fmt:message key="table.service"/></dt>
<dd><c:choose><c:when test="${not empty rdv.service}">${rdv.service}</c:when><c:otherwise>&mdash;</c:otherwise></c:choose></dd>
</div>
<div class="detail-item">
<dt><fmt:message key="table.statut"/></dt>
<dd>
<c:choose>
<c:when test="${rdv.statut == 'RDV_CONFIRME'}"><span class="badge-rdv confirme"><fmt:message key="status.confirme"/></span></c:when>
<c:when test="${rdv.statut == 'RDV_DEMANDE'}"><span class="badge-rdv demande"><fmt:message key="status.rdv_demande"/></span></c:when>
<c:otherwise><span class="badge-rdv">${rdv.statut}</span></c:otherwise>
</c:choose>
</dd>
</div>
</dl>
<c:if test="${rdv.statut == 'RDV_DEMANDE' or rdv.statut == 'RDV_CONFIRME'}">
<div class="rdv-hero-actions">
<a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/patient/rdv/annuler?idRendezVous=${rdv.idRendezVous}" onclick="return confirmApp(this, event, '<fmt:message key="confirm.annuler.rdv"/>')"><fmt:message key="patient.dashboard.annuler"/></a>
</div>
</c:if>
</div>
</c:when>
<c:otherwise>
<div class="empty-state">
<span class="empty-icon"><i data-lucide="calendar-plus"></i></span>
<p class="empty-text"><fmt:message key="patient.dashboard.no_rdv"/></p>
<a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/patient/rdv/hopitaux"><fmt:message key="patient.dashboard.action.rdv"/></a>
</div>
</c:otherwise>
</c:choose>
</section>

<section id="dossier-medical" class="card card-fill reveal">
<div class="card-header-row">
<h2><fmt:message key="patient.dashboard.dossier_medical"/></h2>
<a class="link-muted" href="${pageContext.request.contextPath}/patient/dossier"><fmt:message key="patient.dashboard.voir_dossier"/></a>
</div>
<dl class="detail-grid">
<div class="detail-item">
<dt><fmt:message key="patient.dashboard.numero_patient"/></dt>
<dd class="font-mono">${stats.numeroPatient}</dd>
</div>
<div class="detail-item">
<dt><fmt:message key="patient.dashboard.numero_dossier"/></dt>
<dd class="font-mono">${stats.numeroDossier}</dd>
</div>
<div class="detail-item">
<dt><fmt:message key="patient.dashboard.derniere_maj"/></dt>
<dd>${stats.derniereMaj}</dd>
</div>
</dl>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="patient.dashboard.profil_complete"/></span>
<span class="stat-value">${stats.profilComplete}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.profilComplete}%"></div></div>
</div>
<div class="insight-box">
<span class="insight-icon">&#128100;</span>
<div>
<div class="insight-title"><fmt:message key="patient.dashboard.profil_complete"/></div>
<div class="insight-desc"><strong>${stats.profilComplete}%</strong> — <fmt:message key="patient.dashboard.profil_complete_desc"/></div>
</div>
</div>
<c:if test="${completudeProfil < 100}">
<a class="btn btn-primary btn-sm w-100" href="${pageContext.request.contextPath}/profil/mon-profil"><fmt:message key="patient.dashboard.action.completer_profil"/></a>
</c:if>
</section>
</div>

<div class="charts-row">
<div class="card chart-card reveal">
<div class="chart-card-header">
<h3><fmt:message key="patient.dashboard.rdv_par_mois"/></h3>
<span class="chart-period"><fmt:message key="chart.period.this_year"/></span>
</div>
<c:choose>
<c:when test="${empty stats.chartPatientMois}">
<div class="empty-state">
<span class="empty-icon"><i data-lucide="calendar-x"></i></span>
<p class="empty-text"><fmt:message key="patient.dashboard.no_rdv"/></p>
</div>
</c:when>
<c:otherwise>
<c:set scope="request" var="chartData" value="${stats.chartPatientMois}"/>
<c:set scope="request" var="chartTitle" value="<fmt:message key='patient.dashboard.rdv_par_mois'/>"/>
<jsp:include page="/WEB-INF/views/charts/chart-bar.jsp"/>
</c:otherwise>
</c:choose>
</div>
<div class="card chart-card reveal">
<div class="chart-card-header">
<h3><fmt:message key="patient.dashboard.rdv_par_statut"/></h3>
<span class="chart-period"><fmt:message key="chart.period.this_year"/></span>
</div>
<c:choose>
<c:when test="${empty stats.statutRdvComplet}">
<div class="empty-state">
<span class="empty-icon"><i data-lucide="pie-chart"></i></span>
<p class="empty-text"><fmt:message key="patient.dashboard.no_rdv"/></p>
</div>
</c:when>
<c:otherwise>
<c:set var="totStatuts" value="0"/>
<c:forEach items="${stats.statutRdvComplet}" var="item">
<c:set var="totStatuts" value="${totStatuts + item[1]}"/>
</c:forEach>
<div class="donut-wrap" style="margin-top:12px;">
<svg class="donut" width="120" height="120" viewBox="0 0 120 120" role="img" aria-label="<fmt:message key='patient.dashboard.rdv_par_statut'/>">
<circle cx="60" cy="60" r="45" fill="none" stroke="var(--border-color)" stroke-width="16"/>
<c:set var="circ" value="283"/>
<c:set var="cumul" value="0"/>
<c:forEach items="${stats.statutRdvComplet}" var="item">
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE'}"><c:set var="couleur" value="var(--warning)"/></c:when>
<c:when test="${item[0] == 'RDV_CONFIRME'}"><c:set var="couleur" value="var(--info)"/></c:when>
<c:when test="${item[0] == 'TERMINE'}"><c:set var="couleur" value="var(--success)"/></c:when>
<c:when test="${item[0] == 'RDV_ANNULE'}"><c:set var="couleur" value="var(--danger)"/></c:when>
<c:otherwise><c:set var="couleur" value="var(--neutral)"/></c:otherwise>
</c:choose>
<c:set var="len" value="${totStatuts > 0 ? (item[1] / totStatuts) * circ : 0}"/>
<circle cx="60" cy="60" r="45" fill="none" stroke="${couleur}" stroke-width="16" stroke-dasharray="${len} ${circ}" stroke-dashoffset="${-cumul}" transform="rotate(-90 60 60)"/>
<c:set var="cumul" value="${cumul + len}"/>
</c:forEach>
<text x="60" y="56" class="donut-total">${totStatuts}</text>
<text x="60" y="72" class="donut-label"><fmt:message key="stats.total"/></text>
</svg>
<div class="status-legend">
<c:forEach items="${stats.statutRdvComplet}" var="item">
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE'}"><c:set var="couleur" value="var(--warning)"/></c:when>
<c:when test="${item[0] == 'RDV_CONFIRME'}"><c:set var="couleur" value="var(--info)"/></c:when>
<c:when test="${item[0] == 'TERMINE'}"><c:set var="couleur" value="var(--success)"/></c:when>
<c:when test="${item[0] == 'RDV_ANNULE'}"><c:set var="couleur" value="var(--danger)"/></c:when>
<c:otherwise><c:set var="couleur" value="var(--neutral)"/></c:otherwise>
</c:choose>
<div class="item"><span class="swatch" style="background:${couleur};"></span>
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE'}"><fmt:message key="status.rdv_demande"/></c:when>
<c:when test="${item[0] == 'RDV_CONFIRME'}"><fmt:message key="status.confirme"/></c:when>
<c:when test="${item[0] == 'TERMINE'}"><fmt:message key="status.termine"/></c:when>
<c:when test="${item[0] == 'RDV_ANNULE'}"><fmt:message key="status.annule"/></c:when>
<c:otherwise>${item[0]}</c:otherwise>
</c:choose>
<span class="count">${item[1]}
<span class="text-muted">(<fmt:formatNumber value="${totStatuts > 0 ? (item[1] / totStatuts) * 100 : 0}" pattern="#0"/>%)</span>
</span>
</div>
</c:forEach>
</div>
</div>
</c:otherwise>
</c:choose>
</div>
</div>

<div class="patient-bottom-grid">
<section id="historique-rdv" class="card card-fill reveal">
<div class="card-header-row">
<h2><fmt:message key="patient.dashboard.historique_rdv_recent"/></h2>
<a class="link-muted" href="${pageContext.request.contextPath}/patient/dossier"><fmt:message key="patient.dashboard.voir_tout"/></a>
</div>
<c:choose>
<c:when test="${empty historiqueRdv}">
<div class="empty-state">
<span class="empty-icon"><i data-lucide="calendar-x"></i></span>
<p class="empty-text"><fmt:message key="patient.dashboard.no_historique_rdv"/></p>
</div>
</c:when>
<c:otherwise>
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.date"/></th>
<th scope="col"><fmt:message key="table.medecin"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
</tr>
</thead>
<tbody>
<c:forEach items="${historiqueRdv}" var="r">
<tr>
<td>${r.date}<c:if test="${not empty r.heure}">, ${r.heure}</c:if></td>
<td>${r.medecin}<c:if test="${not empty r.specialite}"> <span class="text-muted">· ${r.specialite}</span></c:if></td>
<td>
<c:choose>
<c:when test="${r.statut == 'TERMINE'}"><span class="badge-rdv termine"><fmt:message key="status.termine"/></span></c:when>
<c:when test="${r.statut == 'RDV_CONFIRME'}"><span class="badge-rdv confirme"><fmt:message key="status.confirme"/></span></c:when>
<c:when test="${r.statut == 'RDV_DEMANDE'}"><span class="badge-rdv demande"><fmt:message key="status.rdv_demande"/></span></c:when>
<c:when test="${r.statut == 'RDV_ANNULE'}"><span class="badge-rdv annule"><fmt:message key="status.annule"/></span></c:when>
<c:otherwise><span class="badge-rdv">${r.statut}</span></c:otherwise>
</c:choose>
</td>
</tr>
</c:forEach>
</tbody>
</table>
</div>
</c:otherwise>
</c:choose>
</section>

<div class="stack">
<section class="card card-fill reveal">
<div class="card-header-row">
<h2><fmt:message key="patient.dashboard.timeline_medicale"/></h2>
<a class="link-muted" href="${pageContext.request.contextPath}/patient/dossier"><fmt:message key="patient.dashboard.voir_tout"/></a>
</div>
<c:choose>
<c:when test="${empty stats.timelineMedicale}">
<div class="empty-state">
<span class="empty-icon"><i data-lucide="folder-open"></i></span>
<p class="empty-text"><fmt:message key="dossier.no.consultations"/></p>
</div>
</c:when>
<c:otherwise>
<div class="mini-timeline">
<c:forEach var="t" items="${stats.timelineMedicale}">
<div class="mini-timeline-item">
<span class="mini-timeline-dot"></span>
<div>
<span class="mini-timeline-date">${t.date}</span>
<p class="mini-timeline-text">${t.motif}</p>
<span class="mini-timeline-medecin">${t.medecin}</span>
</div>
</div>
</c:forEach>
</div>
</c:otherwise>
</c:choose>
</section>

<section class="card card-fill reveal">
<h2><fmt:message key="stats.actions.rapides"/></h2>
<div class="quick-actions">
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/patient/dossier"><fmt:message key="patient.dashboard.action.dossier"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/patient/notifications"><fmt:message key="patient.dashboard.action.notifications"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/profil/mon-profil"><fmt:message key="patient.dashboard.action.profil"/></a>
<a class="btn btn-primary" href="${pageContext.request.contextPath}/patient/rdv/hopitaux"><fmt:message key="patient.dashboard.action.rdv"/></a>
</div>
</section>
</div>
</div>

<div class="patient-mid-grid">
<section class="card card-fill reveal">
<div class="card-header-row">
<h2><fmt:message key="patient.dashboard.mes_ordonnances_actives"/></h2>
<a class="link-muted" href="${pageContext.request.contextPath}/patient/dossier"><fmt:message key="patient.dashboard.voir_toutes_ordonnances"/></a>
</div>
<c:choose>
<c:when test="${empty stats.ordonnancesActives}">
<div class="empty-state">
<span class="empty-icon"><i data-lucide="file-heart"></i></span>
<p class="empty-text"><fmt:message key="patient.dashboard.no_ordonnances"/></p>
</div>
</c:when>
<c:otherwise>
<ul class="activity-list">
<c:forEach items="${stats.ordonnancesActives}" var="o">
<li class="activity-item">
<div class="activity-head">
<span class="activity-title">${o.medicament}${not empty o.dosage ? ' '.concat(o.dosage) : ''}</span>
<span class="badge-rdv active"><fmt:message key="patient.dashboard.ordonnance_active"/></span>
</div>
<div class="activity-meta">
${o.frequence}<c:if test="${not empty o.dureeJours && o.dureeJours > 0}"> <fmt:message key="patient.dashboard.pendant"/> ${o.dureeJours} <fmt:message key="patient.dashboard.jours"/></c:if>
<c:if test="${not empty o.dureeJours && o.dureeJours > 0 && not empty o.medecin}"> — </c:if><c:if test="${not empty o.medecin}"><fmt:message key="patient.dashboard.prescrit_par"/> ${o.medecin}</c:if>
</div>
</li>
</c:forEach>
</ul>
</c:otherwise>
</c:choose>
</section>

<section class="card card-fill reveal">
<div class="card-header-row">
<h2><fmt:message key="patient.dashboard.notifications_recentes"/></h2>
<a class="link-muted" href="${pageContext.request.contextPath}/patient/notifications"><fmt:message key="patient.dashboard.action.notifications"/></a>
</div>
<c:choose>
<c:when test="${empty notificationsRecentes}">
<div class="empty-state">
<span class="empty-icon"><i data-lucide="bell"></i></span>
<p class="empty-text"><fmt:message key="notifications.empty"/></p>
</div>
</c:when>
<c:otherwise>
<div class="stack">
<c:forEach items="${notificationsRecentes}" var="n">
<div class="card hoverable notif-card ${n.lue ? 'read' : ''}">
<div>
<span>${n.message}</span>
</div>
<div class="text-muted" style="font-size:12px;margin-top:6px;">${n.dateCreation}</div>
</div>
</c:forEach>
</div>
</c:otherwise>
</c:choose>
</section>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>