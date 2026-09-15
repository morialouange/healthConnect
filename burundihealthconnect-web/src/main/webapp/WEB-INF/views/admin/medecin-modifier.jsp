<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-medecins"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.medecin.edit"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.medecin.edit"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="medecin.edit.title"/></h2>
<c:if test="${empty medecin}">
<p><fmt:message key="medecin.not.found"/></p>
</c:if>
<c:if test="${not empty medecin}">
<form method="post" action="${pageContext.request.contextPath}/admin/medecins/modifier">
<input type="hidden" name="idMedecin" value="${medecin.idMedecin}">
<div class="form-group">
<label class="form-label" for="fullName"><fmt:message key="label.fullname"/></label>
<input class="form-control" type="text" id="fullName" name="fullName" value="${medecin.utilisateur.fullName}">
</div>
<div class="form-group">
<label class="form-label" for="email"><fmt:message key="label.email"/></label>
<input class="form-control" type="email" id="email" name="email" value="${medecin.utilisateur.email}">
</div>
<div class="grid-auto-240">
<div class="form-group">
<label class="form-label" for="specialite"><fmt:message key="label.specialite"/></label>
<input class="form-control" type="text" id="specialite" name="specialite" value="${medecin.specialite}">
</div>
<div class="form-group">
<label class="form-label" for="experience"><fmt:message key="label.experience.years"/></label>
<input class="form-control" type="number" id="experience" name="experience" min="0" value="${medecin.experience}">
</div>
</div>
<div class="form-group">
<label class="form-label" for="numeroOrdre"><fmt:message key="label.numero_ordre"/></label>
<input class="form-control" type="text" id="numeroOrdre" name="numeroOrdre" value="${medecin.numeroOrdre}" readonly="readonly">
</div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.save.modifications"/></button>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/medecins/detail?idMedecin=${medecin.idMedecin}"><fmt:message key="btn.cancel"/></a>
</form>
</c:if>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
