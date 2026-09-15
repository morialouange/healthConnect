<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="medecin-dossier"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.recherche_dossier"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.dossier.search"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="dossier.search.title"/></h2>
<p >
<fmt:message key="dossier.search.desc"/>
</p>
<c:if test="${not empty erreur}">
<div class="alerte alerte-erreur">${erreur}</div>
</c:if>
<form method="get" action="${pageContext.request.contextPath}/medecin/dossier">
<div class="form-group">
<label class="form-label" for="numeroPatient"><fmt:message key="label.numero_patient"/></label>
<input class="form-control" type="text" id="numeroPatient" name="numeroPatient" required
 placeholder="<fmt:message key='placeholder.numero_patient'/>">
</div>
<div class="form-group">
<label class="form-label" for="motifAcces"><fmt:message key="dossier.motif_acces"/>
<span>*</span></label>
<select class="form-control" id="motifAcces" name="motifAcces" required>
<option value=""><fmt:message key="label.choisir"/></option>
<option value="CONSULTATION"><fmt:message key="dossier.motif.consultation"/></option>
<option value="URGENCE"><fmt:message key="dossier.motif.urgence"/></option>
<option value="SUIVI"><fmt:message key="dossier.motif.suivi"/></option>
<option value="REFERENCEMENT"><fmt:message key="dossier.motif.referenement"/></option>
<option value="AUTRE"><fmt:message key="label.autre"/></option>
</select>
</div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.search"/></button>
</form>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>