<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="auth.login.title"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
</head>
<body>

<div class="auth-page">
    <!-- Éléments décoratifs flottants -->
    <div class="auth-float auth-float-1"></div>
    <div class="auth-float auth-float-2"></div>
    <div class="auth-float auth-float-3"></div>

    <!-- Dark mode toggle en haut à droite (fixe) -->
    <button type="button" class="theme-toggle" data-theme-toggle title="<fmt:message key='btn.theme'/>">
        <span class="theme-icon">&#9788;</span>
    </button>

    <div class="auth-right">
        <div class="auth-card">
            <div class="auth-logo">&#10010; <fmt:message key="app.name"/></div>
            <h2><fmt:message key="auth.login.title"/></h2>

            <c:if test="${not empty erreur}">
                <div class="alerte alerte-erreur">${erreur}</div>
            </c:if>
            <c:if test="${not empty succes}">
                <div class="alerte alerte-succes">${succes}</div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/auth" class="auth-form">
                <div class="form-group">
                    <label for="email"><fmt:message key="label.email"/></label>
                    <input type="email" id="email" name="email" required autocomplete="email">
                </div>
                <div class="form-group">
                    <label for="motDePasse"><fmt:message key="label.password"/></label>
                    <div class="password-wrapper">
                        <input type="password" id="motDePasse" name="motDePasse" required autocomplete="current-password">
                        <button type="button" class="password-toggle" data-toggle="motDePasse" tabindex="-1" aria-label="<fmt:message key='auth.toggle.password'/>">
                            <span class="eye-icon">&#128065;</span>
                        </button>
                    </div>
                    <a href="#" class="forgot-link" onclick="alert('<fmt:message key="auth.forgot.alert"/>'); return false;"><fmt:message key="auth.login.forgot"/></a>
                </div>
                <button type="submit" class="btn"><fmt:message key="auth.login.submit"/></button>
            </form>

            <p class="lien-secondaire">
                <fmt:message key="auth.register.prompt"/>
                <a href="${pageContext.request.contextPath}/auth?action=register"><fmt:message key="auth.register.link"/></a>
            </p>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
