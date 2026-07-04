<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="pageRoute" value="medecin-referenements"/>
<c:set var="pageTitre" value="Mes référencements"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.referenements"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="medecin.referenements.envoyes"/></h2>

        <c:if test="${empty referenements}">
            <p><fmt:message key="medecin.no.referenements"/></p>
        </c:if>

        <c:if test="${not empty referenements}">
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="table.date"/></th>
                    <th><fmt:message key="table.patient"/></th>
                    <th><fmt:message key="table.hopital_destinataire"/></th>
                    <th><fmt:message key="table.motif"/></th>
                    <th><fmt:message key="table.statut"/></th>
                    <th><fmt:message key="table.retour"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="r" items="${referenements}">
                    <tr>
                        <td>${r.dateRef}</td>
                        <td>${r.consultation.dossier.patient.utilisateur.fullName}</td>
                        <td>${r.etablissementDest.nom}</td>
                        <td>${r.motif}</td>
                        <td>
                            <c:choose>
                                <c:when test="${r.statut == 'EN_ATTENTE'}">
                                    <span class="badge badge-demande"><fmt:message key="status.en_attente"/></span>
                                </c:when>
                                <c:when test="${r.statut == 'ACCEPTE'}">
                                    <span class="badge badge-confirme"><fmt:message key="status.accepte"/></span>
                                </c:when>
                                <c:when test="${r.statut == 'RETOUR_RECU'}">
                                    <span class="badge badge-info"><fmt:message key="status.retour_recu"/></span>
                                </c:when>
                                <c:when test="${r.statut == 'CLOTURE'}">
                                    <span class="badge badge-termine"><fmt:message key="status.cloture"/></span>
                                </c:when>
                            </c:choose>
                        </td>
                        <td>${r.retour != null ? r.retour : '—'}</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${page > 0}">
                    <a class="btn btn-small btn-secondary" href="?page=0">&laquo;</a>
                </c:if>
                <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                    <c:choose>
                        <c:when test="${p == page}">
                            <span class="btn btn-small active-page">${p + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-small btn-secondary" href="?page=${p}">${p + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${page < totalPages - 1}">
                    <a class="btn btn-small btn-secondary" href="?page=${page + 1}">&raquo;</a>
                </c:if>
            </div>
            </c:if>
        </c:if>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>