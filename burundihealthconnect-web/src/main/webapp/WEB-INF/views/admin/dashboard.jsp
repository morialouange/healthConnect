<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="admin-dashboard"/>
<c:set var="pageTitre" value="Tableau de bord"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.dashboard"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="grid-stats">
        <div class="stat-box reveal">
            <div class="stat-icon">&#128104;&#8205;&#9877;</div>
            <div class="stat-info">
                <div class="valeur">${stats.medecinsActifs}</div>
                <div class="libelle"><fmt:message key="stats.medecins_actifs"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128203;</div>
            <div class="stat-info">
                <div class="valeur">${stats.consultationsCeMois}</div>
                <div class="libelle"><fmt:message key="stats.consultations_ce_mois"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128197;</div>
            <div class="stat-info">
                <div class="valeur">${stats.rdvAujourdhui}</div>
                <div class="libelle"><fmt:message key="admin.dashboard.rdv_aujourdhui"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#9203;</div>
            <div class="stat-info">
                <div class="valeur">${stats.rdvEnAttente}</div>
                <div class="libelle"><fmt:message key="admin.dashboard.rdv_attente"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#127973;</div>
            <div class="stat-info">
                <div class="valeur">${stats.servicesActifs}</div>
                <div class="libelle"><fmt:message key="admin.dashboard.services_actifs"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#127796;</div>
            <div class="stat-info">
                <div class="valeur">${stats.medecinsIndisponibles}</div>
                <div class="libelle"><fmt:message key="admin.dashboard.medecins_indisponibles"/></div>
            </div>
        </div>
    </div>

    <div class="charts-grid">
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="stats.consultations_7_jours"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartAdminConsultations"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="stats.repartition_rdv"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartAdminRdvStatus"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="admin.dashboard.top_services"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartTopServices"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="admin.dashboard.charge_medecin"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartChargeMedecin"></canvas>
            </div>
        </div>
    </div>

    <div class="perf-grid">
        <div class="chart-card reveal">
            <h3 class="card-section-title"><fmt:message key="admin.dashboard.performance"/></h3>
            <div class="perf-row">
                <span class="perf-label"><fmt:message key="admin.dashboard.taux_confirmation"/></span>
                <span class="perf-bar-wrap"><span class="perf-bar" style="width:${stats.tauxConfirmation}%;"></span></span>
                <span class="perf-value">${stats.tauxConfirmation}%</span>
            </div>
            <div class="perf-row">
                <span class="perf-label"><fmt:message key="admin.dashboard.taux_annulation"/></span>
                <span class="perf-bar-wrap"><span class="perf-bar danger" style="width:${stats.tauxAnnulation}%;"></span></span>
                <span class="perf-value">${stats.tauxAnnulation}%</span>
            </div>
            <div class="perf-row">
                <span class="perf-label"><fmt:message key="admin.dashboard.consultations_versees"/></span>
                <span class="perf-bar-wrap"><span class="perf-bar success" style="width:${stats.tauxConsultationsVersees}%;"></span></span>
                <span class="perf-value">${stats.tauxConsultationsVersees}%</span>
            </div>
        </div>
        <div class="chart-card reveal">
            <h3 class="card-section-title"><fmt:message key="admin.dashboard.priorites_rdv"/></h3>
            <div style="display:flex; gap:1rem; flex-wrap:wrap;">
                <span class="badge badge-normal">NORMAL: ${stats.normalCount}</span>
                <span class="badge badge-urgent">URGENT: ${stats.urgentCount}</span>
                <span class="badge badge-critique">CRITIQUE: ${stats.critiqueCount}</span>
            </div>
        </div>
    </div>

    <div class="chart-card reveal">
        <h3 class="card-section-title">
            <fmt:message key="admin.management.title"/>
            <a class="see-all" href="${pageContext.request.contextPath}/admin/medecins"><fmt:message key="admin.manage.medecins"/></a>
        </h3>
        <p style="color:var(--gris-texte); margin:0 0 0.5rem 0;">
            <fmt:message key="admin.management.desc"/>
        </p>
        <div class="quick-actions">
            <a class="btn btn-primary-action" href="${pageContext.request.contextPath}/admin/services"><fmt:message key="admin.manage.services"/></a>
            <a class="btn" href="${pageContext.request.contextPath}/admin/conges"><fmt:message key="admin.manage.conges"/></a>
            <a class="btn" href="${pageContext.request.contextPath}/admin/rapport"><fmt:message key="admin.manage.rapport"/></a>
        </div>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
(function() {
    var consultationsLabels = [
        <c:forEach items="${stats.chartConsultations7jours}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var consultationsData = [
        <c:forEach items="${stats.chartConsultations7jours}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartAdminConsultations', consultationsLabels, consultationsData, '#0f766e');

    var rdvLabels = [
        <c:forEach items="${stats.chartRdvStatus}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var rdvData = [
        <c:forEach items="${stats.chartRdvStatus}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.doughnut('chartAdminRdvStatus', rdvLabels, rdvData, ['#0f766e','#2563eb','#d97706','#e11d48','#8b5cf6']);

    var topServicesLabels = [
        <c:forEach items="${stats.chartTop5Services}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var topServicesData = [
        <c:forEach items="${stats.chartTop5Services}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartTopServices', topServicesLabels, topServicesData, '#8b5cf6');

    var chargeLabels = [
        <c:forEach items="${stats.chartChargeParMedecin}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var chargeData = [
        <c:forEach items="${stats.chartChargeParMedecin}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartChargeMedecin', chargeLabels, chargeData, '#d97706');
})();
</script>
</body>
</html>