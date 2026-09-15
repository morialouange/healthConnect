package com.burundihealthconnect.servlet;

import com.burundihealthconnect.exception.BusinessException;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.regex.Pattern;

/**
 * Méthodes utilitaires partagées par toutes les servlets.
 * Regroupe la duplication qui existait en copier-coller dans les 7 servlets.
 */
public final class ServletUtils {

    private ServletUtils() {
    }

    // =============================================================
    // Constantes
    // =============================================================

    public static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    public static final int MAX_LENGTH = 100;

    public static final int TAILLE_PAGE = 10;

    // =============================================================
    // Forward / Redirect
    // =============================================================

    /**
     * Transmet la requête à une JSP (forward server-side).
     */
    public static void forward(HttpServletRequest request, HttpServletResponse response,
                               String vue) throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher(vue);
        dispatcher.forward(request, response);
    }

    /**
     * Redirige vers l'URL donnée avec un paramètre "erreur" encodé.
     */
    public static void redirigerAvecErreur(HttpServletRequest request,
                                            HttpServletResponse response,
                                            String url,
                                            String message) throws IOException {
        response.sendRedirect(request.getContextPath() + url
                + "?erreur=" + URLEncoder.encode(message, StandardCharsets.UTF_8));
    }

    // =============================================================
    // i18n
    // =============================================================

    /**
     * Retourne la traduction d'une clé dans le bundle i18n de l'application.
     */
    public static String message(HttpServletRequest request, String key) {
        String lang = (String) request.getSession().getAttribute("langue");
        if (lang == null) lang = "fr";
        Locale locale = Locale.forLanguageTag(lang);
        ResourceBundle bundle = ResourceBundle.getBundle(
                "com.burundihealthconnect.i18n.messages", locale);
        return bundle.getString(key);
    }

    // =============================================================
    // Validation
    // =============================================================

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }

    public static boolean isValidTelephone(String telephone) {
        return telephone == null || telephone.isBlank()
                || telephone.replaceAll("[^0-9]", "").length() >= 8
                && telephone.replaceAll("[^0-9]", "").length() <= 15;
    }

    public static boolean isValidMaxLength(String valeur, int max) {
        return valeur == null || valeur.length() <= max;
    }

    public static boolean isExperienceValide(String experienceStr) {
        if (experienceStr == null || experienceStr.isBlank()) return true;
        try {
            return Integer.parseInt(experienceStr.replaceAll("[^0-9\\-]", "")) >= 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Extrait un paramètre de requête. Si absent ou vide, lève une {@link BusinessException}.
     */
    public static String champRequis(HttpServletRequest request, String nom) {
        String valeur = request.getParameter(nom);
        if (valeur == null || valeur.isBlank()) {
            throw new BusinessException("Le champ '" + nom + "' est obligatoire.");
        }
        return valeur;
    }

    /**
     * Retourne {@code null} si la valeur est vide/blank, sinon la valeur trimée.
     */
    public static String videSiVide(String valeur) {
        return (valeur == null || valeur.isBlank()) ? null : valeur.trim();
    }

    // =============================================================
    // Parsing sécurisé
    // =============================================================

    /**
     * Parse une chaîne en {@link Long}, ou retourne {@code null} en cas d'échec / valeur vide.
     */
    public static Long parseLongOuNull(String valeur) {
        try {
            return (valeur == null || valeur.isBlank()) ? null : Long.parseLong(valeur);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Parse une chaîne en {@code int}, ou retourne 0 en cas d'échec / valeur vide.
     */
    public static int parseIntOuZero(String valeur) {
        Integer n = parseIntOuNull(valeur);
        return (n != null) ? n : 0;
    }

    /**
     * Parse une chaîne en {@link Integer}, ou retourne {@code null} en cas d'échec / valeur vide.
     */
    public static Integer parseIntOuNull(String valeur) {
        try {
            return (valeur == null || valeur.isBlank()) ? null : Integer.parseInt(valeur);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
