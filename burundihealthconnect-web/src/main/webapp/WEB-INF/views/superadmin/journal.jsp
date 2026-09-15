<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set scope="request" var="pageRoute" value="superadmin-journal"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.journal.acces"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.journal.acces"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="journal.acces.title"/></h2>
<p >
<fmt:message key="journal.acces.desc"/>
</p>
<c:if test="${empty journal}">
<p ><fmt:message key="journal.no.acces"/></p>
</c:if>
<c:if test="${not empty journal}">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.date"/></th>
<th scope="col"><fmt:message key="table.dossier"/></th>
<th scope="col"><fmt:message key="table.patient"/></th>
<th scope="col"><fmt:message key="table.medecin"/></th>
<th scope="col"><fmt:message key="table.etablissement"/></th>
<th scope="col"><fmt:message key="table.type.acces"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="a" items="${journal}">
<tr>
<td>${a.dateAcces}</td>
<td><span>${a.dossier.numeroUnique}</span></td>
<td>${a.dossier.patient.utilisateur.fullName}</td>
<td>${a.medecin.utilisateur.fullName}</td>
<td>${a.etablissement.nom}</td>
<td>
<c:choose>
<c:when test="${a.typeAcces == 'LECTURE'}"><span class="badge badge-info"><fmt:message key="status.lecture"/></span></c:when>
<c:when test="${a.typeAcces == 'MODIFICATION'}"><span class="badge badge-warning"><fmt:message key="status.modification"/></span></c:when>
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
