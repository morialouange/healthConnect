<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="pageRoute" value="medecin-ordonnances"/>
<c:set var="pageTitre" value="Mes ordonnances"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.ordonnances"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="medecin.ordonnances.title"/></h2>

        <div style="margin-top:1rem; margin-bottom:1rem;">
            <form method="get" action="${pageContext.request.contextPath}/medecin/ordonnances" style="display:flex; gap:0.5rem;">
                <input type="text" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search'/>..." style="flex:1; padding:0.5rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg-elevated); color:var(--text);">
                <button type="submit" class="btn btn-small"><fmt:message key="btn.search"/></button>
                <c:if test="${not empty filtre}">
                    <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/medecin/ordonnances"><fmt:message key="btn.clear"/></a>
                </c:if>
            </form>
        </div>

        <c:if test="${empty ordonnances}">
            <p><fmt:message key="medecin.no.ordonnances"/></p>
        </c:if>

        <c:if test="${not empty ordonnances}">
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="table.date"/></th>
                    <th><fmt:message key="table.patient"/></th>
                    <th><fmt:message key="table.medicaments"/></th>
                    <th><fmt:message key="table.instructions"/></th>
                    <th><fmt:message key="table.consultation"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="o" items="${ordonnances}">
                    <tr>
                        <td>${o.createdAt.toLocalDate()}</td>
                        <td>${o.consultation.dossier.patient.utilisateur.fullName}</td>
                        <td>
                            <ul style="margin:0; padding-left:1rem;">
                                <c:forEach var="l" items="${o.lignes}">
                                    <li>${l.medicament} — ${l.dosage}, ${l.frequence}
                                        <c:if test="${l.dureeJours > 0}"> (${l.dureeJours}j)</c:if>
                                    </li>
                                </c:forEach>
                            </ul>
                        </td>
                        <td>${not empty o.instructions ? o.instructions : '—'}</td>
                        <td>
                            <a class="btn btn-small btn-secondary"
                               href="${pageContext.request.contextPath}/medecin/consultations"><fmt:message key="btn.voir"/></a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${page > 0}">
                    <a class="btn btn-small btn-secondary" href="?page=0<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>">&laquo;</a>
                </c:if>
                <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                    <c:choose>
                        <c:when test="${p == page}">
                            <span class="btn btn-small active-page">${p + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-small btn-secondary" href="?page=${p}<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>">${p + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${page < totalPages - 1}">
                    <a class="btn btn-small btn-secondary" href="?page=${page + 1}<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>">&raquo;</a>
                </c:if>
            </div>
            </c:if>
        </c:if>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>