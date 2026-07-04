<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="medecin-dashboard"/>
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
                <div class="valeur">${stats.rdvDuJour}</div>
                <div class="libelle"><fmt:message key="stats.rdv_du_jour"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#9203;</div>
            <div class="stat-info">
                <div class="valeur">${stats.rdvEnAttente}</div>
                <div class="libelle"><fmt:message key="stats.rdv_en_attente_confirmation"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#9888;</div>
            <div class="stat-info">
                <div class="valeur" style="color:var(--rouge-danger);">${stats.rdvUrgentsCritiques}</div>
                <div class="libelle"><fmt:message key="medecin.dashboard.urgents_critiques"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128221;</div>
            <div class="stat-info">
                <div class="valeur">${stats.consultationsEnCours}</div>
                <div class="libelle"><fmt:message key="stats.consultations_en_cours"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128203;</div>
            <div class="stat-info">
                <div class="valeur">${stats.consultationsAVerser}</div>
                <div class="libelle"><fmt:message key="medecin.dashboard.cons_a_verser"/></div>
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

    <div class="charts-grid">
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="stats.consultations_7_jours"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartMedecinConsultations7j"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="stats.statut_rdv"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartMedecinRdvStatut"></canvas>
            </div>
        </div>
    </div>

    <div class="chart-card reveal-scale">
        <h3><fmt:message key="stats.par_priorite"/></h3>
        <div class="chart-wrapper">
            <canvas id="chartMedecinPriorites"></canvas>
        </div>
    </div>

    <div class="card reveal">
        <h2><fmt:message key="medecin.dashboard.patients_a_traiter"/></h2>
        <c:choose>
            <c:when test="${empty stats.patientsATraiter}">
                <p style="color:var(--text-muted);"><fmt:message key="medecin.no.rdv.attente"/></p>
            </c:when>
            <c:otherwise>
                <table class="table">
                    <thead>
                        <tr>
                            <th><fmt:message key="table.patient"/></th>
                            <th><fmt:message key="table.heure"/></th>
                            <th><fmt:message key="table.motif"/></th>
                            <th><fmt:message key="table.priorite"/></th>
                            <th><fmt:message key="table.actions"/></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${stats.patientsATraiter}">
                            <tr>
                                <td>${p.patientName}</td>
                                <td>${p.heureRdv}</td>
                                <td>${p.motif}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.priorite == 'CRITIQUE'}">
                                            <span class="badge badge-critique"><fmt:message key="priorite.critique"/></span>
                                        </c:when>
                                        <c:when test="${p.priorite == 'URGENT'}">
                                            <span class="badge badge-urgent"><fmt:message key="priorite.urgent"/></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-normal"><fmt:message key="priorite.normal"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a class="btn btn-small" href="${pageContext.request.contextPath}/medecin/dossier?idDossier=${p.idDossier}"><fmt:message key="btn.consulter"/></a>
                                    <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/medecin/consultations/creer?idRendezVous=${p.idRendezVous}"><fmt:message key="btn.create.consultation"/></a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="card reveal">
        <h2><fmt:message key="medecin.dashboard.timeline_jour"/></h2>
        <c:choose>
            <c:when test="${empty stats.timelineDuJour}">
                <p style="color:var(--text-muted);"><fmt:message key="medecin.no.rdv"/></p>
            </c:when>
            <c:otherwise>
                <div style="position:relative; padding-left:2rem;">
                    <div style="position:absolute; left:0.5rem; top:0; bottom:0; width:2px; background:var(--border);"></div>
                    <c:forEach var="t" items="${stats.timelineDuJour}">
                        <div style="position:relative; padding-bottom:1.2rem; padding-left:0.5rem;">
                            <div style="position:absolute; left:-1.7rem; top:0.3rem; width:12px; height:12px; border-radius:50%; background:var(--bleu-primaire); border:2px solid var(--bg-elevated);"></div>
                            <div style="display:flex; gap:1rem; align-items:center; flex-wrap:wrap;">
                                <span style="font-weight:600; min-width:4rem;">${t.heure}</span>
                                <span style="flex:1;">${t.patient}</span>
                                <span style="color:var(--text-muted); font-size:0.85rem;">${t.motif}</span>
                                <c:choose>
                                    <c:when test="${t.priorite == 'CRITIQUE'}">
                                        <span class="badge badge-critique"><fmt:message key="priorite.critique"/></span>
                                    </c:when>
                                    <c:when test="${t.priorite == 'URGENT'}">
                                        <span class="badge badge-urgent"><fmt:message key="priorite.urgent"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-normal"><fmt:message key="priorite.normal"/></span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="card reveal">
        <h2><fmt:message key="admin.dashboard.performance"/></h2>
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:2rem; margin-top:1rem;">
            <div>
                <div class="progress-label">
                    <span><fmt:message key="medecin.dashboard.taux_rdv_termines"/></span>
                    <span>${stats.tauxRdvTermines}%</span>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${stats.tauxRdvTermines}%;"></div></div>
            </div>
            <div>
                <div class="progress-label">
                    <span><fmt:message key="admin.dashboard.consultations_versees"/></span>
                    <span>${stats.consultationsVersees}%</span>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${stats.consultationsVersees}%; background:var(--bleu-primaire);"></div></div>
            </div>
        </div>
    </div>

    <div class="card reveal" style="display:grid; grid-template-columns:repeat(auto-fit, minmax(160px, 1fr)); gap:1rem;">
        <div><strong><fmt:message key="medecin.ordonnances_ce_mois"/>:</strong> ${stats.ordonnancesCeMois}</div>
        <div><strong><fmt:message key="medecin.referenements_envoyes"/>:</strong> ${stats.referenementsEnvoyes}</div>
        <div><strong><fmt:message key="medecin.prochain_conge"/>:</strong>
            <c:choose>
                <c:when test="${not empty stats.congesRecents and not empty stats.congesRecents[0]}">
                    ${stats.congesRecents[0].debut} - ${stats.congesRecents[0].fin} (${stats.congesRecents[0].statut})
                </c:when>
                <c:otherwise><fmt:message key="message.empty.no_data"/></c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="card hoverable reveal">
        <h2><fmt:message key="stats.actions.rapides"/></h2>
        <div style="display:flex; gap:0.8rem; flex-wrap:wrap; margin-top:1rem;">
            <a class="btn" href="${pageContext.request.contextPath}/medecin/rdv"><fmt:message key="medecin.dashboard.action.rdv"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/dossier"><fmt:message key="medecin.dashboard.action.dossier"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/consultations/creer"><fmt:message key="medecin.dashboard.action.consultation"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/ordonnances/rediger"><fmt:message key="medecin.dashboard.action.ordonnance"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/disponibilites"><fmt:message key="medecin.dashboard.action.disponibilite"/></a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/medecin/conge"><fmt:message key="medecin.dashboard.action.conge"/></a>
        </div>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
(function() {
    var consultationsLabels = [
        <c:forEach items="${stats.chartMedecinConsultations7j}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var consultationsData = [
        <c:forEach items="${stats.chartMedecinConsultations7j}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.line('chartMedecinConsultations7j', consultationsLabels, consultationsData, '#2563eb');

    var rdvStatutLabels = [
        <c:forEach items="${stats.chartMedecinRdvStatut}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var rdvStatutData = [
        <c:forEach items="${stats.chartMedecinRdvStatut}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.doughnut('chartMedecinRdvStatut', rdvStatutLabels, rdvStatutData, ['#0f766e','#2563eb','#d97706','#e11d48','#8b5cf6','#10b981']);

    var prioritesLabels = [
        <c:forEach items="${stats.chartMedecinPriorites}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var prioritesData = [
        <c:forEach items="${stats.chartMedecinPriorites}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartMedecinPriorites', prioritesLabels, prioritesData, '#10b981');
})();
</script>
</body>
</html>