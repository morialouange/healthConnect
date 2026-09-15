<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="superadmin-dashboard"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="superadmin.dashboard.title"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="superadmin.dashboard.title"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<c:if test="${not empty hopitauxSansAdmin or comptesDesactives > 0 or servicesInactifs > 0}">
<div class="alert-critical">
<i data-lucide="alert-triangle"></i>
<div>
<strong><fmt:message key="superadmin.alertes_titre"/></strong> —
<c:if test="${not empty hopitauxSansAdmin}">${fn:length(hopitauxSansAdmin)} <fmt:message key="superadmin.alerte.hopital_sans_admin"/></c:if>
<c:if test="${comptesDesactives > 0}"> · ${comptesDesactives} <fmt:message key="superadmin.alerte.comptes_desactives"/></c:if>
<c:if test="${servicesInactifs > 0}"> · ${servicesInactifs} <fmt:message key="superadmin.alerte.services_inactifs"/></c:if>
</div>
</div>
</c:if>
<div class="kpi-grid">
<div class="kpi-card stat-box reveal">
<div class="kpi-icon"><i data-lucide="stethoscope"></i></div>
<div class="kpi-label"><fmt:message key="superadmin.stats.consultations_mois"/></div>
<div class="kpi-value">${stats.consultationsCeMois}</div>
<c:set var="t" value="${stats.trendConsultationsCeMois}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</div>
<div class="kpi-card stat-box reveal">
<div class="kpi-icon"><i data-lucide="calendar-check"></i></div>
<div class="kpi-label"><fmt:message key="superadmin.stats.rdv_reseau_mois"/></div>
<div class="kpi-value">${stats.rdvReseauMois}</div>
<c:set var="t" value="${stats.trendRdvReseauMois}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</div>
<div class="kpi-card stat-box reveal">
<div class="kpi-icon alert"><i data-lucide="search"></i></div>
<div class="kpi-label"><fmt:message key="superadmin.stats.acces_dossiers_mois"/></div>
<div class="kpi-value">${stats.accesDossiersMois}</div>
<c:set var="t" value="${stats.trendAccesDossiersMois}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</div>
<div class="kpi-card stat-box reveal">
<div class="kpi-icon"><i data-lucide="users"></i></div>
<div class="kpi-label"><fmt:message key="superadmin.stats.patients_reseau"/></div>
<div class="kpi-value">${stats.patientsReseau}</div>
</div>
</div>
<div class="demo-grid">
<div class="card card-fill reveal">
<h3><fmt:message key="superadmin.chart.top_hopitaux"/></h3>
<div class="table-wrap">
<table class="table">
<thead>
<tr><th scope="col"><fmt:message key="table.hopital"/></th><th scope="col"><fmt:message key="superadmin.table.activite"/></th></tr>
</thead>
<tbody>
<c:forEach items="${stats.chartTopHopitauxActifs}" var="item">
<tr><td>${item[0]}</td><td>${item[1]}</td></tr>
</c:forEach>
</tbody>
</table>
</div>
</div>
<div class="card card-fill reveal">
<h3><fmt:message key="superadmin.chart.rdv_par_statut"/></h3>
<c:set var="totStatuts" value="0"/>
<c:forEach items="${stats.chartRdvStatutReseau}" var="item">
<c:set var="totStatuts" value="${totStatuts + item[1]}"/>
</c:forEach>
<div class="flex-center" style="margin-top:12px;">
<svg class="donut" width="120" height="120" viewBox="0 0 120 120" role="img" aria-label="<fmt:message key='superadmin.chart.rdv_par_statut'/>">
<circle cx="60" cy="60" r="45" fill="none" stroke="var(--border-color)" stroke-width="16"/>
<c:set var="circ" value="283"/>
<c:set var="cumul" value="0"/>
<c:forEach items="${stats.chartRdvStatutReseau}" var="item">
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE' || item[0] == 'EN_ATTENTE'}"><c:set var="couleur" value="var(--warning)"/></c:when>
<c:when test="${item[0] == 'RDV_CONFIRME' || item[0] == 'EN_COURS' || item[0] == 'ACCEPTE'}"><c:set var="couleur" value="var(--info)"/></c:when>
<c:when test="${item[0] == 'TERMINE' || item[0] == 'APPROUVE' || item[0] == 'CLOTURE' || item[0] == 'CLOTUREE' || item[0] == 'VERSEE_AU_DOSSIER'}"><c:set var="couleur" value="var(--success)"/></c:when>
<c:when test="${item[0] == 'RDV_ANNULE' || item[0] == 'REFUSE'}"><c:set var="couleur" value="var(--danger)"/></c:when>
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
<c:forEach items="${stats.chartRdvStatutReseau}" var="item">
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE'}"><fmt:message key="status.rdv_demande" var="lib"/></c:when>
<c:when test="${item[0] == 'EN_ATTENTE'}"><fmt:message key="status.en_attente" var="lib"/></c:when>
<c:when test="${item[0] == 'RDV_CONFIRME'}"><fmt:message key="status.confirme" var="lib"/></c:when>
<c:when test="${item[0] == 'TERMINE'}"><fmt:message key="status.termine" var="lib"/></c:when>
<c:when test="${item[0] == 'RDV_ANNULE'}"><fmt:message key="status.annule" var="lib"/></c:when>
<c:otherwise><c:set var="lib" value="${item[0]}"/></c:otherwise>
</c:choose>
<c:set var="couleur" value=""/>
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE' || item[0] == 'EN_ATTENTE'}"><c:set var="couleur" value="var(--warning)"/></c:when>
<c:when test="${item[0] == 'RDV_CONFIRME' || item[0] == 'EN_COURS' || item[0] == 'ACCEPTE'}"><c:set var="couleur" value="var(--info)"/></c:when>
<c:when test="${item[0] == 'TERMINE' || item[0] == 'APPROUVE' || item[0] == 'CLOTURE' || item[0] == 'CLOTUREE' || item[0] == 'VERSEE_AU_DOSSIER'}"><c:set var="couleur" value="var(--success)"/></c:when>
<c:when test="${item[0] == 'RDV_ANNULE' || item[0] == 'REFUSE'}"><c:set var="couleur" value="var(--danger)"/></c:when>
<c:otherwise><c:set var="couleur" value="var(--neutral)"/></c:otherwise>
</c:choose>
<div class="item"><span class="swatch" style="background:${couleur};"></span> ${lib}
<span class="count">${item[1]}
<span class="text-muted">(<fmt:formatNumber value="${totStatuts > 0 ? (item[1] / totStatuts) * 100 : 0}" pattern="#0"/>%)</span>
</span>
</div>
</c:forEach>
</div>
</div>
<div class="insight-box">
<span class="insight-icon">&#127970;</span>
<div>
<div class="insight-title"><fmt:message key="stats.hopitaux_actifs"/></div>
<div class="insight-desc"><strong>${stats.tauxHopitauxActifs}%</strong> — <fmt:message key="stats.hopitaux_actifs_desc"/></div>
</div>
</div>
</div>
</div>
<div class="card reveal">
<h2><fmt:message key="superadmin.alertes_titre"/></h2>
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="superadmin.alerte"/></th>
<th scope="col"><fmt:message key="table.detail"/></th>
</tr>
</thead>
<tbody>
<c:forEach items="${hopitauxSansAdmin}" var="hopital">
<tr>
<td><fmt:message key="superadmin.alerte.hopital_sans_admin"/></td>
<td>${hopital}</td>
</tr>
</c:forEach>
<tr>
<td><fmt:message key="superadmin.alerte.comptes_desactives"/></td>
<td>${comptesDesactives}</td>
</tr>
<tr>
<td><fmt:message key="superadmin.alerte.services_inactifs"/></td>
<td>${servicesInactifs}</td>
</tr>
<c:if test="${empty hopitauxSansAdmin && comptesDesactives == 0 && servicesInactifs == 0}">
<tr>
<td colspan="2" >&#10003; <fmt:message key="message.empty.no_data"/></td>
</tr>
</c:if>
</tbody>
</table>
</div>
<div class="charts-row">
<div class="card chart-card reveal">
<div class="chart-card-header">
<h3><fmt:message key="superadmin.chart.acces_par_hopital"/></h3>
<span class="chart-period"><fmt:message key="chart.period.this_month"/></span>
</div>
<c:set scope="request" var="chartData" value="${stats.chartAccesParHopital}"/>
<c:set scope="request" var="chartTitle" value="<fmt:message key='superadmin.chart.acces_par_hopital'/>"/>
<jsp:include page="/WEB-INF/views/charts/chart-bar.jsp"/>
</div>
<div class="card chart-card reveal">
<div class="chart-card-header">
<h3><fmt:message key="superadmin.chart.consultations_30j"/></h3>
<span class="chart-period">30 <fmt:message key="chart.period.last_days"/></span>
</div>
<c:set scope="request" var="chartData" value="${stats.chartConsultations30Jours}"/>
<c:set scope="request" var="chartTitle" value="<fmt:message key='superadmin.chart.consultations_30j'/>"/>
<jsp:include page="/WEB-INF/views/charts/chart-line.jsp"/>
</div>
</div>
<div class="card reveal">
<h2><fmt:message key="superadmin.sante_reseau"/></h2>
<div class="stack">
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="stats.hopitaux_actifs"/></span>
<span class="stat-value">${stats.tauxHopitauxActifs}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.tauxHopitauxActifs}%"></div></div>
</div>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="superadmin.stats.admins_actifs"/></span>
<span class="stat-value">${stats.tauxAdminsActifs}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.tauxAdminsActifs}%"></div></div>
</div>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="superadmin.stats.medecins_actifs"/></span>
<span class="stat-value">${stats.tauxMedecinsActifs}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.tauxMedecinsActifs}%"></div></div>
</div>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="consultations_versees"/> / <fmt:message key="stats.consultations_ce_mois"/></span>
<span class="stat-value">${stats.tauxConsultationsVersees}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.tauxConsultationsVersees}%"></div></div>
</div>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="dossier.avec.consultation"/></span>
<span class="stat-value">${stats.tauxDossiersAvecConsultation}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.tauxDossiersAvecConsultation}%"></div></div>
</div>
</div>
</div>
<div class="card reveal">
<h3><fmt:message key="superadmin.chart.repartition_roles"/></h3>
<div class="status-legend">
<c:forEach items="${stats.chartRepartitionRoles}" var="item">
<div class="item"><span class="swatch" style="background:var(--info);"></span> ${item[0]} <span class="count">${item[1]}</span></div>
</c:forEach>
</div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>