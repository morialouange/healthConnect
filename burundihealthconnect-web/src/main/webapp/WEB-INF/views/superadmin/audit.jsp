<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="superadmin-audit"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.superadmin.audit"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="audit.title"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="audit.title"/></h2>
<p >
<fmt:message key="journal.acces.desc"/>
</p>
</div>
<div>
<div class="stat-box reveal">
<div><i data-lucide="calendar"></i></div>
<div>
<div class="valeur">${statsLog.actionsAujourdhui}</div>
<div><fmt:message key="audit.stats.aujourdhui"/></div>
</div>
</div>
<div class="stat-box reveal">
<div><i data-lucide="shield-alert"></i></div>
<div>
<div class="valeur">${statsLog.actionsCritiques}</div>
<div><fmt:message key="audit.stats.critiques"/></div>
</div>
</div>
<div class="stat-box reveal">
<div><i data-lucide="lock"></i></div>
<div>
<div class="valeur">${statsLog.connexionsEchouees}</div>
<div><fmt:message key="audit.stats.connexions_echouees"/></div>
</div>
</div>
<div class="stat-box reveal">
<div><i data-lucide="file-pen"></i></div>
<div>
<div class="valeur">${statsLog.modificationsDossier}</div>
<div><fmt:message key="audit.stats.modifications_dossier"/></div>
</div>
</div>
<div class="stat-box reveal">
<div><i data-lucide="user-round-cog"></i></div>
<div>
<div class="valeur">${statsLog.actionsAdmin}</div>
<div><fmt:message key="audit.stats.actions_admin"/></div>
</div>
</div>
<div class="stat-box reveal">
<div><i data-lucide="search"></i></div>
<div>
<div class="valeur">${statsLog.accesDossiers}</div>
<div><fmt:message key="audit.stats.acces_dossiers"/></div>
</div>
</div>
</div>
<div class="card">
<form method="get" action="${pageContext.request.contextPath}/superadmin/audit">
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label"><fmt:message key="audit.filtre.recherche"/></label>
<input class="form-control" type="text" name="recherche" value="${filtreRecherche}" placeholder="<fmt:message key='placeholder.search'/>">
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="audit.filtre.module"/></label>
<select class="form-control" name="module">
<option value=""><fmt:message key="label.tous"/></option>
<option value="AUTH" ${filtreModule == 'AUTH' ? 'selected' : ''}>AUTH</option>
<option value="PATIENT" ${filtreModule == 'PATIENT' ? 'selected' : ''}>PATIENT</option>
<option value="MEDECIN" ${filtreModule == 'MEDECIN' ? 'selected' : ''}>MEDECIN</option>
<option value="RDV" ${filtreModule == 'RDV' ? 'selected' : ''}>RDV</option>
<option value="DOSSIER" ${filtreModule == 'DOSSIER' ? 'selected' : ''}>DOSSIER</option>
<option value="SERVICE" ${filtreModule == 'SERVICE' ? 'selected' : ''}>SERVICE</option>
<option value="CONSULTATION" ${filtreModule == 'CONSULTATION' ? 'selected' : ''}>CONSULTATION</option>
<option value="ADMIN" ${filtreModule == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
</select>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="audit.filtre.niveau"/></label>
<select class="form-control" name="niveau">
<option value=""><fmt:message key="label.tous"/></option>
<option value="INFO" ${filtreNiveau == 'INFO' ? 'selected' : ''}><fmt:message key="audit.level.info"/></option>
<option value="WARNING" ${filtreNiveau == 'WARNING' ? 'selected' : ''}><fmt:message key="audit.level.warning"/></option>
<option value="CRITICAL" ${filtreNiveau == 'CRITICAL' ? 'selected' : ''}><fmt:message key="audit.level.critical"/></option>
</select>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="audit.filtre.date_debut"/></label>
<input class="form-control" type="date" name="dateDebut" value="${dateDebut}">
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="audit.filtre.date_fin"/></label>
<input class="form-control" type="date" name="dateFin" value="${dateFin}">
</div>
</div>
<div>
<button type="submit" class="btn btn-primary"><fmt:message key="audit.filtre.appliquer"/></button>
</div>
</form>
</div>
<div class="card">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="audit.table.date"/></th>
<th scope="col"><fmt:message key="audit.table.utilisateur"/></th>
<th scope="col"><fmt:message key="audit.table.role"/></th>
<th scope="col"><fmt:message key="audit.table.etablissement"/></th>
<th scope="col"><fmt:message key="audit.table.module"/></th>
<th scope="col"><fmt:message key="audit.table.action"/></th>
<th scope="col"><fmt:message key="audit.table.niveau"/></th>
<th scope="col"><fmt:message key="audit.table.cible"/></th>
<th scope="col"><fmt:message key="audit.table.description"/></th>
</tr>
</thead>
<tbody>
<c:forEach items="${logs}" var="log" varStatus="s">
<tr>
<td>${log.dateAction}</td>
<td>${log.nomUtilisateur}</td>
<td>${log.roleUtilisateur}</td>
<td>${log.nomEtablissement}</td>
<td>${log.module}</td>
<td>${log.action}</td>
<td>
<c:choose>
<c:when test="${log.niveau == 'CRITICAL'}">
<span class="badge badge-critical"><fmt:message key="audit.level.critical"/></span>
</c:when>
<c:when test="${log.niveau == 'WARNING'}">
<span class="badge badge-warning"><fmt:message key="audit.level.warning"/></span>
</c:when>
<c:otherwise>
<span class="badge badge-info"><fmt:message key="audit.level.info"/></span>
</c:otherwise>
</c:choose>
</td>
<td>${log.cibleType} #${log.cibleId}</td>
<td title="${log.description}">${log.description}</td>
</tr>
</c:forEach>
<c:if test="${empty logs}">
<tr>
<td colspan="9" ><fmt:message key="message.empty.no_data"/></td>
</tr>
</c:if>
</tbody>
</table>
</div>
<c:if test="${totalPages > 1}">
<nav class="pagination">
<c:if test="${page > 0}">
<a class="page-item" href="?page=0&amp;module=${filtreModule}&amp;niveau=${filtreNiveau}&amp;recherche=${filtreRecherche}&amp;dateDebut=${dateDebut}&amp;dateFin=${dateFin}">&laquo;</a>
</c:if>
<c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
<c:choose>
<c:when test="${p == page}">
<span class="page-item active">${p + 1}</span>
</c:when>
<c:otherwise>
<a class="page-item" href="?page=${p}&amp;module=${filtreModule}&amp;niveau=${filtreNiveau}&amp;recherche=${filtreRecherche}&amp;dateDebut=${dateDebut}&amp;dateFin=${dateFin}">${p + 1}</a>
</c:otherwise>
</c:choose>
</c:forEach>
<c:if test="${page < totalPages - 1}">
<a class="page-item" href="?page=${page + 1}&amp;module=${filtreModule}&amp;niveau=${filtreNiveau}&amp;recherche=${filtreRecherche}&amp;dateDebut=${dateDebut}&amp;dateFin=${dateFin}">&raquo;</a>
</c:if>
</nav>
</c:if>
</div>
<div class="chart-grid">
<div class="card reveal">
<h3><fmt:message key="audit.chart.par_module"/></h3>
<div class="table-wrap">
<table class="table">
<thead>
<tr><th scope="col">Module</th><th scope="col">Actions</th></tr>
</thead>
<tbody>
<c:forEach items="${actionsParModule}" var="item">
<tr><td>${item[0]}</td><td>${item[1]}</td></tr>
</c:forEach>
</tbody>
</table>
</div>
</div>
<div class="card reveal">
<h3><fmt:message key="audit.chart.par_niveau"/></h3>
<div class="status-legend">
<c:forEach items="${actionsParNiveau}" var="item">
<div class="item"><span class="swatch" style="background:var(--info);"></span> ${item[0]} <span class="count">${item[1]}</span></div>
</c:forEach>
</div>
</div>
</div>
<div class="card reveal">
<h3><fmt:message key="audit.chart.activite_7j"/></h3>
<div class="table-wrap">
<table class="table">
<thead>
<tr><th scope="col">Jour</th><th scope="col">Activite</th></tr>
</thead>
<tbody>
<c:forEach items="${activite7Jours}" var="item">
<tr><td>${item[0]}</td><td>${item[1]}</td></tr>
</c:forEach>
</tbody>
</table>
</div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
