<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!-- Graphique ligne via Chart.js (bibliothèque JS pure). Les données sont
     injectées serveur par JSTL/EL au moment du rendu — aucun scriptlet. -->
<canvas id="chartLineConsultations" class="chart-canvas" role="img" aria-label="${chartTitle}" style="width:100%;height:230px;"></canvas>
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
    <c:forEach items="${chartData}" var="item">
    labels.push("<c:out value="${item[0]}"/>");
    valeurs.push(Number("<c:out value="${item[1]}"/>") || 0);
    </c:forEach>
    var el = document.getElementById("chartLineConsultations");
    if (!el) return;
    new Chart(el, {
        type: "line",
        data: {
            labels: labels,
            datasets: [{
                label: "<c:out value="${chartTitle}"/>",
                data: valeurs,
                borderColor: couleur("--brand-primary", "#2563EB"),
                backgroundColor: couleur("--brand-primary", "#2563EB") + "1A",
                fill: true,
                tension: 0.35,
                borderWidth: 2.5,
                pointRadius: 4,
                pointBackgroundColor: couleur("--bg-card", "#FFFFFF"),
                pointBorderColor: couleur("--brand-primary", "#2563EB"),
                pointBorderWidth: 2
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
                        maxTicksLimit: 12,
                        maxRotation: 0,
                        autoSkip: true
                    },
                    grid: { color: couleur("--border-color", "#E4E9F1") }
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