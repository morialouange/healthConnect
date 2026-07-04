<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="pageRoute" value="superadmin-historique"/>
<c:set var="pageTitre" value="Historique global"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.historique.global"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="historique.global.title"/></h2>
        <p style="color:var(--text-muted); font-size:0.85rem;">
            <fmt:message key="historique.global.desc"/>
        </p>

        <c:if test="${empty historique}">
            <p style="color:var(--text-muted);"><fmt:message key="historique.no.modifications"/></p>
        </c:if>

        <c:if test="${not empty historique}">
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="table.date"/></th>
                    <th><fmt:message key="table.patient"/></th>
                    <th><fmt:message key="table.medecin"/></th>
                    <th><fmt:message key="table.etablissement"/></th>
                    <th><fmt:message key="table.champ"/></th>
                    <th><fmt:message key="table.ancienne_valeur"/></th>
                    <th><fmt:message key="table.nouvelle_valeur"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="h" items="${historique}">
                    <tr>
                        <td>${h.dateModification}</td>
                        <td>${h.dossier.patient.utilisateur.fullName}</td>
                        <td>${h.medecin.utilisateur.fullName}</td>
                        <td>${h.etablissement.nom}</td>
                        <td><span class="badge badge-normal">${h.champModifie}</span></td>
                        <td style="max-width:180px; overflow:hidden; text-overflow:ellipsis;">
                            <c:choose>
                                <c:when test="${not empty h.ancienneValeur}">${h.ancienneValeur}</c:when>
                                <c:otherwise><em style="color:var(--text-muted);"><fmt:message key="historique.empty"/></em></c:otherwise>
                            </c:choose>
                        </td>
                        <td style="max-width:180px; overflow:hidden; text-overflow:ellipsis;">
                            <c:choose>
                                <c:when test="${not empty h.nouvelleValeur}">${h.nouvelleValeur}</c:when>
                                <c:otherwise><em style="color:var(--text-muted);"><fmt:message key="historique.empty"/></em></c:otherwise>
                            </c:choose>
                        </td>
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
