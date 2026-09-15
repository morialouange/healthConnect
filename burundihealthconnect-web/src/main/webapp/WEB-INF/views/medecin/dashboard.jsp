<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="medecin-dashboard"/>
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
<div class="kpi-grid">
<div class="kpi-card stat-box reveal">
<div class="kpi-icon"><i data-lucide="calendar-check"></i></div>
<div class="kpi-label"><fmt:message key="stats.rdv_du_jour"/></div>
<div class="kpi-value">${stats.rdvDuJour}</div>
<c:set var="t" value="${stats.trendRdvDuJour}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</div>
<div class="kpi-card stat-box reveal">
<div class="kpi-icon alert"><i data-lucide="clock"></i></div>
<div class="kpi-label"><fmt:message key="stats.rdv_en_attente_confirmation"/></div>
<div class="kpi-value">${stats.rdvEnAttente}</div>
<c:set var="t" value="${stats.trendRdvEnAttente}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</div>
<div class="kpi-card stat-box reveal">
<div class="kpi-icon"><i data-lucide="alert-triangle"></i></div>
<div class="kpi-label"><fmt:message key="medecin.dashboard.urgents_critiques"/></div>
<div class="kpi-value">${stats.rdvUrgentsCritiques}</div>
<c:set var="t" value="${stats.trendUrgentsCritiques}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</div>
<div class="kpi-card stat-box reveal">
<div class="kpi-icon"><i data-lucide="stethoscope"></i></div>
<div class="kpi-label"><fmt:message key="stats.consultations_en_cours"/></div>
<div class="kpi-value">${stats.consultationsEnCours}</div>
<c:set var="t" value="${stats.trendConsultationsEnCours}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</div>
</div>
<c:if test="${stats.rdvUrgentsCritiques > 0}">
<div class="alert-critical">
<i data-lucide="alert-triangle"></i>
<div><strong>${stats.rdvUrgentsCritiques} <fmt:message key="medecin.dashboard.urgents_critiques"/></strong> — <fmt:message key="medecin.dashboard.alerte_critique_desc"/></div>
</div>
</c:if>
<div class="demo-grid">
<div class="card card-fill reveal">
<h3><fmt:message key="medecin.dashboard.patients_a_traiter"/></h3>
<c:choose>
<c:when test="${empty stats.patientsATraiter}">
<div class="empty-state">
<span class="empty-icon"><i data-lucide="calendar-x"></i></span>
<p class="empty-text"><fmt:message key="medecin.no.rdv.attente"/></p>
<a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="nav.medecin.rdv"/></a>
</div>
</c:when>
<c:otherwise>
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.patient"/></th>
<th scope="col"><fmt:message key="table.heure"/></th>
<th scope="col"><fmt:message key="table.motif"/></th>
<th scope="col"><fmt:message key="table.priorite"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="p" items="${stats.patientsATraiter}">
<tr>
<td>${p.patientName}</td>
<td>${p.heureRdv}</td>
<td>${p.motif}</td>
<td>
 <c:choose>
 <c:when test="${p.priorite == 'CRITIQUE'}">
 <span class="badge badge-critical"><fmt:message key="priorite.critique"/></span>
 </c:when>
 <c:when test="${p.priorite == 'URGENT'}">
 <span class="badge badge-urgent"><fmt:message key="priorite.urgent"/></span>
 </c:when>
 <c:otherwise>
 <span class="badge badge-neutral"><fmt:message key="priorite.normal"/></span>
 </c:otherwise>
 </c:choose>
 </td>
<td>
<a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/medecin/dossier?idDossier=${p.idDossier}"><fmt:message key="btn.consulter"/></a>
<c:if test="${p.statut == 'RDV_CONFIRME'}">
<a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/medecin/consultations/creer?idRendezVous=${p.idRendezVous}"><fmt:message key="btn.create.consultation"/></a>
</c:if>
</td>
</tr>
</c:forEach>
</tbody>
</table>
</div>
<div class="pagination">
<div class="page-item">&#8249;</div>
<div class="page-item active">1</div>
<div class="page-item">2</div>
<div class="page-item">3</div>
<div class="page-item">&#8250;</div>
</div>
</c:otherwise>
</c:choose>
</div>
<div class="card card-fill reveal">
<h3><fmt:message key="stats.statut_rdv"/></h3>
<c:set var="totStatuts" value="0"/>
<c:forEach items="${stats.chartMedecinRdvStatut}" var="item">
<c:set var="totStatuts" value="${totStatuts + item[1]}"/>
</c:forEach>
<div class="flex-center" style="margin-top:12px;">
<svg class="donut" width="120" height="120" viewBox="0 0 120 120" role="img" aria-label="<fmt:message key='stats.statut_rdv'/>">
<circle cx="60" cy="60" r="45" fill="none" stroke="var(--border-color)" stroke-width="16"/>
<c:set var="circ" value="283"/>
<c:set var="cumul" value="0"/>
<c:forEach items="${stats.chartMedecinRdvStatut}" var="item">
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE' || item[0] == 'EN_ATTENTE'}"><c:set var="couleur" value="var(--warning)"/></c:when>
<c:when test="${item[0] == 'CONFIRME' || item[0] == 'RDV_CONFIRME' || item[0] == 'EN_COURS' || item[0] == 'ACCEPTE'}"><c:set var="couleur" value="var(--info)"/></c:when>
<c:when test="${item[0] == 'TERMINE' || item[0] == 'APPROUVE' || item[0] == 'CLOTURE' || item[0] == 'CLOTUREE' || item[0] == 'VERSEE_AU_DOSSIER'}"><c:set var="couleur" value="var(--success)"/></c:when>
<c:when test="${item[0] == 'ANNULE' || item[0] == 'REFUSE' || item[0] == 'RDV_ANNULE'}"><c:set var="couleur" value="var(--danger)"/></c:when>
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
<c:forEach items="${stats.chartMedecinRdvStatut}" var="item">
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE'}"><fmt:message key="status.rdv_demande" var="lib"/></c:when>
<c:when test="${item[0] == 'EN_ATTENTE'}"><fmt:message key="status.en_attente" var="lib"/></c:when>
<c:when test="${item[0] == 'CONFIRME' || item[0] == 'RDV_CONFIRME'}"><fmt:message key="status.confirme" var="lib"/></c:when>
<c:when test="${item[0] == 'EN_COURS'}"><fmt:message key="status.en_cours" var="lib"/></c:when>
<c:when test="${item[0] == 'ACCEPTE'}"><fmt:message key="status.accepte" var="lib"/></c:when>
<c:when test="${item[0] == 'TERMINE' || item[0] == 'CLOTURE' || item[0] == 'CLOTUREE' || item[0] == 'VERSEE_AU_DOSSIER'}"><fmt:message key="status.termine" var="lib"/></c:when>
<c:when test="${item[0] == 'APPROUVE'}"><fmt:message key="status.approuve" var="lib"/></c:when>
<c:when test="${item[0] == 'ANNULE' || item[0] == 'RDV_ANNULE'}"><fmt:message key="status.annule" var="lib"/></c:when>
<c:when test="${item[0] == 'REFUSE'}"><fmt:message key="status.refuse" var="lib"/></c:when>
<c:when test="${item[0] == 'RETOUR_RECU'}"><fmt:message key="status.retour_recu" var="lib"/></c:when>
<c:otherwise><c:set var="lib" value="${item[0]}"/></c:otherwise>
</c:choose>
<c:set var="couleur" value=""/>
<c:choose>
<c:when test="${item[0] == 'RDV_DEMANDE' || item[0] == 'EN_ATTENTE'}"><c:set var="couleur" value="var(--warning)"/></c:when>
<c:when test="${item[0] == 'CONFIRME' || item[0] == 'RDV_CONFIRME' || item[0] == 'EN_COURS' || item[0] == 'ACCEPTE'}"><c:set var="couleur" value="var(--info)"/></c:when>
<c:when test="${item[0] == 'TERMINE' || item[0] == 'APPROUVE' || item[0] == 'CLOTURE' || item[0] == 'CLOTUREE' || item[0] == 'VERSEE_AU_DOSSIER'}"><c:set var="couleur" value="var(--success)"/></c:when>
<c:when test="${item[0] == 'ANNULE' || item[0] == 'REFUSE' || item[0] == 'RDV_ANNULE'}"><c:set var="couleur" value="var(--danger)"/></c:when>
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
<span class="insight-icon">&#9989;</span>
<div>
<div class="insight-title"><fmt:message key="medecin.dashboard.taux_rdv_termines"/></div>
<div class="insight-desc"><strong>${stats.tauxRdvTermines}%</strong> — <fmt:message key="medecin.dashboard.taux_rdv_termines_desc"/></div>
</div>
</div>
</div>
</div>
<div class="card chart-card reveal">
<h2><fmt:message key="medecin.dashboard.timeline_jour"/></h2>
<c:choose>
<c:when test="${empty stats.timelineDuJour}">
<div class="empty-state">
<span class="empty-icon"><i data-lucide="list-x"></i></span>
<p class="empty-text"><fmt:message key="medecin.no.rdv"/></p>
<a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="nav.medecin.rdv"/></a>
</div>
</c:when>
<c:otherwise>
<div>
<c:forEach var="t" items="${stats.timelineDuJour}">
<div>
<div>
<span>${t.heure}</span>
<span>${t.patient}</span>
<span>${t.motif}</span>
<c:choose>
<c:when test="${t.priorite == 'CRITIQUE'}">
<span class="badge badge-critical"><fmt:message key="priorite.critique"/></span>
</c:when>
<c:when test="${t.priorite == 'URGENT'}">
 <span class="badge badge-urgent"><fmt:message key="priorite.urgent"/></span>
 </c:when>
<c:otherwise>
<span class="badge badge-neutral"><fmt:message key="priorite.normal"/></span>
</c:otherwise>
</c:choose>
</div>
</div>
</c:forEach>
</div>
</c:otherwise>
</c:choose>
</div>
<div class="charts-row">
<div class="card chart-card reveal">
<div class="chart-card-header">
<h3><fmt:message key="stats.par_priorite"/></h3>
<span class="chart-period"><fmt:message key="chart.period.this_month"/></span>
</div>
<c:set scope="request" var="chartData" value="${stats.chartMedecinPriorites}"/>
<c:set scope="request" var="chartTitle" value="<fmt:message key='stats.par_priorite'/>"/>
<jsp:include page="/WEB-INF/views/charts/chart-bar.jsp"/>
</div>
<div class="card chart-card reveal">
<div class="chart-card-header">
<h3><fmt:message key="stats.consultations_7_jours"/></h3>
<span class="chart-period">7 <fmt:message key="chart.period.last_7_days"/></span>
</div>
<c:set scope="request" var="chartData" value="${stats.chartMedecinConsultations7j}"/>
<c:set scope="request" var="chartTitle" value="<fmt:message key='stats.consultations_7_jours'/>"/>
<jsp:include page="/WEB-INF/views/charts/chart-line.jsp"/>
</div>
</div>
<div class="card chart-card reveal">
<h2><fmt:message key="admin.dashboard.performance"/></h2>
<div class="stack">
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="medecin.dashboard.taux_rdv_termines"/></span>
<span class="stat-value">${stats.tauxRdvTermines}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.tauxRdvTermines}%"></div></div>
</div>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="admin.dashboard.consultations_versees"/></span>
<span class="stat-value">${stats.consultationsVersees}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.consultationsVersees}%"></div></div>
</div>
</div>
</div>
<div class="card reveal">
<div><strong><fmt:message key="medecin.ordonnances_ce_mois"/>:</strong> ${stats.ordonnancesCeMois}</div>
<div><strong><fmt:message key="medecin.referenements_envoyes"/>:</strong> ${stats.referenementsEnvoyes}</div>
<div><strong><fmt:message key="medecin.prochain_conge"/>:</strong>
<c:choose>
<c:when test="${not empty stats.congesRecents and not empty stats.congesRecents[0]}">
 ${stats.congesRecents[0].debut} - ${stats.congesRecents[0].fin}
 <c:choose>
<c:when test="${stats.congesRecents[0].statut == 'EN_ATTENTE'}"><span><fmt:message key="status.en_attente"/></span></c:when>
<c:when test="${stats.congesRecents[0].statut == 'APPROUVE'}"><span><fmt:message key="status.approuve"/></span></c:when>
<c:when test="${stats.congesRecents[0].statut == 'REFUSE'}"><span><fmt:message key="status.refuse"/></span></c:when>
<c:otherwise><span>${stats.congesRecents[0].statut}</span></c:otherwise>
</c:choose>
</c:when>
<c:otherwise><fmt:message key="message.empty.no_data"/></c:otherwise>
</c:choose>
</div>
</div>
<div class="card reveal">
<h2><fmt:message key="stats.actions.rapides"/></h2>
<div>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="medecin.dashboard.action.rdv"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/dossier"><fmt:message key="medecin.dashboard.action.dossier"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/consultations/creer"><fmt:message key="medecin.dashboard.action.consultation"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/ordonnances/rediger"><fmt:message key="medecin.dashboard.action.ordonnance"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/disponibilites"><fmt:message key="medecin.dashboard.action.disponibilite"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/conge"><fmt:message key="medecin.dashboard.action.conge"/></a>
</div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>