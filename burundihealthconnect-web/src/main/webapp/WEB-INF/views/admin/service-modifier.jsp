<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-services"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.service.edit"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.service.edit"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<c:if test="${empty service}">
<div class="card"><p><fmt:message key="service.not.found"/></p></div>
</c:if>
<c:if test="${not empty service}">
<div class="card">
<h2><fmt:message key="service.edit.title"/></h2>
<form method="post" action="${pageContext.request.contextPath}/admin/services/modifier">
<input type="hidden" name="idService" value="${service.idService}">
<div class="form-group">
<label class="form-label" for="nom"><fmt:message key="label.service.name"/></label>
<input class="form-control" type="text" id="nom" name="nom" value="${service.nom}" required>
</div>
<div class="form-group">
<label class="form-label" for="categorie"><fmt:message key="label.categorie"/></label>
<select class="form-control" id="categorie" name="categorie" required>
<c:forEach var="cat" items="${categories}">
<option value="${cat}" ${cat == service.categorie ? 'selected' : ''}>${cat}</option>
</c:forEach>
</select>
</div>
<div>
<button type="submit" class="btn btn-primary"><fmt:message key="btn.save"/></button>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/services/detail?idService=${service.idService}"><fmt:message key="btn.cancel"/></a>
</div>
</form>
</div>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
