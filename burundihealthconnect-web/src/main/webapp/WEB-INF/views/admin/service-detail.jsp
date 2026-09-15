<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-services"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.service.detail"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.service.detail"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<c:if test="${empty service}">
<div class="card"><p><fmt:message key="service.not.found"/></p></div>
</c:if>
<c:if test="${not empty service}">
<div class="card">
<div >
<h2>${service.nom}</h2>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/services">← <fmt:message key="btn.back"/></a>
</div>
</div>
<div class="card">
<h3><fmt:message key="service.info"/></h3>
<div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.categorie"/></label>
<input class="form-control" type="text" value="${service.categorie}" disabled>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="table.statut"/></label>
<c:choose>
<c:when test="${service.actif}"><span class="badge badge-success"><fmt:message key="status.actif"/></span></c:when>
<c:otherwise><span class="badge badge-neutral"><fmt:message key="status.inactif"/></span></c:otherwise>
</c:choose>
</div>
</div>
</div>
<div class="card">
<h3><fmt:message key="service.stats.title"/></h3>
<div >
<div class="stat-box">
<div><i data-lucide="calendar-check"></i></div>
<div>
<div>${rdvCeMois}</div>
<div><fmt:message key="stats.rdv_ce_mois"/></div>
</div>
</div>
<div class="stat-box">
<div><i data-lucide="user-round-cog"></i></div>
<div>
<div>${medecinsDistincts}</div>
<div><fmt:message key="stats.medecins_distincts"/></div>
</div>
</div>
</div>
</div>
<div class="card">
<h3><fmt:message key="table.actions"/></h3>
<div>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/services/modifier?idService=${service.idService}"><fmt:message key="btn.modify"/></a>
<c:if test="${service.actif}">
<form method="post" action="${pageContext.request.contextPath}/admin/services/desactiver" >
<input type="hidden" name="idService" value="${service.idService}">
<button type="submit" class="btn btn-danger" onclick="return confirmApp(this, event, '<fmt:message key="confirm.desactivate.service"/>')"><fmt:message key="btn.desactiver"/></button>
</form>
</c:if>
</div>
</div>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
