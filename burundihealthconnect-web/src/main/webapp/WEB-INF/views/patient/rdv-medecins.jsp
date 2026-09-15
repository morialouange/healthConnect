<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="patient-rdv"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.rdv.medecin"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.rdv.medecin"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="stepper">
<div class="step done"><span class="circle">✓</span> <fmt:message key="rdv.step1.title"/></div>
<div class="step-line done"></div>
<div class="step active"><span class="circle">2</span> <fmt:message key="rdv.step2.title"/></div>
<div class="step-line"></div>
<div class="step"><span class="circle">3</span> <fmt:message key="rdv.step3.title"/></div>
</div>
<div class="card">
<h2><fmt:message key="rdv.step2.title"/></h2>
<a href="${pageContext.request.contextPath}/patient/rdv/hopitaux" >
 &larr; <fmt:message key="rdv.change.etablissement"/>
</a>
</div>
<c:if test="${empty medecins}">
<div class="card"><p><fmt:message key="rdv.no.medecins"/></p></div>
</c:if>
<div>
<c:forEach var="m" items="${medecins}">
<a href="${pageContext.request.contextPath}/patient/rdv/creneaux?idMedecin=${m.idMedecin}" >
<div class="stat-box" >
<div><i data-lucide="stethoscope"></i></div>
<div>
<div >
 Dr ${m.utilisateur.fullName}
 </div>
<div>${m.specialite}</div>
<c:if test="${not empty m.numeroOrdre}">
<div><span class="badge-id">${m.numeroOrdre}</span></div>
</c:if>
<div>
<c:if test="${not empty m.experience}">${m.experience} <fmt:message key="years.experience"/></c:if>
</div>
</div>
</div>
</a>
</c:forEach>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>