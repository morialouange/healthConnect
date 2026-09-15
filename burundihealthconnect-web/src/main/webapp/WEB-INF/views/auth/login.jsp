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
</head>
<body class="mc-page">
<div class="py-48 px-16">
    <div class="auth-corner">
        <button type="button" class="icon-btn" id="lang-toggle" title="<fmt:message key='btn.lang'/>" aria-label="<fmt:message key='btn.lang'/>"><i data-lucide="globe"></i><span class="lang-label"></span></button>
        <button type="button" class="icon-btn theme-toggle" data-theme-toggle title="<fmt:message key='btn.theme'/>" aria-label="<fmt:message key='btn.theme'/>"><span class="theme-icon">&#9788;</span></button>
    </div>
    <div class="auth-wrapper relative text-center">
        <div class="card text-left mt-32">
            <div class="fw-700 fs-16 mb-4">&#10010; <fmt:message key="app.name"/></div>
            <h2><fmt:message key="auth.login.title"/></h2>
            <div class="ecg-line" aria-hidden="true"></div>
            <c:if test="${not empty erreur}">
                <div class="alerte alerte-erreur">${erreur}</div>
            </c:if>
            <c:if test="${not empty succes}">
                <div class="alerte alerte-succes">${succes}</div>
            </c:if>
            <form method="post" action="${pageContext.request.contextPath}/auth">
                <div class="form-group">
                    <label class="form-label" for="email"><fmt:message key="label.email"/></label>
                    <input class="form-control" type="email" id="email" name="email" required autocomplete="email" placeholder="<fmt:message key='placeholder.email'/>">
                </div>
                <div class="form-group">
                    <label class="form-label" for="motDePasse"><fmt:message key="label.password"/></label>
                    <div class="flex gap-8">
                        <input class="form-control" type="password" id="motDePasse" name="motDePasse" required autocomplete="current-password" placeholder="<fmt:message key='placeholder.password.min'/>">
                        <button type="button" class="password-toggle icon-btn" data-toggle="motDePasse" tabindex="-1" aria-label="<fmt:message key='auth.toggle.password'/>">
                            <span>&#128065;</span>
                        </button>
                    </div>
                    <a href="#" class="fs-13 login-forgot" onclick="alert('<fmt:message key="auth.forgot.alert"/>'); return false;"><fmt:message key="auth.login.forgot"/></a>
                </div>
                <button type="submit" class="btn btn-primary w-100 auth-submit">
                    <span class="btn-text"><fmt:message key="auth.login.submit"/></span>
                </button>
            </form>
            <p class="mt-16">
                <fmt:message key="auth.register.prompt"/>
                <a href="${pageContext.request.contextPath}/auth?action=register"><fmt:message key="auth.register.link"/></a>
            </p>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=8"></script>
<script>if(window.lucide) lucide.createIcons();</script>
</body>
</html>