<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="admin-medecins"/>
<c:set var="pageTitre" value="Gestion des médecins"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.medecins"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.8rem;">
            <h2><fmt:message key="admin.medecins.title"/></h2>
            <button type="button" class="btn" onclick="document.getElementById('formCreerMedecin').style.display='block'">
                + <fmt:message key="btn.new.medecin"/>
            </button>
        </div>

        <div style="margin-top:1rem;">
            <form method="get" action="${pageContext.request.contextPath}/admin/medecins" style="display:flex; gap:0.5rem;">
                <input type="text" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search.name'/>..." style="flex:1; padding:0.5rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg-elevated); color:var(--text);">
                <button type="submit" class="btn btn-small"><fmt:message key="btn.search"/></button>
                <c:if test="${not empty filtre}">
                    <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/admin/medecins"><fmt:message key="btn.clear"/></a>
                </c:if>
            </form>
        </div>

        <div id="formCreerMedecin" style="display:none; margin-top:1rem; padding:1rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg);">
            <h3><fmt:message key="admin.create.medecin.title"/></h3>
            <form method="post" action="${pageContext.request.contextPath}/admin/medecins/creer">
                <div class="form-row">
                    <div class="form-group">
                        <label for="fullName"><fmt:message key="label.fullname"/></label>
                        <input type="text" id="fullName" name="fullName" required>
                    </div>
                    <div class="form-group">
                        <label for="email"><fmt:message key="label.email"/></label>
                        <input type="email" id="email" name="email" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="motDePasseTemporaire"><fmt:message key="label.temp.password"/></label>
                    <input type="text" id="motDePasseTemporaire" name="motDePasseTemporaire" minlength="8" required>
                </div>
                <button type="submit" class="btn"><fmt:message key="btn.create.account"/></button>
                <button type="button" class="btn btn-secondary" onclick="document.getElementById('formCreerMedecin').style.display='none'"><fmt:message key="btn.cancel"/></button>
            </form>
        </div>
    </div>

    <c:if test="${empty medecins}">
        <div class="card"><p><fmt:message key="admin.no.medecins"/></p></div>
    </c:if>

    <c:if test="${not empty medecins}">
        <div class="card">
            <table class="table">
                <thead>
                <tr>
                    <th><a href="?tri=nom&ordre=${tri == 'nom' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}" style="color:inherit; text-decoration:none;"><fmt:message key="table.nom"/> ${tri == 'nom' ? (ordre == 'desc' ? '▼' : '▲') : ''}</a></th>
                    <th><a href="?tri=specialite&ordre=${tri == 'specialite' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}" style="color:inherit; text-decoration:none;"><fmt:message key="table.specialite"/> ${tri == 'specialite' ? (ordre == 'desc' ? '▼' : '▲') : ''}</a></th>
                    <th><a href="?tri=experience&ordre=${tri == 'experience' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}" style="color:inherit; text-decoration:none;"><fmt:message key="table.experience"/> ${tri == 'experience' ? (ordre == 'desc' ? '▼' : '▲') : ''}</a></th>
                    <th><fmt:message key="table.numero_ordre"/></th>
                    <th><a href="?tri=email&ordre=${tri == 'email' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}" style="color:inherit; text-decoration:none;"><fmt:message key="label.email"/> ${tri == 'email' ? (ordre == 'desc' ? '▼' : '▲') : ''}</a></th>
                    <th><fmt:message key="table.actif"/></th>
                    <th><fmt:message key="table.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="m" items="${medecins}">
                    <tr>
                        <td>${m.utilisateur.fullName}</td>
                        <td>${m.specialite}</td>
                        <td><c:choose><c:when test="${not empty m.experience}">${m.experience} <fmt:message key="years"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                        <td>${m.numeroOrdre}</td>
                        <td>${m.utilisateur.email}</td>
                        <td><c:choose><c:when test="${m.utilisateur.actif}"><span class="badge badge-confirme"><fmt:message key="status.actif"/></span></c:when><c:otherwise><span class="badge badge-annule"><fmt:message key="status.inactif"/></span></c:otherwise></c:choose></td>
                        <td><a class="btn btn-small" href="${pageContext.request.contextPath}/admin/medecins/detail?idMedecin=${m.idMedecin}"><fmt:message key="btn.detail"/></a></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:set var="sortParams" value="${tri != null ? '&tri='.concat(tri).concat('&ordre=').concat(ordre) : ''}"/>
            <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${page > 0}">
                    <a class="btn btn-small btn-secondary" href="?page=0&amp;filtre=${filtre}${sortParams}">&laquo;</a>
                </c:if>
                <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                    <c:choose>
                        <c:when test="${p == page}">
                            <span class="btn btn-small active-page">${p + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-small btn-secondary" href="?page=${p}&amp;filtre=${filtre}${sortParams}">${p + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${page < totalPages - 1}">
                    <a class="btn btn-small btn-secondary" href="?page=${page + 1}&amp;filtre=${filtre}${sortParams}">&raquo;</a>
                </c:if>
            </div>
            </c:if>
        </div>
    </c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
