<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="medecin-dossier"/>
<c:set var="pageTitre" value="Dossier patient"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.dossier.patient"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <c:if test="${empty dossier}">
        <div class="card">
            <p><fmt:message key="dossier.not.found"/></p>
            <a class="btn" href="${pageContext.request.contextPath}/medecin/dossier"><fmt:message key="dossier.new.search"/></a>
        </div>
    </c:if>

    <c:if test="${not empty dossier}">
        <div class="card hoverable">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap;">
                <h2><fmt:message key="dossier.medical"/> — ${dossier.patient.utilisateur.fullName}</h2>
                <div style="display:flex; gap:0.5rem;">
                    <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/medecin/dossier">← <fmt:message key="dossier.new.search"/></a>
                    <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/medecin/historique?idDossier=${dossier.idDossier}"><fmt:message key="btn.historique"/></a>
                </div>
            </div>
        </div>

        <div class="card">
            <h3><fmt:message key="dossier.general.info"/></h3>
            <div class="form-row">
                <div class="form-group">
                    <label><fmt:message key="label.numero_patient"/></label>
                    <input type="text" value="${dossier.patient.numeroPatient}" disabled>
                </div>
                <div class="form-group">
                    <label><fmt:message key="label.numero_dossier"/></label>
                    <input type="text" value="${dossier.numeroUnique}" disabled>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label><fmt:message key="label.date_naissance"/></label>
                    <input type="text" value="${dossier.patient.dateNaissance}" disabled>
                </div>
                <div class="form-group">
                    <label><fmt:message key="label.sexe"/></label>
                    <input type="text" value="${dossier.patient.sexe == 'M' ? 'Masculin' : 'F\u00e9minin'}" disabled>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label><fmt:message key="label.telephone"/></label>
                    <input type="text" value="<c:choose><c:when test="${not empty dossier.patient.telephone}">${dossier.patient.telephone}</c:when><c:otherwise>—</c:otherwise></c:choose>" disabled>
                </div>
                <div class="form-group">
                    <label><fmt:message key="label.groupe_sanguin"/></label>
                    <input type="text" value="<c:choose><c:when test="${not empty dossier.patient.groupeSanguin}">${dossier.patient.groupeSanguin}</c:when><c:otherwise>—</c:otherwise></c:choose>" disabled>
                </div>
            </div>
            <div class="form-group">
                <label><fmt:message key="label.allergies"/></label>
                <textarea rows="2" disabled style="width:100%; padding:0.6rem 0.7rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg-elevated); color:var(--text);"><c:choose><c:when test="${not empty dossier.patient.allergies}">${dossier.patient.allergies}</c:when><c:otherwise><fmt:message key="dossier.no.allergies"/></c:otherwise></c:choose></textarea>
            </div>
            <div class="form-group">
                <label><fmt:message key="dossier.antecedents"/></label>
                <textarea rows="3" disabled style="width:100%; padding:0.6rem 0.7rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg-elevated); color:var(--text);"><c:choose><c:when test="${not empty dossier.antecedents}">${dossier.antecedents}</c:when><c:otherwise><fmt:message key="dossier.no.antecedents"/></c:otherwise></c:choose></textarea>
            </div>
        </div>

        <div class="card">
            <h3><fmt:message key="consultation.new.title"/></h3>
            <form method="post" action="${pageContext.request.contextPath}/medecin/consultation/creer">
                <input type="hidden" name="idDossier" value="${dossier.idDossier}">
                <div class="form-group">
                    <label for="notes"><fmt:message key="label.notes"/></label>
                    <textarea id="notes" name="notes" rows="4" placeholder="<fmt:message key='placeholder.notes'/>"></textarea>
                </div>
                <div class="form-group">
                    <label for="diagnostic"><fmt:message key="label.diagnostic"/></label>
                    <textarea id="diagnostic" name="diagnostic" rows="3" placeholder="<fmt:message key='placeholder.diagnostic'/>"></textarea>
                </div>
                <button type="submit" class="btn"><fmt:message key="btn.create.consultation"/></button>
            </form>
        </div>

        <div class="card">
            <h3><fmt:message key="dossier.historique.consultations"/></h3>
            <p style="color:var(--text-muted); font-size:0.85rem;">
                <fmt:message key="dossier.historique.notice"/>
            </p>
            <c:if test="${empty historique}">
                <p style="color:var(--text-muted);"><fmt:message key="dossier.no.consultations.versed"/></p>
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
                        <th><fmt:message key="table.statut"/></th>
                        <th><fmt:message key="table.actions"/></th>
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
                                    </c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </td>
                            <td><span class="badge badge-confirme">${c.statut}</span></td>
                            <td>
                                <a class="btn btn-small btn-secondary"
                                   href="${pageContext.request.contextPath}/medecin/ordonnance?idConsultation=${c.idConsultation}">
                                    <fmt:message key="btn.ordonnance"/></a>
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