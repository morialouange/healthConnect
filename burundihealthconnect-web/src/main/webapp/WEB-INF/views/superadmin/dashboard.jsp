<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="superadmin-dashboard"/>
<c:set var="pageTitre" value="Tableau de bord réseau"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="superadmin.dashboard.title"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="superadmin.dashboard.title"/></h2>
        <p style="color:var(--text-muted); font-size:0.85rem;">
            <fmt:message key="stats.reseau.desc"/>
        </p>
    </div>

    <div class="grid-stats">
        <div class="stat-box reveal">
            <div class="stat-icon">&#127973;</div>
            <div class="stat-info">
                <div class="valeur">${stats.hopitauxActifs}</div>
                <div class="libelle"><fmt:message key="superadmin.stats.hopitaux_actifs"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128101;</div>
            <div class="stat-info">
                <div class="valeur">${stats.patientsReseau}</div>
                <div class="libelle"><fmt:message key="superadmin.stats.patients_reseau"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128104;&#8205;&#9877;</div>
            <div class="stat-info">
                <div class="valeur">${stats.medecinsActifs}</div>
                <div class="libelle"><fmt:message key="superadmin.stats.medecins_actifs"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128100;</div>
            <div class="stat-info">
                <div class="valeur">${stats.adminsActifs}</div>
                <div class="libelle"><fmt:message key="superadmin.stats.admins_actifs"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128221;</div>
            <div class="stat-info">
                <div class="valeur">${stats.consultationsCeMois}</div>
                <div class="libelle"><fmt:message key="superadmin.stats.consultations_mois"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128269;</div>
            <div class="stat-info">
                <div class="valeur">${stats.accesDossiersMois}</div>
                <div class="libelle"><fmt:message key="superadmin.stats.acces_dossiers_mois"/></div>
            </div>
        </div>
    </div>

    <div class="charts-grid">
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="superadmin.chart.consultations_30j"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartConsultations30"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="superadmin.chart.top_hopitaux"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartTopHopitaux"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="superadmin.chart.rdv_par_statut"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartRdvStatut"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="superadmin.chart.acces_par_hopital"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartAccesHopital"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="superadmin.chart.patients_par_hopital"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartPatientsHopital"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="superadmin.chart.repartition_roles"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartRepartitionRoles"></canvas>
            </div>
        </div>
    </div>

    <div class="card reveal">
        <h2><fmt:message key="superadmin.sante_reseau"/></h2>
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:1.5rem; margin-top:1rem;">
            <div>
                <label><fmt:message key="stats.hopitaux_actifs"/></label>
                <div class="progress-bar" style="height:8px; background:var(--border); border-radius:4px; overflow:hidden;">
                    <div style="height:100%; width:${stats.tauxHopitauxActifs}%; background:var(--accent); border-radius:4px;"></div>
                </div>
                <small style="color:var(--text-muted);">${stats.tauxHopitauxActifs}%</small>
            </div>
            <div>
                <label><fmt:message key="superadmin.stats.admins_actifs"/></label>
                <div class="progress-bar" style="height:8px; background:var(--border); border-radius:4px; overflow:hidden;">
                    <div style="height:100%; width:${stats.tauxAdminsActifs}%; background:var(--accent); border-radius:4px;"></div>
                </div>
                <small style="color:var(--text-muted);">${stats.tauxAdminsActifs}%</small>
            </div>
            <div>
                <label><fmt:message key="superadmin.stats.medecins_actifs"/></label>
                <div class="progress-bar" style="height:8px; background:var(--border); border-radius:4px; overflow:hidden;">
                    <div style="height:100%; width:${stats.tauxMedecinsActifs}%; background:var(--accent); border-radius:4px;"></div>
                </div>
                <small style="color:var(--text-muted);">${stats.tauxMedecinsActifs}%</small>
            </div>
            <div>
                <label><fmt:message key="consultations_versees"/> / <fmt:message key="stats.consultations_ce_mois"/></label>
                <div class="progress-bar" style="height:8px; background:var(--border); border-radius:4px; overflow:hidden;">
                    <div style="height:100%; width:${stats.tauxConsultationsVersees}%; background:var(--success); border-radius:4px;"></div>
                </div>
                <small style="color:var(--text-muted);">${stats.tauxConsultationsVersees}%</small>
            </div>
            <div>
                <label><fmt:message key="dossier.avec.consultation"/></label>
                <div class="progress-bar" style="height:8px; background:var(--border); border-radius:4px; overflow:hidden;">
                    <div style="height:100%; width:${stats.tauxDossiersAvecConsultation}%; background:var(--warning); border-radius:4px;"></div>
                </div>
                <small style="color:var(--text-muted);">${stats.tauxDossiersAvecConsultation}%</small>
            </div>
        </div>
    </div>

    <div class="card reveal">
        <h2><fmt:message key="superadmin.alertes_titre"/></h2>
        <table class="table">
            <thead>
                <tr>
                    <th><fmt:message key="superadmin.alerte"/></th>
                    <th><fmt:message key="table.detail"/></th>
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
                    <td colspan="2" style="text-align:center; color:var(--success);">&#10003; <fmt:message key="message.empty.no_data"/></td>
                </tr>
                </c:if>
            </tbody>
        </table>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
(function() {
    var consultLabels = [
        <c:forEach items="${stats.chartConsultations30Jours}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var consultData = [
        <c:forEach items="${stats.chartConsultations30Jours}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartConsultations30', consultLabels, consultData, '#0f766e');

    var topLabels = [
        <c:forEach items="${stats.chartTopHopitauxActifs}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var topData = [
        <c:forEach items="${stats.chartTopHopitauxActifs}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartTopHopitaux', topLabels, topData, '#2563eb');

    var rdvLabels = [
        <c:forEach items="${stats.chartRdvStatutReseau}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var rdvData = [
        <c:forEach items="${stats.chartRdvStatutReseau}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.doughnut('chartRdvStatut', rdvLabels, rdvData, ['#f59e0b','#22c55e','#ef4444','#8b5cf6']);

    var accesLabels = [
        <c:forEach items="${stats.chartAccesParHopital}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var accesData = [
        <c:forEach items="${stats.chartAccesParHopital}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartAccesHopital', accesLabels, accesData, '#d97706');

    var patientsHopitauxLabels = [
        <c:forEach items="${stats.chartPatientsParHopital}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var patientsHopitauxData = [
        <c:forEach items="${stats.chartPatientsParHopital}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartPatientsHopital', patientsHopitauxLabels, patientsHopitauxData, '#10b981');

    var rolesLabels = [
        <c:forEach items="${stats.chartRepartitionRoles}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var rolesData = [
        <c:forEach items="${stats.chartRepartitionRoles}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.doughnut('chartRepartitionRoles', rolesLabels, rolesData, ['#2563eb','#10b981','#f59e0b','#8b5cf6']);
})();
</script>
</body>
</html>
