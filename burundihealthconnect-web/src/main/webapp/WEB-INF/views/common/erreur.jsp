<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="error.page.title"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<div class="auth-page">
    <div class="auth-wrapper">
        <h1><fmt:message key="app.name"/></h1>
        <div class="card">
            <h2><fmt:message key="error.title"/></h2>
            <p style="color:var(--text-muted); margin-bottom:1rem;">
                <c:choose>
                    <c:when test="${pageContext.errorData.statusCode == 404}">
                        <fmt:message key="error.404.message"/>
                    </c:when>
                    <c:when test="${pageContext.errorData.statusCode == 403}">
                        <fmt:message key="error.403.message"/>
                    </c:when>
                    <c:otherwise>
                        <fmt:message key="error.internal.message"/>
                    </c:otherwise>
                </c:choose>
            </p>
            <c:if test="${not empty pageContext.errorData.throwable}">
                <p style="font-size:0.8rem; color:var(--danger-text); background:var(--danger-bg); padding:0.8rem; border-radius:var(--radius-sm);">
                    ${pageContext.errorData.throwable.message}
                </p>
            </c:if>
            <a class="btn" href="${pageContext.request.contextPath}/auth" style="width:100%;"><fmt:message key="error.back.home"/></a>
        </div>
    </div>
</div>

</body>
</html>
