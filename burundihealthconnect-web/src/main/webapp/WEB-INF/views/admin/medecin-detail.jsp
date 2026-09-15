<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-medecins"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.medecin.detail"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.medecin.detail"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<c:if test="${empty medecin}">
<div class="card"><p><fmt:message key="medecin.not.found"/></p></div>
</c:if>
<c:if test="${not empty medecin}">
<div class="card">
<div >
<h2>${medecin.utilisateur.fullName}</h2>
<div>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/medecins">← <fmt:message key="btn.back"/></a>
</div>
</div>
</div>
<div class="card">
<h3><fmt:message key="medecin.personal.info"/></h3>
<div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.email"/></label>
<input class="form-control" type="text" value="${medecin.utilisateur.email}" disabled>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.numero_ordre"/></label>
<div><span class="badge-id">${medecin.numeroOrdre}</span></div>
</div>
</div>
<div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.specialite"/></label>
<input class="form-control" type="text" value="${medecin.specialite}" disabled>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.experience"/></label>
<input class="form-control" type="text" value="<c:choose><c:when test="${not empty medecin.experience}">${medecin.experience} <fmt:message key="years"/></c:when><c:otherwise>—</c:otherwise></c:choose>" disabled>
</div>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.account.status"/></label>
<c:choose>
<c:when test="${medecin.utilisateur.actif}"><span class="badge badge-success"><fmt:message key="status.actif"/></span></c:when>
<c:otherwise><span class="badge badge-neutral"><fmt:message key="status.desactive"/></span></c:otherwise>
</c:choose>
</div>
</div>
<div class="card">
<h3><fmt:message key="medecin.activity.stats"/></h3>
<div >
<div class="stat-box">
<div><i data-lucide="calendar-check"></i></div>
<div>
<div>${rdvTotaux}</div>
<div><fmt:message key="stats.rdv_totaux"/></div>
</div>
</div>
<div class="stat-box">
<div><i data-lucide="stethoscope"></i></div>
<div>
<div>${consultationsMois}</div>
<div><fmt:message key="stats.consultations_ce_mois"/></div>
</div>
</div>
</div>
</div>
<c:if test="${not empty prochainsRdv}">
<div class="card">
<h3><fmt:message key="medecin.prochains_rdv"/></h3>
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.date"/></th>
<th scope="col"><fmt:message key="table.patient"/></th>
<th scope="col"><fmt:message key="table.motif"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="r" items="${prochainsRdv}">
<tr>
<td>${r.dateRendez}</td>
<td>${r.patient.utilisateur.fullName}</td>
<td>${r.motif}</td>
<td><span>${r.statut}</span></td>
</tr>
</c:forEach>
</tbody>
</table>
</div>
</div>
</c:if>
<c:if test="${not empty congesEnCours}">
<div class="card">
<h3><fmt:message key="medecin.conges_en_cours"/></h3>
<c:forEach var="c" items="${congesEnCours}">
<p><span>${c.dateDebut} → ${c.dateFin}</span></p>
</c:forEach>
</div>
</c:if>
<div class="card">
<h3><fmt:message key="table.actions"/></h3>
<div>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/medecins/modifier?idMedecin=${medecin.idMedecin}"><fmt:message key="btn.modify"/></a>
<c:if test="${medecin.utilisateur.actif}">
<form method="post" action="${pageContext.request.contextPath}/admin/medecins/desactiver" >
<input type="hidden" name="idMedecin" value="${medecin.idMedecin}">
<button type="submit" class="btn btn-danger" onclick="return confirmApp(this, event, '<fmt:message key="confirm.desactivate.medecin"/>')"><fmt:message key="btn.desactiver"/></button>
</form>
</c:if>
</div>
</div>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
