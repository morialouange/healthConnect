package com.burundihealthconnect.servlet;

import com.burundihealthconnect.ejb.DisponibiliteService;
import com.burundihealthconnect.ejb.DossierService;
import com.burundihealthconnect.ejb.EtablissementService;
import com.burundihealthconnect.ejb.NotificationService;
import com.burundihealthconnect.ejb.RendezVousService;
import com.burundihealthconnect.entity.CreneauDisponible;
import com.burundihealthconnect.entity.DossierMedical;
import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.enums.Role;
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
import java.time.LocalDate;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * PatientServlet — @WebServlet("/patient/*")
 * Routes :
 *   GET /patient/dashboard      -> L08, L17
 *   GET /patient/dossier        -> L05 (lecture seule, jamais de modification ici)
 *   GET /patient/rdv/hopitaux   -> liste des hôpitaux du réseau
 *   GET /patient/rdv/medecins   -> médecins de l'hôpital choisi (?idEtablissement=)
 *   GET /patient/rdv/creneaux   -> créneaux libres d'un médecin (?idMedecin=) L14, L20
 *   POST /patient/rdv/creer     -> création du RDV (réservation créneau)
 *   POST /patient/rdv/annuler   -> annulation patient (L21)
 */
@WebServlet("/patient/*")
public class PatientServlet extends HttpServlet {

    @Inject
    private EtablissementService etablissementService;

    @Inject
    private DisponibiliteService disponibiliteService;

    @Inject
    private RendezVousService rendezVousService;

    @Inject
    private DossierService dossierService;

    @Inject
    private NotificationService notificationService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/auth");
            return;
        }
        Long idUtilisateur = (Long) session.getAttribute(SessionKeys.ID_UTILISATEUR);
        Long idPatient = (Long) session.getAttribute(SessionKeys.ID_PATIENT);

        if (pathInfo == null || "/dashboard".equals(pathInfo)) {
            afficherDashboard(request, response, idPatient);
        } else if ("/dossier".equals(pathInfo)) {
            afficherDossier(request, response, idPatient);
        } else if ("/rdv/hopitaux".equals(pathInfo)) {
            afficherHopitaux(request, response);
        } else if ("/rdv/medecins".equals(pathInfo)) {
            afficherMedecins(request, response);
        } else if ("/rdv/creneaux".equals(pathInfo)) {
            afficherCreneaux(request, response);
        } else if ("/notifications".equals(pathInfo)) {
            afficherNotifications(request, response, idUtilisateur);
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
        Long idPatient = (Long) session.getAttribute(SessionKeys.ID_PATIENT);

        if ("/rdv/creer".equals(pathInfo)) {
            traiterCreationRdv(request, response, idPatient);
        } else if ("/rdv/annuler".equals(pathInfo)) {
            traiterAnnulationRdv(request, response, idPatient);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================
    // DASHBOARD — L08, L17
    // =========================================================

    private void afficherDashboard(HttpServletRequest request, HttpServletResponse response, Long idPatient)
            throws ServletException, IOException {
        Map<String, Object> stats = etablissementService.getStatistiques(Role.PATIENT, idPatient, null);
        request.setAttribute("stats", stats);
        forward(request, response, "/WEB-INF/views/patient/dashboard.jsp");
    }

    private void afficherNotifications(HttpServletRequest request, HttpServletResponse response, Long idUtilisateur)
            throws ServletException, IOException {
        int page = parseIntOuZero(request.getParameter("page"));
        request.setAttribute("notifications", notificationService.getToutes(idUtilisateur, page));
        request.setAttribute("page", page);
        long totalCount = notificationService.countToutes(idUtilisateur);
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("totalPages", totalPages);
        forward(request, response, "/WEB-INF/views/patient/notifications.jsp");
    }

    // =========================================================
    // DOSSIER MEDICAL (LECTURE SEULE) — L05
    // =========================================================

    private void afficherDossier(HttpServletRequest request, HttpServletResponse response, Long idPatient)
            throws ServletException, IOException {
        try {
            // Le patient consulte son PROPRE dossier — pas besoin de passer par
            // ouvrirDossier() (réservé à la traçabilité des accès MEDECIN, L10).
            DossierMedical dossier = dossierService.getDossierByIdPatient(idPatient);

            request.setAttribute("dossier", dossier);
            request.setAttribute("historique", dossierService.getHistoriqueComplet(dossier.getIdDossier()));
            forward(request, response, "/WEB-INF/views/patient/dossier.jsp");

        } catch (BusinessException e) {
            request.setAttribute("erreur", e.getMessage());
            forward(request, response, "/WEB-INF/views/patient/dossier.jsp");
        }
    }

    // =========================================================
    // PRISE DE RDV — L14, L20
    // =========================================================

    private void afficherHopitaux(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<EtablissementSante> hopitaux = etablissementService.findAll(0);
        request.setAttribute("hopitaux", hopitaux);
        forward(request, response, "/WEB-INF/views/patient/rdv-hopitaux.jsp");
    }

    private void afficherMedecins(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long idEtablissement = parseLongOuNull(request.getParameter("idEtablissement"));
        if (idEtablissement == null) {
            response.sendRedirect(request.getContextPath() + "/patient/rdv/hopitaux");
            return;
        }
        List<Medecin> medecins = etablissementService.getMedecinsByEtablissement(idEtablissement);
        request.setAttribute("medecins", medecins);
        request.setAttribute("idEtablissement", idEtablissement);
        forward(request, response, "/WEB-INF/views/patient/rdv-medecins.jsp");
    }

    private void afficherCreneaux(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long idMedecin = parseLongOuNull(request.getParameter("idMedecin"));
        if (idMedecin == null) {
            response.sendRedirect(request.getContextPath() + "/patient/rdv/hopitaux");
            return;
        }
        LocalDate aujourdHui = LocalDate.now();
        List<CreneauDisponible> creneaux = disponibiliteService.getCreneauxLibres(
                idMedecin, aujourdHui, aujourdHui.plusDays(14));
        request.setAttribute("creneaux", creneaux);
        request.setAttribute("idMedecin", idMedecin);
        forward(request, response, "/WEB-INF/views/patient/rdv-creneaux.jsp");
    }

    private void traiterCreationRdv(HttpServletRequest request, HttpServletResponse response, Long idPatient)
            throws ServletException, IOException {
        Long idCreneau = parseLongOuNull(request.getParameter("idCreneau"));
        Long idService = parseLongOuNull(request.getParameter("idService"));
        String motif = request.getParameter("motif");

        if (idCreneau == null || motif == null || motif.isBlank()) {
            request.setAttribute("erreur", "Veuillez choisir un créneau et indiquer un motif.");
            response.sendRedirect(request.getContextPath() + "/patient/rdv/hopitaux");
            return;
        }
        if (!isValidMaxLength(motif, 200)) {
            request.setAttribute("erreur", message(request, "error.validation.maxlength")
                    .replace("{0}", "Motif").replace("{1}", "200"));
            forward(request, response, "/WEB-INF/views/patient/rdv-creneaux.jsp");
            return;
        }

        try {
            rendezVousService.creerRdvAvecCreneau(idPatient, idCreneau, idService, motif.trim());
            response.sendRedirect(request.getContextPath() + "/patient/dashboard?succesRdv=1");
        } catch (BusinessException e) {
            // L20 (LimiteRdvAtteintException) ou créneau déjà pris (CreneauDejaReserveException)
            request.setAttribute("erreur", e.getMessage());
            forward(request, response, "/WEB-INF/views/patient/rdv-creneaux.jsp");
        }
    }

    private void traiterAnnulationRdv(HttpServletRequest request, HttpServletResponse response, Long idPatient)
            throws ServletException, IOException {
        Long idRendezVous = parseLongOuNull(request.getParameter("idRendezVous"));
        if (idRendezVous == null) {
            response.sendRedirect(request.getContextPath() + "/patient/dashboard");
            return;
        }

        try {
            rendezVousService.annulerParPatient(idRendezVous, idPatient);
            response.sendRedirect(request.getContextPath() + "/patient/dashboard?annulationOk=1");
        } catch (BusinessException e) {
            // L21 — RDV non annulable (déjà confirmé) ou n'appartenant pas au patient
            response.sendRedirect(request.getContextPath() + "/patient/dashboard?erreur="
                    + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
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

    private Long parseLongOuNull(String valeur) {
        try {
            return (valeur == null || valeur.isBlank()) ? null : Long.parseLong(valeur);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseIntOuZero(String valeur) {
        try {
            return (valeur == null || valeur.isBlank()) ? 0 : Integer.parseInt(valeur);
        } catch (NumberFormatException e) {
            return 0;
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