<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="admin-rapport"/>
<c:set var="pageTitre" value="Rapport mensuel"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.rapport"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="rapport.mensuel.title"/></h2>

        <form method="get" action="${pageContext.request.contextPath}/admin/rapport" style="margin-bottom:1.5rem;">
            <div class="form-row" style="align-items:flex-end;">
                <div class="form-group" style="max-width:250px;">
                    <label for="mois"><fmt:message key="label.mois"/></label>
                    <input type="month" id="mois" name="mois" value="${mois}">
                </div>
                <div class="form-group" style="flex:0;">
                    <button type="submit" class="btn btn-secondary"><fmt:message key="btn.consulter"/></button>
                </div>
            </div>
        </form>

        <c:if test="${empty rapport}">
            <p style="color:var(--text-muted);"><fmt:message key="rapport.no.data"/></p>
        </c:if>

        <c:if test="${not empty rapport}">
            <div class="no-print" style="margin-bottom:1rem;">
                <button onclick="window.print()" class="btn btn-secondary"><fmt:message key="btn.print"/></button>
            </div>
            <div class="grid-stats">
                <div class="stat-box">
                    <div class="valeur">${rapport.totalRdv}</div>
                    <div class="libelle"><fmt:message key="stats.rdv_crees"/></div>
                </div>
                <div class="stat-box">
                    <div class="valeur">${rapport.rdvTermines}</div>
                    <div class="libelle"><fmt:message key="stats.rdv_termines"/></div>
                </div>
                <div class="stat-box">
                    <div class="valeur">${rapport.rdvAnnules}</div>
                    <div class="libelle"><fmt:message key="stats.rdv_annules"/></div>
                </div>
                <div class="stat-box">
                    <div class="valeur">${rapport.consultationsVersees}</div>
                    <div class="libelle"><fmt:message key="stats.consultations_versees"/></div>
                </div>
                <div class="stat-box">
                    <div class="valeur">${rapport.patientsDistincts}</div>
                    <div class="libelle"><fmt:message key="stats.patients_distincts"/></div>
                </div>
            </div>
        </c:if>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>