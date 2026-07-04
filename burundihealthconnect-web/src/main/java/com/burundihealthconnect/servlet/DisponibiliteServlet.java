package com.burundihealthconnect.servlet;

import com.burundihealthconnect.ejb.DisponibiliteService;
import com.burundihealthconnect.exception.BusinessException;
import com.burundihealthconnect.util.SessionKeys;

import jakarta.inject.Inject;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * DisponibiliteServlet — @WebServlet("/medecin/disponibilite/*")
 * Routes :
 *   GET  /medecin/disponibilite/mes-semaines  -> liste les semaines déclarées (L14)
 *   POST /medecin/disponibilite/declarer      -> déclare une nouvelle semaine (L14)
 *   POST /medecin/disponibilite/supprimer     -> supprime un créneau encore libre
 *   POST /medecin/disponibilite/copier        -> copie une semaine vers la suivante
 */
@WebServlet("/medecin/disponibilite/*")
public class DisponibiliteServlet extends HttpServlet {

    @Inject
    private DisponibiliteService disponibiliteService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/auth");
            return;
        }
        Long idMedecin = (Long) session.getAttribute(SessionKeys.ID_MEDECIN);

        if (pathInfo == null || "/mes-semaines".equals(pathInfo)) {
            int page = 0;
            request.setAttribute("semaines", disponibiliteService.getMesSemaines(idMedecin, page));
            request.setAttribute("page", page);
            forward(request, response, "/WEB-INF/views/medecin/disponibilite.jsp");
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/auth");
            return;
        }
        Long idMedecin = (Long) session.getAttribute(SessionKeys.ID_MEDECIN);
        Long idEtablissement = (Long) session.getAttribute(SessionKeys.ID_ETABLISSEMENT);

        if ("/declarer".equals(pathInfo)) {
            traiterDeclarerSemaine(request, response, idMedecin, idEtablissement);
        } else if ("/supprimer".equals(pathInfo)) {
            traiterSupprimerCreneau(request, response, idMedecin);
        } else if ("/copier".equals(pathInfo)) {
            traiterCopierSemaine(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================
    // DECLARATION DE SEMAINE — L14
    // =========================================================

    private void traiterDeclarerSemaine(HttpServletRequest request, HttpServletResponse response,
                                         Long idMedecin, Long idEtablissement)
            throws ServletException, IOException {

        String dateDebutStr = request.getParameter("dateDebutSemaine");
        String dureeStr = request.getParameter("dureeCreneauMin");
        String[] joursStr = request.getParameterValues("joursTravailles");

        if (dateDebutStr == null || dureeStr == null || joursStr == null || joursStr.length == 0) {
            redirigerAvecErreur(request, response,
                    "Veuillez remplir tous les champs et choisir au moins un jour travaillé.");
            return;
        }

        try {
            LocalDate dateDebutSemaine = LocalDate.parse(dateDebutStr);
            int dureeCreneauMin = Integer.parseInt(dureeStr);
            if (dureeCreneauMin <= 0) {
                redirigerAvecErreur(request, response, "La durée du créneau doit être positive.");
                return;
            }

            Map<DayOfWeek, LocalTime[]> plagesHoraires = new HashMap<>();
            for (String jour : joursStr) {
                DayOfWeek day = DayOfWeek.valueOf(jour);
                String heureDebut = request.getParameter("heureDebut_" + jour);
                String heureFin = request.getParameter("heureFin_" + jour);
                if (heureDebut == null || heureFin == null) {
                    redirigerAvecErreur(request, response,
                            "Plage horaire manquante pour " + traduireJour(day) + ".");
                    return;
                }
                LocalTime debut = LocalTime.parse(heureDebut);
                LocalTime fin = LocalTime.parse(heureFin);
                if (!debut.isBefore(fin)) {
                    redirigerAvecErreur(request, response,
                            "L'heure de fin doit être après l'heure de début pour " + traduireJour(day) + ".");
                    return;
                }
                plagesHoraires.put(day, new LocalTime[]{debut, fin});
            }

            disponibiliteService.declarerSemaine(idMedecin, idEtablissement, dateDebutSemaine,
                    dureeCreneauMin, plagesHoraires);

            response.sendRedirect(request.getContextPath() + "/medecin/disponibilite/mes-semaines?succes=1");

        } catch (BusinessException | IllegalArgumentException
                | java.time.format.DateTimeParseException e) {
            redirigerAvecErreur(request, response, "Données invalides : " + e.getMessage());
        }
    }

    private String traduireJour(DayOfWeek day) {
        switch (day) {
            case MONDAY:    return "Lundi";
            case TUESDAY:   return "Mardi";
            case WEDNESDAY: return "Mercredi";
            case THURSDAY:  return "Jeudi";
            case FRIDAY:    return "Vendredi";
            case SATURDAY:  return "Samedi";
            case SUNDAY:    return "Dimanche";
            default:        return day.name();
        }
    }

    // =========================================================
    // SUPPRESSION CRENEAU
    // =========================================================

    private void traiterSupprimerCreneau(HttpServletRequest request, HttpServletResponse response, Long idMedecin)
            throws IOException {
        Long idCreneau = parseLongOuNull(request.getParameter("idCreneau"));
        if (idCreneau == null) {
            redirigerAvecErreur(request, response, "Créneau introuvable.");
            return;
        }
        try {
            disponibiliteService.supprimerCreneau(idCreneau, idMedecin);
            response.sendRedirect(request.getContextPath() + "/medecin/disponibilite/mes-semaines?succes=1");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, e.getMessage());
        }
    }

    // =========================================================
    // COPIE DE SEMAINE
    // =========================================================

    private void traiterCopierSemaine(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Long idDisponibilite = parseLongOuNull(request.getParameter("idDisponibilite"));
        if (idDisponibilite == null) {
            redirigerAvecErreur(request, response, "Semaine introuvable.");
            return;
        }
        try {
            disponibiliteService.copierSemaineSuivante(idDisponibilite);
            response.sendRedirect(request.getContextPath() + "/medecin/disponibilite/mes-semaines?succes=1");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, e.getMessage());
        }
    }

    // =========================================================
    // VALIDATION
    // =========================================================

    private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final int MAX_LENGTH = 100;

    private boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }

    private boolean isValidTelephone(String telephone) {
        return telephone == null || telephone.isBlank() || telephone.replaceAll("[^0-9]", "").length() >= 8
            && telephone.replaceAll("[^0-9]", "").length() <= 15;
    }

    private boolean isValidMaxLength(String valeur, int max) {
        return valeur == null || valeur.length() <= max;
    }

    private boolean isExperienceValide(String experienceStr) {
        if (experienceStr == null || experienceStr.isBlank()) return true;
        try {
            return Integer.parseInt(experienceStr.replaceAll("[^0-9\\-]", "")) >= 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    // =========================================================
    // UTILITAIRES
    // =========================================================

    private void redirigerAvecErreur(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/medecin/disponibilite/mes-semaines?erreur="
                + java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
    }

    private Long parseLongOuNull(String valeur) {
        try {
            return (valeur == null || valeur.isBlank()) ? null : Long.parseLong(valeur);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String message(HttpServletRequest request, String key) {
        String lang = (String) request.getSession().getAttribute("langue");
        if (lang == null) lang = "fr";
        Locale locale = Locale.forLanguageTag(lang);
        java.util.ResourceBundle bundle = java.util.ResourceBundle.getBundle("com.burundihealthconnect.i18n.messages", locale);
        return bundle.getString(key);
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String vue)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher(vue);
        dispatcher.forward(request, response);
    }
}