<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="pageRoute" value="medecin-conge"/>
<c:set var="pageTitre" value="Mes congés"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.conges"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="conge.demander.title"/></h2>
        <form method="post" action="${pageContext.request.contextPath}/medecin/conge/demander">
            <div class="form-row">
                <div class="form-group">
                    <label for="dateDebut"><fmt:message key="label.date_debut"/></label>
                    <input type="date" id="dateDebut" name="dateDebut" required>
                </div>
                <div class="form-group">
                    <label for="dateFin"><fmt:message key="label.date_fin"/></label>
                    <input type="date" id="dateFin" name="dateFin" required>
                </div>
            </div>
            <div class="form-group">
                <label for="motif"><fmt:message key="label.motif"/></label>
                <textarea id="motif" name="motif" rows="3" placeholder="<fmt:message key='placeholder.motif.conge'/>..." required></textarea>
            </div>
            <button type="submit" class="btn"><fmt:message key="btn.submit.request"/></button>
        </form>
    </div>

    <div class="card">
        <h2><fmt:message key="conge.mes.demandes"/></h2>

        <c:if test="${empty conges}">
            <p style="color:var(--text-muted);"><fmt:message key="conge.no.requests"/></p>
        </c:if>

        <c:if test="${not empty conges}">
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="conge.from"/></th>
                    <th><fmt:message key="conge.to"/></th>
                    <th><fmt:message key="table.motif"/></th>
                    <th><fmt:message key="table.statut"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="c" items="${conges}">
                    <tr>
                        <td>${c.dateDebut}</td>
                        <td>${c.dateFin}</td>
                        <td>${c.motif}</td>
                        <td>
                            <c:choose>
                                <c:when test="${c.statut == 'EN_ATTENTE'}"><span class="badge badge-demande"><fmt:message key="status.en_attente"/></span></c:when>
                                <c:when test="${c.statut == 'APPROUVE'}"><span class="badge badge-confirme"><fmt:message key="status.approuve"/></span></c:when>
                                <c:when test="${c.statut == 'REFUSE'}"><span class="badge badge-annule"><fmt:message key="status.refuse"/></span></c:when>
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