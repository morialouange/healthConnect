package com.burundihealthconnect.servlet;

import com.burundihealthconnect.ejb.DisponibiliteService;
import com.burundihealthconnect.exception.BusinessException;
import com.burundihealthconnect.util.SessionKeys;

import jakarta.inject.Inject;
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
import java.util.Map;

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
            ServletUtils.forward(request, response, "/WEB-INF/views/medecin/disponibilite.jsp");
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
            ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines",
                    "Veuillez remplir tous les champs et choisir au moins un jour travaillé.");
            return;
        }

        try {
            LocalDate dateDebutSemaine = LocalDate.parse(dateDebutStr);
            int dureeCreneauMin = Integer.parseInt(dureeStr);
            if (dureeCreneauMin <= 0) {
                ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines", "La durée du créneau doit être positive.");
                return;
            }

            Map<DayOfWeek, LocalTime[]> plagesHoraires = new HashMap<>();
            for (String jour : joursStr) {
                DayOfWeek day = DayOfWeek.valueOf(jour);
                String heureDebut = request.getParameter("heureDebut_" + jour);
                String heureFin = request.getParameter("heureFin_" + jour);
                if (heureDebut == null || heureFin == null) {
                    ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines",
                            "Plage horaire manquante pour " + traduireJour(day) + ".");
                    return;
                }
                LocalTime debut = LocalTime.parse(heureDebut);
                LocalTime fin = LocalTime.parse(heureFin);
                if (!debut.isBefore(fin)) {
                    ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines",
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
            ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines", "Données invalides : " + e.getMessage());
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
        Long idCreneau = ServletUtils.parseLongOuNull(request.getParameter("idCreneau"));
        if (idCreneau == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines", "Créneau introuvable.");
            return;
        }
        try {
            disponibiliteService.supprimerCreneau(idCreneau, idMedecin);
            response.sendRedirect(request.getContextPath() + "/medecin/disponibilite/mes-semaines?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines", e.getMessage());
        }
    }

    // =========================================================
    // COPIE DE SEMAINE
    // =========================================================

    private void traiterCopierSemaine(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Long idDisponibilite = ServletUtils.parseLongOuNull(request.getParameter("idDisponibilite"));
        if (idDisponibilite == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines", "Semaine introuvable.");
            return;
        }
        try {
            disponibiliteService.copierSemaineSuivante(idDisponibilite);
            response.sendRedirect(request.getContextPath() + "/medecin/disponibilite/mes-semaines?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/medecin/disponibilite/mes-semaines", e.getMessage());
        }
    }

}