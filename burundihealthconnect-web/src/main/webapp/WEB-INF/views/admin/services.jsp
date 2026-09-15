<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-services"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="admin.services.title"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.services"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<div >
<h2><fmt:message key="admin.services.title"/></h2>
<button type="button" class="btn btn-primary" onclick="document.getElementById('formCreerService').classList.add('is-open')">
 + <fmt:message key="btn.new.service"/>
</button>
</div>
<div>
<form method="get" action="${pageContext.request.contextPath}/admin/services" class="flex flex-wrap gap-8">
<input class="form-control" type="text" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search.name'/>...">
<button type="submit" class="btn btn-primary"><fmt:message key="btn.search"/></button>
<c:if test="${not empty filtre}">
<a class="btn btn-ghost" href="${pageContext.request.contextPath}/admin/services"><fmt:message key="btn.clear"/></a>
</c:if>
</form>
</div>
<div id="formCreerService" class="form-creer${requestScope.afficherFormulaire ? ' is-open' : ''}">
<h3><fmt:message key="admin.create.service.title"/></h3>
<form method="post" action="${pageContext.request.contextPath}/admin/services/creer">
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="nom"><fmt:message key="label.service.name"/></label>
<input class="form-control" type="text" id="nom" name="nom" required>
</div>
<div class="form-group">
<label class="form-label" for="categorie"><fmt:message key="label.categorie"/></label>
<select class="form-control" id="categorie" name="categorie" required>
<option value="">-- <fmt:message key="btn.choose"/> --</option>
<c:forEach var="cat" items="${categories}">
<option value="${cat}">${cat}</option>
</c:forEach>
</select>
</div>
</div>
<div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.create"/></button>
<button type="button" class="btn btn-ghost" onclick="document.getElementById('formCreerService').classList.remove('is-open')"><fmt:message key="btn.cancel"/></button>
</div>
</form>
</div>
</div>
<c:if test="${empty services}">
<div class="card"><p><fmt:message key="admin.no.services"/></p></div>
</c:if>
<c:if test="${not empty services}">
<div class="card">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.nom"/></th>
<th scope="col"><fmt:message key="table.categorie"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="s" items="${services}">
<tr>
<td><a href="${pageContext.request.contextPath}/admin/services/detail?idService=${s.idService}">${s.nom}</a></td>
<td><span>${s.categorie}</span></td>
<td>
<c:choose>
<c:when test="${s.actif}"><span class="badge badge-success"><fmt:message key="status.actif"/></span></c:when>
<c:otherwise><span class="badge badge-neutral"><fmt:message key="status.inactif"/></span></c:otherwise>
</c:choose>
</td>
<td>
<a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/admin/services/detail?idService=${s.idService}"><fmt:message key="btn.detail"/></a>
<c:if test="${s.actif}">
<form method="post" action="${pageContext.request.contextPath}/admin/services/desactiver" >
<input type="hidden" name="idService" value="${s.idService}">
<button type="submit" class="btn btn-danger btn-sm" onclick="return confirmApp(this, event, '<fmt:message key="confirm.desactivate.service"/>')"><fmt:message key="btn.desactiver"/></button>
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
