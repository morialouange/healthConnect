<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="medecin-rdv"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="medecin.rdv.title"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.rdv"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="medecin.rdv.title"/></h2>
<form method="get" action="${pageContext.request.contextPath}/medecin/rdv" class="flex items-center gap-8">
<input type="text" class="form-control" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search_patient'/>...">
<button type="submit" class="btn btn-primary"><fmt:message key="btn.filter"/></button>
</form>
<c:if test="${empty rdv}">
<p><fmt:message key="medecin.no.rdv"/></p>
</c:if>
<c:if test="${not empty rdv}">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.patient"/></th>
<th scope="col"><fmt:message key="table.date"/></th>
<th scope="col"><fmt:message key="table.motif"/></th>
<th scope="col"><fmt:message key="table.priorite"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="r" items="${rdv}">
<tr>
<td>${r.patient.utilisateur.fullName}</td>
<td>${r.dateRendez}</td>
<td>${r.motif}</td>
<td>
<form method="post" action="${pageContext.request.contextPath}/medecin/rdv/priorite" >
<input type="hidden" name="idRendezVous" value="${r.idRendez}">
<select class="form-control" name="priorite" onchange="this.form.submit()" >
<option value="NORMAL" ${r.priorite == 'NORMAL' ? 'selected' : ''}><fmt:message key="priorite.normal"/></option>
<option value="URGENT" ${r.priorite == 'URGENT' ? 'selected' : ''}><fmt:message key="priorite.urgent"/></option>
<option value="CRITIQUE" ${r.priorite == 'CRITIQUE' ? 'selected' : ''}><fmt:message key="priorite.critique"/></option>
</select>
</form>
</td>
<td>
<c:choose>
<c:when test="${r.statut == 'RDV_DEMANDE'}">
<span class="badge badge-warning"><fmt:message key="status.rdv_demande"/></span>
</c:when>
<c:when test="${r.statut == 'RDV_CONFIRME'}">
<span class="badge badge-info"><fmt:message key="status.confirme"/></span>
</c:when>
<c:when test="${r.statut == 'RDV_ANNULE'}">
<span class="badge badge-danger"><fmt:message key="status.annule"/></span>
</c:when>
<c:when test="${r.statut == 'TERMINE'}">
<span class="badge badge-success"><fmt:message key="status.termine"/></span>
</c:when>
</c:choose>
</td>
<td>
<c:if test="${r.statut == 'RDV_DEMANDE'}">
<form method="post" action="${pageContext.request.contextPath}/medecin/rdv/confirmer" >
<input type="hidden" name="idRendezVous" value="${r.idRendez}">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.confirm"/></button>
</form>
<form method="post" action="${pageContext.request.contextPath}/medecin/rdv/refuser" >
<input type="hidden" name="idRendezVous" value="${r.idRendez}">
<button type="submit" class="btn btn-danger btn-sm" onclick="return confirmApp(this, event, '<fmt:message key="confirm.refuser.rdv"/>')"><fmt:message key="btn.refuse"/></button>
</form>
</c:if>
<c:if test="${r.statut == 'RDV_CONFIRME'}">
<a class="btn btn-secondary btn-sm"
 href="${pageContext.request.contextPath}/medecin/consultation/creer?idRendezVous=${r.idRendez}">
<fmt:message key="btn.create.consultation"/></a>
<form method="post" action="${pageContext.request.contextPath}/medecin/rdv/terminer" >
<input type="hidden" name="idRendezVous" value="${r.idRendez}">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.mark.termine"/></button>
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
</c:if>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>