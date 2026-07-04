<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="patient-rdv"/>
<c:set var="pageTitre" value="Prendre rendez-vous — Étape 2/3"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.rdv.medecin"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="rdv.step2.title"/></h2>
        <a href="${pageContext.request.contextPath}/patient/rdv/hopitaux" style="font-size:0.85rem;">
            &larr; <fmt:message key="rdv.change.etablissement"/>
        </a>
    </div>

    <c:if test="${empty medecins}">
        <div class="card"><p><fmt:message key="rdv.no.medecins"/></p></div>
    </c:if>

    <div class="grid-stats">
        <c:forEach var="m" items="${medecins}">
            <a href="${pageContext.request.contextPath}/patient/rdv/creneaux?idMedecin=${m.idMedecin}"
               style="text-decoration:none;">
                <div class="stat-box" style="text-align:left;">
                    <div style="font-weight:600; color:var(--text); margin-bottom:0.3rem;">
                        Dr ${m.utilisateur.fullName}
                    </div>
                    <div class="libelle">${m.specialite}</div>
                    <div class="libelle">
                        <c:if test="${not empty m.experience}">${m.experience} <fmt:message key="years.experience"/></c:if>
                    </div>
                </div>
            </a>
        </c:forEach>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>