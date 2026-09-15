<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set scope="request" var="pageRoute" value="medecin-disponibilite"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.disponibilites"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.disponibilites"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="dispo.declare.title"/></h2>
<p >
<fmt:message key="dispo.declare.desc"/>
</p>
<form method="post" action="${pageContext.request.contextPath}/medecin/disponibilite/declarer">
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="dateDebutSemaine"><fmt:message key="label.date_debut_semaine"/></label>
<input class="form-control" type="date" id="dateDebutSemaine" name="dateDebutSemaine" required>
</div>
<div class="form-group">
<label class="form-label" for="dureeCreneauMin"><fmt:message key="label.duree_creneau"/></label>
<select class="form-control" id="dureeCreneauMin" name="dureeCreneauMin" required>
<option value="15"><fmt:message key="dispo.15min"/></option>
<option value="30" selected><fmt:message key="dispo.30min"/></option>
<option value="60"><fmt:message key="dispo.60min"/></option>
</select>
</div>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="dispo.jours.travailles"/></label>
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="dispo.jour"/></th>
<th scope="col"><fmt:message key="dispo.inclure"/></th>
<th scope="col"><fmt:message key="dispo.debut"/></th>
<th scope="col"><fmt:message key="dispo.fin"/></th>
</tr>
</thead>
<tbody>
<tr>
<td><fmt:message key="day.monday"/></td>
<td><input type="checkbox" name="joursTravailles" value="MONDAY" checked data-day="MONDAY"></td>
<td><input type="time" class="form-control" name="heureDebut_MONDAY" value="08:00" data-day="MONDAY"></td>
<td><input type="time" class="form-control" name="heureFin_MONDAY" value="17:00" data-day="MONDAY"></td>
</tr>
<tr>
<td><fmt:message key="day.tuesday"/></td>
<td><input type="checkbox" name="joursTravailles" value="TUESDAY" checked data-day="TUESDAY"></td>
<td><input type="time" class="form-control" name="heureDebut_TUESDAY" value="08:00" data-day="TUESDAY"></td>
<td><input type="time" class="form-control" name="heureFin_TUESDAY" value="17:00" data-day="TUESDAY"></td>
</tr>
<tr>
<td><fmt:message key="day.wednesday"/></td>
<td><input type="checkbox" name="joursTravailles" value="WEDNESDAY" checked data-day="WEDNESDAY"></td>
<td><input type="time" class="form-control" name="heureDebut_WEDNESDAY" value="08:00" data-day="WEDNESDAY"></td>
<td><input type="time" class="form-control" name="heureFin_WEDNESDAY" value="17:00" data-day="WEDNESDAY"></td>
</tr>
<tr>
<td><fmt:message key="day.thursday"/></td>
<td><input type="checkbox" name="joursTravailles" value="THURSDAY" checked data-day="THURSDAY"></td>
<td><input type="time" class="form-control" name="heureDebut_THURSDAY" value="08:00" data-day="THURSDAY"></td>
<td><input type="time" class="form-control" name="heureFin_THURSDAY" value="17:00" data-day="THURSDAY"></td>
</tr>
<tr>
<td><fmt:message key="day.friday"/></td>
<td><input type="checkbox" name="joursTravailles" value="FRIDAY" checked data-day="FRIDAY"></td>
<td><input type="time" class="form-control" name="heureDebut_FRIDAY" value="08:00" data-day="FRIDAY"></td>
<td><input type="time" class="form-control" name="heureFin_FRIDAY" value="17:00" data-day="FRIDAY"></td>
</tr>
<tr>
<td><fmt:message key="day.saturday"/></td>
<td><input type="checkbox" name="joursTravailles" value="SATURDAY" data-day="SATURDAY"></td>
<td><input type="time" class="form-control" name="heureDebut_SATURDAY" value="08:00" data-day="SATURDAY"></td>
<td><input type="time" class="form-control" name="heureFin_SATURDAY" value="12:00" data-day="SATURDAY"></td>
</tr>
<tr>
<td><fmt:message key="day.sunday"/></td>
<td><input type="checkbox" name="joursTravailles" value="SUNDAY" data-day="SUNDAY"></td>
<td><input type="time" class="form-control" name="heureDebut_SUNDAY" value="08:00" data-day="SUNDAY"></td>
<td><input type="time" class="form-control" name="heureFin_SUNDAY" value="12:00" data-day="SUNDAY"></td>
</tr>
</tbody>
</table>
</div>
</div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.declare.week"/></button>
<script>
 document.querySelectorAll('.day-check').forEach(function(cb) {
 function toggle() {
 var day = cb.getAttribute('data-day');
 var times = document.querySelectorAll('.day-time[data-day="' + day + '"]');
 times.forEach(function(t) { t.disabled = !cb.checked; });
 }
 cb.addEventListener('change', toggle);
 toggle();
 });
 </script>
</form>
</div>
<div class="card">
<h2><fmt:message key="dispo.weeks.declared"/></h2>
<c:if test="${empty semaines}">
<p ><fmt:message key="dispo.no.weeks"/></p>
</c:if>
<c:if test="${not empty semaines}">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="dispo.from"/></th>
<th scope="col"><fmt:message key="dispo.to"/></th>
<th scope="col"><fmt:message key="dispo.duree"/></th>
<th scope="col"><fmt:message key="table.actif"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="s" items="${semaines}">
<tr>
<td>${s.dateDebutSemaine}</td>
<td>${s.dateFinSemaine}</td>
<td>${s.dureeCreneauMin} <fmt:message key="dispo.min"/></td>
<td>
<c:choose>
<c:when test="${s.actif}"><span class="badge badge-success"><fmt:message key="status.active"/></span></c:when>
<c:otherwise><span class="badge badge-neutral"><fmt:message key="status.inactive"/></span></c:otherwise>
</c:choose>
</td>
<td>
<form method="post" action="${pageContext.request.contextPath}/medecin/disponibilite/copier" >
<input type="hidden" name="idDisponibilite" value="${s.idDisponibilite}">
<button type="submit" class="btn btn-secondary btn-sm"><fmt:message key="btn.copy.next.week"/></button>
</form>
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