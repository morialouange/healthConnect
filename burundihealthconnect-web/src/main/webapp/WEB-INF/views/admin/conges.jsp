<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="admin-conges"/>
<c:set var="pageTitre" value="Demandes de congé"/>
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
        <h2><fmt:message key="admin.conges.title"/></h2>

        <div style="margin-bottom:1rem;">
            <form method="get" action="${pageContext.request.contextPath}/admin/conges" style="display:flex; gap:0.5rem;">
                <input type="text" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search.doctor'/>..." style="flex:1; padding:0.5rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg-elevated); color:var(--text);">
                <button type="submit" class="btn btn-small"><fmt:message key="btn.search"/></button>
                <c:if test="${not empty filtre}">
                    <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/admin/conges"><fmt:message key="btn.clear"/></a>
                </c:if>
            </form>
        </div>
    </div>

    <c:if test="${empty conges}">
        <div class="card"><p><fmt:message key="admin.no.conges"/></p></div>
    </c:if>

    <c:if test="${not empty conges}">
        <div class="card">
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="table.medecin"/></th>
                    <th><fmt:message key="table.date_debut"/></th>
                    <th><fmt:message key="table.date_fin"/></th>
                    <th><fmt:message key="table.motif"/></th>
                    <th><fmt:message key="table.statut"/></th>
                    <th><fmt:message key="table.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="c" items="${conges}">
                    <tr>
                        <td>${c.medecin.utilisateur.fullName}</td>
                        <td>${c.dateDebut}</td>
                        <td>${c.dateFin}</td>
                        <td>${c.motif}</td>
                        <td>
                            <c:choose>
                                <c:when test="${c.statut == 'EN_ATTENTE'}"><span class="badge badge-normal"><fmt:message key="status.en_attente"/></span></c:when>
                                <c:when test="${c.statut == 'APPROUVE'}"><span class="badge badge-confirme"><fmt:message key="status.approuve"/></span></c:when>
                                <c:when test="${c.statut == 'REFUSE'}"><span class="badge badge-annule"><fmt:message key="status.refuse"/></span></c:when>
                            </c:choose>
                        </td>
                        <td>
                            <c:if test="${c.statut == 'EN_ATTENTE'}">
                                <form method="post" action="${pageContext.request.contextPath}/admin/conges/approuver" style="display:inline;">
                                    <input type="hidden" name="idConge" value="${c.idConge}">
                                    <button type="submit" class="btn btn-small"><fmt:message key="btn.approuver"/></button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/admin/conges/refuser" style="display:inline;">
                                    <input type="hidden" name="idConge" value="${c.idConge}">
                                    <button type="submit" class="btn btn-small btn-danger" onclick="return confirm('<fmt:message key="confirm.refuser.conge"/>')"><fmt:message key="btn.refuser"/></button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${page > 0}">
                    <a class="btn btn-small btn-secondary" href="?page=0&amp;filtre=${filtre}">&laquo;</a>
                </c:if>
                <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                    <c:choose>
                        <c:when test="${p == page}">
                            <span class="btn btn-small active-page">${p + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-small btn-secondary" href="?page=${p}&amp;filtre=${filtre}">${p + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${page < totalPages - 1}">
                    <a class="btn btn-small btn-secondary" href="?page=${page + 1}&amp;filtre=${filtre}">&raquo;</a>
                </c:if>
            </div>
            </c:if>
        </div>
    </c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>