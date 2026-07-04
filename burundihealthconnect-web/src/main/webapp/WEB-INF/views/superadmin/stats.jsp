<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="superadmin-stats"/>
<c:set var="pageTitre" value="Statistiques réseau"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.stats"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="stats.reseau.title"/></h2>
        <p style="color:var(--text-muted); font-size:0.85rem;">
            <fmt:message key="stats.reseau.desc"/>
        </p>
    </div>

    <div class="grid-stats">
        <div class="stat-box">
            <div class="stat-icon">&#127973;</div>
            <div class="stat-info">
                <div class="valeur">${stats.hopitauxActifs}</div>
                <div class="libelle"><fmt:message key="stats.hopitaux_actifs"/></div>
            </div>
        </div>
        <div class="stat-box">
            <div class="stat-icon">&#128101;</div>
            <div class="stat-info">
                <div class="valeur">${stats.patientsReseau}</div>
                <div class="libelle"><fmt:message key="stats.patients_reseau"/></div>
            </div>
        </div>
    </div>

    <div class="charts-grid">
        <div class="chart-card">
            <h3><fmt:message key="stats.chart.patients.par.hopital"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartSuperPatients"></canvas>
            </div>
        </div>
        <div class="chart-card">
            <h3><fmt:message key="stats.chart.repartition.utilisateurs"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartSuperRoles"></canvas>
            </div>
        </div>
    </div>

    <div class="card hoverable">
        <h2><fmt:message key="stats.actions.rapides"/></h2>
        <div style="display:flex; gap:0.8rem; flex-wrap:wrap;">
            <a class="btn" href="${pageContext.request.contextPath}/superadmin/hopitaux"><fmt:message key="btn.gerer.hopitaux"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/superadmin/journal"><fmt:message key="btn.journal.acces"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/superadmin/historique"><fmt:message key="btn.historique.global"/></a>
        </div>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
(function() {
    var patientsLabels = [
        <c:forEach items="${stats.chartPatientsParHopital}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var patientsData = [
        <c:forEach items="${stats.chartPatientsParHopital}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartSuperPatients', patientsLabels, patientsData, '#2563eb');

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
    window.bhcCharts.doughnut('chartSuperRoles', rolesLabels, rolesData, ['#0f766e','#2563eb','#d97706','#8b5cf6']);
})();
</script>
</body>
</html>
