<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="patient-dossier"/>
<c:set var="pageTitre" value="Mon dossier médical"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.dossier"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <c:if test="${empty dossier}">
        <div class="card">
            <p><fmt:message key="dossier.not.loaded"/></p>
        </div>
    </c:if>

    <c:if test="${not empty dossier}">
        <div class="card hoverable">
            <h2><fmt:message key="dossier.general.info"/></h2>
            <p><strong><fmt:message key="dossier.numero"/> :</strong> ${dossier.numeroUnique}</p>
            <p><strong><fmt:message key="dossier.date_creation"/> :</strong> ${dossier.dateCreation}</p>
            <p><strong><fmt:message key="dossier.derniere_maj"/> :</strong>
                <c:choose>
                    <c:when test="${not empty dossier.dateMiseAJour}">${dossier.dateMiseAJour}</c:when>
                    <c:otherwise>—</c:otherwise>
                </c:choose>
            </p>
            <p><strong><fmt:message key="dossier.antecedents"/> :</strong>
                <c:choose>
                    <c:when test="${not empty dossier.antecedents}">${dossier.antecedents}</c:when>
                    <c:otherwise><fmt:message key="dossier.no.antecedents"/></c:otherwise>
                </c:choose>
            </p>
            <p style="color:var(--text-muted); font-size:0.85rem;">
                <fmt:message key="dossier.readonly.notice"/>
            </p>
        </div>

        <div class="card">
            <h2><fmt:message key="dossier.historique.consultations"/></h2>
            <p style="color:var(--text-muted); font-size:0.85rem;">
                <fmt:message key="dossier.historique.notice"/>
            </p>

            <c:if test="${empty historique}">
                <p><fmt:message key="dossier.no.consultations"/></p>
            </c:if>

            <c:if test="${not empty historique}">
                <table class="table">
                    <thead>
                    <tr>
                        <th><fmt:message key="table.date"/></th>
                        <th><fmt:message key="table.etablissement"/></th>
                        <th><fmt:message key="table.medecin"/></th>
                        <th><fmt:message key="table.diagnostic"/></th>
                        <th><fmt:message key="table.notes"/></th>
                        <th><fmt:message key="table.prescriptions"/></th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="c" items="${historique}">
                        <tr>
                            <td>${c.dateConsultation}</td>
                            <td>${c.etablissement.nom}</td>
                            <td>${c.medecin.utilisateur.fullName}</td>
                            <td>${not empty c.diagnostic ? c.diagnostic : '—'}</td>
                            <td>${not empty c.notes ? c.notes : '—'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty c.ordonance and not empty c.ordonance.lignes}">
                                        <ul style="margin:0; padding-left:1rem;">
                                            <c:forEach var="l" items="${c.ordonance.lignes}">
                                                <li><strong>${l.medicament}</strong>
                                                    <c:if test="${not empty l.dosage}"> — ${l.dosage}</c:if>
                                                    <c:if test="${not empty l.frequence}">, ${l.frequence}</c:if>
                                                    <c:if test="${l.dureeJours > 0}"> (${l.dureeJours}j)</c:if>
                                                </li>
                                            </c:forEach>
                                        </ul>
                                        <c:if test="${not empty c.ordonance.instructions}">
                                            <p style="margin:0.3rem 0 0; font-size:0.85rem; color:var(--text-muted);">
                                                ${c.ordonance.instructions}</p>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>
    </c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>