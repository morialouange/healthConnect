<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="completer-profil"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.completer.profil.patient"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.completer.profil.patient"/> — <fmt:message key="app.name"/></title>
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
                <h1><fmt:message key="auth.welcome"/></h1>
                <div class="ecg-line" aria-hidden="true"></div>
                <p><fmt:message key="auth.complete.patient.subtitle"/></p>
            </div>
            <c:if test="${not empty erreur}">
                <div class="alerte alerte-erreur">${erreur}</div>
            </c:if>
            <form method="post" action="${pageContext.request.contextPath}/profil/completer">
                <div class="grid-auto-180">
                    <div class="form-group">
                        <label class="form-label" for="dateNaissance"><fmt:message key="label.date_naissance"/></label>
                        <input class="form-control" type="date" id="dateNaissance" name="dateNaissance" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="sexe"><fmt:message key="label.sexe"/></label>
                        <select class="form-control" id="sexe" name="sexe" required>
                            <option value=""><fmt:message key="btn.select"/></option>
<option value="M"><fmt:message key="sexe.masculin"/></option>
                            <option value="F"><fmt:message key="sexe.feminin"/></option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="telephone"><fmt:message key="label.telephone"/></label>
                    <input class="form-control" type="tel" id="telephone" name="telephone" placeholder="<fmt:message key='placeholder.telephone'/>" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="adresse"><fmt:message key="label.adresse"/></label>
                    <input class="form-control" type="text" id="adresse" name="adresse" placeholder="<fmt:message key='placeholder.adresse'/>">
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