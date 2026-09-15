package com.burundihealthconnect.filter;

import com.burundihealthconnect.ejb.NotificationService;
import com.burundihealthconnect.entity.enums.Role;
import com.burundihealthconnect.util.SessionKeys;

import jakarta.inject.Inject;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * FiltreSecurite — @WebFilter("/*") appliqué sur TOUTE l'application.
 * Quatre responsabilités, dans cet ordre strict :
 *   0. Protection CSRF (jeton de session validé sur toute requête modifiante)
 *   1. Laisser passer les ressources publiques (login, register, assets statiques)
 *   2. Vérifier qu'une HttpSession valide existe — sinon redirection /auth
 *   3. Vérifier profil_complete — sinon redirection /profil/completer
 *   4. Vérifier que le rôle de l'utilisateur correspond au préfixe d'URL
 *      demandé (ex. /admin/* exige Role.ADMIN) — sinon 403
 */
@WebFilter("/*")
public class FiltreSecurite implements Filter {

    /** Attribut de requête lu par les vues JSP pour afficher le rôle courant. */
    private static final String ATTRIBUT_ROLE_CODE = "roleCode";

    @Inject
    private NotificationService notificationService;

    /** URLs accessibles SANS connexion (page de login/register + ressources statiques). */
    private static final String[] URLS_PUBLIQUES = {
            "/auth", "/index.jsp", "/css/", "/js/", "/images/", "/resources/"
    };

    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String chemin = uri.substring(contextPath.length()); // ex: /admin/dashboard

        // 0) PROTECTION CSRF — vaut aussi pour les pages publiques (login/register)
        if (!estRessourceStatique(chemin)) {
            if (estMethodeModifiante(request.getMethod())) {
                if (!validerTokenCSRF(request)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN,
                            "Jeton de sécurité invalide ou expiré. Rechargez la page puis réessayez.");
                    return;
                }
            }
            // Le jeton est exposé à la vue (meta name="csrf-token") pour toutes
            // les pages non statiques, y compris lors d'un re-rendu après erreur.
            request.setAttribute(SessionKeys.CSRF_TOKEN, assurerTokenCSRF(request));
        }

        // 1) RESSOURCES PUBLIQUES — on laisse passer sans authentification
        if (estUrlPublique(chemin)) {
            chain.doFilter(req, res);
            return;
        }

        // 2) SESSION VALIDE ?
        HttpSession session = request.getSession(false);
        Long idUtilisateur = (session != null) ? (Long) session.getAttribute(SessionKeys.ID_UTILISATEUR) : null;

        if (idUtilisateur == null) {
            response.sendRedirect(contextPath + "/auth");
            return;
        }

        Role role = (Role) session.getAttribute(SessionKeys.ROLE);
        Boolean profilComplete = (Boolean) session.getAttribute(SessionKeys.PROFIL_COMPLETE);

// Les comparaisons et les clÃ©s i18n des JSP doivent utiliser une chaÃ®ne,
        // pas l'objet Enum placÃ© en session pour les contrÃ´les de sÃ©curitÃ©.
        request.setAttribute(ATTRIBUT_ROLE_CODE, role != null ? role.name() : "");

        // Salutation contextuelle (matin / après-midi / soir) pour l'en-tête des pages.
        // Calculée ici (couche métier/sécurité, Java autorisé) plutôt que dans la JSP
        // afin de respecter la règle « zéro scriptlet » imposée par le cahier des charges.
        int heure = java.time.LocalTime.now().getHour();
        request.setAttribute("salutationCle",
                heure < 12 ? "greeting.morning" : (heure < 17 ? "greeting.afternoon" : "greeting.evening"));

        // 3) PROFIL COMPLETE ?
        boolean profilRequis = (role == Role.PATIENT || role == Role.MEDECIN);
        boolean cheminCompletion = chemin.startsWith("/profil/completer");

        if (profilRequis && !Boolean.TRUE.equals(profilComplete) && !cheminCompletion) {
            response.sendRedirect(contextPath + "/profil/completer");
            return;
        }

        // 4) CONTROLE DE ROLE SELON LE PREFIXE D'URL
        if (!roleAutorisePourChemin(role, chemin)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Accès refusé : votre rôle ne permet pas d'accéder à cette ressource.");
            return;
        }

        // L17 — Badge notifications non lues dans la sidebar
        try {
            long notifCount = notificationService.countNonLues(idUtilisateur);
            request.setAttribute("notifNonLues", notifCount);
        } catch (Exception e) {
            request.setAttribute("notifNonLues", 0L);
        }

        chain.doFilter(req, res);
    }

    private boolean estUrlPublique(String chemin) {
        // La racine exacte de l'application ("/") est publique : welcome-file vers index.jsp.
        if (chemin.isEmpty() || "/".equals(chemin)) {
            return true;
        }
        for (String url : URLS_PUBLIQUES) {
            if (chemin.equals(url) || (url.endsWith("/") && chemin.startsWith(url))) {
                return true;
            }
        }
        return false;
    }

    /** Ressources statiques (CSS/JS/images) : inutile de les protéger ou d'exposer un jeton. */
    private boolean estRessourceStatique(String chemin) {
        return chemin.startsWith("/css/") || chemin.startsWith("/js/") || chemin.startsWith("/images/") || chemin.startsWith("/resources/");
    }

    /** Méthodes HTTP qui modifient l'état du serveur et doivent donc être protégées. */
    private boolean estMethodeModifiante(String methode) {
        return "POST".equals(methode) || "PUT".equals(methode)
                || "PATCH".equals(methode) || "DELETE".equals(methode);
    }

    /** Récupère le jeton CSRF de la session, ou en génère un nouveau si absent. */
    private String assurerTokenCSRF(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        String token = (String) session.getAttribute(SessionKeys.CSRF_TOKEN);
        if (token == null || token.isBlank()) {
            byte[] octets = new byte[32];
            RANDOM.nextBytes(octets);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(octets);
            session.setAttribute(SessionKeys.CSRF_TOKEN, token);
        }
        return token;
    }

    /** Valide le jeton envoyé par le formulaire contre celui de la session (comparaison temps constant). */
    private boolean validerTokenCSRF(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        String sessionToken = (String) session.getAttribute(SessionKeys.CSRF_TOKEN);
        String requestToken = request.getParameter(SessionKeys.CSRF_TOKEN);
        if (sessionToken == null || requestToken == null) {
            return false;
        }
        return MessageDigest.isEqual(
                sessionToken.getBytes(StandardCharsets.UTF_8),
                requestToken.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Vérifie que le rôle en session correspond au préfixe d'URL demandé.
     * /profil/* est accessible par TOUS les rôles authentifiés.
     */
    private boolean roleAutorisePourChemin(Role role, String chemin) {
        if (chemin.startsWith("/patient/")) {
            return role == Role.PATIENT;
        }
        if (chemin.startsWith("/medecin/")) {
            return role == Role.MEDECIN;
        }
        if (chemin.startsWith("/admin/")) {
            return role == Role.ADMIN;
        }
        if (chemin.startsWith("/superadmin/")) {
            return role == Role.SUPER_ADMIN;
        }
        // /profil/* et toute autre URL non préfixée : accessible à tout utilisateur connecté
        return true;
    }
}
