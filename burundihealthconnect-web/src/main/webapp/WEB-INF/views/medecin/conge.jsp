<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set scope="request" var="pageRoute" value="medecin-conge"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="conge.mes.demandes"/></c:set>
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
<div>
<h2><fmt:message key="conge.demander.title"/></h2>
<button type="button" class="btn btn-primary" onclick="document.getElementById('formDemanderConge').classList.toggle('is-open')">+ <fmt:message key="btn.new.conge"/></button>
</div>
<div id="formDemanderConge" class="form-creer">
<form method="post" action="${pageContext.request.contextPath}/medecin/conge/demander">
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="dateDebut"><fmt:message key="label.date_debut"/></label>
<input class="form-control" type="date" id="dateDebut" name="dateDebut" required>
</div>
<div class="form-group">
<label class="form-label" for="dateFin"><fmt:message key="label.date_fin"/></label>
<input class="form-control" type="date" id="dateFin" name="dateFin" required>
</div>
</div>
<div class="form-group">
<label class="form-label" for="motif"><fmt:message key="label.motif"/></label>
<textarea class="form-control" id="motif" name="motif" rows="3" placeholder="<fmt:message key='placeholder.motif.conge'/>..." required></textarea>
</div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.submit.request"/></button>
</form>
</div>
</div>
<div class="card">
<h2><fmt:message key="conge.mes.demandes"/></h2>
<c:if test="${empty conges}">
<p ><fmt:message key="conge.no.requests"/></p>
</c:if>
<c:if test="${not empty conges}">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="conge.from"/></th>
<th scope="col"><fmt:message key="conge.to"/></th>
<th scope="col"><fmt:message key="table.motif"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="c" items="${conges}">
<tr>
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