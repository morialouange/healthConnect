<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="completer-profil"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.completer.profil.medecin"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.completer.profil.medecin"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<div class="py-48 px-16">
    <div class="auth-corner">
        <button type="button" class="icon-btn" id="lang-toggle" title="<fmt:message key='btn.lang'/>" aria-label="<fmt:message key='btn.lang'/>"><i data-lucide="globe"></i><span class="lang-label"></span></button>
        <button type="button" class="icon-btn theme-toggle" data-theme-toggle title="<fmt:message key='btn.theme.toggle'/>" aria-label="<fmt:message key='btn.theme.toggle'/>"><span class="theme-icon">&#9790;</span></button>
    </div>
    <div class="auth-wrapper relative text-center">
        <div class="card text-left mt-32">
            <div class="text-center mb-12">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="icon-40 text-brand">
                    <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
                </svg>
                <h1><fmt:message key="auth.welcome.medecin"/></h1>
                <div class="ecg-line" aria-hidden="true"></div>
                <p><fmt:message key="auth.complete.medecin.subtitle"/></p>
            </div>
            <c:if test="${not empty erreur}">
                <div class="alerte alerte-erreur">${erreur}</div>
            </c:if>
            <form method="post" action="${pageContext.request.contextPath}/profil/completer">
                <div class="form-group">
                    <label class="form-label"><fmt:message key="label.numero_ordre"/></label>
                    <p><fmt:message key="medecin.numero_ordre.auto"/></p>
                </div>
                <div class="form-group">
                    <label class="form-label" for="specialite"><fmt:message key="label.specialite"/></label>
                    <input class="form-control" type="text" id="specialite" name="specialite" required placeholder="<fmt:message key='placeholder.specialite'/>">
                </div>
                <div class="form-group">
                    <label class="form-label" for="idService"><fmt:message key="label.service"/></label>
                    <select class="form-control" id="idService" name="idService" required>
                        <option value=""><fmt:message key="btn.select"/></option>
                        <c:forEach var="s" items="${services}">
                            <option value="${s.idService}">${s.nom}</option>
                        </c:forEach>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary w-100"><fmt:message key="btn.complete.profil"/></button>
            </form>
            <div class="mt-16">
                <a href="${pageContext.request.contextPath}/logout"><fmt:message key="btn.logout"/></a>
            </div>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=8"></script>
<script>if(window.lucide) lucide.createIcons();</script>
</body>
</html>