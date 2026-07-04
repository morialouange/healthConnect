(function () {
    "use strict";

    var THEME_KEY = "bhc-theme";

    function appliquerTheme(theme) {
        document.documentElement.setAttribute("data-theme", theme);
    }

    function basculerTheme() {
        var actuel = document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light";
        var nouveau = actuel === "dark" ? "light" : "dark";
        appliquerTheme(nouveau);
        try { localStorage.setItem(THEME_KEY, nouveau); } catch (e) { }
        var btn = document.querySelector("[data-theme-toggle]");
        if (btn) btn.style.transform = "rotate(360deg)";
        window.setTimeout(function() {
            if (btn) btn.style.transform = "";
        }, 300);
    }

    function initThemeToggle() {
        var bouton = document.querySelector("[data-theme-toggle]");
        if (bouton) bouton.addEventListener("click", basculerTheme);
    }

    function initRipple() {
        document.addEventListener("click", function (e) {
            var btn = e.target.closest(".btn");
            if (!btn) return;
            var rect = btn.getBoundingClientRect();
            var taille = Math.max(rect.width, rect.height);
            var onde = document.createElement("span");
            onde.className = "ripple";
            onde.style.width = onde.style.height = taille + "px";
            onde.style.left = (e.clientX - rect.left - taille / 2) + "px";
            onde.style.top = (e.clientY - rect.top - taille / 2) + "px";
            btn.appendChild(onde);
            window.setTimeout(function () { onde.remove(); }, 600);
        });
    }

    function initEntreeEnCascade() {
        var elements = document.querySelectorAll(".card, .stat-box, .chart-card");
        elements = Array.prototype.filter.call(elements, function (el) {
            return el.closest(".auth-wrapper") === null;
        });
        elements.forEach(function (el, i) {
            el.classList.add("entrance");
            el.style.animationDelay = (i * 50) + "ms";
        });
        var lignes = document.querySelectorAll("table.table tbody tr");
        lignes.forEach(function (ligne, i) {
            ligne.style.opacity = "0";
            ligne.style.animation = "fade-in-up 360ms var(--ease-water) forwards";
            ligne.style.animationDelay = (i * 35) + "ms";
        });
    }

    function initPasswordToggle() {
        document.addEventListener("click", function (e) {
            var btn = e.target.closest(".password-toggle");
            if (!btn) return;
            var input = document.getElementById(btn.getAttribute("data-toggle"));
            if (!input) return;
            var type = input.getAttribute("type") === "password" ? "text" : "password";
            input.setAttribute("type", type);
            btn.setAttribute("aria-label", type === "password" ? "Afficher" : "Masquer");
        });
    }

    // =================================================================
    // SCROLL REVEAL — IntersectionObserver
    // =================================================================
    function initScrollReveal() {
        if (!window.IntersectionObserver) {
            document.querySelectorAll(".reveal, .reveal-left, .reveal-right, .reveal-scale")
                .forEach(function (el) { el.classList.add("visible"); });
            return;
        }
        var obs = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add("visible");
                    obs.unobserve(entry.target);
                }
            });
        }, { threshold: 0.08, rootMargin: "0px 0px -40px 0px" });
        document.querySelectorAll(".reveal, .reveal-left, .reveal-right, .reveal-scale")
            .forEach(function (el) { obs.observe(el); });
    }

    // =================================================================
    // SPINNER — helper overlay
    // =================================================================
    window.showSpinner = function (show) {
        var el = document.getElementById("app-spinner");
        if (!el && show) {
            el = document.createElement("div");
            el.id = "app-spinner";
            el.className = "overlay-spinner";
            el.innerHTML = '<div class="spinner"></div>';
            document.body.appendChild(el);
            requestAnimationFrame(function () { el.classList.add("active"); });
        } else if (el && !show) {
            el.classList.remove("active");
            setTimeout(function () { el.remove(); }, 200);
        } else if (el && show) {
            el.classList.add("active");
        }
    };

    function initAlertes() {
        document.querySelectorAll(".alerte").forEach(function (a) {
            a.addEventListener("click", function () {
                a.style.transition = "opacity 200ms ease, transform 200ms ease";
                a.style.opacity = "0";
                a.style.transform = "translateY(-6px)";
                window.setTimeout(function () { a.remove(); }, 200);
            });
            window.setTimeout(function () {
                if (a.parentElement) {
                    a.style.transition = "opacity 600ms ease, transform 600ms ease";
                    a.style.opacity = "0";
                    a.style.transform = "translateY(-10px)";
                    window.setTimeout(function () { a.remove(); }, 600);
                }
            }, 5000);
        });
    }

    function initGreeting() {
        var el = document.querySelector(".greeting");
        if (!el) return;
        var h = new Date().getHours();
        var msg = h < 12 ? "Bonjour" : h < 17 ? "Bon après-midi" : "Bonsoir";
        el.textContent = msg;
    }

    function initCharts() {
        if (window.bhcCharts && window.bhcCharts._dashboardInit) {
            window.bhcCharts._dashboardInit();
        }
    }

    function initSidebarToggle() {
        var btn = document.querySelector(".collapse-btn");
        var sidebar = document.querySelector(".sidebar");
        if (!btn || !sidebar) return;
        btn.addEventListener("click", function () {
            sidebar.classList.toggle("collapsed");
        });
    }

    function initCountUp() {
        document.querySelectorAll(".stat-box .valeur").forEach(function (el) {
            var texte = el.textContent.trim();
            var cible = parseInt(texte, 10);
            if (isNaN(cible) || cible === 0) return;
            el.textContent = "0";
            el.style.display = "inline-block";
            var duree = Math.min(800, 60 + cible * 10);
            var debut = performance.now();
            function animer(now) {
                var p = Math.min(1, (now - debut) / duree);
                p = 1 - Math.pow(1 - p, 3);
                el.textContent = Math.round(p * cible);
                if (p < 1) requestAnimationFrame(animer);
                else el.classList.add("count-up");
            }
            requestAnimationFrame(animer);
        });
    }

    function initPhoneInput() {
        var forms = document.querySelectorAll("form:not(.no-phone-merge)");
        forms.forEach(function (form) {
            var phoneInput = form.querySelector("#telephone");
            var indicatifSelect = form.querySelector("#indicatif");
            if (!phoneInput || !indicatifSelect) return;
            form.addEventListener("submit", function () {
                var code = indicatifSelect.value;
                var num = phoneInput.value.replace(/\s+/g, "").replace(/^0+/, "");
                if (num && !num.startsWith("+")) {
                    phoneInput.value = code + num;
                }
            });
        });
    }

    // =================================================================
    // ADRESSE CASCADE — Province / Commune / Zone (Burundi)
    // =================================================================
    var BURUNDI = {
        "Bubanza": {
            "Bubanza": ["Bubanza", "Gihanga", "Mpanda", "Musigati"],
            "Gihanga": ["Gihanga", "Mubanga", "Rugazi"],
            "Mpanda": ["Mpanda", "Kanyosha"],
            "Musigati": ["Musigati", "Bukeye", "Rwanzagira"]
        },
        "Bujumbura Mairie": {
            "Mukaza": ["Centre", "Buyenzi", "Bwiza", "Nyakabiga", "Rohero"],
            "Ntahangwa": ["Buterere", "Cibitoke", "Gihosha", "Kamenge", "Kinama", "Ngagara"],
            "Muha": ["Kanyosha", "Kinindo", "Musaga", "Nyakabiga"]
        },
        "Bujumbura Rural": {
            "Isale": ["Isale", "Kigwena", "Mubone", "Rugazi"],
            "Kabezi": ["Kabezi", "Mugongo", "Muhuta"],
            "Kanyosha": ["Kanyosha", "Gatumba", "Rukambura"],
            "Mutambu": ["Mutambu", "Muyira", "Rwibaga"]
        },
        "Bururi": {
            "Bururi": ["Bururi", "Kiremba", "Muhweza"],
            "Matana": ["Matana", "Kibimba", "Rutovu"],
            "Rumonge": ["Rumonge", "Bugarama", "Mugongo"],
            "Vyanda": ["Vyanda", "Kigwena", "Rubanga"]
        },
        "Cankuzo": {
            "Cankuzo": ["Cankuzo", "Cendajuru", "Rugerero"],
            "Cendajuru": ["Cendajuru", "Bweru", "Kinyovu"],
            "Gisagara": ["Gisagara", "Gisuru", "Kigamba"],
            "Kigamba": ["Kigamba", "Muhweza", "Rugazi"]
        },
        "Cibitoke": {
            "Buganda": ["Buganda", "Buhayira", "Mubone"],
            "Cibitoke": ["Cibitoke", "Mugina", "Murwi"],
            "Mabayi": ["Mabayi", "Bukinanyana", "Rugazi"],
            "Rugombo": ["Rugombo", "Gihungwe", "Mpanda"]
        },
        "Gitega": {
            "Gitega": ["Gitega", "Bugendana", "Rutegama"],
            "Bugendana": ["Bugendana", "Gihanga", "Murehe"],
            "Bukirasazi": ["Bukirasazi", "Mutaho", "Rwamiko"],
            "Mutaho": ["Mutaho", "Kinyinya", "Rugerero"],
            "Ryansoro": ["Ryansoro", "Gishubi", "Mubuga"]
        },
        "Karuzi": {
            "Karuzi": ["Karuzi", "Buhiga", "Gihogazi"],
            "Buhiga": ["Buhiga", "Mpanda", "Nyabikere"],
            "Gihogazi": ["Gihogazi", "Butezi", "Rwimbogo"],
            "Mutumba": ["Mutumba", "Gitaramuka", "Rugari"]
        },
        "Kayanza": {
            "Kayanza": ["Kayanza", "Butaganzwa", "Kabanga"],
            "Butaganzwa": ["Butaganzwa", "Gatara", "Muhanga"],
            "Gahombo": ["Gahombo", "Gisunzu", "Mubuga"],
            "Matongo": ["Matongo", "Kabuye", "Rugazi"],
            "Rango": ["Rango", "Gihoma", "Kigamba"]
        },
        "Kirundo": {
            "Kirundo": ["Kirundo", "Busoni", "Mugongo"],
            "Bugabira": ["Bugabira", "Buhiga", "Gitobe"],
            "Busoni": ["Busoni", "Bwambarangwe", "Mabayi"],
            "Muyinga": ["Muyinga", "Bucana", "Mugera"],
            "Ntega": ["Ntega", "Gusaba", "Mugimbu"]
        },
        "Makamba": {
            "Makamba": ["Makamba", "Kayogoro", "Vugizo"],
            "Kayogoro": ["Kayogoro", "Gihungwe", "Mishiha"],
            "Mabanda": ["Mabanda", "Kigwena", "Mubanga"],
            "Nyanza": ["Nyanza-Lac", "Kiremba", "Rutegama"],
            "Vugizo": ["Vugizo", "Kibago", "Mugongo"]
        },
        "Muramvya": {
            "Muramvya": ["Muramvya", "Bukeye", "Rutegama"],
            "Bukeye": ["Bukeye", "Mbuye", "Rugazi"],
            "Mbuye": ["Mbuye", "Rugazi", "Rwankuba"],
            "Rutegama": ["Rutegama", "Gashiha", "Muhweza"]
        },
        "Muyinga": {
            "Muyinga": ["Muyinga", "Buhinyuza", "Gasorwe"],
            "Buhinyuza": ["Buhinyuza", "Bweru", "Kiremba"],
            "Butihinda": ["Butihinda", "Giteranyi", "Muhweza"],
            "Gasorwe": ["Gasorwe", "Gishubi", "Rugari"],
            "Giteranyi": ["Giteranyi", "Muhanga", "Mukoni"]
        },
        "Mwaro": {
            "Mwaro": ["Mwaro", "Bisoro", "Rutegama"],
            "Bisoro": ["Bisoro", "Mbuye", "Murima"],
            "Gisozi": ["Gisozi", "Bukirasazi", "Mubuga"],
            "Kayokwe": ["Kayokwe", "Kibumbu", "Rugari"],
            "Nyabikere": ["Nyabikere", "Muhweza", "Rwanzagira"]
        },
        "Ngozi": {
            "Ngozi": ["Ngozi", "Busiga", "Mwumba"],
            "Busiga": ["Busiga", "Kiremba", "Rugari"],
            "Gashikanwa": ["Gashikanwa", "Mabayi", "Ruziba"],
            "Kiremba": ["Kiremba", "Butihinda", "Muhanga"],
            "Mwumba": ["Mwumba", "Buhiga", "Nyamurenza"]
        },
        "Rumonge": {
            "Rumonge": ["Rumonge", "Bugarama", "Mugongo"],
            "Bugarama": ["Bugarama", "Kigwena", "Rugazi"],
            "Buhinga": ["Buhinga", "Mubanga", "Muhuta"],
            "Muhuta": ["Muhuta", "Gihungwe", "Nyabikere"]
        },
        "Rutana": {
            "Rutana": ["Rutana", "Bukemba", "Mpinga"],
            "Bukemba": ["Bukemba", "Giharo", "Rugara"],
            "Giharo": ["Giharo", "Muhweza", "Rutovu"],
            "Mpinga": ["Mpinga", "Kigwena", "Musaga"],
            "Muyange": ["Muyange", "Bweru", "Gisuru"]
        },
        "Ruyigi": {
            "Ruyigi": ["Ruyigi", "Butaganzwa", "Kinyinya"],
            "Butaganzwa": ["Butaganzwa", "Gisuru", "Mubira"],
            "Bweru": ["Bweru", "Kiremba", "Rugari"],
            "Cankuzo": ["Cankuzo", "Buhinda", "Rwanzagira"],
            "Kinyinya": ["Kinyinya", "Muhanga", "Mukoni"]
        }
    };

    function peuplerSelect(el, options, placeholder) {
        el.innerHTML = "";
        var optPlaceholder = document.createElement("option");
        optPlaceholder.value = "";
        optPlaceholder.textContent = placeholder;
        el.appendChild(optPlaceholder);
        options.forEach(function (v) {
            var opt = document.createElement("option");
            opt.value = v;
            opt.textContent = v;
            el.appendChild(opt);
        });
    }

    function initAddressCascade() {
        var provinceEl = document.getElementById("province");
        var communeEl = document.getElementById("commune");
        var zoneEl = document.getElementById("zone");
        var adresseHidden = document.getElementById("adresse");
        var complementEl = document.getElementById("complementAdresse");
        if (!provinceEl || !communeEl || !zoneEl || !adresseHidden) return;

        // populate provinces
        peuplerSelect(provinceEl, Object.keys(BURUNDI).sort(), "— Province —");

        function onProvinceChange() {
            var prov = provinceEl.value;
            communeEl.innerHTML = "";
            zoneEl.innerHTML = "";
            if (!prov) {
                peuplerSelect(communeEl, [], "— Commune —");
                peuplerSelect(zoneEl, [], "— Zone —");
                return;
            }
            peuplerSelect(communeEl, Object.keys(BURUNDI[prov]).sort(), "— Commune —");
        }

        function onCommuneChange() {
            var prov = provinceEl.value;
            var comm = communeEl.value;
            if (!prov || !comm) {
                peuplerSelect(zoneEl, [], "— Zone —");
                return;
            }
            peuplerSelect(zoneEl, BURUNDI[prov][comm] || [], "— Zone —");
        }

        provinceEl.addEventListener("change", onProvinceChange);
        communeEl.addEventListener("change", onCommuneChange);

        // combine into hidden adresse field before submit
        var form = provinceEl.closest("form");
        if (form) {
            form.addEventListener("submit", function () {
                var parts = [];
                if (provinceEl.value) parts.push("Province: " + provinceEl.value);
                if (communeEl.value) parts.push("Commune: " + communeEl.value);
                if (zoneEl.value) parts.push("Zone: " + zoneEl.value);
                if (complementEl && complementEl.value.trim()) parts.push(complementEl.value.trim());
                adresseHidden.value = parts.join(", ");
            });
        }
    }

    function initToast() {
        var alertes = document.querySelectorAll(".alerte-succes");
        alertes.forEach(function (a, i) {
            if (a.closest(".auth-wrapper")) return;
            a.style.position = "fixed";
            a.style.top = (1 + i * 3.5) + "rem";
            a.style.right = "1rem";
            a.style.zIndex = "9999";
            a.style.minWidth = "280px";
            a.style.borderRadius = "var(--radius)";
            a.style.boxShadow = "0 8px 24px rgba(0,0,0,0.12)";
            a.style.animation = "fade-in-up 400ms var(--ease-water) forwards";
        });
    }

    // =================================================================
    // CHART UTILITIES — Canvas API pure, zéro dépendance
    // =================================================================

    function hexToRgba(hex, a) {
        var r = parseInt(hex.slice(1,3), 16);
        var g = parseInt(hex.slice(3,5), 16);
        var b = parseInt(hex.slice(5,7), 16);
        return "rgba(" + r + "," + g + "," + b + "," + a + ")";
    }

    function drawBarChart(canvasId, labels, data, color) {
        var canvas = document.getElementById(canvasId);
        if (!canvas) return;
        var ctx = canvas.getContext("2d");
        var dpr = window.devicePixelRatio || 1;
        var rect = canvas.parentElement.getBoundingClientRect();
        var W = rect.width;
        var H = 180;
        canvas.width = W * dpr;
        canvas.height = H * dpr;
        canvas.style.width = W + "px";
        canvas.style.height = H + "px";
        ctx.scale(dpr, dpr);

        var max = Math.max(1, Math.max.apply(null, data));
        var pad = { t: 10, b: 20, l: 10, r: 10 };
        var cw = W - pad.l - pad.r;
        var ch = H - pad.t - pad.b;
        var bw = Math.min(40, (cw / data.length) * 0.6);
        var gap = (cw - bw * data.length) / (data.length + 1);

        ctx.clearRect(0, 0, W, H);
        data.forEach(function (v, i) {
            var x = pad.l + gap + i * (bw + gap);
            var h = (v / max) * ch;
            var y = pad.t + ch - h;
            var grad = ctx.createLinearGradient(x, y, x, pad.t + ch);
            grad.addColorStop(0, color);
            grad.addColorStop(1, hexToRgba(color, 0.3));
            ctx.fillStyle = grad;
            ctx.beginPath();
            ctx.moveTo(x + 3, y);
            ctx.lineTo(x + bw - 3, y);
            ctx.quadraticCurveTo(x + bw, y, x + bw, y + 3);
            ctx.lineTo(x + bw, y + h);
            ctx.lineTo(x, y + h);
            ctx.lineTo(x, y + 3);
            ctx.quadraticCurveTo(x, y, x + 3, y);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue("--text-muted").trim() || "#78716c";
            ctx.font = "10px sans-serif";
            ctx.textAlign = "center";
            ctx.fillText(labels[i], x + bw / 2, pad.t + ch + 14);
        });
    }

    function drawDoughnutChart(canvasId, labels, data, colors) {
        var canvas = document.getElementById(canvasId);
        if (!canvas) return;
        var ctx = canvas.getContext("2d");
        var dpr = window.devicePixelRatio || 1;
        var size = Math.min(180, canvas.parentElement.clientWidth || 180);
        canvas.width = size * dpr;
        canvas.height = size * dpr;
        canvas.style.width = size + "px";
        canvas.style.height = size + "px";
        ctx.scale(dpr, dpr);

        var cx = size / 2, cy = size / 2, r = size * 0.35, ep = size * 0.12;
        var total = data.reduce(function (a, b) { return a + b; }, 0);
        if (total === 0) return;
        var angles = [];
        data.forEach(function (v) { angles.push((v / total) * Math.PI * 2); });
        var start = -Math.PI / 2;
        ctx.clearRect(0, 0, size, size);
        angles.forEach(function (a, i) {
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + a);
            ctx.arc(cx, cy, r - ep, start + a, start, true);
            ctx.closePath();
            ctx.fillStyle = colors[i % colors.length];
            ctx.fill();
            start += a;
        });
        // centre
        ctx.beginPath();
        ctx.arc(cx, cy, r - ep - 2, 0, Math.PI * 2);
        ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue("--bg-elevated").trim() || "#fff";
        ctx.fill();
    }

    function drawLineChart(canvasId, labels, data, color) {
        var canvas = document.getElementById(canvasId);
        if (!canvas) return;
        var ctx = canvas.getContext("2d");
        var dpr = window.devicePixelRatio || 1;
        var rect = canvas.parentElement.getBoundingClientRect();
        var W = rect.width;
        var H = 180;
        canvas.width = W * dpr;
        canvas.height = H * dpr;
        canvas.style.width = W + "px";
        canvas.style.height = H + "px";
        ctx.scale(dpr, dpr);

        var max = Math.max(1, Math.max.apply(null, data));
        var pad = { t: 10, b: 20, l: 10, r: 10 };
        var cw = W - pad.l - pad.r;
        var ch = H - pad.t - pad.b;
        var step = cw / Math.max(1, data.length - 1);

        ctx.clearRect(0, 0, W, H);
        ctx.beginPath();
        var points = data.map(function (v, i) {
            return { x: pad.l + i * step, y: pad.t + ch - (v / max) * ch };
        });
        points.forEach(function (p, i) {
            if (i === 0) ctx.moveTo(p.x, p.y);
            else ctx.lineTo(p.x, p.y);
        });
        ctx.strokeStyle = color;
        ctx.lineWidth = 2.5;
        ctx.lineJoin = "round";
        ctx.stroke();

        // fill
        ctx.lineTo(points[points.length - 1].x, pad.t + ch);
        ctx.lineTo(points[0].x, pad.t + ch);
        ctx.closePath();
        var grad = ctx.createLinearGradient(0, pad.t, 0, pad.t + ch);
        grad.addColorStop(0, hexToRgba(color, 0.15));
        grad.addColorStop(1, hexToRgba(color, 0.01));
        ctx.fillStyle = grad;
        ctx.fill();

        // dots
        points.forEach(function (p) {
            ctx.beginPath();
            ctx.arc(p.x, p.y, 3, 0, Math.PI * 2);
            ctx.fillStyle = color;
            ctx.fill();
            ctx.strokeStyle = getComputedStyle(document.documentElement).getPropertyValue("--bg-elevated").trim() || "#fff";
            ctx.lineWidth = 2;
            ctx.stroke();
        });

        ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue("--text-muted").trim() || "#78716c";
        ctx.font = "10px sans-serif";
        ctx.textAlign = "center";
        data.forEach(function (v, i) {
            ctx.fillText(labels[i], pad.l + i * step, pad.t + ch + 14);
        });
    }

    // =================================================================
    // INIT CHARTS — appelé par chaque dashboard
    // =================================================================
    window.bhcCharts = {
        bar: drawBarChart,
        doughnut: drawDoughnutChart,
        line: drawLineChart,
        initCountUp: initCountUp
    };

    // =================================================================
    // INIT GÉNÉRALE
    // =================================================================
    document.addEventListener("DOMContentLoaded", function () {
        initThemeToggle();
        initRipple();
        initEntreeEnCascade();
        initPasswordToggle();
        initAlertes();
        initGreeting();
        initSidebarToggle();
        initCountUp();
        initPhoneInput();
        initAddressCascade();
        initScrollReveal();
        initToast();
        initCharts();
    });
})();
