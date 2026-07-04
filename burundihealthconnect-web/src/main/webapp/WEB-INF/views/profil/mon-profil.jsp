<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="profil"/>
<c:set var="pageTitre" value="Mon profil"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.profil"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card hoverable">
        <h2><fmt:message key="profil.title"/></h2>

        <form method="post" action="${pageContext.request.contextPath}/profil/mon-profil">
            <div class="form-row">
                <div class="form-group">
                    <label for="fullName"><fmt:message key="label.fullname"/></label>
                    <input type="text" id="fullName" name="fullName" value="${profil.utilisateur.fullName}">
                </div>
                <div class="form-group">
                    <label><fmt:message key="label.role"/></label>
                    <input type="text" value="${profil.utilisateur.role}" disabled>
                </div>
            </div>

            <!-- ===== Champs sp\u00e9cifiques PATIENT ===== -->
            <c:if test="${sessionScope.role == 'PATIENT'}">
                <div class="form-group">
                    <label><fmt:message key="label.numero_patient"/></label>
                    <input type="text" value="${profil.patient.numeroPatient}" disabled>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="telephone"><fmt:message key="label.telephone"/></label>
                        <input type="tel" id="telephone" name="telephone" value="${profil.patient.telephone}">
                    </div>
                    <div class="form-group">
                        <label for="groupeSanguin"><fmt:message key="label.groupe_sanguin"/></label>
                        <select id="groupeSanguin" name="groupeSanguin">
                            <option value="">--</option>
                            <c:forEach var="g" items="${['A+','A-','B+','B-','AB+','AB-','O+','O-']}">
                                <option value="${g}" ${g == profil.patient.groupeSanguin ? 'selected' : ''}>${g}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label for="allergies"><fmt:message key="label.allergies"/></label>
                    <textarea id="allergies" name="allergies" rows="3">${profil.patient.allergies}</textarea>
                </div>
                <div class="form-group">
                    <label for="adresse"><fmt:message key="label.adresse"/></label>
                    <input type="text" id="adresse" name="adresse" value="${profil.patient.adresse}">
                </div>
            </c:if>

            <!-- ===== Champs sp\u00e9cifiques MEDECIN ===== -->
            <c:if test="${sessionScope.role == 'MEDECIN'}">
                <div class="form-row">
                    <div class="form-group">
                        <label for="specialite"><fmt:message key="label.specialite"/></label>
                        <input type="text" id="specialite" name="specialite" value="${profil.medecin.specialite}">
                    </div>
                    <div class="form-group">
                        <label for="experience"><fmt:message key="label.experience.years"/></label>
                        <input type="number" id="experience" name="experience" min="0"
                               value="${profil.medecin.experience}">
                    </div>
                </div>
                <div class="form-group">
                    <label><fmt:message key="label.numero_ordre.admin"/></label>
                    <input type="text" value="${profil.medecin.numeroOrdre}" disabled>
                </div>
            </c:if>

            <!-- ===== Champs sp\u00e9cifiques ADMIN / SUPER_ADMIN ===== -->
            <c:if test="${sessionScope.role == 'ADMIN' or sessionScope.role == 'SUPER_ADMIN'}">
                <div class="form-group">
                    <label for="email"><fmt:message key="label.email"/></label>
                    <input type="email" id="email" name="email" value="${profil.utilisateur.email}">
                </div>
            </c:if>

            <button type="submit" class="btn"><fmt:message key="btn.save.modifications"/></button>
        </form>
    </div>

    <!-- ===== Changement de mot de passe ===== -->
    <div class="card hoverable">
        <h3><fmt:message key="profil.change.password.title"/></h3>
        <form method="post" action="${pageContext.request.contextPath}/profil/changer-mot-de-passe">
            <div class="form-row">
                <div class="form-group">
                    <label for="ancienMotDePasse"><fmt:message key="label.current.password"/></label>
                    <input type="password" id="ancienMotDePasse" name="ancienMotDePasse" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="nouveauMotDePasse"><fmt:message key="label.new.password"/></label>
                    <input type="password" id="nouveauMotDePasse" name="nouveauMotDePasse" minlength="8" required>
                </div>
                <div class="form-group">
                    <label for="confirmationMotDePasse"><fmt:message key="label.confirm.password"/></label>
                    <input type="password" id="confirmationMotDePasse" name="confirmationMotDePasse"
                           minlength="8" required>
                </div>
            </div>
            <button type="submit" class="btn btn-secondary"><fmt:message key="btn.change.password"/></button>
        </form>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>