(function () {
    "use strict";

    var THEME_KEY = "bhc-theme";

    function appliquerTheme(theme) {
        document.documentElement.setAttribute("data-theme", theme);
    }

    window.toggleTheme = function () {
        var actuel = document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light";
        var nouveau = actuel === "dark" ? "light" : "dark";
        appliquerTheme(nouveau);
        try { localStorage.setItem(THEME_KEY, nouveau); } catch (e) {}
        var btn = document.querySelector(".theme-toggle");
        if (btn) {
            btn.style.transform = "rotate(360deg)";
            setTimeout(function () { btn.style.transform = ""; }, 300);
        }
    };

    function init() {
        var saved = null;
        try { saved = localStorage.getItem(THEME_KEY); } catch (e) {}
        if (saved) appliquerTheme(saved);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
