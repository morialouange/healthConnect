<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="superadmin-audit"/>
<c:set var="pageTitre" value="Journal &amp; Audit"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="audit.title"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="audit.title"/></h2>
        <p style="color:var(--text-muted); font-size:0.85rem;">
            <fmt:message key="journal.acces.desc"/>
        </p>
    </div>

    <div class="grid-stats">
        <div class="stat-box reveal">
            <div class="stat-icon">&#128197;</div>
            <div class="stat-info">
                <div class="valeur">${statsLog.actionsAujourdhui}</div>
                <div class="libelle"><fmt:message key="audit.stats.aujourdhui"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#9888;</div>
            <div class="stat-info">
                <div class="valeur">${statsLog.actionsCritiques}</div>
                <div class="libelle"><fmt:message key="audit.stats.critiques"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128274;</div>
            <div class="stat-info">
                <div class="valeur">${statsLog.connexionsEchouees}</div>
                <div class="libelle"><fmt:message key="audit.stats.connexions_echouees"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128221;</div>
            <div class="stat-info">
                <div class="valeur">${statsLog.modificationsDossier}</div>
                <div class="libelle"><fmt:message key="audit.stats.modifications_dossier"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128100;</div>
            <div class="stat-info">
                <div class="valeur">${statsLog.actionsAdmin}</div>
                <div class="libelle"><fmt:message key="audit.stats.actions_admin"/></div>
            </div>
        </div>
        <div class="stat-box reveal">
            <div class="stat-icon">&#128269;</div>
            <div class="stat-info">
                <div class="valeur">${statsLog.accesDossiers}</div>
                <div class="libelle"><fmt:message key="audit.stats.acces_dossiers"/></div>
            </div>
        </div>
    </div>

    <div class="card">
        <form method="get" action="${pageContext.request.contextPath}/superadmin/audit" class="filter-form" style="display:flex; gap:0.8rem; flex-wrap:wrap; align-items:end;">
            <div>
                <label><fmt:message key="audit.filtre.recherche"/></label>
                <input type="text" name="recherche" value="${filtreRecherche}" placeholder="<fmt:message key='placeholder.search'/>">
            </div>
            <div>
                <label><fmt:message key="audit.filtre.module"/></label>
                <select name="module">
                    <option value=""><fmt:message key="label.tous"/></option>
                    <option value="AUTH" ${filtreModule == 'AUTH' ? 'selected' : ''}>AUTH</option>
                    <option value="PATIENT" ${filtreModule == 'PATIENT' ? 'selected' : ''}>PATIENT</option>
                    <option value="MEDECIN" ${filtreModule == 'MEDECIN' ? 'selected' : ''}>MEDECIN</option>
                    <option value="RDV" ${filtreModule == 'RDV' ? 'selected' : ''}>RDV</option>
                    <option value="DOSSIER" ${filtreModule == 'DOSSIER' ? 'selected' : ''}>DOSSIER</option>
                    <option value="SERVICE" ${filtreModule == 'SERVICE' ? 'selected' : ''}>SERVICE</option>
                    <option value="CONSULTATION" ${filtreModule == 'CONSULTATION' ? 'selected' : ''}>CONSULTATION</option>
                    <option value="ADMIN" ${filtreModule == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                </select>
            </div>
            <div>
                <label><fmt:message key="audit.filtre.niveau"/></label>
                <select name="niveau">
                    <option value=""><fmt:message key="label.tous"/></option>
                    <option value="INFO" ${filtreNiveau == 'INFO' ? 'selected' : ''}><fmt:message key="audit.level.info"/></option>
                    <option value="WARNING" ${filtreNiveau == 'WARNING' ? 'selected' : ''}><fmt:message key="audit.level.warning"/></option>
                    <option value="CRITICAL" ${filtreNiveau == 'CRITICAL' ? 'selected' : ''}><fmt:message key="audit.level.critical"/></option>
                </select>
            </div>
            <div>
                <label><fmt:message key="audit.filtre.date_debut"/></label>
                <input type="date" name="dateDebut" value="${dateDebut}">
            </div>
            <div>
                <label><fmt:message key="audit.filtre.date_fin"/></label>
                <input type="date" name="dateFin" value="${dateFin}">
            </div>
            <div>
                <button type="submit" class="btn"><fmt:message key="audit.filtre.appliquer"/></button>
            </div>
        </form>
    </div>

    <div class="card">
        <table class="table">
            <thead>
                <tr>
                    <th><fmt:message key="audit.table.date"/></th>
                    <th><fmt:message key="audit.table.utilisateur"/></th>
                    <th><fmt:message key="audit.table.role"/></th>
                    <th><fmt:message key="audit.table.etablissement"/></th>
                    <th><fmt:message key="audit.table.module"/></th>
                    <th><fmt:message key="audit.table.action"/></th>
                    <th><fmt:message key="audit.table.niveau"/></th>
                    <th><fmt:message key="audit.table.cible"/></th>
                    <th><fmt:message key="audit.table.description"/></th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${logs}" var="log" varStatus="s">
                <tr>
                    <td>${log.dateAction}</td>
                    <td>${log.nomUtilisateur}</td>
                    <td>${log.roleUtilisateur}</td>
                    <td>${log.nomEtablissement}</td>
                    <td>${log.module}</td>
                    <td>${log.action}</td>
                    <td>
                        <c:choose>
                            <c:when test="${log.niveau == 'CRITICAL'}">
                                <span class="badge badge-critique"><fmt:message key="audit.level.critical"/></span>
                            </c:when>
                            <c:when test="${log.niveau == 'WARNING'}">
                                <span class="badge badge-demande"><fmt:message key="audit.level.warning"/></span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-info"><fmt:message key="audit.level.info"/></span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>${log.cibleType} #${log.cibleId}</td>
                    <td style="max-width:200px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;" title="${log.description}">${log.description}</td>
                </tr>
                </c:forEach>
                <c:if test="${empty logs}">
                <tr>
                    <td colspan="9" style="text-align:center;"><fmt:message key="message.empty.no_data"/></td>
                </tr>
                </c:if>
            </tbody>
        </table>

        <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${page > 0}">
                <a class="btn btn-small btn-secondary" href="?page=0&amp;module=${filtreModule}&amp;niveau=${filtreNiveau}&amp;recherche=${filtreRecherche}&amp;dateDebut=${dateDebut}&amp;dateFin=${dateFin}">&laquo;</a>
            </c:if>
            <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                <c:choose>
                    <c:when test="${p == page}">
                        <span class="btn btn-small active-page">${p + 1}</span>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-small btn-secondary" href="?page=${p}&amp;module=${filtreModule}&amp;niveau=${filtreNiveau}&amp;recherche=${filtreRecherche}&amp;dateDebut=${dateDebut}&amp;dateFin=${dateFin}">${p + 1}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${page < totalPages - 1}">
                <a class="btn btn-small btn-secondary" href="?page=${page + 1}&amp;module=${filtreModule}&amp;niveau=${filtreNiveau}&amp;recherche=${filtreRecherche}&amp;dateDebut=${dateDebut}&amp;dateFin=${dateFin}">&raquo;</a>
            </c:if>
        </div>
        </c:if>
    </div>

    <div class="charts-grid">
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="audit.chart.par_module"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartModule"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="audit.chart.par_niveau"/></h3>
            <div class="chart-wrapper">
                <canvas id="chartNiveau"></canvas>
            </div>
        </div>
        <div class="chart-card reveal-scale">
            <h3><fmt:message key="audit.chart.activite_7j"/></h3>
            <div class="chart-wrapper">
                <canvas id="chart7Jours"></canvas>
            </div>
        </div>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
(function() {
    var moduleLabels = [
        <c:forEach items="${actionsParModule}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var moduleData = [
        <c:forEach items="${actionsParModule}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.bar('chartModule', moduleLabels, moduleData, '#2563eb');

    var niveauLabels = [
        <c:forEach items="${actionsParNiveau}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var niveauData = [
        <c:forEach items="${actionsParNiveau}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.doughnut('chartNiveau', niveauLabels, niveauData, ['#22c55e', '#f59e0b', '#ef4444']);

    var activiteLabels = [
        <c:forEach items="${activite7Jours}" var="item" varStatus="s">
        '${item[0]}'${not s.last ? ',' : ''}
        </c:forEach>
    ];
    var activiteData = [
        <c:forEach items="${activite7Jours}" var="item" varStatus="s">
        ${item[1]}${not s.last ? ',' : ''}
        </c:forEach>
    ];
    window.bhcCharts.line('chart7Jours', activiteLabels, activiteData, '#8b5cf6');
})();
</script>
</body>
</html>
