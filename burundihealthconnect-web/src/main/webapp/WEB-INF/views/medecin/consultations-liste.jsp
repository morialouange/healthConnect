<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set scope="request" var="pageRoute" value="medecin-consultations"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="medecin.consultations.title"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.consultations"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="medecin.consultations.title"/></h2>
<c:if test="${empty consultations}">
<p><fmt:message key="medecin.no.consultations"/></p>
</c:if>
<c:if test="${not empty consultations}">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.date"/></th>
<th scope="col"><fmt:message key="table.patient"/></th>
<th scope="col"><fmt:message key="table.diagnostic"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="c" items="${consultations}">
<tr>
<td>${c.dateConsultation}</td>
<td>${c.dossier.patient.utilisateur.fullName}</td>
<td>${c.diagnostic}</td>
<td>
<c:choose>
<c:when test="${c.statut == 'EN_COURS'}">
<span class="badge badge-info"><fmt:message key="status.en_cours"/></span>
</c:when>
<c:when test="${c.statut == 'CLOTUREE'}">
<span class="badge badge-success"><fmt:message key="status.cloturee"/></span>
</c:when>
<c:when test="${c.statut == 'VERSEE_AU_DOSSIER'}">
<span class="badge badge-success"><fmt:message key="status.versee_dossier"/></span>
</c:when>
</c:choose>
</td>
<td>
<c:if test="${c.statut == 'EN_COURS'}">
<form method="post" action="${pageContext.request.contextPath}/medecin/consultation/statut" >
<input type="hidden" name="idConsultation" value="${c.idConsultation}">
<input type="hidden" name="statut" value="CLOTUREE">
<button type="submit" class="btn btn-secondary btn-sm"><fmt:message key="btn.cloturer"/></button>
</form>
<a class="btn btn-secondary btn-sm"
 href="${pageContext.request.contextPath}/medecin/referenement/creer?idConsultation=${c.idConsultation}">
<fmt:message key="btn.referer"/></a>
</c:if>
<c:if test="${c.statut == 'CLOTUREE'}">
<form method="post" action="${pageContext.request.contextPath}/medecin/consultation/statut" >
<input type="hidden" name="idConsultation" value="${c.idConsultation}">
<input type="hidden" name="statut" value="VERSEE_AU_DOSSIER">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.verser.dossier"/></button>
</form>
</c:if>
<c:if test="${c.ordonance != null}">
<a class="btn btn-secondary btn-sm"
 href="${pageContext.request.contextPath}/medecin/ordonnances">
<fmt:message key="btn.voir.ordonnance"/></a>
</c:if>
<c:if test="${c.ordonance == null && c.statut == 'EN_COURS'}">
<a class="btn btn-primary btn-sm"
 href="${pageContext.request.contextPath}/medecin/ordonnance?idConsultation=${c.idConsultation}">
<fmt:message key="btn.prescrire"/></a>
</c:if>
</td>
</tr>
</c:forEach>
</tbody>
</table>
</div>
<c:if test="${totalPages > 1}">
<nav class="pagination">
<c:if test="${page > 0}">
<a class="page-item" href="?page=0">&laquo;</a>
</c:if>
<c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
<c:choose>
<c:when test="${p == page}">
<span class="page-item active">${p + 1}</span>
</c:when>
<c:otherwise>
<a class="page-item" href="?page=${p}">${p + 1}</a>
</c:otherwise>
</c:choose>
</c:forEach>
<c:if test="${page < totalPages - 1}">
<a class="page-item" href="?page=${page + 1}">&raquo;</a>
</c:if>
</nav>
</c:if>
</c:if>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>