<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="patient-rdv"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.rdv.creneaux"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.rdv.creneaux"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="stepper">
<div class="step done"><span class="circle">✓</span> <fmt:message key="rdv.step1.title"/></div>
<div class="step-line done"></div>
<div class="step done"><span class="circle">✓</span> <fmt:message key="rdv.step2.title"/></div>
<div class="step-line done"></div>
<div class="step active"><span class="circle">3</span> <fmt:message key="rdv.step3.title"/></div>
</div>
<div class="card">
<h2><fmt:message key="rdv.step3.title"/></h2>
<p >
<fmt:message key="rdv.step3.desc"/>
</p>
</div>
<c:if test="${not empty erreur}">
<div class="alerte alerte-erreur">${erreur}</div>
</c:if>
<c:if test="${empty creneaux}">
<div class="card"><p><fmt:message key="rdv.no.creneaux"/></p></div>
</c:if>
<c:if test="${not empty creneaux}">
<div class="card">
<form method="post" action="${pageContext.request.contextPath}/patient/rdv/creer">
<input type="hidden" name="idMedecin" value="${idMedecin}">
<div class="form-group">
<label class="form-label" for="idCreneau"><fmt:message key="label.creneau"/></label>
<select class="form-control" id="idCreneau" name="idCreneau" required>
<option value="">-- <fmt:message key="rdv.select.creneau"/> --</option>
<c:forEach var="c" items="${creneaux}">
<option value="${c.idCreneau}">
 ${c.dateCreneau} — ${c.heureDebut} à ${c.heureFin}
 </option>
</c:forEach>
</select>
</div>
<div class="form-group">
<label class="form-label" for="motif"><fmt:message key="label.motif"/></label>
<textarea class="form-control" id="motif" name="motif" rows="3" required
 placeholder="<fmt:message key='placeholder.motif'/>"></textarea>
</div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.confirm.rdv"/></button>
</form>
</div>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>