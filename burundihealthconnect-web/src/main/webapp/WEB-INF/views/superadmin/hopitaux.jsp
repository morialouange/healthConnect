<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="pageRoute" value="superadmin-hopitaux"/>
<c:set var="pageTitre" value="Gestion des hôpitaux"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.hopitaux"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.8rem;">
            <h2><fmt:message key="hopitaux.reseau.title"/></h2>
            <button type="button" class="btn" onclick="document.getElementById('formCreerHopital').style.display='block'">
                <fmt:message key="btn.ajouter.hopital"/>
            </button>
        </div>

        <div style="margin-top:1rem;">
            <form method="get" action="${pageContext.request.contextPath}/superadmin/hopitaux" style="display:flex; gap:0.5rem;">
                <input type="text" name="filtre" value="${filtre}" placeholder="Rechercher un hôpital..." style="flex:1; padding:0.5rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg-elevated); color:var(--text);">
                <button type="submit" class="btn btn-small"><fmt:message key="btn.search"/></button>
                <c:if test="${not empty filtre}">
                    <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/superadmin/hopitaux"><fmt:message key="btn.clear"/></a>
                </c:if>
            </form>
        </div>

        <div id="formCreerHopital" style="display:none; margin-top:1rem; padding:1rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg);">
            <h3><fmt:message key="hopitaux.ajouter.title"/></h3>
            <form method="post" action="${pageContext.request.contextPath}/superadmin/hopitaux/creer">
                <div class="form-row">
                    <div class="form-group">
                        <label for="nom"><fmt:message key="label.nom"/></label>
                        <input type="text" id="nom" name="nom" required>
                    </div>
                    <div class="form-group">
                        <label for="typeEtablissement"><fmt:message key="label.type"/></label>
                        <input type="text" id="typeEtablissement" name="typeEtablissement" placeholder="<fmt:message key='placeholder.type.etablissement'/>">
                    </div>
                </div>
                <div class="form-group">
                    <label for="adresse"><fmt:message key="label.adresse"/></label>
                    <input type="text" id="adresse" name="adresse" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="email"><fmt:message key="label.email"/></label>
                        <input type="email" id="email" name="email">
                    </div>
                    <div class="form-group">
                        <label for="telephone"><fmt:message key="label.telephone"/></label>
                        <input type="tel" id="telephone" name="telephone">
                    </div>
                </div>
                <button type="submit" class="btn"><fmt:message key="btn.ajouter"/></button>
                <button type="button" class="btn btn-secondary" onclick="document.getElementById('formCreerHopital').style.display='none'"><fmt:message key="btn.cancel"/></button>
            </form>
        </div>
    </div>

    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.8rem; margin-bottom:1rem;">
            <h3><fmt:message key="hopitaux.ajouter.administrateur.title"/></h3>
            <button type="button" class="btn btn-secondary" onclick="document.getElementById('formCreerAdmin').style.display='block'">
                <fmt:message key="btn.creer.compte.admin"/>
            </button>
        </div>
        <div id="formCreerAdmin" style="display:none; padding:1rem; border:1px solid var(--border); border-radius:var(--radius-sm); background:var(--bg);">
            <form method="post" action="${pageContext.request.contextPath}/superadmin/admins/creer">
                <div class="form-row">
                    <div class="form-group">
                        <label for="adminFullName"><fmt:message key="label.fullname"/></label>
                        <input type="text" id="adminFullName" name="fullName" required>
                    </div>
                    <div class="form-group">
                        <label for="adminEmail">Email</label>
                        <input type="email" id="adminEmail" name="email" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="adminMdp"><fmt:message key="label.password.temporaire"/></label>
                        <input type="text" id="adminMdp" name="motDePasseTemporaire" minlength="8" required>
                    </div>
                    <div class="form-group">
                        <label for="idEtablissement"><fmt:message key="label.etablissement"/></label>
                        <select id="idEtablissement" name="idEtablissement" required>
                            <option value="">-- <fmt:message key="btn.select"/> --</option>
                            <c:forEach var="h" items="${hopitaux}">
                                <option value="${h.idEtablissement}">${h.nom}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn"><fmt:message key="btn.creer.admin"/></button>
                <button type="button" class="btn btn-secondary" onclick="document.getElementById('formCreerAdmin').style.display='none'"><fmt:message key="btn.cancel"/></button>
            </form>
        </div>
    </div>

    <c:if test="${empty hopitaux}">
        <div class="card"><p><fmt:message key="hopitaux.none"/></p></div>
    </c:if>

    <c:if test="${not empty hopitaux}">
        <div class="card">
            <table class="table">
                <thead>
                <tr>
                    <th><a href="?tri=nom&ordre=${tri == 'nom' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}" style="color:inherit; text-decoration:none;"><fmt:message key="table.nom"/> ${tri == 'nom' ? (ordre == 'desc' ? '▼' : '▲') : ''}</a></th>
                    <th><a href="?tri=type&ordre=${tri == 'type' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}" style="color:inherit; text-decoration:none;"><fmt:message key="table.type"/> ${tri == 'type' ? (ordre == 'desc' ? '▼' : '▲') : ''}</a></th>
                    <th><a href="?tri=adresse&ordre=${tri == 'adresse' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}" style="color:inherit; text-decoration:none;"><fmt:message key="table.adresse"/> ${tri == 'adresse' ? (ordre == 'desc' ? '▼' : '▲') : ''}</a></th>
                    <th><fmt:message key="table.contact"/></th>
                    <th><a href="?tri=actif&ordre=${tri == 'actif' && ordre != 'desc' ? 'desc' : 'asc'}${filtre != null ? '&filtre='.concat(filtre) : ''}" style="color:inherit; text-decoration:none;"><fmt:message key="table.statut"/> ${tri == 'actif' ? (ordre == 'desc' ? '▼' : '▲') : ''}</a></th>
                    <th><fmt:message key="table.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="h" items="${hopitaux}">
                    <tr>
                        <td>${h.nom}</td>
                        <td>${h.typeEtablissement}</td>
                        <td>${h.adresse}</td>
                        <td>
                            <c:if test="${not empty h.email}">${h.email}<br></c:if>
                            <c:if test="${not empty h.telephone}">${h.telephone}</c:if>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${h.actif}"><span class="badge badge-confirme"><fmt:message key="status.actif"/></span></c:when>
                                <c:otherwise><span class="badge badge-annule"><fmt:message key="status.inactif"/></span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/superadmin/hopitaux/modifier" style="display:inline;">
                                <input type="hidden" name="idEtablissement" value="${h.idEtablissement}">
                                <input type="text" name="nom" value="${h.nom}" placeholder="<fmt:message key='placeholder.nom'/>" style="width:100px; padding:0.25rem; border:1px solid var(--border); border-radius:var(--radius-sm);">
                                <button type="submit" class="btn btn-small btn-secondary"><fmt:message key="btn.modify"/></button>
                            </form>
                            <c:if test="${h.actif}">
                                <form method="post" action="${pageContext.request.contextPath}/superadmin/hopitaux/desactiver" style="display:inline;">
                                    <input type="hidden" name="idEtablissement" value="${h.idEtablissement}">
                                    <button type="submit" class="btn btn-small btn-danger" onclick="return confirm('<fmt:message key="confirm.desactiver.etablissement"/>')"><fmt:message key="btn.desactiver"/></button>
                                </form>
                            </c:if>
                            <c:if test="${not h.actif}">
                                <form method="post" action="${pageContext.request.contextPath}/superadmin/hopitaux/reactiver" style="display:inline;">
                                    <input type="hidden" name="idEtablissement" value="${h.idEtablissement}">
                                    <button type="submit" class="btn btn-small"><fmt:message key="btn.reactiver"/></button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:set var="sortParams" value="${tri != null ? '&tri='.concat(tri).concat('&ordre=').concat(ordre) : ''}"/>
            <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:if test="${page > 0}">
                    <a class="btn btn-small btn-secondary" href="?page=0<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>${sortParams}">&laquo;</a>
                </c:if>
                <c:forEach var="p" begin="${page - 2 < 0 ? 0 : page - 2}" end="${page + 2 >= totalPages ? totalPages - 1 : page + 2}">
                    <c:choose>
                        <c:when test="${p == page}">
                            <span class="btn btn-small active-page">${p + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-small btn-secondary" href="?page=${p}<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>${sortParams}">${p + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${page < totalPages - 1}">
                    <a class="btn btn-small btn-secondary" href="?page=${page + 1}<c:if test="${not empty filtre}">&amp;filtre=${filtre}</c:if>${sortParams}">&raquo;</a>
                </c:if>
            </div>
            </c:if>
        </div>
    </c:if>

    <c:if test="${not empty admins}">
        <div class="card">
            <h3><fmt:message key="hopitaux.administrateurs.title"/></h3>
            <table class="table">
                <thead>
                <tr>
                    <th><fmt:message key="table.nom"/></th>
                    <th><fmt:message key="table.email"/></th>
                    <th><fmt:message key="table.etablissement"/></th>
                    <th><fmt:message key="table.statut"/></th>
                    <th><fmt:message key="table.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="a" items="${admins}">
                    <tr>
                        <td>${a.fullName}</td>
                        <td>${a.email}</td>
                        <td>${a.etablissement.nom}</td>
                        <td>
                            <c:choose>
                                <c:when test="${a.actif}"><span class="badge badge-confirme"><fmt:message key="status.actif"/></span></c:when>
                                <c:otherwise><span class="badge badge-annule"><fmt:message key="status.inactif"/></span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <a class="btn btn-small btn-secondary" href="${pageContext.request.contextPath}/superadmin/admins/modifier?idUtilisateur=${a.idUtilisateur}"><fmt:message key="btn.modify"/></a>
                            <c:if test="${a.actif}">
                                <form method="post" action="${pageContext.request.contextPath}/superadmin/admins/desactiver" style="display:inline;">
                                    <input type="hidden" name="idUtilisateur" value="${a.idUtilisateur}">
                                    <button type="submit" class="btn btn-small btn-danger" onclick="return confirm('<fmt:message key="confirm.desactiver.admin"/>')"><fmt:message key="btn.desactiver"/></button>
                                </form>
                            </c:if>
                            <c:if test="${not a.actif}">
                                <form method="post" action="${pageContext.request.contextPath}/superadmin/admins/reactiver" style="display:inline;">
                                    <input type="hidden" name="idUtilisateur" value="${a.idUtilisateur}">
                                    <button type="submit" class="btn btn-small"><fmt:message key="btn.reactiver"/></button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
