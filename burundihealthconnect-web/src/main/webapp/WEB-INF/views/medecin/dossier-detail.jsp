<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="medecin-dossier"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.medecin.dossier_patient"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.dossier.patient"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<c:if test="${empty dossier}">
<div class="card">
<p><fmt:message key="dossier.not.found"/></p>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/dossier"><fmt:message key="dossier.new.search"/></a>
</div>
</c:if>
<c:if test="${not empty dossier}">
<div class="card">
<div class="flex flex-wrap items-center justify-between gap-12">
<h2><fmt:message key="dossier.medical"/> — ${dossier.patient.utilisateur.fullName}</h2>
<div>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/dossier">← <fmt:message key="dossier.new.search"/></a>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/historique?idDossier=${dossier.idDossier}"><fmt:message key="btn.historique"/></a>
</div>
</div>
</div>
<div class="card">
<h3><fmt:message key="dossier.general.info"/></h3>
<div class="grid-auto-200">
<div class="form-group">
<label class="form-label"><fmt:message key="label.numero_patient"/></label>
<div><span class="badge-id">${dossier.patient.numeroPatient}</span></div>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.numero_dossier"/></label>
<div><span>${dossier.numeroUnique}</span></div>
</div>
</div>
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label"><fmt:message key="label.date_naissance"/></label>
<input class="form-control" type="text" value="${dossier.patient.dateNaissance}" disabled>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.sexe"/></label>
<input class="form-control" type="text" value="${dossier.patient.sexe == 'M' ? 'Masculin' : 'F\u00e9minin'}" disabled>
</div>
</div>
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label"><fmt:message key="label.telephone"/></label>
<input class="form-control" type="text" value="<c:choose><c:when test="${not empty dossier.patient.telephone}">${dossier.patient.telephone}</c:when><c:otherwise>—</c:otherwise></c:choose>" disabled>
</div>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="dossier.antecedents"/></label>
<textarea class="form-control" rows="3" disabled><c:choose><c:when test="${not empty dossier.antecedents}">${dossier.antecedents}</c:when><c:otherwise><fmt:message key="dossier.no.antecedents"/></c:otherwise></c:choose></textarea>
</div>
</div>
<div class="card">
<h3><fmt:message key="consultation.new.title"/></h3>
<form method="post" action="${pageContext.request.contextPath}/medecin/consultation/creer">
<input type="hidden" name="idDossier" value="${dossier.idDossier}">
<div class="form-group">
<label class="form-label" for="notes"><fmt:message key="label.notes"/></label>
<textarea class="form-control" id="notes" name="notes" rows="4" placeholder="<fmt:message key='placeholder.notes'/>"></textarea>
</div>
<div class="form-group">
<label class="form-label" for="diagnostic"><fmt:message key="label.diagnostic"/></label>
<textarea class="form-control" id="diagnostic" name="diagnostic" rows="3" placeholder="<fmt:message key='placeholder.diagnostic'/>"></textarea>
</div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.create.consultation"/></button>
</form>
</div>
<div class="card">
<h3><fmt:message key="dossier.historique.consultations"/></h3>
<p >
<fmt:message key="dossier.historique.notice"/>
</p>
<c:if test="${empty historique}">
<p ><fmt:message key="dossier.no.consultations.versed"/></p>
</c:if>
<c:if test="${not empty historique}">
<div class="table-wrap">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.date"/></th>
<th scope="col"><fmt:message key="table.etablissement"/></th>
<th scope="col"><fmt:message key="table.medecin"/></th>
<th scope="col"><fmt:message key="table.diagnostic"/></th>
<th scope="col"><fmt:message key="table.notes"/></th>
<th scope="col"><fmt:message key="table.prescriptions"/></th>
<th scope="col"><fmt:message key="table.statut"/></th>
<th scope="col"><fmt:message key="table.actions"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="c" items="${historique}">
<tr>
<td>${c.dateConsultation}</td>
<td>${c.etablissement.nom}</td>
<td>${c.medecin.utilisateur.fullName}</td>
<td>${not empty c.diagnostic ? c.diagnostic : '—'}</td>
<td>${not empty c.notes ? c.notes : '—'}</td>
<td>
<c:choose>
<c:when test="${not empty c.ordonance and not empty c.ordonance.lignes}">
<ul >
<c:forEach var="l" items="${c.ordonance.lignes}">
<li><strong>${l.medicament}</strong>
<c:if test="${not empty l.dosage}"> — ${l.dosage}</c:if>
<c:if test="${not empty l.frequence}">, ${l.frequence}</c:if>
<c:if test="${l.dureeJours > 0}"> (${l.dureeJours}j)</c:if>
</li>
</c:forEach>
</ul>
</c:when>
<c:otherwise>—</c:otherwise>
</c:choose>
</td>
<td>
<c:choose>
<c:when test="${c.statut == 'EN_COURS'}"><span class="badge badge-info"><fmt:message key="status.en_cours"/></span></c:when>
<c:when test="${c.statut == 'CLOTUREE'}"><span class="badge badge-success"><fmt:message key="status.cloturee"/></span></c:when>
<c:when test="${c.statut == 'VERSEE_AU_DOSSIER'}"><span class="badge badge-success"><fmt:message key="status.versee_dossier"/></span></c:when>
<c:otherwise><span class="badge badge-neutral">${c.statut}</span></c:otherwise>
</c:choose>
</td>
<td>
<a class="btn btn-secondary btn-sm"
 href="${pageContext.request.contextPath}/medecin/ordonnance?idConsultation=${c.idConsultation}">
<fmt:message key="btn.ordonnance"/></a>
</td>
</tr>
</c:forEach>
</tbody>
</table>
</div>
</c:if>
</div>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>