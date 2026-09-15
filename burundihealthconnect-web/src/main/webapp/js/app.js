(function () {
    "use strict";

    var THEME_KEY = "mc-theme";
    var SIDEBAR_KEY = "mc-sidebar-collapsed";

    function mettreAJourIconeTheme() {
        var sombre = document.documentElement.getAttribute("data-theme") === "dark";
        document.querySelectorAll("[data-theme-toggle] .theme-icon").forEach(function (icone) {
            icone.textContent = sombre ? "\u2600" : "\u263E";
        });
    }

    function appliquerTheme(theme) {
        document.documentElement.setAttribute("data-theme", theme);
        mettreAJourIconeTheme();
    }

    function basculerTheme() {
        var actuel = document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light";
        var nouveau = actuel === "dark" ? "light" : "dark";
        appliquerTheme(nouveau);
        try { localStorage.setItem(THEME_KEY, nouveau); } catch (e) { }
    }

    function initThemeToggle() {
        var bouton = document.querySelector("[data-theme-toggle]");
        if (bouton) bouton.addEventListener("click", basculerTheme);
    }

    function appliquerEtatTiroir(sidebar, ouvert) {
        var backdrop = document.querySelector(".sidebar-backdrop");
        sidebar.classList.toggle("open", ouvert);
        if (backdrop) backdrop.classList.toggle("open", ouvert);
        document.body.classList.toggle("sidebar-lock", ouvert);
    }

    function mettreAJourIconeSidebar(collapsed) {
        var btn = document.querySelector(".sidebar-toggle-btn, .collapse-btn");
        if (!btn) return;
        var icone = btn.querySelector("[data-lucide]");
        if (!icone) return;
        icone.setAttribute("data-lucide", collapsed ? "panel-left-open" : "panel-left-close");
        if (typeof lucide !== "undefined" && lucide.createIcons) {
            // Ré-initialisation SANS attributs personnalisés : les valeurs par
            // défaut de lucide (stroke-width 2, classes .lucide/.icon) sont
            // conservées. Passer attrs={"stroke-width":0} rendait les icônes
            // invisibles après le premier clic sur le chevron.
            lucide.createIcons();
        }
    }

    function initSidebarToggle() {
        var sidebar = document.querySelector(".sidebar");
        var btn = document.querySelector(".sidebar-toggle-btn");
        var appShell = document.querySelector(".app-shell");
        if (!sidebar || !appShell) return;

        var mobileQuery = window.matchMedia("(max-width: 960px)");
        var drawerOuvert = false;

        function fermerTiroir() { if (drawerOuvert) { drawerOuvert = false; appliquerEtatTiroir(sidebar, false); } }

        function appliquerCollapse(collapsed) {
            appShell.classList.toggle("collapsed", collapsed);
            mettreAJourIconeSidebar(collapsed);
            gererTooltipsRepli(collapsed);
        }

        function gererTooltipsRepli(collapsed) {
            document.querySelectorAll(".sidebar .sidebar-item").forEach(function (lien) {
                if (collapsed) {
                    var libelle = lien.getAttribute("aria-label");
                    if (libelle) lien.setAttribute("title", libelle);
                } else {
                    lien.removeAttribute("title");
                }
            });
        }

        function relierFermetures() {
            var backdrop = document.querySelector(".sidebar-backdrop");
            if (backdrop) backdrop.addEventListener("click", fermerTiroir);
            var closeBtn = document.querySelector(".sidebar-close");
            if (closeBtn) closeBtn.addEventListener("click", fermerTiroir);
            document.querySelectorAll(".sidebar nav a").forEach(function (lien) {
                lien.addEventListener("click", fermerTiroir);
            });
            document.addEventListener("keydown", function (e) {
                if (e.key === "Escape") fermerTiroir();
            });
        }

        if (btn) {
            btn.addEventListener("click", function () {
                if (mobileQuery.matches) {
                    drawerOuvert = !drawerOuvert;
                    appliquerEtatTiroir(sidebar, drawerOuvert);
                } else {
                    var estReplie = !appShell.classList.contains("collapsed");
                    appliquerCollapse(estReplie);
                    try { localStorage.setItem(SIDEBAR_KEY, estReplie ? "1" : "0"); } catch (e) { }
                }
            });
        }

        try {
            if (localStorage.getItem(SIDEBAR_KEY) === "1") {
                appliquerCollapse(true);
            } else {
                mettreAJourIconeSidebar(false);
            }
        } catch (e) { }

        mobileQuery.addEventListener("change", function (e) {
            if (!e.matches) {
                fermerTiroir();
                var memorise = false;
                try { memorise = localStorage.getItem(SIDEBAR_KEY) === "1"; } catch (er) { }
                appliquerCollapse(memorise);
            }
        });

        relierFermetures();
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

    function initCsrf() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        if (!meta) return;
        var token = meta.getAttribute("content");
        if (!token) return;
        document.querySelectorAll('form[method="post"]').forEach(function (form) {
            var input = document.createElement("input");
            input.type = "hidden";
            input.name = "csrfToken";
            input.value = token;
            form.appendChild(input);
        });
    }

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

    function initLangToggle() {
        var boutons = document.querySelectorAll("#lang-toggle");
        if (!boutons.length) return;
        var actuelle = (document.documentElement.getAttribute("lang") || "fr").toLowerCase();
        var cible = actuelle === "fr" ? "en" : "fr";
        var libelle = cible === "fr" ? "FR" : "EN";
        boutons.forEach(function (btn) {
            btn.querySelectorAll(".lang-label").forEach(function (l) { l.textContent = libelle; });
            btn.addEventListener("click", function () {
                var url = new URL(window.location.href);
                url.searchParams.set("lang", cible);
                window.location.href = url.pathname + url.search + url.hash;
            });
        });
    }

    window.confirmApp = function (el, evt, message) {
        if (evt) evt.preventDefault();
        var executer = function () {
            if (!el) return;
            if (el.tagName === "A") { window.location.href = el.getAttribute("href"); }
            else { var f = el.closest("form"); if (f) f.submit(); }
        };
        var backdrop = document.getElementById("confirm-backdrop");
        if (!backdrop) { executer(); return false; }
        var msgEl = document.getElementById("confirm-message");
        if (msgEl) msgEl.textContent = message;
        backdrop.classList.add("open");
        var okBtn = document.getElementById("confirm-ok");
        var cancelBtn = document.getElementById("confirm-cancel");
        if (okBtn) {
            okBtn.focus();
            okBtn.onclick = function () { backdrop.classList.remove("open"); executer(); };
        }
        if (cancelBtn) cancelBtn.onclick = function () { backdrop.classList.remove("open"); };
        backdrop.onclick = function (e) { if (e.target === backdrop) backdrop.classList.remove("open"); };
        return false;
    };

    function initConfirmDialog() {
        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape") {
                var b = document.getElementById("confirm-backdrop");
                if (b) b.classList.remove("open");
            }
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

    function initAuthSubmit() {
        document.querySelectorAll(".auth-submit").forEach(function (btn) {
            var form = btn.closest("form");
            if (!form) return;
            form.addEventListener("submit", function () {
                if (form.checkValidity() && !btn.classList.contains("is-loading")) {
                    btn.classList.add("is-loading");
                    var spinner = document.createElement("span");
                    spinner.className = "btn-spinner";
                    spinner.setAttribute("aria-hidden", "true");
                    btn.insertBefore(spinner, btn.firstChild);
                }
            });
        });
    }

    function initAddressCascade() {
        var provinceEl = document.getElementById("province");
        var communeEl = document.getElementById("commune");
        var zoneEl = document.getElementById("zone");
        var adresseHidden = document.getElementById("adresse");
        var complementEl = document.getElementById("complementAdresse");
        if (!provinceEl || !communeEl || !zoneEl || !adresseHidden) return;

        peuplerSelect(provinceEl, Object.keys(BURUNDI).sort(), "\u2014 Province \u2014");

        function onProvinceChange() {
            var prov = provinceEl.value;
            communeEl.innerHTML = "";
            zoneEl.innerHTML = "";
            if (!prov) {
                peuplerSelect(communeEl, [], "\u2014 Commune \u2014");
                peuplerSelect(zoneEl, [], "\u2014 Zone \u2014");
                return;
            }
            peuplerSelect(communeEl, Object.keys(BURUNDI[prov]).sort(), "\u2014 Commune \u2014");
        }

        function onCommuneChange() {
            var prov = provinceEl.value;
            var comm = communeEl.value;
            if (!prov || !comm) {
                peuplerSelect(zoneEl, [], "\u2014 Zone \u2014");
                return;
            }
            peuplerSelect(zoneEl, BURUNDI[prov][comm] || [], "\u2014 Zone \u2014");
        }

        provinceEl.addEventListener("change", onProvinceChange);
        communeEl.addEventListener("change", onCommuneChange);

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

    // =================================================================
    // INIT GENERALE
    // =================================================================
    document.addEventListener("DOMContentLoaded", function () {
        initCsrf();
        initThemeToggle();
        initSidebarToggle();
        initPasswordToggle();
        initAlertes();
        initLangToggle();
        initConfirmDialog();
        initPhoneInput();
        initAuthSubmit();
        initAddressCascade();
    });
})();
