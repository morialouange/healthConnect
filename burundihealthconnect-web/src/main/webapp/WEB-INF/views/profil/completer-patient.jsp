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
    <title><fmt:message key="page.completer.profil.patient"/> — <fmt:message key="app.name"/></title>
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
            <h1><fmt:message key="auth.welcome"/></h1>
            <p class="auth-subtitle"><fmt:message key="auth.complete.patient.subtitle"/></p>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/auth/completer-patient">
            <div class="form-group">
                <label for="dateNaissance"><fmt:message key="label.date_naissance"/></label>
                <input type="date" id="dateNaissance" name="dateNaissance" required>
            </div>

            <div class="form-group">
                <label for="sexe"><fmt:message key="label.sexe"/></label>
                <select id="sexe" name="sexe" required>
                    <option value=""><fmt:message key="btn.select"/></option>
                    <option value="MASCULIN"><fmt:message key="sexe.masculin"/></option>
                    <option value="FEMININ"><fmt:message key="sexe.feminin"/></option>
                </select>
            </div>

            <div class="form-group">
                <label for="telephone"><fmt:message key="label.telephone"/></label>
                <input type="tel" id="telephone" name="telephone"
                       placeholder="<fmt:message key='placeholder.telephone'/>" required>
            </div>

            <div class="form-group">
                <label for="groupeSanguin"><fmt:message key="label.groupe_sanguin"/></label>
                <select id="groupeSanguin" name="groupeSanguin">
                    <option value=""><fmt:message key="btn.select"/></option>
                    <option value="A+">A+</option>
                    <option value="A-">A-</option>
                    <option value="B+">B+</option>
                    <option value="B-">B-</option>
                    <option value="AB+">AB+</option>
                    <option value="AB-">AB-</option>
                    <option value="O+">O+</option>
                    <option value="O-">O-</option>
                </select>
            </div>

            <div class="form-group">
                <label for="allergies"><fmt:message key="label.allergies"/></label>
                <textarea id="allergies" name="allergies" rows="3"
                          placeholder="<fmt:message key='placeholder.allergies'/>"></textarea>
            </div>

            <div class="form-group">
                <label for="adresse"><fmt:message key="label.adresse"/></label>
                <input type="text" id="adresse" name="adresse"
                       placeholder="<fmt:message key='placeholder.adresse'/>">
            </div>

            <div class="form-group">
                <label for="numeroUrgence"><fmt:message key="label.numero_urgence"/></label>
                <input type="tel" id="numeroUrgence" name="numeroUrgence"
                       placeholder="<fmt:message key='placeholder.numero_urgence'/>">
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