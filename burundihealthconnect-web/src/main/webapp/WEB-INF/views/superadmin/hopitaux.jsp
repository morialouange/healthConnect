<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set scope="request" var="pageRoute" value="superadmin-hopitaux"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.superadmin.hopitaux"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.hopitaux"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<div>
<h2><fmt:message key="hopitaux.reseau.title"/></h2>
<button type="button" class="btn btn-primary" onclick="document.getElementById('formCreerHopital').classList.toggle('is-open')">
<fmt:message key="btn.ajouter.hopital"/>
</button>
</div>
<div>
<form method="get" action="${pageContext.request.contextPath}/superadmin/hopitaux" class="flex flex-wrap gap-8">
<input class="form-control" type="text" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search.hopital'/>...">
<button type="submit" class="btn btn-primary"><fmt:message key="btn.search"/></button>
<c:if test="${not empty filtre}">
<a class="btn btn-ghost" href="${pageContext.request.contextPath}/superadmin/hopitaux"><fmt:message key="btn.clear"/></a>
</c:if>
</form>
</div>
<div id="formCreerHopital" class="form-creer">
<h3><fmt:message key="hopitaux.ajouter.title"/></h3>
<form method="post" action="${pageContext.request.contextPath}/superadmin/hopitaux/creer">
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="nom"><fmt:message key="label.nom"/></label>
<input class="form-control" type="text" id="nom" name="nom" required>
</div>
<div class="form-group">
<label class="form-label" for="typeEtablissement"><fmt:message key="label.type"/></label>
<input class="form-control" type="text" id="typeEtablissement" name="typeEtablissement" placeholder="<fmt:message key='placeholder.type.etablissement'/>">
</div>
</div>
<div class="form-group">
<label class="form-label" for="adresse"><fmt:message key="label.adresse"/></label>
<input class="form-control" type="text" id="adresse" name="adresse" required>
</div>
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="email"><fmt:message key="label.email"/></label>
<input class="form-control" type="email" id="email" name="email">
</div>
<div class="form-group">
<label class="form-label" for="telephone"><fmt:message key="label.telephone"/></label>
<input class="form-control" type="tel" id="telephone" name="telephone">
</div>
</div>
<div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.ajouter"/></button>
<button type="button" class="btn btn-ghost" onclick="document.getElementById('formCreerHopital').classList.remove('is-open')"><fmt:message key="btn.cancel"/></button>
</div>
</form>
</div>
</div>
<div class="card">
<div>
<h3><fmt:message key="hopitaux.ajouter.administrateur.title"/></h3>
<button type="button" class="btn btn-primary" onclick="document.getElementById('formCreerAdmin').classList.toggle('is-open')">
<fmt:message key="btn.creer.compte.admin"/>
</button>
</div>
<div id="formCreerAdmin" class="form-creer">
<form method="post" action="${pageContext.request.contextPath}/superadmin/admins/creer">
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="adminFullName"><fmt:message key="label.fullname"/></label>
<input class="form-control" type="text" id="adminFullName" name="fullName" required>
</div>
<div class="form-group">
<label class="form-label" for="adminEmail">Email</label>
<input class="form-control" type="email" id="adminEmail" name="email" required>
</div>
</div>
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="adminMdp"><fmt:message key="label.password.temporaire"/></label>
<input class="form-control" type="text" id="adminMdp" name="motDePasseTemporaire" minlength="8" required>
</div>
<div class="form-group">
<label class="form-label" for="idEtablissement"><fmt:message key="label.etablissement"/></label>
<select class="form-control" id="idEtablissement" name="idEtablissement" required>
<option value="">-- <fmt:message key="btn.select"/> --</option>
<c:forEach var="h" items="${hopitaux}">
<option value="${h.idEtablissement}">${h.nom}</option>
</c:forEach>
</select>
</div>
</div>
<div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.creer.admin"/></button>
<button type="button" class="btn btn-ghost" onclick="document.getElementById('formCreerAdmin').classList.remove('is-open')"><fmt:message key="btn.cancel"/></button>
</div>
</form>
</div>
</div>
<c:if test="${empty hopitaux}">
<div class="card"><p><fmt:message key="hopitaux.none"/></p></div>
</c:if>
<c:if test="${not empty hopitaux}">
<div class="card">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><a href="?tri=nom&ordre=${tri == 'nom' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}"><fmt:message key="table.nom"/> ${tri == 'nom' ? (ordre == 'desc' ? '&#9660;' : '&#9650;') : ''}</a></th>
<th scope="col"><a href="?tri=type&ordre=${tri == 'type' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}"><fmt:message key="table.type"/> ${tri == 'type' ? (ordre == 'desc' ? '&#9660;' : '&#9650;') : ''}</a></th>
<th scope="col"><a href="?tri=adresse&ordre=${tri == 'adresse' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}"><fmt:message key="table.adresse"/> ${tri == 'adresse' ? (ordre == 'desc' ? '&#9660;' : '&#9650;') : ''}</a></th>
<th scope="col"><fmt:message key="table.contact"/></th>
<th scope="col"><a href="?tri=actif&ordre=${tri == 'actif' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}"><fmt:message key="table.statut"/> ${tri == 'actif' ? (ordre == 'desc' ? '&#9660;' : '&#9650;') : ''}</a></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="h" items="${hopitaux}">
<tr>
<td>${h.nom}</td>
<td>${h.typeEtablissement}</td>
<td>${h.adresse}</td>
<td>
<c:if test="${not empty h.email}">${h.email}<br></c:if>
<c:if test="${not empty h.telephone}">${h.telephone}</c:if>
</td>
<td>
<c:choose>
<c:when test="${h.actif}"><span class="badge badge-success"><fmt:message key="status.actif"/></span></c:when>
<c:otherwise><span class="badge badge-neutral"><fmt:message key="status.inactif"/></span></c:otherwise>
</c:choose>
</td>
<td>
<form method="post" action="${pageContext.request.contextPath}/superadmin/hopitaux/modifier" >
<input type="hidden" name="idEtablissement" value="${h.idEtablissement}">
<input class="form-control" type="text" name="nom" value="${h.nom}" placeholder="<fmt:message key='placeholder.nom'/>">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.modify"/></button>
</form>
<c:if test="${h.actif}">
<form method="post" action="${pageContext.request.contextPath}/superadmin/hopitaux/desactiver" >
<input type="hidden" name="idEtablissement" value="${h.idEtablissement}">
<button type="submit" class="btn btn-danger btn-sm" onclick="return confirmApp(this, event, '<fmt:message key="confirm.desactiver.etablissement"/>')"><fmt:message key="btn.desactiver"/></button>
</form>
</c:if>
<c:if test="${not h.actif}">
<form method="post" action="${pageContext.request.contextPath}/superadmin/hopitaux/reactiver" >
<input type="hidden" name="idEtablissement" value="${h.idEtablissement}">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.reactiver"/></button>
</form>
</c:if>
</td>
</tr>
</c:forEach>
</tbody>
</table>
</div>
<c:set var="sortParams" value="${tri != null ? '&tri='.concat(tri).concat('&ordre=').concat(ordre) : ''}"/>
<c:if test="${totalPages > 1}">
<nav class="pagination">
<c:if test="${page > 0}">
<a class="page-item" href="?page=0<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>${sortParams}">&laquo;</a>
</c:if>
<c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
<c:choose>
<c:when test="${p == page}">
<span class="page-item active">${p + 1}</span>
</c:when>
<c:otherwise>
<a class="page-item" href="?page=${p}<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>${sortParams}">${p + 1}</a>
</c:otherwise>
</c:choose>
</c:forEach>
<c:if test="${page < totalPages - 1}">
<a class="page-item" href="?page=${page + 1}<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>${sortParams}">&raquo;</a>
</c:if>
</nav>
</c:if>
</div>
</c:if>
<c:if test="${not empty admins}">
<div class="card">
<h3><fmt:message key="hopitaux.administrateurs.title"/></h3>
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.nom"/></th>
<th scope="col"><fmt:message key="table.email"/></th>
<th scope="col"><fmt:message key="table.etablissement"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="a" items="${admins}">
<tr>
<td>${a.fullName}</td>
<td>${a.email}</td>
<td>${a.etablissement.nom}</td>
<td>
<c:choose>
<c:when test="${a.actif}"><span class="badge badge-success"><fmt:message key="status.actif"/></span></c:when>
<c:otherwise><span class="badge badge-neutral"><fmt:message key="status.inactif"/></span></c:otherwise>
</c:choose>
</td>
<td>
<a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/superadmin/admins/modifier?idUtilisateur=${a.idUtilisateur}"><fmt:message key="btn.modify"/></a>
<c:if test="${a.actif}">
<form method="post" action="${pageContext.request.contextPath}/superadmin/admins/desactiver" >
<input type="hidden" name="idUtilisateur" value="${a.idUtilisateur}">
<button type="submit" class="btn btn-danger btn-sm" onclick="return confirmApp(this, event, '<fmt:message key="confirm.desactiver.admin"/>')"><fmt:message key="btn.desactiver"/></button>
</form>
</c:if>
<c:if test="${not a.actif}">
<form method="post" action="${pageContext.request.contextPath}/superadmin/admins/reactiver" >
<input type="hidden" name="idUtilisateur" value="${a.idUtilisateur}">
<button type="submit" class="btn btn-primary btn-sm"><fmt:message key="btn.reactiver"/></button>
</form>
</c:if>
</td>
</tr>
</c:forEach>
</tbody>
</table>
</div>
</div>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
