<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="medecin-consultations"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="page.referer.patient"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><fmt:message key="page.referer.patient"/> — <fmt:message key="app.name"/></title>
<jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
<h2><fmt:message key="referenement.creer.title"/></h2>
<c:if test="${empty hopitaux}">
<p><fmt:message key="referenement.no.hopitaux"/></p>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/consultations"><fmt:message key="btn.back.consultations"/></a>
</c:if>
<c:if test="${not empty hopitaux}">
<form method="post" action="${pageContext.request.contextPath}/medecin/referenement/creer">
<input type="hidden" name="idConsultation" value="${consultation.idConsultation}">
<div class="form-group">
<label class="form-label"><fmt:message key="label.patient"/></label>
<input class="form-control" type="text" value="${consultation.dossier.patient.utilisateur.fullName} (${consultation.dossier.patient.numeroPatient})" disabled>
</div>
<div class="form-group">
<label class="form-label" for="idEtablissementDest"><fmt:message key="label.hopital.destination"/></label>
<select class="form-control" id="idEtablissementDest" name="idEtablissementDest" required>
<option value="">-- <fmt:message key="btn.select"/> --</option>
<c:forEach var="h" items="${hopitaux}">
<option value="${h.idEtablissement}">${h.nom}</option>
</c:forEach>
</select>
</div>
 <div class="form-group">
 <label class="form-label" for="idMedecinDest"><fmt:message key="label.medecin.destinataire.optionnel"/></label>
 <select class="form-control" id="idMedecinDest" name="idMedecinDest">
 <option value="">-- <fmt:message key="btn.not.specified"/> --</option>
 <c:forEach var="entry" items="${medecinsParEtablissement}">
   <c:forEach var="m" items="${entry.value}">
     <option value="${m.idMedecin}" data-etab="${entry.key}">${m.utilisateur.fullName}</option>
   </c:forEach>
 </c:forEach>
 </select>
 </div>
 <div class="form-group">
 <label class="form-label" for="motif"><fmt:message key="label.motif.referenement"/></label>
 <textarea class="form-control" id="motif" name="motif" rows="4" required
  placeholder="<fmt:message key='placeholder.motif.ref'/>"></textarea>
 </div>
 <button type="submit" class="btn btn-primary"><fmt:message key="btn.send.referenement"/></button>
 <a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/consultations"><fmt:message key="btn.cancel"/></a>
 </form>
 </c:if>
 </div>
 <script>
  (function() {
  var selectEtab = document.getElementById('idEtablissementDest');
  var selectMed = document.getElementById('idMedecinDest');
  if (!selectEtab || !selectMed) return;
  var allOptions = Array.prototype.slice.call(selectMed.options, 1);
  var placeholder = selectMed.options[0];
  selectEtab.addEventListener('change', function() {
    var idEtab = this.value;
    selectMed.innerHTML = '';
    selectMed.appendChild(placeholder);
    allOptions.forEach(function(opt) {
      if (!idEtab || opt.getAttribute('data-etab') === idEtab) {
        selectMed.appendChild(opt.cloneNode(true));
      }
    });
  });
  })();
  </script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>