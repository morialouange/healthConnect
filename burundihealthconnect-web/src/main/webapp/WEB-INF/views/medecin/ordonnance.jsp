<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="medecin-rdv"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.creer_ordonnance"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.ordonnance"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="ordonnance.rediger.title"/></h2>
<c:if test="${empty consultation}">
<p ><fmt:message key="consultation.not.found"/></p>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="btn.back.rdv"/></a>
</c:if>
<c:if test="${not empty consultation}">
<p >
<fmt:message key="ordonnance.patient"/> : <strong>${consultation.dossier.patient.utilisateur.fullName}</strong>
<span class="badge-id">${consultation.dossier.patient.numeroPatient}</span>
 — <fmt:message key="label.diagnostic"/> : ${consultation.diagnostic}
 <br>
<fmt:message key="ordonnance.allergies.check"/>
</p>
<form method="post" action="${pageContext.request.contextPath}/medecin/ordonnance/creer">
<input type="hidden" name="idConsultation" value="${consultation.idConsultation}">
<div class="form-group">
<label class="form-label" for="instructions"><fmt:message key="label.instructions.generales"/></label>
<textarea class="form-control" id="instructions" name="instructions" rows="3"
 placeholder="<fmt:message key='placeholder.instructions'/>"></textarea>
</div>
<h3><fmt:message key="ordonnance.lignes.prescription"/></h3>
<div id="lignes">
<div class="ligne-prescription">
<div class="form-group">
<label class="form-label"><fmt:message key="label.medicament"/></label>
<input class="form-control" type="text" name="medicament" placeholder="<fmt:message key='placeholder.medicament'/>">
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.dosage"/></label>
<input class="form-control" type="text" name="dosage" placeholder="<fmt:message key='placeholder.dosage'/>">
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.frequence"/></label>
<input class="form-control" type="text" name="frequence" placeholder="<fmt:message key='placeholder.frequence'/>">
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.jours"/></label>
<input class="form-control" type="number" name="dureeJours" min="1" placeholder="30">
</div>
</div>
</div>
<button type="button" class="btn btn-secondary" onclick="ajouterLigne()">+ <fmt:message key="btn.add.line"/></button>
<br><br>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.validate.ordonnance"/></button>
</form>
</c:if>
</div>
<script>
function ajouterLigne() {
 var div = document.getElementById('lignes');
 var template = document.querySelector('.ligne-prescription').cloneNode(true);
 var inputs = template.querySelectorAll('input');
 inputs.forEach(function(input) { input.value = ''; });
 div.appendChild(template);
}
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>