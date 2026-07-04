package com.burundihealthconnect.servlet;

import com.burundihealthconnect.ejb.CongeService;
import com.burundihealthconnect.ejb.ConsultationService;
import com.burundihealthconnect.ejb.DossierService;
import com.burundihealthconnect.ejb.EtablissementService;
import com.burundihealthconnect.ejb.NotificationService;
import com.burundihealthconnect.ejb.OrdonnanceService;
import com.burundihealthconnect.ejb.ReferenementService;
import com.burundihealthconnect.ejb.RendezVousService;
import com.burundihealthconnect.entity.Consultation;
import com.burundihealthconnect.entity.DossierMedical;
import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.Referenement;
import com.burundihealthconnect.entity.RendezVous;
import com.burundihealthconnect.entity.enums.Priorite;
import com.burundihealthconnect.entity.enums.Role;
import com.burundihealthconnect.entity.enums.StatutConsultation;
import com.burundihealthconnect.entity.enums.TypeAcces;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * MedecinServlet — @WebServlet("/medecin/*")
 * Routes :
 *   GET  /medecin/dashboard        -> L08, L16, L17
 *   GET  /medecin/rdv              -> RDV en attente / liste paginée (L02, L07, L09)
 *   POST /medecin/rdv/confirmer    -> confirme un RDV
 *   POST /medecin/rdv/refuser      -> refuse un RDV
 *   POST /medecin/rdv/terminer     -> marque RDV terminé
 *   POST /medecin/rdv/priorite     -> change priorité (L16)
 *   GET  /medecin/dossier          -> dossier patient (L05, L10) — ?numeroPatient=
 *   POST /medecin/consultation/creer    -> crée consultation (L02)
 *   POST /medecin/consultation/statut   -> change statut consultation (L02)
 *   POST /medecin/ordonnance/creer      -> rédige ordonnance (L04)
 *   GET  /medecin/historique       -> historique modifications dossier (L18) — ?idDossier=
 *   GET  /medecin/conge            -> mes demandes de congé
 *   POST /medecin/conge/demander   -> demande un congé (L19)
 */
@WebServlet("/medecin/*")
public class MedecinServlet extends HttpServlet {

    @Inject
    private EtablissementService etablissementService;

    @Inject
    private RendezVousService rendezVousService;

    @Inject
    private DossierService dossierService;

    @Inject
    private ConsultationService consultationService;

    @Inject
    private CongeService congeService;

    @Inject
    private ReferenementService referenementService;

    @Inject
    private OrdonnanceService ordonnanceService;

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
        Long idMedecin = (Long) session.getAttribute(SessionKeys.ID_MEDECIN);
        Long idEtablissement = (Long) session.getAttribute(SessionKeys.ID_ETABLISSEMENT);
        Long idUtilisateur = (Long) session.getAttribute(SessionKeys.ID_UTILISATEUR);

        if (pathInfo == null || "/dashboard".equals(pathInfo)) {
            afficherDashboard(request, response, idMedecin, idEtablissement);
        } else if ("/rdv".equals(pathInfo)) {
            afficherRdv(request, response, idMedecin, idEtablissement);
        } else if ("/dossier".equals(pathInfo) && "medecins".equals(request.getParameter("ajax"))) {
            repondreMedecinsParEtablissement(request, response);
        } else if ("/dossier".equals(pathInfo)) {
            afficherDossier(request, response, idMedecin, idEtablissement);
        } else if ("/historique".equals(pathInfo)) {
            afficherHistorique(request, response);
        } else if ("/conge".equals(pathInfo)) {
            afficherConges(request, response, idMedecin);
        } else if ("/notifications".equals(pathInfo)) {
            afficherNotifications(request, response, idUtilisateur);
        } else if ("/ordonnance".equals(pathInfo)) {
            afficherFormulaireOrdonnance(request, response);
        } else if ("/consultation/creer".equals(pathInfo)) {
            afficherFormulaireCreationConsultation(request, response, idMedecin);
        } else if ("/consultations".equals(pathInfo)) {
            afficherConsultations(request, response, idMedecin, idEtablissement);
        } else if ("/referenements".equals(pathInfo)) {
            afficherReferenements(request, response, idMedecin);
        } else if ("/referenement/creer".equals(pathInfo)) {
            afficherFormulaireReferenement(request, response, idMedecin, idEtablissement);
        } else if ("/ordonnances".equals(pathInfo)) {
            afficherOrdonnances(request, response, idMedecin);
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

        switch (pathInfo == null ? "" : pathInfo) {
            case "/rdv/confirmer":
                traiterConfirmerRdv(request, response, idMedecin);
                break;
            case "/rdv/refuser":
                traiterRefuserRdv(request, response, idMedecin);
                break;
            case "/rdv/terminer":
                traiterTerminerRdv(request, response, idMedecin);
                break;
            case "/rdv/priorite":
                traiterChangerPriorite(request, response, idMedecin);
                break;
            case "/consultation/creer":
                traiterCreerConsultation(request, response, idMedecin, idEtablissement);
                break;
            case "/consultation/statut":
                traiterChangerStatutConsultation(request, response, idMedecin);
                break;
            case "/ordonnance/creer":
                traiterCreerOrdonnance(request, response);
                break;
            case "/conge/demander":
                traiterDemanderConge(request, response, idMedecin, idEtablissement);
                break;
            case "/referenement/creer":
                traiterCreerReferenement(request, response, idMedecin);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================
    // DASHBOARD — L08, L16, L17
    // =========================================================

    private void afficherDashboard(HttpServletRequest request, HttpServletResponse response,
                                    Long idMedecin, Long idEtablissement)
            throws ServletException, IOException {
        Map<String, Object> stats = etablissementService.getStatistiques(Role.MEDECIN, idMedecin, idEtablissement);
        request.setAttribute("stats", stats);
        request.setAttribute("rdvParPriorite", rendezVousService.getRdvParPriorite(idEtablissement));
        forward(request, response, "/WEB-INF/views/medecin/dashboard.jsp");
    }

    // =========================================================
    // GESTION RDV — L02, L07, L09, L16
    // =========================================================

    private void afficherRdv(HttpServletRequest request, HttpServletResponse response,
                              Long idMedecin, Long idEtablissement)
            throws ServletException, IOException {
        int page = parseIntOuZero(request.getParameter("page"));
        String filtre = request.getParameter("filtre");

        List<RendezVous> rdv = rendezVousService.getRdvParMedecin(idMedecin, idEtablissement, page, filtre);
        request.setAttribute("rdv", rdv);
        request.setAttribute("page", page);
        request.setAttribute("filtre", filtre);
        long totalCount = rendezVousService.countRdvParMedecin(idMedecin, filtre);
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("totalPages", totalPages);
        forward(request, response, "/WEB-INF/views/medecin/rdv-liste.jsp");
    }

    private void traiterConfirmerRdv(HttpServletRequest request, HttpServletResponse response, Long idMedecin)
            throws IOException {
        Long idRendezVous = parseLongOuNull(request.getParameter("idRendezVous"));
        try {
            rendezVousService.confirmerRdv(idRendezVous, idMedecin);
            response.sendRedirect(request.getContextPath() + "/medecin/rdv?succes=1");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/rdv", e.getMessage());
        }
    }

    private void traiterRefuserRdv(HttpServletRequest request, HttpServletResponse response, Long idMedecin)
            throws IOException {
        Long idRendezVous = parseLongOuNull(request.getParameter("idRendezVous"));
        try {
            rendezVousService.refuserRdv(idRendezVous, idMedecin);
            response.sendRedirect(request.getContextPath() + "/medecin/rdv?succes=1");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/rdv", e.getMessage());
        }
    }

    private void traiterTerminerRdv(HttpServletRequest request, HttpServletResponse response, Long idMedecin)
            throws IOException {
        Long idRendezVous = parseLongOuNull(request.getParameter("idRendezVous"));
        try {
            rendezVousService.marquerTermine(idRendezVous, idMedecin);
            response.sendRedirect(request.getContextPath() + "/medecin/rdv?succes=1");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/rdv", e.getMessage());
        }
    }

    /** L16 — Le médecin change la priorité d'un RDV. */
    private void traiterChangerPriorite(HttpServletRequest request, HttpServletResponse response, Long idMedecin)
            throws IOException {
        Long idRendezVous = parseLongOuNull(request.getParameter("idRendezVous"));
        String prioriteStr = request.getParameter("priorite");
        try {
            Priorite priorite = Priorite.valueOf(prioriteStr);
            rendezVousService.changerPriorite(idRendezVous, idMedecin, priorite);
            response.sendRedirect(request.getContextPath() + "/medecin/dashboard?succes=1");
        } catch (BusinessException | IllegalArgumentException e) {
            redirigerAvecErreur(request, response, "/medecin/dashboard", "Priorité invalide ou RDV introuvable.");
        }
    }

    // =========================================================
    // DOSSIER PATIENT — L05, L10
    // =========================================================

    private void afficherDossier(HttpServletRequest request, HttpServletResponse response,
                                  Long idMedecin, Long idEtablissement)
            throws ServletException, IOException {
        String numeroPatient = request.getParameter("numeroPatient");
        if (numeroPatient == null || numeroPatient.isBlank()) {
            forward(request, response, "/WEB-INF/views/medecin/dossier-recherche.jsp");
            return;
        }

        try {
            DossierMedical dossierTrouve = dossierService.getDossierByNumeroPatient(numeroPatient.trim());

            // L10 — Trace l'accès en LECTURE avant tout affichage
            DossierMedical dossier = dossierService.ouvrirDossier(
                    dossierTrouve.getIdDossier(), idMedecin, idEtablissement, TypeAcces.LECTURE);

            request.setAttribute("dossier", dossier);
            request.setAttribute("historique", dossierService.getHistoriqueComplet(dossier.getIdDossier()));
            forward(request, response, "/WEB-INF/views/medecin/dossier-detail.jsp");

        } catch (BusinessException e) {
            request.setAttribute("erreur", e.getMessage());
            forward(request, response, "/WEB-INF/views/medecin/dossier-recherche.jsp");
        }
    }

    private void afficherHistorique(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long idDossier = parseLongOuNull(request.getParameter("idDossier"));
        if (idDossier == null) {
            response.sendRedirect(request.getContextPath() + "/medecin/dossier");
            return;
        }
        request.setAttribute("historique", dossierService.getHistoriqueModifications(idDossier));
        forward(request, response, "/WEB-INF/views/medecin/historique.jsp");
    }

    // =========================================================
    // CONSULTATION — L02
    // =========================================================

    private void traiterCreerConsultation(HttpServletRequest request, HttpServletResponse response,
                                            Long idMedecin, Long idEtablissement)
            throws ServletException, IOException {
        Long idRendezVous = parseLongOuNull(request.getParameter("idRendezVous"));
        Long idDossier = parseLongOuNull(request.getParameter("idDossier"));
        String notes = request.getParameter("notes");
        String diagnostic = request.getParameter("diagnostic");

        if (idDossier == null) {
            redirigerAvecErreur(request, response, "/medecin/dossier", "Dossier introuvable pour cette consultation.");
            return;
        }
        if (!isValidMaxLength(notes, 500)) {
            redirigerAvecErreur(request, response, "/medecin/dossier",
                    message(request, "error.validation.maxlength")
                            .replace("{0}", "Notes").replace("{1}", "500"));
            return;
        }
        if (!isValidMaxLength(diagnostic, 500)) {
            redirigerAvecErreur(request, response, "/medecin/dossier",
                    message(request, "error.validation.maxlength")
                            .replace("{0}", "Diagnostic").replace("{1}", "500"));
            return;
        }

        try {
            Consultation consultation = consultationService.creerConsultation(
                    idRendezVous, idDossier, idMedecin, idEtablissement, notes, diagnostic);
            response.sendRedirect(request.getContextPath()
                    + "/medecin/consultations?succes=1");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/dossier", e.getMessage());
        }
    }

    private void traiterChangerStatutConsultation(HttpServletRequest request, HttpServletResponse response,
                                                   Long idMedecin)
            throws IOException {
        Long idConsultation = parseLongOuNull(request.getParameter("idConsultation"));
        String statutStr = request.getParameter("statut");
        try {
            StatutConsultation statut = StatutConsultation.valueOf(statutStr);
            consultationService.changerStatut(idConsultation, idMedecin, statut);
            response.sendRedirect(request.getContextPath() + "/medecin/consultations?succes=1");
        } catch (BusinessException | IllegalArgumentException e) {
            redirigerAvecErreur(request, response, "/medecin/consultations", "Transition de statut invalide.");
        }
    }

    // =========================================================
    // ORDONNANCE — L04
    // =========================================================

    /** GET — Affiche le formulaire d'ordonnance pour une consultation donnée. */
    private void afficherFormulaireOrdonnance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long idConsultation = parseLongOuNull(request.getParameter("idConsultation"));
        if (idConsultation == null) {
            response.sendRedirect(request.getContextPath() + "/medecin/rdv");
            return;
        }
        try {
            Consultation consultation = consultationService.getConsultationById(idConsultation);
            request.setAttribute("consultation", consultation);
            forward(request, response, "/WEB-INF/views/medecin/ordonnance.jsp");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/rdv", e.getMessage());
        }
    }

    private void traiterCreerOrdonnance(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Long idConsultation = parseLongOuNull(request.getParameter("idConsultation"));
        String instructions = request.getParameter("instructions");

        if (!isValidMaxLength(instructions, 500)) {
            redirigerAvecErreur(request, response, "/medecin/ordonnances",
                    message(request, "error.validation.maxlength")
                            .replace("{0}", "Instructions").replace("{1}", "500"));
            return;
        }

        // Les lignes arrivent sous forme de tableaux parallèles depuis le formulaire JSP :
        // medicament[], dosage[], frequence[], dureeJours[]
        String[] medicaments = request.getParameterValues("medicament");
        String[] dosages = request.getParameterValues("dosage");
        String[] frequences = request.getParameterValues("frequence");
        String[] durees = request.getParameterValues("dureeJours");

        List<ConsultationService.LignePrescriptionDTO> lignes = new ArrayList<>();
        if (medicaments != null) {
            for (int i = 0; i < medicaments.length; i++) {
                if (medicaments[i] == null || medicaments[i].isBlank()) {
                    continue;
                }
                Integer dureeJours = parseIntOuNull(durees != null && i < durees.length ? durees[i] : null);
                lignes.add(new ConsultationService.LignePrescriptionDTO(
                        medicaments[i], dosages[i], frequences[i], dureeJours));
            }
        }

        try {
            ConsultationService.OrdonnanceResultat resultat =
                    consultationService.creerOrdonnance(idConsultation, instructions, lignes);

            String parametreAlerte = resultat.alerteAllergieDeclenchee ? "&alerteAllergie=1" : "";
            response.sendRedirect(request.getContextPath() + "/medecin/ordonnances?succes=1" + parametreAlerte);

        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/ordonnances", e.getMessage());
        }
    }

    // =========================================================
    // CONSULTATIONS — L02
    // =========================================================

    private void afficherFormulaireCreationConsultation(HttpServletRequest request, HttpServletResponse response,
                                                         Long idMedecin)
            throws ServletException, IOException {
        Long idRendezVous = parseLongOuNull(request.getParameter("idRendezVous"));
        if (idRendezVous == null) {
            response.sendRedirect(request.getContextPath() + "/medecin/rdv");
            return;
        }
        try {
            RendezVous rdv = rendezVousService.getRendezVousById(idRendezVous, idMedecin);
            request.setAttribute("rdv", rdv);
            forward(request, response, "/WEB-INF/views/medecin/consultation-creer.jsp");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/rdv", e.getMessage());
        }
    }

    private void afficherConsultations(HttpServletRequest request, HttpServletResponse response,
                                        Long idMedecin, Long idEtablissement)
            throws ServletException, IOException {
        int page = parseIntOuZero(request.getParameter("page"));
        request.setAttribute("consultations", consultationService.getConsultationsByMedecin(idMedecin, page));
        request.setAttribute("page", page);
        long totalCount = consultationService.countConsultationsByMedecin(idMedecin);
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("totalPages", totalPages);
        forward(request, response, "/WEB-INF/views/medecin/consultations-liste.jsp");
    }

    // =========================================================
    // REFERENCEMENT — L06
    // =========================================================

    private void afficherReferenements(HttpServletRequest request, HttpServletResponse response,
                                        Long idMedecin)
            throws ServletException, IOException {
        int page = parseIntOuZero(request.getParameter("page"));
        request.setAttribute("referenements", referenementService.getReferenementsParMedecin(idMedecin, page));
        request.setAttribute("page", page);
        long totalCount = referenementService.countReferenementsParMedecin(idMedecin);
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("totalPages", totalPages);
        forward(request, response, "/WEB-INF/views/medecin/referenements-liste.jsp");
    }

    private void afficherFormulaireReferenement(HttpServletRequest request, HttpServletResponse response,
                                                 Long idMedecin, Long idEtablissement)
            throws ServletException, IOException {
        Long idConsultation = parseLongOuNull(request.getParameter("idConsultation"));
        if (idConsultation == null) {
            response.sendRedirect(request.getContextPath() + "/medecin/consultations");
            return;
        }
        request.setAttribute("consultation", consultationService.getConsultationById(idConsultation));
        request.setAttribute("hopitaux", etablissementService.getAllSauf(idEtablissement));
        forward(request, response, "/WEB-INF/views/medecin/referenement-creer.jsp");
    }

    private void traiterCreerReferenement(HttpServletRequest request, HttpServletResponse response,
                                           Long idMedecin)
            throws IOException {
        Long idConsultation = parseLongOuNull(request.getParameter("idConsultation"));
        Long idEtablissementDest = parseLongOuNull(request.getParameter("idEtablissementDest"));
        Long idMedecinDest = parseLongOuNull(request.getParameter("idMedecinDest"));
        String motif = request.getParameter("motif");

        if (idConsultation == null || idEtablissementDest == null || motif == null || motif.isBlank()) {
            redirigerAvecErreur(request, response, "/medecin/referenements",
                    message(request, "message.error.required_fields"));
            return;
        }

        try {
            referenementService.creerReferenement(idConsultation, idEtablissementDest, idMedecinDest, motif);
            response.sendRedirect(request.getContextPath() + "/medecin/referenements?succes=1");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/referenements", e.getMessage());
        }
    }

    // =========================================================
    // ORDONNANCES — L04
    // =========================================================

    private void afficherOrdonnances(HttpServletRequest request, HttpServletResponse response, Long idMedecin)
            throws ServletException, IOException {
        int page = parseIntOuZero(request.getParameter("page"));
        String filtre = request.getParameter("filtre");
        request.setAttribute("ordonnances", ordonnanceService.getOrdonnancesByMedecin(idMedecin, filtre, page));
        request.setAttribute("filtre", filtre);
        request.setAttribute("page", page);
        long totalCount = ordonnanceService.countOrdonnancesByMedecin(idMedecin, filtre);
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("totalPages", totalPages);
        forward(request, response, "/WEB-INF/views/medecin/ordonnances-liste.jsp");
    }

    // =========================================================
    // NOTIFICATIONS — L17
    // =========================================================

    private void afficherNotifications(HttpServletRequest request, HttpServletResponse response, Long idUtilisateur)
            throws ServletException, IOException {
        int page = parseIntOuZero(request.getParameter("page"));
        request.setAttribute("notifications", notificationService.getToutes(idUtilisateur, page));
        request.setAttribute("page", page);
        long totalCount = notificationService.countToutes(idUtilisateur);
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("totalPages", totalPages);
        forward(request, response, "/WEB-INF/views/medecin/notifications.jsp");
    }

    // =========================================================
    // CONGE — L19
    // =========================================================

    private void afficherConges(HttpServletRequest request, HttpServletResponse response, Long idMedecin)
            throws ServletException, IOException {
        int page = 0;
        request.setAttribute("conges", congeService.getMesDemandes(idMedecin, page));
        request.setAttribute("page", page);
        forward(request, response, "/WEB-INF/views/medecin/conge.jsp");
    }

    private void traiterDemanderConge(HttpServletRequest request, HttpServletResponse response,
                                       Long idMedecin, Long idEtablissement)
            throws ServletException, IOException {
        String dateDebutStr = request.getParameter("dateDebut");
        String dateFinStr = request.getParameter("dateFin");
        String motif = request.getParameter("motif");

        if (dateDebutStr == null || dateFinStr == null) {
            redirigerAvecErreur(request, response, "/medecin/conge", "Veuillez indiquer les dates de début et fin.");
            return;
        }

        try {
            LocalDate dateDebut = LocalDate.parse(dateDebutStr);
            LocalDate dateFin = LocalDate.parse(dateFinStr);
            congeService.demanderConge(idMedecin, idEtablissement, dateDebut, dateFin, motif);
            response.sendRedirect(request.getContextPath() + "/medecin/conge?succes=1");
        } catch (BusinessException e) {
            redirigerAvecErreur(request, response, "/medecin/conge", e.getMessage());
        }
    }

    // =========================================================
    // AJAX — Médecins d'un établissement
    // =========================================================

    private void repondreMedecinsParEtablissement(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Long idEtablissement = parseLongOuNull(request.getParameter("idEtablissement"));
        response.setContentType("application/json;charset=UTF-8");
        if (idEtablissement == null) {
            response.getWriter().write("[]");
            return;
        }
        List<Medecin> medecins = etablissementService.getMedecinsByEtablissement(idEtablissement);
        StringBuilder json = new StringBuilder("[");
        boolean premier = true;
        for (Medecin m : medecins) {
            if (!premier) json.append(",");
            json.append("{\"id\":").append(m.getIdMedecin())
                .append(",\"nom\":\"").append(escJson(m.getUtilisateur().getFullName())).append("\"}");
            premier = false;
        }
        json.append("]");
        response.getWriter().write(json.toString());
    }

    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
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

    private void redirigerAvecErreur(HttpServletRequest request, HttpServletResponse response,
                                      String url, String message) throws IOException {
        response.sendRedirect(request.getContextPath() + url + "?erreur="
                + java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
    }

    private Long parseLongOuNull(String valeur) {
        try {
            return (valeur == null || valeur.isBlank()) ? null : Long.parseLong(valeur);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Integer parseIntOuNull(String valeur) {
        try {
            return (valeur == null || valeur.isBlank()) ? null : Integer.parseInt(valeur);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseIntOuZero(String valeur) {
        Integer resultat = parseIntOuNull(valeur);
        return resultat == null ? 0 : resultat;
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