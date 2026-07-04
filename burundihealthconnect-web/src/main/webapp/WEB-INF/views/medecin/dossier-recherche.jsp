<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="medecin-dossier"/>
<c:set var="pageTitre" value="Rechercher un dossier"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.dossier.search"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="dossier.search.title"/></h2>
        <p style="color:var(--text-muted); font-size:0.85rem;">
            <fmt:message key="dossier.search.desc"/>
        </p>

        <c:if test="${not empty erreur}">
            <div class="alerte alerte-erreur">${erreur}</div>
        </c:if>

        <form method="get" action="${pageContext.request.contextPath}/medecin/dossier">
            <div class="form-group">
                <label for="numeroPatient"><fmt:message key="label.numero_patient"/></label>
                <input type="text" id="numeroPatient" name="numeroPatient" required
                       placeholder="<fmt:message key='placeholder.numero_patient'/>">
            </div>
            <div class="form-group">
                <label for="motifAcces"><fmt:message key="dossier.motif_acces"/> <span style="color:var(--rouge-danger);">*</span></label>
                <select id="motifAcces" name="motifAcces" required>
                    <option value=""><fmt:message key="label.choisir"/></option>
                    <option value="CONSULTATION"><fmt:message key="dossier.motif.consultation"/></option>
                    <option value="URGENCE"><fmt:message key="dossier.motif.urgence"/></option>
                    <option value="SUIVI"><fmt:message key="dossier.motif.suivi"/></option>
                    <option value="REFERENCEMENT"><fmt:message key="dossier.motif.referenement"/></option>
                    <option value="AUTRE"><fmt:message key="label.autre"/></option>
                </select>
            </div>
            <button type="submit" class="btn"><fmt:message key="btn.search"/></button>
        </form>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>