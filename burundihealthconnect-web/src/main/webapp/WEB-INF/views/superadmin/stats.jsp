<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="superadmin-stats"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.superadmin.stats"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.stats"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="stats.reseau.title"/></h2>
<p >
<fmt:message key="stats.reseau.desc"/>
</p>
</div>
<div class="kpi-grid" style="--kpi-cols:2;">
<div class="kpi-card stat-box">
<div class="kpi-icon"><i data-lucide="building-2"></i></div>
<div>
<div class="kpi-label"><fmt:message key="stats.hopitaux_actifs"/></div>
<div class="kpi-value valeur">${stats.hopitauxActifs}</div>
</div>
</div>
<div class="kpi-card stat-box">
<div class="kpi-icon"><i data-lucide="users"></i></div>
<div>
<div class="kpi-label"><fmt:message key="stats.patients_reseau"/></div>
<div class="kpi-value valeur">${stats.patientsReseau}</div>
</div>
</div>
</div>
<div class="chart-grid">
<div class="card reveal">
<h3><fmt:message key="stats.chart.patients.par.hopital"/></h3>
<div class="table-wrap">
<table class="table">
<thead>
<tr><th scope="col">Hopital</th><th scope="col">Patients</th></tr>
</thead>
<tbody>
<c:forEach items="${stats.chartPatientsParHopital}" var="item">
<tr><td>${item[0]}</td><td>${item[1]}</td></tr>
</c:forEach>
</tbody>
</table>
</div>
</div>
<div class="card reveal">
<h3><fmt:message key="stats.chart.repartition.utilisateurs"/></h3>
<div class="status-legend">
<c:forEach items="${stats.chartRepartitionRoles}" var="item">
<div class="item"><span class="swatch" style="background:var(--info);"></span> ${item[0]} <span class="count">${item[1]}</span></div>
</c:forEach>
</div>
</div>
</div>
<div class="card">
<h2><fmt:message key="stats.actions.rapides"/></h2>
<div>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/superadmin/hopitaux"><fmt:message key="btn.gerer.hopitaux"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/superadmin/journal"><fmt:message key="btn.journal.acces"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/superadmin/historique"><fmt:message key="btn.historique.global"/></a>
</div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
