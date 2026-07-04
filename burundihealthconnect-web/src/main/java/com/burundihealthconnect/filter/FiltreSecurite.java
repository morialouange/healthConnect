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

/**
 * FiltreSecurite — @WebFilter("/*") appliqué sur TOUTE l'application.
 * Trois responsabilités, dans cet ordre strict :
 *   1. Laisser passer les ressources publiques (login, register, assets statiques)
 *   2. Vérifier qu'une HttpSession valide existe — sinon redirection /auth
 *   3. Vérifier profil_complete — sinon redirection /profil/completer
 *   4. Vérifier que le rôle de l'utilisateur correspond au préfixe d'URL
 *      demandé (ex. /admin/* exige Role.ADMIN) — sinon 403
 */
@WebFilter("/*")
public class FiltreSecurite implements Filter {

    @Inject
    private NotificationService notificationService;

    /** URLs accessibles SANS connexion (page de login/register + ressources statiques). */
    private static final String[] URLS_PUBLIQUES = {
            "/auth", "/index.jsp", "/", "/css/", "/js/", "/images/"
    };

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String chemin = uri.substring(contextPath.length()); // ex: /admin/dashboard

        // 1) RESSOURCES PUBLIQUES — on laisse passer sans vérification
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
        for (String url : URLS_PUBLIQUES) {
            if (chemin.equals(url) || (url.endsWith("/") && chemin.startsWith(url))) {
                return true;
            }
        }
        return false;
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