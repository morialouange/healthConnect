<%@ page contentType="text/html;charset=UTF-8" %>
</main>
</div>
</div>
<script>
 // Toggle dark mode — vanilla JS uniquement, aucune dépendance.
 (function () {
 var root = document.documentElement;
 var toggleBtn = document.getElementById('theme-toggle');
 if (!toggleBtn) return;
 toggleBtn.addEventListener('click', function () {
 var isDark = root.getAttribute('data-theme') === 'dark';
 if (isDark) { root.removeAttribute('data-theme'); toggleBtn.textContent = '\u263E'; localStorage.setItem('mc-theme', 'light'); }
 else { root.setAttribute('data-theme', 'dark'); toggleBtn.textContent = '\u2600'; localStorage.setItem('mc-theme', 'dark'); }
 });
 })();
</script>
<script src="${pageContext.request.contextPath}/js/app.js?v=8"></script>
<script>if(window.lucide) lucide.createIcons();</script>