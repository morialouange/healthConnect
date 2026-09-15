<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-conges"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="admin.conges.title"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.conges"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="admin.conges.title"/></h2>
<div>
<form method="get" action="${pageContext.request.contextPath}/admin/conges" class="flex flex-wrap gap-8">
<input class="form-control" type="text" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search.doctor'/>...">
<button type="submit" class="btn btn-primary"><fmt:message key="btn.search"/></button>
<c:if test="${not empty filtre}">
<a class="btn btn-ghost" href="${pageContext.request.contextPath}/admin/conges"><fmt:message key="btn.clear"/></a>
</c:if>
</form>
</div>
</div>
<c:if test="${empty conges}">
<div class="card"><p><fmt:message key="admin.no.conges"/></p></div>
</c:if>
<c:if test="${not empty conges}">
<div class="card">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.medecin"/></th>
<th scope="col"><fmt:message key="table.date_debut"/></th>
<th scope="col"><fmt:message key="table.date_fin"/></th>
<th scope="col"><fmt:message key="table.motif"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="c" items="${conges}">
<tr>
<td>${c.medecin.utilisateur.fullName}</td>
<td>${c.dateDebut}</td>
<td>${c.dateFin}</td>
<td>${c.motif}</td>
<td>
<c:choose>
<c:when test="${c.statut == 'EN_ATTENTE'}"><span class="badge badge-warning"><fmt:message key="status.en_attente"/></span></c:when>
<c:when test="${c.statut == 'APPROUVE'}"><span class="badge badge-success"><fmt:message key="status.approuve"/></span></c:when>
<c:when test="${c.statut == 'REFUSE'}"><span class="badge badge-danger"><fmt:message key="status.refuse"/></span></c:when>
</c:choose>
</td>
<td>
<c:if test="${c.statut == 'EN_ATTENTE'}">
<form method="post" action="${pageContext.request.contextPath}/admin/conges/approuver" >
<input type="hidden" name="idConge" value="${c.idConge}">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.approuver"/></button>
</form>
<form method="post" action="${pageContext.request.contextPath}/admin/conges/refuser" >
<input type="hidden" name="idConge" value="${c.idConge}">
<button type="submit" class="btn btn-danger btn-sm" onclick="return confirmApp(this, event, '<fmt:message key="confirm.refuser.conge"/>')"><fmt:message key="btn.refuser"/></button>
</form>
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
<a class="page-item" href="?page=0&amp;filtre=${filtre}">&laquo;</a>
</c:if>
<c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
<c:choose>
<c:when test="${p == page}">
<span class="page-item active">${p + 1}</span>
</c:when>
<c:otherwise>
<a class="page-item" href="?page=${p}&amp;filtre=${filtre}">${p + 1}</a>
</c:otherwise>
</c:choose>
</c:forEach>
<c:if test="${page < totalPages - 1}">
<a class="page-item" href="?page=${page + 1}&amp;filtre=${filtre}">&raquo;</a>
</c:if>
</nav>
</c:if>
</div>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
