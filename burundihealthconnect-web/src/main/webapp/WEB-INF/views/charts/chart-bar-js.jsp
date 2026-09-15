<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!-- Graphique barres via Chart.js (bibliothèque JS pure). Les données sont
     injectées serveur par JSTL/EL au moment du rendu — aucun scriptlet. -->
<canvas id="chartBarTopServices" class="chart-canvas" role="img" aria-label="${chartTitle}" style="width:100%;height:230px;"></canvas>
<script>
(function () {
    if (typeof Chart === "undefined") return;
    var root = getComputedStyle(document.documentElement);
    function couleur(nom, defaut) {
        var v = root.getPropertyValue(nom).trim();
        return v ? v : defaut;
    }
    var labels = [];
    var valeurs = [];
    var couleurs = [];
    <c:forEach items="${chartData}" var="item" varStatus="st">
    labels.push("<c:out value="${item[0]}"/>");
    valeurs.push(Number("<c:out value="${item[1]}"/>") || 0);
    couleurs.push(couleur("${st.count % 2 == 0 ? '--brand-teal' : '--brand-primary'}", "${st.count % 2 == 0 ? '#0D9488' : '#2563EB'}"));
    </c:forEach>
    var el = document.getElementById("chartBarTopServices");
    if (!el) return;
    new Chart(el, {
        type: "bar",
        data: {
            labels: labels,
            datasets: [{
                label: "<c:out value="${chartTitle}"/>",
                data: valeurs,
                backgroundColor: couleurs,
                borderRadius: 5,
                maxBarThickness: 64
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            animation: { duration: 500 },
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: couleur("--bg-card", "#FFFFFF"),
                    titleColor: couleur("--text-primary", "#101828"),
                    bodyColor: couleur("--text-secondary", "#5A6472"),
                    borderColor: couleur("--border-color", "#E4E9F1"),
                    borderWidth: 1,
                    padding: 10,
                    displayColors: false
                }
            },
            scales: {
                x: {
                    ticks: {
                        color: couleur("--text-muted", "#9AA4B2"),
                        maxRotation: 0,
                        autoSkip: false
                    },
                    grid: { display: false }
                },
                y: {
                    beginAtZero: true,
                    ticks: {
                        color: couleur("--text-muted", "#9AA4B2"),
                        precision: 0
                    },
                    grid: { color: couleur("--border-color", "#E4E9F1") }
                }
            }
        }
    });
})();
</script>