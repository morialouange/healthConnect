<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="medecin-consultations"/>
<c:set var="pageTitre" value="Référencer un patient"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.referer.patient"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="referenement.creer.title"/></h2>

        <c:if test="${empty hopitaux}">
            <p><fmt:message key="referenement.no.hopitaux"/></p>
            <a class="btn" href="${pageContext.request.contextPath}/medecin/consultations"><fmt:message key="btn.back.consultations"/></a>
        </c:if>

        <c:if test="${not empty hopitaux}">
            <form method="post" action="${pageContext.request.contextPath}/medecin/referenement/creer">
                <input type="hidden" name="idConsultation" value="${consultation.idConsultation}">

                <div class="form-group">
                    <label><fmt:message key="label.patient"/></label>
                    <input type="text" value="${consultation.dossier.patient.utilisateur.fullName}" disabled>
                </div>

                <div class="form-group">
                    <label for="idEtablissementDest"><fmt:message key="label.hopital.destination"/></label>
                    <select id="idEtablissementDest" name="idEtablissementDest" required>
                        <option value="">-- <fmt:message key="btn.select"/> --</option>
                        <c:forEach var="h" items="${hopitaux}">
                            <option value="${h.idEtablissement}">${h.nom}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="idMedecinDest"><fmt:message key="label.medecin.destinataire.optionnel"/></label>
                    <select id="idMedecinDest" name="idMedecinDest">
                        <option value="">-- <fmt:message key="btn.not.specified"/> --</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="motif"><fmt:message key="label.motif.referenement"/></label>
                    <textarea id="motif" name="motif" rows="4" required
                              placeholder="<fmt:message key='placeholder.motif.ref'/>"></textarea>
                </div>

                <button type="submit" class="btn"><fmt:message key="btn.send.referenement"/></button>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/consultations"><fmt:message key="btn.cancel"/></a>
            </form>
        </c:if>
    </div>

    <script>
    document.getElementById('idEtablissementDest').addEventListener('change', function() {
        var selectMed = document.getElementById('idMedecinDest');
        selectMed.innerHTML = '<option value="">-- <fmt:message key="btn.not.specified"/> --</option>';
        var idEtab = this.value;
        if (!idEtab) return;
        fetch('${pageContext.request.contextPath}/medecin/dossier?ajax=medecins&idEtablissement=' + idEtab)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                data.forEach(function(m) {
                    var opt = document.createElement('option');
                    opt.value = m.id;
                    opt.textContent = m.nom;
                    selectMed.appendChild(opt);
                });
            })
            .catch(function() {});
    });
    </script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>