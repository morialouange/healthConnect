<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set scope="request" var="pageRoute" value="admin-medecins"/>
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<c:set scope="request" var="pageTitre"><fmt:message key="admin.medecins.title"/></c:set>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.medecins"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
</head>
<body class="mc-page">
<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>
<div class="card">
    <div class="flex flex-wrap items-center justify-between gap-12">
        <h2><fmt:message key="admin.medecins.title"/></h2>
        <button type="button" class="btn btn-primary" onclick="var p=document.getElementById('formCreerMedecin'); p.classList.toggle('is-open');">
            + <fmt:message key="btn.new.medecin"/>
        </button>
    </div>
    <div class="mt-12">
        <form method="get" action="${pageContext.request.contextPath}/admin/medecins" class="flex flex-wrap gap-8">
            <input class="form-control" type="text" name="filtre" value="${filtre}" placeholder="<fmt:message key='placeholder.search.name'/>...">
            <button type="submit" class="btn btn-primary"><fmt:message key="btn.search"/></button>
            <c:if test="${not empty filtre}">
                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/admin/medecins"><fmt:message key="btn.clear"/></a>
            </c:if>
        </form>
    </div>
    <div id="formCreerMedecin" class="form-creer mt-12${requestScope.afficherFormulaire ? ' is-open' : ''}">
        <h3><fmt:message key="admin.create.medecin.title"/></h3>
        <form method="post" action="${pageContext.request.contextPath}/admin/medecins/creer">
            <div class="grid-auto-240">
                <div class="form-group">
                    <label class="form-label" for="fullName"><fmt:message key="label.fullname"/></label>
                    <input class="form-control" type="text" id="fullName" name="fullName" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="email"><fmt:message key="label.email"/></label>
                    <input class="form-control" type="email" id="email" name="email" required>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="motDePasseTemporaire"><fmt:message key="label.temp.password"/></label>
                <input class="form-control" type="text" id="motDePasseTemporaire" name="motDePasseTemporaire" minlength="8" required>
            </div>
            <div class="flex gap-8">
                <button type="submit" class="btn btn-primary"><fmt:message key="btn.create.account"/></button>
                <button type="button" class="btn btn-ghost" onclick="document.getElementById('formCreerMedecin').classList.remove('is-open')"><fmt:message key="btn.cancel"/></button>
            </div>
        </form>
    </div>
</div>
<c:if test="${empty medecins}">
    <div class="card"><p><fmt:message key="admin.no.medecins"/></p></div>
</c:if>
<c:if test="${not empty medecins}">
    <div class="card">
        <div class="table-wrap">
            <table class="table">
                <thead>
                <tr>
                    <th scope="col"><a href="?tri=nom&ordre=${tri == 'nom' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}"><fmt:message key="table.nom"/> ${tri == 'nom' ? (ordre == 'desc' ? '&#9660;' : '&#9650;') : ''}</a></th>
                    <th scope="col"><a href="?tri=specialite&ordre=${tri == 'specialite' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}"><fmt:message key="table.specialite"/> ${tri == 'specialite' ? (ordre == 'desc' ? '&#9660;' : '&#9650;') : ''}</a></th>
                    <th scope="col"><a href="?tri=experience&ordre=${tri == 'experience' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}"><fmt:message key="table.experience"/> ${tri == 'experience' ? (ordre == 'desc' ? '&#9660;' : '&#9650;') : ''}</a></th>
                    <th scope="col"><fmt:message key="table.numero_ordre"/></th>
                    <th scope="col"><a href="?tri=email&ordre=${tri == 'email' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}"><fmt:message key="label.email"/> ${tri == 'email' ? (ordre == 'desc' ? '&#9660;' : '&#9650;') : ''}</a></th>
                    <th scope="col"><fmt:message key="table.actif"/></th>
                    <th scope="col"><fmt:message key="table.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="m" items="${medecins}">
                    <tr>
                        <td>${m.utilisateur.fullName}</td>
                        <td>${m.specialite}</td>
                        <td><c:choose><c:when test="${not empty m.experience}">${m.experience} <fmt:message key="years"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                        <td><span class="badge-id">${m.numeroOrdre}</span></td>
                        <td>${m.utilisateur.email}</td>
                        <td>
                            <c:choose>
                                <c:when test="${m.utilisateur.actif}"><span class="badge badge-success"><fmt:message key="status.actif"/></span></c:when>
                                <c:otherwise><span class="badge badge-neutral"><fmt:message key="status.inactif"/></span></c:otherwise>
                            </c:choose>
                        </td>
                        <td><a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/admin/medecins/detail?idMedecin=${m.idMedecin}"><fmt:message key="btn.detail"/></a></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
        <c:set var="sortParams" value="${tri != null ? '&tri='.concat(tri).concat('&ordre=').concat(ordre) : ''}"/>
        <c:if test="${totalPages > 1}">
            <nav class="pagination">
                <c:if test="${page > 0}">
                    <a class="page-item" href="?page=0&amp;filtre=${filtre}${sortParams}">&laquo;</a>
                </c:if>
                <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                    <c:choose>
                        <c:when test="${p == page}">
                            <span class="page-item active">${p + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="page-item" href="?page=${p}&amp;filtre=${filtre}${sortParams}">${p + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${page < totalPages - 1}">
                    <a class="page-item" href="?page=${page + 1}&amp;filtre=${filtre}${sortParams}">&raquo;</a>
                </c:if>
            </nav>
        </c:if>
    </div>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>