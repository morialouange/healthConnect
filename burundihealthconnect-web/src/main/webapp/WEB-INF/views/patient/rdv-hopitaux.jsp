<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="patient-rdv"/>
<c:set var="pageTitre" value="Prendre rendez-vous — Étape 1/3"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.rdv.hopital"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="rdv.step1.title"/></h2>
        <p style="color:var(--text-muted);">
            <fmt:message key="rdv.step1.desc"/>
        </p>
    </div>

    <c:if test="${empty hopitaux}">
        <div class="card"><p><fmt:message key="rdv.no.hopitaux"/></p></div>
    </c:if>

    <div class="grid-stats">
        <c:forEach var="h" items="${hopitaux}">
            <a href="${pageContext.request.contextPath}/patient/rdv/medecins?idEtablissement=${h.idEtablissement}"
               style="text-decoration:none;">
                <div class="stat-box" style="text-align:left;">
                    <div style="font-weight:600; color:var(--text); margin-bottom:0.3rem;">${h.nom}</div>
                    <div class="libelle">${h.typeEtablissement}</div>
                    <div class="libelle">${h.adresse}</div>
                </div>
            </a>
        </c:forEach>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>