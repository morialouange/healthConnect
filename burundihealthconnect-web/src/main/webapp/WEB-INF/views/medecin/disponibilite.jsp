<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="pageRoute" value="medecin-disponibilite"/>
<c:set var="pageTitre" value="Mes disponibilités"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.disponibilites"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="dispo.declare.title"/></h2>
        <p style="color:var(--text-muted); font-size:0.85rem;">
            <fmt:message key="dispo.declare.desc"/>
        </p>

        <form method="post" action="${pageContext.request.contextPath}/medecin/disponibilite/declarer">
            <div class="form-row">
                <div class="form-group">
                    <label for="dateDebutSemaine"><fmt:message key="label.date_debut_semaine"/></label>
                    <input type="date" id="dateDebutSemaine" name="dateDebutSemaine" required>
                </div>
                <div class="form-group">
                    <label for="dureeCreneauMin"><fmt:message key="label.duree_creneau"/></label>
                    <select id="dureeCreneauMin" name="dureeCreneauMin" required>
                        <option value="15"><fmt:message key="dispo.15min"/></option>
                        <option value="30" selected><fmt:message key="dispo.30min"/></option>
                        <option value="60"><fmt:message key="dispo.60min"/></option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label><fmt:message key="dispo.jours.travailles"/></label>
                <table style="width:100%; border-collapse:collapse;">
                    <thead>
                        <tr>
                            <th style="text-align:left; padding:0.3rem 0.5rem;"><fmt:message key="dispo.jour"/></th>
                            <th style="text-align:left; padding:0.3rem 0.5rem;"><fmt:message key="dispo.inclure"/></th>
                            <th style="text-align:left; padding:0.3rem 0.5rem;"><fmt:message key="dispo.debut"/></th>
                            <th style="text-align:left; padding:0.3rem 0.5rem;"><fmt:message key="dispo.fin"/></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="padding:0.3rem 0.5rem;"><fmt:message key="day.monday"/></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="checkbox" name="joursTravailles" value="MONDAY" checked class="day-check" data-day="MONDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureDebut_MONDAY" value="08:00" class="day-time" data-day="MONDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureFin_MONDAY" value="17:00" class="day-time" data-day="MONDAY"></td>
                        </tr>
                        <tr>
                            <td style="padding:0.3rem 0.5rem;"><fmt:message key="day.tuesday"/></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="checkbox" name="joursTravailles" value="TUESDAY" checked class="day-check" data-day="TUESDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureDebut_TUESDAY" value="08:00" class="day-time" data-day="TUESDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureFin_TUESDAY" value="17:00" class="day-time" data-day="TUESDAY"></td>
                        </tr>
                        <tr>
                            <td style="padding:0.3rem 0.5rem;"><fmt:message key="day.wednesday"/></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="checkbox" name="joursTravailles" value="WEDNESDAY" checked class="day-check" data-day="WEDNESDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureDebut_WEDNESDAY" value="08:00" class="day-time" data-day="WEDNESDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureFin_WEDNESDAY" value="17:00" class="day-time" data-day="WEDNESDAY"></td>
                        </tr>
                        <tr>
                            <td style="padding:0.3rem 0.5rem;"><fmt:message key="day.thursday"/></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="checkbox" name="joursTravailles" value="THURSDAY" checked class="day-check" data-day="THURSDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureDebut_THURSDAY" value="08:00" class="day-time" data-day="THURSDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureFin_THURSDAY" value="17:00" class="day-time" data-day="THURSDAY"></td>
                        </tr>
                        <tr>
                            <td style="padding:0.3rem 0.5rem;"><fmt:message key="day.friday"/></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="checkbox" name="joursTravailles" value="FRIDAY" checked class="day-check" data-day="FRIDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureDebut_FRIDAY" value="08:00" class="day-time" data-day="FRIDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureFin_FRIDAY" value="17:00" class="day-time" data-day="FRIDAY"></td>
                        </tr>
                        <tr>
                            <td style="padding:0.3rem 0.5rem;"><fmt:message key="day.saturday"/></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="checkbox" name="joursTravailles" value="SATURDAY" class="day-check" data-day="SATURDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureDebut_SATURDAY" value="08:00" class="day-time" data-day="SATURDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureFin_SATURDAY" value="12:00" class="day-time" data-day="SATURDAY"></td>
                        </tr>
                        <tr>
                            <td style="padding:0.3rem 0.5rem;"><fmt:message key="day.sunday"/></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="checkbox" name="joursTravailles" value="SUNDAY" class="day-check" data-day="SUNDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureDebut_SUNDAY" value="08:00" class="day-time" data-day="SUNDAY"></td>
                            <td style="padding:0.3rem 0.5rem;"><input type="time" name="heureFin_SUNDAY" value="12:00" class="day-time" data-day="SUNDAY"></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <button type="submit" class="btn" style="margin-top:1rem;"><fmt:message key="btn.declare.week"/></button>

            <script>
            document.querySelectorAll('.day-check').forEach(function(cb) {
                function toggle() {
                    var day = cb.getAttribute('data-day');
                    var times = document.querySelectorAll('.day-time[data-day="' + day + '"]');
                    times.forEach(function(t) { t.disabled = !cb.checked; });
                }
                cb.addEventListener('change', toggle);
                toggle();
            });
            </script>
        </form>
    </div>

    <div class="card">
        <h2><fmt:message key="dispo.weeks.declared"/></h2>

        <c:if test="${empty semaines}">
            <p style="color:var(--text-muted);"><fmt:message key="dispo.no.weeks"/></p>
        </c:if>

        <c:if test="${not empty semaines}">
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="dispo.from"/></th>
                    <th><fmt:message key="dispo.to"/></th>
                    <th><fmt:message key="dispo.duree"/></th>
                    <th><fmt:message key="table.actif"/></th>
                    <th><fmt:message key="table.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="s" items="${semaines}">
                    <tr>
                        <td>${s.dateDebutSemaine}</td>
                        <td>${s.dateFinSemaine}</td>
                        <td>${s.dureeCreneauMin} <fmt:message key="dispo.min"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${s.actif}"><span class="badge badge-confirme"><fmt:message key="status.active"/></span></c:when>
                                <c:otherwise><span class="badge badge-annule"><fmt:message key="status.inactive"/></span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/medecin/disponibilite/copier" style="display:inline;">
                                <input type="hidden" name="idDisponibilite" value="${s.idDisponibilite}">
                                <button type="submit" class="btn btn-small btn-secondary"><fmt:message key="btn.copy.next.week"/></button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${page > 0}">
                    <a class="btn btn-small btn-secondary" href="?page=0">&laquo;</a>
                </c:if>
                <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                    <c:choose>
                        <c:when test="${p == page}">
                            <span class="btn btn-small active-page">${p + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-small btn-secondary" href="?page=${p}">${p + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${page < totalPages - 1}">
                    <a class="btn btn-small btn-secondary" href="?page=${page + 1}">&raquo;</a>
                </c:if>
            </div>
            </c:if>
        </c:if>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>