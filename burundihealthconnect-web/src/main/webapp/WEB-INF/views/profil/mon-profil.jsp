<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set scope="request" var="pageRoute" value="profil"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.profil"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.profil"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="profil.title"/></h2>
<form method="post" action="${pageContext.request.contextPath}/profil/mon-profil">
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="fullName"><fmt:message key="label.fullname"/></label>
<input class="form-control" type="text" id="fullName" name="fullName" value="${profil.utilisateur.fullName}">
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.role"/></label>
<div><span class="badge-role badge-role-${fn:toLowerCase(requestScope.roleCode)}">
<c:choose>
<c:when test="${requestScope.roleCode == 'SUPER_ADMIN'}"><fmt:message key="role.super_admin"/></c:when>
<c:when test="${requestScope.roleCode == 'ADMIN'}"><fmt:message key="role.admin"/></c:when>
<c:when test="${requestScope.roleCode == 'MEDECIN'}"><fmt:message key="role.medecin"/></c:when>
<c:otherwise><fmt:message key="role.patient"/></c:otherwise>
</c:choose>
</span></div>
</div>
</div>
<!-- ===== Champs spéifiques PATIENT ===== -->
<c:if test="${requestScope.roleCode == 'PATIENT'}">
<div class="form-group">
<label class="form-label"><fmt:message key="label.numero_patient"/></label>
<div><span class="badge-id">${profil.patient.numeroPatient}</span></div>
</div>
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="telephone"><fmt:message key="label.telephone"/></label>
<input class="form-control" type="tel" id="telephone" name="telephone" value="${profil.patient.telephone}">
</div>
</div>
<div class="form-group">
<label class="form-label" for="adresse"><fmt:message key="label.adresse"/></label>
<input class="form-control" type="text" id="adresse" name="adresse" value="${profil.patient.adresse}">
</div>
</c:if>
<!-- ===== Champs spéifiques MEDECIN ===== -->
<c:if test="${requestScope.roleCode == 'MEDECIN'}">
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="specialite"><fmt:message key="label.specialite"/></label>
<input class="form-control" type="text" id="specialite" name="specialite" value="${profil.medecin.specialite}">
</div>
<div class="form-group">
<label class="form-label" for="experience"><fmt:message key="label.experience.years"/></label>
<input class="form-control" type="number" id="experience" name="experience" min="0" value="${profil.medecin.experience}">
</div>
</div>
<div class="form-group">
<label class="form-label"><fmt:message key="label.numero_ordre.admin"/></label>
<div><span class="badge-id">${profil.medecin.numeroOrdre}</span></div>
</div>
</c:if>
<!-- ===== Champs spéifiques ADMIN / SUPER_ADMIN ===== -->
<c:if test="${requestScope.roleCode == 'ADMIN' or requestScope.roleCode == 'SUPER_ADMIN'}">
<div class="form-group">
<label class="form-label" for="email"><fmt:message key="label.email"/></label>
<input class="form-control" type="email" id="email" name="email" value="${profil.utilisateur.email}">
</div>
</c:if>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.save.modifications"/></button>
</form>
</div>
<!-- ===== Changement de mot de passe ===== -->
<div class="card">
<h3><fmt:message key="profil.change.password.title"/></h3>
<form method="post" action="${pageContext.request.contextPath}/profil/changer-mot-de-passe">
<div class="form-group">
<label class="form-label" for="ancienMotDePasse"><fmt:message key="label.current.password"/></label>
<input class="form-control" type="password" id="ancienMotDePasse" name="ancienMotDePasse" required>
</div>
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="nouveauMotDePasse"><fmt:message key="label.new.password"/></label>
<input class="form-control" type="password" id="nouveauMotDePasse" name="nouveauMotDePasse" minlength="8" required>
</div>
<div class="form-group">
<label class="form-label" for="confirmationMotDePasse"><fmt:message key="label.confirm.password"/></label>
<input class="form-control" type="password" id="confirmationMotDePasse" name="confirmationMotDePasse" minlength="8" required>
</div>
</div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.change.password"/></button>
</form>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
