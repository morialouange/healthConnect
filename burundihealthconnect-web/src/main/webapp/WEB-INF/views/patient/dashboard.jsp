<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="patient-dashboard"/>
<c:set var="pageTitre" value="Tableau de bord"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.dashboard"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="grid-stats">
        <div class="stat-box reveal">
            <div class="stat-icon">&#128197;</div>
            <div class="stat-info">
                <div class="valeur">
                    <c:choose>
                        <c:when test="${not empty stats.prochainRdv}">${stats.prochainRdv}</c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
                <div class="libelle"><fmt:message key="patient.dashboard.prochain_rdv"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#9203;</div>
            <div class="stat-info">
                <div class="valeur">${stats.rdvEnAttenteConfirmation}</div>
                <div class="libelle"><fmt:message key="patient.dashboard.rdv_attente"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128138;</div>
            <div class="stat-info">
                <div class="valeur" style="font-size:1.1rem;">
                    <c:choose>
                        <c:when test="${not empty stats.derniereConsultationDetail}">${stats.derniereConsultationDetail}</c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
                <div class="libelle"><fmt:message key="patient.dashboard.derniere_consult"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128220;</div>
            <div class="stat-info">
                <div class="valeur">${stats.ordonnancesDisponibles}</div>
                <div class="libelle"><fmt:message key="patient.dashboard.ordonnances"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128276;</div>
            <div class="stat-info">
                <div class="valeur">${stats.notificationsNonLues}</div>
                <div class="libelle"><fmt:message key="patient.dashboard.notifications"/></div>
            </div>
        </div>
    </div>

    <c:if test="${not empty stats.prochainRdvDetail}">
    <div class="card reveal">
        <h2><fmt:message key="patient.dashboard.mon_prochain_passage"/></h2>
        <c:set var="rdv" value="${stats.prochainRdvDetail}" />
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:1rem; margin-top:1rem;">
            <div><strong><fmt:message key="table.date"/>:</strong> ${rdv.date}</div>
            <div><strong><fmt:message key="table.heure"/>:</strong> ${rdv.heure}</div>
            <div><strong><fmt:message key="table.medecin"/>:</strong> ${rdv.medecin}</div>
            <div><strong><fmt:message key="table.etablissement"/>:</strong> ${rdv.hopital}</div>
            <div><strong><fmt:message key="table.service"/>:</strong> ${rdv.service}</div>
            <div><strong><fmt:message key="table.statut"/>:</strong>
                <c:choose>
                    <c:when test="${rdv.statut == 'RDV_CONFIRME'}">
                        <span class="badge badge-confirme"><fmt:message key="status.confirme"/></span>
                    </c:when>
                    <c:when test="${rdv.statut == 'RDV_DEMANDE'}">
                        <span class="badge badge-demande"><fmt:message key="status.rdv_demande"/></span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge badge-normal">${rdv.statut}</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div style="display:flex; gap:0.8rem; margin-top:1rem;">
            <a class="btn" href="${pageContext.request.contextPath}/patient/rdv/hopitaux"><fmt:message key="patient.dashboard.voir_details"/></a>
            <c:if test="${rdv.statut == 'RDV_DEMANDE' or rdv.statut == 'RDV_CONFIRME'}">
                <a class="btn btn-danger" href="${pageContext.request.contextPath}/patient/rdv/annuler?idRendezVous=${rdv.idRendezVous}" onclick="return confirm('<fmt:message key="confirm.logout"/>')"><fmt:message key="patient.dashboard.annuler"/></a>
            </c:if>
        </div>
    </div>
    </c:if>

    <div class="charts-grid">
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="patient.dashboard.rdv_par_mois"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartPatientMois"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="patient.dashboard.rdv_par_statut"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartPatientStatuts"></canvas>
            </div>
        </div>
    </div>

    <div class="card reveal">
        <h2><fmt:message key="patient.dashboard.dossier_medical"/></h2>
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:1rem; margin-top:1rem;">
            <div><strong><fmt:message key="patient.dashboard.numero_patient"/>:</strong> ${stats.numeroPatient}</div>
            <div><strong><fmt:message key="patient.dashboard.numero_dossier"/>:</strong> ${stats.numeroDossier}</div>
            <div><strong><fmt:message key="patient.dashboard.groupe_sanguin"/>:</strong> ${stats.groupeSanguin}</div>
            <div><strong><fmt:message key="patient.dashboard.allergies"/>:</strong> ${stats.allergies}</div>
            <div><strong><fmt:message key="patient.dashboard.derniere_maj"/>:</strong> ${stats.derniereMaj}</div>
        </div>
        <a class="btn" href="${pageContext.request.contextPath}/patient/dossier" style="margin-top:1rem;"><fmt:message key="patient.dashboard.voir_dossier"/></a>
    </div>

    <div class="card reveal">
        <h2><fmt:message key="patient.dashboard.timeline_medicale"/></h2>
        <c:choose>
            <c:when test="${empty stats.timelineMedicale}">
                <p style="color:var(--text-muted);"><fmt:message key="dossier.no.consultations"/></p>
            </c:when>
            <c:otherwise>
                <div style="position:relative; padding-left:2rem;">
                    <div style="position:absolute; left:0.5rem; top:0; bottom:0; width:2px; background:var(--border);"></div>
                    <c:forEach var="t" items="${stats.timelineMedicale}">
                        <div style="position:relative; padding-bottom:1.2rem; padding-left:0.5rem;">
                            <div style="position:absolute; left:-1.7rem; top:0.3rem; width:12px; height:12px; border-radius:50%; background:var(--vert-succes); border:2px solid var(--bg-elevated);"></div>
                            <div><strong>${t.date}</strong> — ${t.medecin}</div>
                            <div style="color:var(--text-muted); font-size:0.85rem;">${t.motif}</div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="card hoverable reveal">
        <h2><fmt:message key="stats.actions.rapides"/></h2>
        <div style="display:flex; gap:0.8rem; flex-wrap:wrap; margin-top:1rem;">
            <a class="btn" href="${pageContext.request.contextPath}/patient/rdv/hopitaux"><fmt:message key="patient.dashboard.action.rdv"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/patient/dossier"><fmt:message key="patient.dashboard.action.dossier"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/patient/notifications"><fmt:message key="patient.dashboard.action.notifications"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/profil/mon-profil"><fmt:message key="patient.dashboard.action.profil"/></a>
        </div>
    </div>

    <div class="card reveal">
        <h2><fmt:message key="admin.dashboard.performance"/></h2>
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:2rem; margin-top:1rem;">
            <div>
                <div class="progress-label">
                    <span><fmt:message key="patient.dashboard.taux_presence"/></span>
                    <span>${stats.tauxPresence}%</span>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${stats.tauxPresence}%; background:var(--vert-succes);"></div></div>
            </div>
            <div>
                <div class="progress-label">
                    <span><fmt:message key="patient.dashboard.profil_complete"/></span>
                    <span>${stats.profilComplete}%</span>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${stats.profilComplete}%; background:var(--bleu-primaire);"></div></div>
            </div>
        </div>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
(function() {
    var moisLabels = [
        <c:forEach items="${stats.chartPatientMois}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var moisData = [
        <c:forEach items="${stats.chartPatientMois}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.line('chartPatientMois', moisLabels, moisData, '#0f766e');

    var statutsLabels = [
        <c:forEach items="${stats.chartPatientStatuts}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var statutsData = [
        <c:forEach items="${stats.chartPatientStatuts}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.doughnut('chartPatientStatuts', statutsLabels, statutsData, ['#0f766e','#2563eb','#d97706','#e11d48','#8b5cf6','#10b981']);
})();
</script>
</body>
</html>