<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="patient-rdv"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.rdv.hopital"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.rdv.hopital"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="stepper">
<div class="step active"><span class="circle">1</span> <fmt:message key="rdv.step1.title"/></div>
<div class="step-line"></div>
<div class="step"><span class="circle">2</span> <fmt:message key="rdv.step2.title"/></div>
<div class="step-line"></div>
<div class="step"><span class="circle">3</span> <fmt:message key="rdv.step3.title"/></div>
</div>
<div class="card">
<h2><fmt:message key="rdv.step1.title"/></h2>
<p >
<fmt:message key="rdv.step1.desc"/>
</p>
</div>
<c:if test="${empty hopitaux}">
<div class="card"><p><fmt:message key="rdv.no.hopitaux"/></p></div>
</c:if>
<div>
<c:forEach var="h" items="${hopitaux}">
<a href="${pageContext.request.contextPath}/patient/rdv/medecins?idEtablissement=${h.idEtablissement}" >
<div class="stat-box" >
<div><i data-lucide="building-2"></i></div>
<div>
<div >${h.nom}</div>
<div>${h.typeEtablissement}</div>
<div>${h.adresse}</div>
</div>
</div>
</a>
</c:forEach>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>