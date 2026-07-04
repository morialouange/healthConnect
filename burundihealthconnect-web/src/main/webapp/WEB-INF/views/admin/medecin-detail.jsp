<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="admin-medecins"/>
<c:set var="pageTitre" value="Détail du médecin"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.medecin.detail"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <c:if test="${empty medecin}">
        <div class="card"><p><fmt:message key="medecin.not.found"/></p></div>
    </c:if>

    <c:if test="${not empty medecin}">
        <div class="card hoverable">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap;">
                <h2>${medecin.utilisateur.fullName}</h2>
                <div>
                    <a class="btn btn-small" href="${pageContext.request.contextPath}/admin/medecins">← <fmt:message key="btn.back"/></a>
                </div>
            </div>
        </div>

        <div class="card">
            <h3><fmt:message key="medecin.personal.info"/></h3>
            <div class="form-row">
                <div class="form-group">
                    <label><fmt:message key="label.email"/></label>
                    <input type="text" value="${medecin.utilisateur.email}" disabled>
                </div>
                <div class="form-group">
                    <label><fmt:message key="label.numero_ordre"/></label>
                    <input type="text" value="${medecin.numeroOrdre}" disabled>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label><fmt:message key="label.specialite"/></label>
                    <input type="text" value="${medecin.specialite}" disabled>
                </div>
                <div class="form-group">
                    <label><fmt:message key="label.experience"/></label>
                    <input type="text" value="<c:choose><c:when test="${not empty medecin.experience}">${medecin.experience} <fmt:message key="years"/></c:when><c:otherwise>—</c:otherwise></c:choose>" disabled>
                </div>
            </div>
            <div class="form-group">
                <label><fmt:message key="label.account.status"/></label>
                <c:choose>
                    <c:when test="${medecin.utilisateur.actif}"><span class="badge badge-confirme"><fmt:message key="status.actif"/></span></c:when>
                    <c:otherwise><span class="badge badge-annule"><fmt:message key="status.desactive"/></span></c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="card">
            <h3><fmt:message key="medecin.activity.stats"/></h3>
            <div class="grid-stats" style="display:grid; grid-template-columns:repeat(auto-fit, minmax(150px, 1fr)); gap:1rem;">
                <div class="stat-box">
                    <span class="stat-value">${rdvTotaux}</span>
                    <span class="stat-label"><fmt:message key="stats.rdv_totaux"/></span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">${consultationsMois}</span>
                    <span class="stat-label"><fmt:message key="stats.consultations_ce_mois"/></span>
                </div>
            </div>
        </div>

        <c:if test="${not empty prochainsRdv}">
        <div class="card">
            <h3><fmt:message key="medecin.prochains_rdv"/></h3>
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="table.date"/></th>
                    <th><fmt:message key="table.patient"/></th>
                    <th><fmt:message key="table.motif"/></th>
                    <th><fmt:message key="table.statut"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="r" items="${prochainsRdv}">
                    <tr>
                        <td>${r.dateRendez}</td>
                        <td>${r.patient.utilisateur.fullName}</td>
                        <td>${r.motif}</td>
                        <td><span class="badge badge-normal">${r.statut}</span></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
        </c:if>

        <c:if test="${not empty congesEnCours}">
        <div class="card">
            <h3><fmt:message key="medecin.conges_en_cours"/></h3>
            <c:forEach var="c" items="${congesEnCours}">
                <p><span class="badge badge-normal">${c.dateDebut} → ${c.dateFin}</span></p>
            </c:forEach>
        </div>
        </c:if>

        <div class="card">
            <h3><fmt:message key="table.actions"/></h3>
            <div style="display:flex; gap:0.8rem; flex-wrap:wrap;">
                <a class="btn" href="${pageContext.request.contextPath}/admin/medecins/modifier?idMedecin=${medecin.idMedecin}"><fmt:message key="btn.modify"/></a>
                <c:if test="${medecin.utilisateur.actif}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/medecins/desactiver" style="display:inline;">
                        <input type="hidden" name="idMedecin" value="${medecin.idMedecin}">
                        <button type="submit" class="btn btn-danger" onclick="return confirm('<fmt:message key="confirm.desactivate.medecin"/>')"><fmt:message key="btn.desactiver"/></button>
                    </form>
                </c:if>
            </div>
        </div>
    </c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>