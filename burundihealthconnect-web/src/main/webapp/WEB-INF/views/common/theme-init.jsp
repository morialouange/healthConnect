<%@ page contentType="text/html;charset=UTF-8" %>
<meta name="csrf-token" content="${requestScope.csrfToken}">
<link rel="icon" href="${pageContext.request.contextPath}/img/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/fonts.css?v=6">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css?v=12">
<script src="${pageContext.request.contextPath}/resources/js/lucide.min.js?v=4"></script>
<script>
 (function () {
 try {
 var theme = localStorage.getItem("mc-theme");
 if (theme) {
 document.documentElement.setAttribute("data-theme", theme);
 }
 } catch (e) {}
 })();
</script>
