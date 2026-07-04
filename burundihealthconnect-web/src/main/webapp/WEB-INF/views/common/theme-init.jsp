<%@ page contentType="text/html;charset=UTF-8" %>
<link rel="icon" href="${pageContext.request.contextPath}/img/favicon.svg" type="image/svg+xml">
<style>
    body { font-family: 'Bell MT', Georgia, 'Times New Roman', serif; }
</style>
<script>
    (function () {
        try {
            var theme = localStorage.getItem("bhc-theme");
            if (theme) {
                document.documentElement.setAttribute("data-theme", theme);
            }
        } catch (e) {}
    })();
</script>