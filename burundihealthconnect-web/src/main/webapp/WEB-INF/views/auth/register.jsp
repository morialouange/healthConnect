<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="auth.register.title"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<div class="auth-page">
    <div class="auth-wrapper wide">
        <button type="button" class="icon-btn" data-theme-toggle
                style="position:absolute; top:1rem; right:1rem;" title="<fmt:message key='btn.theme'/>">&#9788;</button>

        <h1><fmt:message key="app.name"/></h1>
        <div class="card">
            <h2><fmt:message key="auth.register.title"/></h2>

            <c:if test="${not empty erreur}">
                <div class="alerte alerte-erreur">${erreur}</div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/auth">
                <input type="hidden" name="action" value="register">

                <div class="form-group">
                    <label for="fullName"><fmt:message key="label.fullname"/></label>
                    <input type="text" id="fullName" name="fullName" required
                           placeholder="<fmt:message key='placeholder.fullname'/>">
                </div>

                <div class="form-group">
                    <label for="email"><fmt:message key="label.email"/></label>
                    <input type="email" id="email" name="email" required
                           placeholder="<fmt:message key='placeholder.email'/>">
                </div>

                <div class="form-group">
                    <label for="motDePasse"><fmt:message key="label.password"/></label>
                    <div class="password-wrapper">
                        <input type="password" id="motDePasse" name="motDePasse" required
                               placeholder="<fmt:message key='placeholder.password.min'/>" minlength="8">
                        <button type="button" class="password-toggle" data-toggle="motDePasse" tabindex="-1" aria-label="<fmt:message key='auth.toggle.password'/>">
                            <span class="eye-icon">&#128065;</span>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmationMotDePasse"><fmt:message key="label.confirm.password"/></label>
                    <div class="password-wrapper">
                        <input type="password" id="confirmationMotDePasse" name="confirmationMotDePasse" required
                               placeholder="<fmt:message key='placeholder.confirm.password'/>" minlength="8">
                        <button type="button" class="password-toggle" data-toggle="confirmationMotDePasse" tabindex="-1" aria-label="<fmt:message key='auth.toggle.password'/>">
                            <span class="eye-icon">&#128065;</span>
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn" style="width:100%;"><fmt:message key="auth.register.submit"/></button>
            </form>

            <p class="lien-secondaire">
                <fmt:message key="auth.login.prompt"/>
                <a href="${pageContext.request.contextPath}/auth"><fmt:message key="auth.login.link"/></a>
            </p>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
