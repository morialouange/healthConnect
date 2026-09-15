<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-rapport"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.rapport"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.rapport"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="rapport.mensuel.title"/></h2>
<form method="get" action="${pageContext.request.contextPath}/admin/rapport" class="flex flex-wrap items-end gap-12">
<div class="form-group">
<label class="form-label" for="mois"><fmt:message key="label.mois"/></label>
<input class="form-control" type="month" id="mois" name="mois" value="${mois}">
</div>
<div class="form-group">
<button type="submit" class="btn btn-primary"><fmt:message key="btn.consulter"/></button>
</div>
</form>
<c:if test="${empty rapport}">
<p ><fmt:message key="rapport.no.data"/></p>
</c:if>
<c:if test="${not empty rapport}">
<div >
<button onclick="window.print()" class="btn btn-secondary"><fmt:message key="btn.print"/></button>
</div>
<div class="kpi-grid" style="--kpi-cols:5;">
<div class="kpi-card stat-box">
<div class="kpi-icon"><i data-lucide="calendar-check"></i></div>
<div>
<div class="kpi-label"><fmt:message key="stats.rdv_crees"/></div>
<div class="kpi-value valeur">${rapport.totalRdv}</div>
</div>
</div>
<div class="kpi-card stat-box">
<div class="kpi-icon"><i data-lucide="check-circle"></i></div>
<div>
<div class="kpi-label"><fmt:message key="stats.rdv_termines"/></div>
<div class="kpi-value valeur">${rapport.rdvTermines}</div>
</div>
</div>
<div class="kpi-card stat-box">
<div class="kpi-icon"><i data-lucide="x-circle"></i></div>
<div>
<div class="kpi-label"><fmt:message key="stats.rdv_annules"/></div>
<div class="kpi-value valeur">${rapport.rdvAnnules}</div>
</div>
</div>
<div class="kpi-card stat-box">
<div class="kpi-icon"><i data-lucide="file-check"></i></div>
<div>
<div class="kpi-label"><fmt:message key="stats.consultations_versees"/></div>
<div class="kpi-value valeur">${rapport.consultationsVersees}</div>
</div>
</div>
<div class="kpi-card stat-box">
<div class="kpi-icon"><i data-lucide="users"></i></div>
<div>
<div class="kpi-label"><fmt:message key="stats.patients_distincts"/></div>
<div class="kpi-value valeur">${rapport.patientsDistincts}</div>
</div>
</div>
</div>
</c:if>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>