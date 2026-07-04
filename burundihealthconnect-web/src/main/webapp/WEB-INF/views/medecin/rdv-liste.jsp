<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="medecin-rdv"/>
<c:set var="pageTitre" value="Mes rendez-vous"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.rdv"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="medecin.rdv.title"/></h2>
        <form method="get" action="${pageContext.request.contextPath}/medecin/rdv" style="margin-bottom:1rem;">
            <div class="form-row" style="align-items:flex-end;">
                <div class="form-group" style="max-width:280px;">
                    <label for="filtre"><fmt:message key="label.filter.patient"/></label>
                    <input type="text" id="filtre" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search'/>...">
                </div>
                <div class="form-group" style="flex:0;">
                    <button type="submit" class="btn btn-secondary"><fmt:message key="btn.filter"/></button>
                </div>
            </div>
        </form>

        <c:if test="${empty rdv}">
            <p><fmt:message key="medecin.no.rdv"/></p>
        </c:if>

        <c:if test="${not empty rdv}">
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="table.patient"/></th>
                    <th><fmt:message key="table.date"/></th>
                    <th><fmt:message key="table.motif"/></th>
                    <th><fmt:message key="table.priorite"/></th>
                    <th><fmt:message key="table.statut"/></th>
                    <th><fmt:message key="table.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="r" items="${rdv}">
                    <tr>
                        <td>${r.patient.utilisateur.fullName}</td>
                        <td>${r.dateRendez}</td>
                        <td>${r.motif}</td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/medecin/rdv/priorite"
                                  style="display:inline;">
                                <input type="hidden" name="idRendezVous" value="${r.idRendez}">
                                <select name="priorite" onchange="this.form.submit()" class="btn-small"
                                        style="border-radius:6px; border:1px solid var(--border); padding:0.25rem;">
                                    <option value="NORMAL" ${r.priorite == 'NORMAL' ? 'selected' : ''}><fmt:message key="priorite.normal"/></option>
                                    <option value="URGENT" ${r.priorite == 'URGENT' ? 'selected' : ''}><fmt:message key="priorite.urgent"/></option>
                                    <option value="CRITIQUE" ${r.priorite == 'CRITIQUE' ? 'selected' : ''}><fmt:message key="priorite.critique"/></option>
                                </select>
                            </form>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${r.statut == 'RDV_DEMANDE'}">
                                    <span class="badge badge-demande"><fmt:message key="status.rdv_demande"/></span>
                                </c:when>
                                <c:when test="${r.statut == 'RDV_CONFIRME'}">
                                    <span class="badge badge-confirme"><fmt:message key="status.confirme"/></span>
                                </c:when>
                                <c:when test="${r.statut == 'RDV_ANNULE'}">
                                    <span class="badge badge-annule"><fmt:message key="status.annule"/></span>
                                </c:when>
                                <c:when test="${r.statut == 'TERMINE'}">
                                    <span class="badge badge-termine"><fmt:message key="status.termine"/></span>
                                </c:when>
                            </c:choose>
                        </td>
                        <td>
                            <c:if test="${r.statut == 'RDV_DEMANDE'}">
                                <form method="post" action="${pageContext.request.contextPath}/medecin/rdv/confirmer"
                                      style="display:inline;">
                                    <input type="hidden" name="idRendezVous" value="${r.idRendez}">
                                    <button type="submit" class="btn btn-small"><fmt:message key="btn.confirm"/></button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/medecin/rdv/refuser"
                                      style="display:inline;">
                                    <input type="hidden" name="idRendezVous" value="${r.idRendez}">
                                    <button type="submit" class="btn btn-small btn-danger" onclick="return confirm('<fmt:message key="confirm.refuser.rdv"/>')"><fmt:message key="btn.refuse"/></button>
                                </form>
                            </c:if>
                            <c:if test="${r.statut == 'RDV_CONFIRME'}">
                                <a class="btn btn-small"
                                   href="${pageContext.request.contextPath}/medecin/consultation/creer?idRendezVous=${r.idRendez}">
                                    <fmt:message key="btn.create.consultation"/></a>
                                <form method="post" action="${pageContext.request.contextPath}/medecin/rdv/terminer"
                                      style="display:inline;">
                                    <input type="hidden" name="idRendezVous" value="${r.idRendez}">
                                    <button type="submit" class="btn btn-small btn-secondary"><fmt:message key="btn.mark.termine"/></button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>

            <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${page > 0}">
                    <a class="btn btn-small btn-secondary" href="?page=0&amp;filtre=${filtre}">&laquo;</a>
                </c:if>
                <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                    <c:choose>
                        <c:when test="${p == page}">
                            <span class="btn btn-small active-page">${p + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-small btn-secondary" href="?page=${p}&amp;filtre=${filtre}">${p + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${page < totalPages - 1}">
                    <a class="btn btn-small btn-secondary" href="?page=${page + 1}&amp;filtre=${filtre}">&raquo;</a>
                </c:if>
            </div>
            </c:if>
        </c:if>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>