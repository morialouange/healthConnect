<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-dashboard"/>
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
<script src="${pageContext.request.contextPath}/resources/js/chart.umd.js?v=1"></script>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

<!-- 2.2 KPI cliquables (5 cartes) -->
<div class="kpi-grid" style="--kpi-cols: 5">
<a class="kpi-card stat-box reveal" href="${pageContext.request.contextPath}/admin/rapport">
<div class="kpi-icon"><i data-lucide="calendar-check"></i></div>
<div class="kpi-label"><fmt:message key="admin.dashboard.rdv_aujourdhui"/></div>
<div class="kpi-value">${stats.rdvAujourdhui}</div>
<c:set var="t" value="${stats.trendRdvAujourdhui}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</a>
<a class="kpi-card stat-box reveal" href="${pageContext.request.contextPath}/admin/medecins">
<div class="kpi-icon alert"><i data-lucide="clock"></i></div>
<div class="kpi-label"><fmt:message key="admin.dashboard.rdv_attente"/></div>
<div class="kpi-value">${stats.rdvEnAttente}</div>
<c:set var="t" value="${stats.trendRdvEnAttente}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_hier"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</a>
<a class="kpi-card stat-box reveal" href="${pageContext.request.contextPath}/admin/rapport">
<div class="kpi-icon"><i data-lucide="scroll-text"></i></div>
<div class="kpi-label"><fmt:message key="stats.consultations_ce_mois"/></div>
<div class="kpi-value">${stats.consultationsCeMois}</div>
<c:set var="t" value="${stats.trendConsultationsCeMois}"/>
<div class="kpi-trend ${t > 0 ? 'up' : (t < 0 ? 'down' : 'flat')}">
<c:choose>
<c:when test="${t > 0}">&#9650; ${t}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:when test="${t < 0}">&#9660; ${t * -1}% <fmt:message key="stats.trend.vs_mois"/></c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>
</a>
<a class="kpi-card stat-box reveal" href="${pageContext.request.contextPath}/admin/medecins">
<div class="kpi-icon"><i data-lucide="user-round-cog"></i></div>
<div class="kpi-label"><fmt:message key="stats.medecins_actifs"/></div>
<div class="kpi-value">${stats.medecinsActifs}</div>
<c:if test="${stats.medecinsIndisponibles > 0}">
<div class="kpi-trend flat"><fmt:message key="admin.dashboard.medecins_indisponibles"/> : ${stats.medecinsIndisponibles}</div>
</c:if>
</a>
<a class="kpi-card stat-box reveal" href="${pageContext.request.contextPath}/admin/services">
<div class="kpi-icon alert"><i data-lucide="building-2"></i></div>
<div class="kpi-label"><fmt:message key="admin.dashboard.services_actifs"/></div>
<div class="kpi-value">${stats.servicesActifs}</div>
</a>
</div>

<!-- 2.3 Actions rapides + 2.4 Alertes -->
<div class="charts-row">
<div class="card card-fill reveal">
<div class="chart-card-header">
<h3><fmt:message key="admin.dashboard.actions_rapides"/></h3>
</div>
<div class="quick-actions">
<a class="quick-action-btn" href="${pageContext.request.contextPath}/admin/medecins/creer">
<i data-lucide="user-round-plus"></i> <fmt:message key="admin.dashboard.add_medecin"/>
</a>
<a class="quick-action-btn" href="${pageContext.request.contextPath}/admin/services/creer">
<i data-lucide="building-2"></i> <fmt:message key="admin.dashboard.add_service"/>
</a>
<a class="quick-action-btn" href="${pageContext.request.contextPath}/admin/conges">
<i data-lucide="palm-tree"></i> <fmt:message key="admin.dashboard.manage_conges"/>
<c:if test="${stats.congesEnAttente > 0}"><span class="badge badge-warning">${stats.congesEnAttente}</span></c:if>
</a>
<a class="quick-action-btn" href="${pageContext.request.contextPath}/admin/referenements">
<i data-lucide="link"></i> <fmt:message key="admin.dashboard.referenements"/>
</a>
<a class="quick-action-btn" href="${pageContext.request.contextPath}/admin/rapport">
<i data-lucide="bar-chart-3"></i> <fmt:message key="admin.dashboard.rapport_mensuel"/>
</a>
</div>
</div>

<div class="card card-fill reveal alert-card">
<div class="chart-card-header">
<h3><fmt:message key="admin.dashboard.alertes_traiter"/></h3>
</div>
<c:choose>
<c:when test="${stats.congesEnAttente > 0 or stats.rdvCritiquesUrgents > 0}">
<div class="alert-items">
<c:if test="${stats.congesEnAttente > 0}">
<div class="alert-row">
<i data-lucide="palm-tree"></i>
<span><strong>${stats.congesEnAttente}</strong> <fmt:message key="admin.dashboard.alerte_conges_attente"/></span>
<a class="alert-link" href="${pageContext.request.contextPath}/admin/conges"><fmt:message key="admin.dashboard.voir_tout"/></a>
</div>
</c:if>
<c:if test="${stats.rdvCritiquesUrgents > 0}">
<div class="alert-row">
<i data-lucide="triangle-alert"></i>
<span><strong>${stats.rdvCritiquesUrgents}</strong> <fmt:message key="admin.dashboard.alerte_rdv_critiques"/></span>
<a class="alert-link" href="${pageContext.request.contextPath}/admin/medecins"><fmt:message key="admin.dashboard.voir_tout"/></a>
</div>
</c:if>
</div>
</c:when>
<c:otherwise>
<div class="empty-state">
<div class="empty-icon">&#10004;&#65039;</div>
<div class="alert-title"><fmt:message key="admin.dashboard.alerte_aucune"/></div>
<div class="empty-text"><fmt:message key="admin.dashboard.alerte_aucune_desc"/></div>
</div>
</c:otherwise>
</c:choose>
</div>
</div>

<!-- 2.5 Graphiques avec sélecteurs de période -->
<div class="charts-row">
<div class="card chart-card reveal">
<div class="chart-card-header">
<c:choose>
<c:when test="${periode == '30'}">
<h3><fmt:message key="stats.consultations_30_jours"/></h3>
</c:when>
<c:otherwise>
<h3><fmt:message key="stats.consultations_7_jours"/></h3>
</c:otherwise>
</c:choose>
<div class="chart-seg">
<a class="${periode == '7' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?periode=7&amp;periodeTop=${periodeTop}"><fmt:message key="chart.period.7j"/></a>
<a class="${periode == '30' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?periode=30&amp;periodeTop=${periodeTop}"><fmt:message key="chart.period.30j"/></a>
</div>
</div>
<c:choose>
<c:when test="${periode == '30'}">
<c:set scope="request" var="chartData" value="${stats.chartConsultations30jours}"/>
<c:set scope="request" var="chartTitle"><fmt:message key="stats.consultations_30_jours"/></c:set>
</c:when>
<c:otherwise>
<c:set scope="request" var="chartData" value="${stats.chartConsultations7jours}"/>
<c:set scope="request" var="chartTitle"><fmt:message key="stats.consultations_7_jours"/></c:set>
</c:otherwise>
</c:choose>
<jsp:include page="/WEB-INF/views/charts/chart-line-js.jsp"/>
</div>
<div class="card chart-card reveal">
<div class="chart-card-header">
<c:choose>
<c:when test="${periodeTop == 'trimestre'}">
<h3><fmt:message key="admin.dashboard.top_services_trimestre"/></h3>
</c:when>
<c:otherwise>
<h3><fmt:message key="admin.dashboard.top_services_mois"/></h3>
</c:otherwise>
</c:choose>
<div class="chart-seg">
<a class="${periodeTop == 'mois' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?periode=${periode}&amp;periodeTop=mois"><fmt:message key="chart.period.this_month"/></a>
<a class="${periodeTop == 'trimestre' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?periode=${periode}&amp;periodeTop=trimestre"><fmt:message key="chart.period.this_quarter"/></a>
</div>
</div>
<c:choose>
<c:when test="${periodeTop == 'trimestre'}">
<c:set scope="request" var="chartData" value="${stats.chartTop5ServicesTrimestre}"/>
<c:set scope="request" var="chartTitle"><fmt:message key="admin.dashboard.top_services_trimestre"/></c:set>
</c:when>
<c:otherwise>
<c:set scope="request" var="chartData" value="${stats.chartTop5ServicesMois}"/>
<c:set scope="request" var="chartTitle"><fmt:message key="admin.dashboard.top_services_mois"/></c:set>
</c:otherwise>
</c:choose>
<jsp:include page="/WEB-INF/views/charts/chart-bar-js.jsp"/>
</div>
</div>

<!-- 2.6 Répartition des RDV + Priorités -->
<div class="charts-row">
<div class="card card-fill reveal">
<h3><fmt:message key="stats.repartition_rdv"/></h3>
<c:set var="totStatuts" value="0"/>
<c:forEach items="${stats.chartRdvStatus}" var="item">
<c:set var="totStatuts" value="${totStatuts + item[1]}"/>
</c:forEach>
<div class="flex-center" style="margin-top:12px;">
<svg class="donut" width="120" height="120" viewBox="0 0 120 120" role="img" aria-label="<fmt:message key='stats.repartition_rdv'/>">
<circle cx="60" cy="60" r="45" fill="none" stroke="var(--border-color)" stroke-width="16"/>
<c:set var="circ" value="283"/>
<c:set var="cumul" value="0"/>
<c:forEach items="${stats.chartRdvStatus}" var="item">
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
<c:forEach items="${stats.chartRdvStatus}" var="item">
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
<span class="insight-icon">&#128200;</span>
<div>
<div class="insight-title"><fmt:message key="admin.dashboard.insight_confirmation"/></div>
<div class="insight-desc"><strong>${stats.tauxConfirmation}%</strong> — <fmt:message key="admin.dashboard.taux_confirmation_desc"/></div>
</div>
</div>
</div>
<div class="card chart-card reveal">
<h3><fmt:message key="admin.dashboard.priorites_rdv"/></h3>
<c:set var="pxMax" value="${stats.normalCount}"/>
<c:if test="${stats.urgentCount > pxMax}"><c:set var="pxMax" value="${stats.urgentCount}"/></c:if>
<c:if test="${stats.critiqueCount > pxMax}"><c:set var="pxMax" value="${stats.critiqueCount}"/></c:if>
<c:if test="${pxMax <= 0}"><c:set var="pxMax" value="1"/></c:if>
<div class="priority-bars">
<div class="priority-bar">
<span class="label"><fmt:message key="priorite.normal"/></span>
<div class="bar-track"><div class="bar-fill normal" style="width:${stats.normalCount * 100 / pxMax}%"></div></div>
<span class="count">${stats.normalCount}</span>
</div>
<div class="priority-bar">
<span class="label"><fmt:message key="priorite.urgent"/></span>
<div class="bar-track"><div class="bar-fill urgent" style="width:${stats.urgentCount * 100 / pxMax}%"></div></div>
<span class="count">${stats.urgentCount}</span>
</div>
<div class="priority-bar">
<span class="label"><fmt:message key="priorite.critique"/></span>
<div class="bar-track"><div class="bar-fill critique" style="width:${stats.critiqueCount * 100 / pxMax}%"></div></div>
<span class="count">${stats.critiqueCount}</span>
</div>
</div>
</div>
</div>

<!-- 2.7 Charge par médecin enrichie + Performance -->
<div class="charts-row">
<div class="card card-fill reveal">
<div class="chart-card-header">
<h3><fmt:message key="admin.dashboard.charge_medecin"/></h3>
</div>
<c:choose>
<c:when test="${not empty stats.chargeMedecins}">
<c:set var="cmMax" value="${stats.maxChargeMedecin}"/>
<c:if test="${cmMax <= 0}"><c:set var="cmMax" value="1"/></c:if>
<div class="charge-list">
<c:forEach items="${stats.chargeMedecins}" var="item">
<div class="charge-row">
<div class="doc-name">${item[0]}</div>
<div class="doc-spec">${empty item[1] ? '-' : item[1]}</div>
<div class="charge-bar-wrap">
<div class="charge-track"><div class="charge-fill" style="width:${item[2] * 100 / cmMax}%"></div></div>
<span class="charge-val">${item[2]} <fmt:message key="admin.dashboard.rdv_ce_mois"/></span>
</div>
<div class="doc-link"><a href="${pageContext.request.contextPath}/admin/medecins/detail?idMedecin=${item[3]}"><fmt:message key="admin.dashboard.voir_fiche"/></a></div>
</div>
</c:forEach>
</div>
</c:when>
<c:otherwise>
<div class="empty-state">
<div class="empty-text"><fmt:message key="admin.dashboard.alerte_aucune_desc"/></div>
</div>
</c:otherwise>
</c:choose>
</div>
<div class="card chart-card reveal">
<h3><fmt:message key="admin.dashboard.performance"/></h3>
<div class="stack">
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="admin.dashboard.taux_annulation"/></span>
<span class="stat-value">${stats.tauxAnnulation}%</span>
</div>
<div class="bar"><div class="bar-fill danger" style="width:${stats.tauxAnnulation}%"></div></div>
</div>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="admin.dashboard.consultations_versees"/></span>
<span class="stat-value">${stats.tauxConsultationsVersees}%</span>
</div>
<div class="bar"><div class="bar-fill teal" style="width:${stats.tauxConsultationsVersees}%"></div></div>
</div>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="admin.dashboard.medecins_indisponibles"/></span>
<span class="stat-value">${stats.medecinsIndisponibles}</span>
</div>
<div class="bar"><div class="bar-fill warning" style="width:${stats.medecinsIndisponibles > 0 ? 100 : 0}%"></div></div>
</div>
<div class="stat-row">
<div class="stat-label">
<span><fmt:message key="admin.dashboard.taux_confirmation"/></span>
<span class="stat-value">${stats.tauxConfirmation}%</span>
</div>
<div class="bar"><div class="bar-fill" style="width:${stats.tauxConfirmation}%"></div></div>
</div>
</div>
</div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>