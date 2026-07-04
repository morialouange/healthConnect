<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="admin-services"/>
<c:set var="pageTitre" value="Gestion des services"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.services"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.8rem;">
            <h2><fmt:message key="admin.services.title"/></h2>
            <button type="button" class="btn" onclick="document.getElementById('formCreerService').style.display='block'">
                + <fmt:message key="btn.new.service"/>
            </button>
        </div>

        <div style="margin-top:1rem;">
            <form method="get" action="${pageContext.request.contextPath}/admin/services" style="display:flex; gap:0.5rem;">
                <input type="text" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search.name'/>..." style="flex:1; padding:0.5rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg-elevated); color:var(--text);">
                <button type="submit" class="btn btn-small"><fmt:message key="btn.search"/></button>
                <c:if test="${not empty filtre}">
                    <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/admin/services"><fmt:message key="btn.clear"/></a>
                </c:if>
            </form>
        </div>

        <div id="formCreerService" style="display:none; margin-top:1rem; padding:1rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg);">
            <h3><fmt:message key="admin.create.service.title"/></h3>
            <form method="post" action="${pageContext.request.contextPath}/admin/services/creer">
                <div class="form-row">
                    <div class="form-group">
                        <label for="nom"><fmt:message key="label.service.name"/></label>
                        <input type="text" id="nom" name="nom" required>
                    </div>
                    <div class="form-group">
                        <label for="categorie"><fmt:message key="label.categorie"/></label>
                        <select id="categorie" name="categorie" required>
                            <option value="">-- <fmt:message key="btn.choose"/> --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat}">${cat}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn"><fmt:message key="btn.create"/></button>
                <button type="button" class="btn btn-secondary" onclick="document.getElementById('formCreerService').style.display='none'"><fmt:message key="btn.cancel"/></button>
            </form>
        </div>
    </div>

    <c:if test="${empty services}">
        <div class="card"><p><fmt:message key="admin.no.services"/></p></div>
    </c:if>

    <c:if test="${not empty services}">
        <div class="card">
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="table.nom"/></th>
                    <th><fmt:message key="table.categorie"/></th>
                    <th><fmt:message key="table.statut"/></th>
                    <th><fmt:message key="table.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="s" items="${services}">
                    <tr>
                        <td><a href="${pageContext.request.contextPath}/admin/services/detail?idService=${s.idService}">${s.nom}</a></td>
                        <td><span class="badge badge-normal">${s.categorie}</span></td>
                        <td>
                            <c:choose>
                                <c:when test="${s.actif}"><span class="badge badge-confirme"><fmt:message key="status.actif"/></span></c:when>
                                <c:otherwise><span class="badge badge-annule"><fmt:message key="status.inactif"/></span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <a class="btn btn-small" href="${pageContext.request.contextPath}/admin/services/detail?idService=${s.idService}"><fmt:message key="btn.detail"/></a>
                            <c:if test="${s.actif}">
                                <form method="post" action="${pageContext.request.contextPath}/admin/services/desactiver" style="display:inline;">
                                    <input type="hidden" name="idService" value="${s.idService}">
                                    <button type="submit" class="btn btn-small btn-danger" onclick="return confirm('<fmt:message key="confirm.desactivate.service"/>')"><fmt:message key="btn.desactiver"/></button>
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