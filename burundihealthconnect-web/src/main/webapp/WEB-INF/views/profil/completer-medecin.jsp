<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="completer-profil"/>
<c:set var="pageTitre" value="Compl\u00e9ter mon profil"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.completer.profil.medecin"/> — <fmt:message key="app.name"/></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
</head>
<body class="auth-body">

<button class="theme-toggle auth-theme-toggle" onclick="toggleTheme()" title="<fmt:message key='btn.theme.toggle'/>">
    <span class="theme-icon">&#9790;</span>
</button>

<div class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <div class="auth-logo">
                <svg class="auth-logo-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
                </svg>
            </div>
            <h1><fmt:message key="auth.welcome.medecin"/></h1>
            <p class="auth-subtitle"><fmt:message key="auth.complete.medecin.subtitle"/></p>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/auth/completer-medecin">
            <div class="form-group">
                <label><fmt:message key="label.numero_ordre"/></label>
                <p style="color:var(--text-muted); font-size:0.85rem; margin-top:4px;">
                    <fmt:message key="medecin.numero_ordre.auto"/>
                </p>
            </div>

            <div class="form-group">
                <label for="specialite"><fmt:message key="label.specialite"/></label>
                <input type="text" id="specialite" name="specialite" required
                       placeholder="<fmt:message key='placeholder.specialite'/>">
            </div>

            <div class="form-group">
                <label for="idService"><fmt:message key="label.service"/></label>
                <select id="idService" name="idService" required>
                    <option value=""><fmt:message key="btn.select"/></option>
                    <c:forEach var="s" items="${services}">
                        <option value="${s.idService}">${s.nom}</option>
                    </c:forEach>
                </select>
            </div>

            <button type="submit" class="btn auth-btn"><fmt:message key="btn.complete.profil"/></button>
        </form>

        <div class="auth-links">
            <a href="${pageContext.request.contextPath}/logout"><fmt:message key="btn.logout"/></a>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/theme.js"></script>
</body>
</html>