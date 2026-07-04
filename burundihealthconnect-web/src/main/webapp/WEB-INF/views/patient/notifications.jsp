<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="pageRoute" value="patient-notifications"/>
<c:set var="pageTitre" value="Notifications"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.notifications"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="notifications.title"/></h2>

        <c:if test="${empty notifications}">
            <p style="color:var(--text-muted);"><fmt:message key="notifications.empty"/></p>
        </c:if>

        <c:forEach var="n" items="${notifications}">
            <div class="card hoverable" style="margin-bottom:0.8rem; ${n.lue ? 'opacity:0.6;' : ''}">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <span>${n.message}</span>
                    <c:if test="${not n.lue}"><span class="badge badge-urgent"><fmt:message key="badge.new"/></span></c:if>
                </div>
                <div style="color:var(--text-muted); font-size:0.78rem; margin-top:0.3rem;">
                    ${n.dateCreation}
                </div>
            </div>
        </c:forEach>
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
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>