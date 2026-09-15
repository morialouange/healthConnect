<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="medecin-dossier"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="historique.modifications.title"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.historique"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="historique.modifications.title"/></h2>
<p >
<fmt:message key="historique.modifications.desc"/>
</p>
<c:if test="${empty historique}">
<p ><fmt:message key="historique.no.modifications"/></p>
</c:if>
<c:if test="${not empty historique}">
<table class="table">
<thead>
<tr>
<th scope="col"><fmt:message key="table.date"/></th>
<th scope="col"><fmt:message key="table.medecin"/></th>
<th scope="col"><fmt:message key="table.etablissement"/></th>
<th scope="col"><fmt:message key="table.champ_modifie"/></th>
<th scope="col"><fmt:message key="table.ancienne_valeur"/></th>
<th scope="col"><fmt:message key="table.nouvelle_valeur"/></th>
</tr>
</thead>
<tbody>
<c:forEach var="h" items="${historique}">
<tr>
<td>${h.dateModification}</td>
<td>${h.medecin.utilisateur.fullName}</td>
<td>${h.etablissement.nom}</td>
<td><span>${h.champModifie}</span></td>
<td>
<c:choose>
<c:when test="${not empty h.ancienneValeur}">${h.ancienneValeur}</c:when>
<c:otherwise><em><fmt:message key="historique.empty"/></em></c:otherwise>
</c:choose>
</td>
<td>
<c:choose>
<c:when test="${not empty h.nouvelleValeur}">${h.nouvelleValeur}</c:when>
<c:otherwise><em><fmt:message key="historique.empty"/></em></c:otherwise>
</c:choose>
</td>
</tr>
</c:forEach>
</tbody>
</table>
</c:if>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>