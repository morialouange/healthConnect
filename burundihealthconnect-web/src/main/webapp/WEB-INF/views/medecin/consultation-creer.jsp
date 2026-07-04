<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="medecin-rdv"/>
<c:set var="pageTitre" value="Nouvelle consultation"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.consultation.new"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="consultation.new.title"/></h2>

        <c:if test="${empty rdv}">
            <p><fmt:message key="rdv.not.found"/></p>
            <a class="btn" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="btn.back"/></a>
        </c:if>

        <c:if test="${not empty rdv}">
            <div class="card" style="margin-bottom:1rem;">
                <h3><fmt:message key="rdv.info"/></h3>
                <div class="form-row">
                    <div class="form-group">
                        <label><fmt:message key="label.patient"/></label>
                        <input type="text" value="${rdv.patient.utilisateur.fullName}" disabled>
                    </div>
                    <div class="form-group">
                        <label><fmt:message key="label.date.rdv"/></label>
                        <input type="text" value="${rdv.dateRendez}" disabled>
                    </div>
                </div>
                <div class="form-group">
                    <label><fmt:message key="label.motif"/></label>
                    <input type="text" value="${rdv.motif}" disabled>
                </div>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/medecin/consultation/creer">
                <input type="hidden" name="idRendezVous" value="${rdv.idRendez}">
                <input type="hidden" name="idDossier" value="${rdv.patient.dossierMedical.idDossier}">

                <div class="form-group">
                    <label for="notes"><fmt:message key="label.notes"/></label>
                    <textarea id="notes" name="notes" rows="4" placeholder="<fmt:message key='placeholder.notes'/>"></textarea>
                </div>
                <div class="form-group">
                    <label for="diagnostic"><fmt:message key="label.diagnostic"/></label>
                    <textarea id="diagnostic" name="diagnostic" rows="3" placeholder="<fmt:message key='placeholder.diagnostic'/>"></textarea>
                </div>
                <button type="submit" class="btn"><fmt:message key="btn.create.consultation"/></button>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="btn.cancel"/></a>
            </form>
        </c:if>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>