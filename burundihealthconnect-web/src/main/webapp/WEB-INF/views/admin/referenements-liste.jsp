<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set scope="request" var="pageRoute" value="admin-referenements"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="admin.referenements.title"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.referenements"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="admin.referenements.title"/></h2>
<c:if test="${empty referenements}">
<p><fmt:message key="admin.no.referenements"/></p>
</c:if>
<c:if test="${not empty referenements}">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.date"/></th>
<th scope="col"><fmt:message key="table.patient"/></th>
<th scope="col"><fmt:message key="table.hopital_source"/></th>
<th scope="col"><fmt:message key="table.motif"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="r" items="${referenements}">
<tr>
<td>${r.dateRef}</td>
<td>${r.consultation.dossier.patient.utilisateur.fullName}</td>
<td>${r.consultation.etablissement.nom}</td>
<td>${r.motif}</td>
<td>
<c:choose>
<c:when test="${r.statut == 'EN_ATTENTE'}">
<span class="badge badge-warning"><fmt:message key="status.en_attente"/></span>
</c:when>
<c:when test="${r.statut == 'ACCEPTE'}">
<span class="badge badge-info"><fmt:message key="status.accepte"/></span>
</c:when>
<c:when test="${r.statut == 'RETOUR_RECU'}">
<span class="badge badge-info"><fmt:message key="status.retour_recu"/></span>
</c:when>
<c:when test="${r.statut == 'CLOTURE'}">
<span class="badge badge-success"><fmt:message key="status.cloture"/></span>
</c:when>
</c:choose>
</td>
<td>
<c:if test="${r.statut == 'EN_ATTENTE'}">
<form method="post" action="${pageContext.request.contextPath}/admin/referenement/accepter" >
<input type="hidden" name="idRef" value="${r.idRef}">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.accepter"/></button>
</form>
</c:if>
<c:if test="${r.statut == 'ACCEPTE'}">
<form method="post" action="${pageContext.request.contextPath}/admin/referenement/retour" >
<input type="hidden" name="idRef" value="${r.idRef}">
<textarea class="form-control" name="retour" rows="2" placeholder="<fmt:message key='placeholder.resultat.ref'/>..." required ></textarea>
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.send.retour"/></button>
</form>
</c:if>
<c:if test="${r.statut == 'RETOUR_RECU'}">
<c:if test="${not empty r.retour}">
<div >
<strong><fmt:message key="label.retour"/> :</strong> ${r.retour}
 </div>
</c:if>
<form method="post" action="${pageContext.request.contextPath}/admin/referenement/cloturer" >
<input type="hidden" name="idRef" value="${r.idRef}">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.cloturer"/></button>
</form>
</c:if>
<c:if test="${r.statut == 'CLOTURE'}">
<c:if test="${not empty r.retour}">
<div >
<strong><fmt:message key="label.retour"/> :</strong> ${r.retour}
 </div>
</c:if>
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
