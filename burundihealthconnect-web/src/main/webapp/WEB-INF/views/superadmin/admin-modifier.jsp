<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="pageRoute" value="superadmin-admins-modifier"/>
<c:set var="pageTitre" value="Modifier un administrateur"/>
<!DOCTYPE html>
<html lang="${sessionScope.langue != null ? sessionScope.langue : 'fr'}">
<fmt:setLocale value="${sessionScope.langue != null ? sessionScope.langue : 'fr'}" />
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="page.modifier.admin"/> — <fmt:message key="app.name"/></title>
    <jsp:include page="/WEB-INF/views/common/theme-init.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="card">
        <h2><fmt:message key="admin.modifier.title"/></h2>
        <c:if test="${empty admin}">
            <p><fmt:message key="admin.not.found"/></p>
        </c:if>
        <c:if test="${not empty admin}">
            <form method="post" action="${pageContext.request.contextPath}/superadmin/admins/modifier">
                <input type="hidden" name="idUtilisateur" value="${admin.idUtilisateur}">

                <div class="form-group">
                    <label for="fullName"><fmt:message key="label.fullname"/></label>
                    <input type="text" id="fullName" name="fullName" value="${admin.fullName}" required>
                </div>
                <div class="form-group">
                    <label for="email"><fmt:message key="label.email"/></label>
                    <input type="email" id="email" name="email" value="${admin.email}" required>
                </div>
                <div class="form-group">
                    <label for="idEtablissement"><fmt:message key="label.etablissement"/></label>
                    <select id="idEtablissement" name="idEtablissement" required>
                        <option value="">-- <fmt:message key="btn.select"/> --</option>
                        <c:forEach var="h" items="${hopitaux}">
                            <option value="${h.idEtablissement}" ${admin.etablissement.idEtablissement == h.idEtablissement ? 'selected' : ''}>${h.nom}</option>
                        </c:forEach>
                    </select>
                </div>

                <button type="submit" class="btn"><fmt:message key="btn.save.modifications"/></button>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/superadmin/hopitaux"><fmt:message key="btn.cancel"/></a>
            </form>
        </c:if>
    </div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
