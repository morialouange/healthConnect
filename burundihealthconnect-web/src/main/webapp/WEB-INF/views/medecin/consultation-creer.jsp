<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="medecin-rdv"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.consultation.new"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.consultation.new"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="consultation.new.title"/></h2>
<c:if test="${empty rdv}">
<p><fmt:message key="rdv.not.found"/></p>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="btn.back"/></a>
</c:if>
<c:if test="${not empty rdv}">
<div class="card" >
<h3><fmt:message key="rdv.info"/></h3>
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label"><fmt:message key="label.patient"/></label>
<input class="form-control" type="text" value="${rdv.patient.utilisateur.fullName} (${rdv.patient.numeroPatient})" disabled>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.date.rdv"/></label>
<input class="form-control" type="text" value="${rdv.dateRendez}" disabled>
</div>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.motif"/></label>
<input class="form-control" type="text" value="${rdv.motif}" disabled>
</div>
</div>
<form method="post" action="${pageContext.request.contextPath}/medecin/consultation/creer">
<input type="hidden" name="idRendezVous" value="${rdv.idRendez}">
<input type="hidden" name="idDossier" value="${rdv.patient.dossierMedical.idDossier}">
<div class="form-group">
<label class="form-label" for="notes"><fmt:message key="label.notes"/></label>
<textarea class="form-control" id="notes" name="notes" rows="4" placeholder="<fmt:message key='placeholder.notes'/>"></textarea>
</div>
<div class="form-group">
<label class="form-label" for="diagnostic"><fmt:message key="label.diagnostic"/></label>
<textarea class="form-control" id="diagnostic" name="diagnostic" rows="3" placeholder="<fmt:message key='placeholder.diagnostic'/>"></textarea>
</div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.create.consultation"/></button>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="btn.cancel"/></a>
</form>
</c:if>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>