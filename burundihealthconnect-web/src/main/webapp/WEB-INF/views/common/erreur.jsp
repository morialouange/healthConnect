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
</head>
<body class="mc-page">
<div class="py-48 px-16">
    <div class="maxw-none text-center">
        <h1><fmt:message key="app.name"/></h1>
        <div class="card maxw-420 mx-auto">
            <h2><fmt:message key="error.title"/></h2>
            <div class="ecg-line" aria-hidden="true"></div>
            <p>
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
                <p>${pageContext.errorData.throwable.message}</p>
            </c:if>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/auth"><fmt:message key="error.back.home"/></a>
        </div>
    </div>
</div>
</body>
</html>