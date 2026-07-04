<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="admin-services"/>
<c:set var="pageTitre" value="Détail du service"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.service.detail"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <c:if test="${empty service}">
        <div class="card"><p><fmt:message key="service.not.found"/></p></div>
    </c:if>

    <c:if test="${not empty service}">
        <div class="card hoverable">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap;">
                <h2>${service.nom}</h2>
                <a class="btn btn-small" href="${pageContext.request.contextPath}/admin/services">← <fmt:message key="btn.back"/></a>
            </div>
        </div>

        <div class="card">
            <h3><fmt:message key="service.info"/></h3>
            <div class="form-row">
                <div class="form-group">
                    <label><fmt:message key="label.categorie"/></label>
                    <input type="text" value="${service.categorie}" disabled>
                </div>
                <div class="form-group">
                    <label><fmt:message key="table.statut"/></label>
                    <c:choose>
                        <c:when test="${service.actif}"><span class="badge badge-confirme"><fmt:message key="status.actif"/></span></c:when>
                        <c:otherwise><span class="badge badge-annule"><fmt:message key="status.inactif"/></span></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="card">
            <h3><fmt:message key="service.stats.title"/></h3>
            <div class="grid-stats" style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:1rem;">
                <div class="stat-box">
                    <span class="stat-value">${rdvCeMois}</span>
                    <span class="stat-label"><fmt:message key="stats.rdv_ce_mois"/></span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">${medecinsDistincts}</span>
                    <span class="stat-label"><fmt:message key="stats.medecins_distincts"/></span>
                </div>
            </div>
        </div>

        <div class="card">
            <h3><fmt:message key="table.actions"/></h3>
            <div style="display:flex; gap:0.8rem; flex-wrap:wrap;">
                <a class="btn" href="${pageContext.request.contextPath}/admin/services/modifier?idService=${service.idService}"><fmt:message key="btn.modify"/></a>
                <c:if test="${service.actif}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/services/desactiver" style="display:inline;">
                        <input type="hidden" name="idService" value="${service.idService}">
                        <button type="submit" class="btn btn-danger" onclick="return confirm('<fmt:message key="confirm.desactivate.service"/>')"><fmt:message key="btn.desactiver"/></button>
                    </form>
                </c:if>
            </div>
        </div>
    </c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>