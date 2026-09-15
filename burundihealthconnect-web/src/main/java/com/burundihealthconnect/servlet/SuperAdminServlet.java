package com.burundihealthconnect.servlet;

import com.burundihealthconnect.ejb.AuditService;
import com.burundihealthconnect.ejb.AuthService;
import com.burundihealthconnect.ejb.DossierService;
import com.burundihealthconnect.ejb.EtablissementService;
import com.burundihealthconnect.entity.Utilisateur;
import com.burundihealthconnect.entity.enums.Role;
import com.burundihealthconnect.exception.BusinessException;

import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * SuperAdminServlet — @WebServlet("/superadmin/*")
 * Routes :
 *   GET  /superadmin/hopitaux          -> liste tous les établissements du réseau
 *   POST /superadmin/hopitaux/creer    -> crée un établissement
 *   POST /superadmin/hopitaux/modifier -> modifie un établissement
 *   POST /superadmin/hopitaux/desactiver -> désactive un établissement
 *   POST /superadmin/hopitaux/reactiver  -> réactive un établissement
 *   POST /superadmin/admins/creer      -> crée un compte ADMIN pour un établissement
 *   GET  /superadmin/stats             -> statistiques réseau (L08)
 *   GET  /superadmin/journal           -> journal d'accès dossier GLOBAL (L10)
 *   GET  /superadmin/historique        -> historique modifications GLOBAL (L18)
 */
@WebServlet("/superadmin/*")
public class SuperAdminServlet extends HttpServlet {

    @Inject
    private EtablissementService etablissementService;

    @Inject
    private AuthService authService;

    @Inject
    private DossierService dossierService;

    @Inject
    private AuditService auditService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || "/hopitaux".equals(pathInfo)) {
            afficherHopitaux(request, response);
        } else if ("/dashboard".equals(pathInfo)) {
            afficherDashboard(request, response);
        } else if ("/audit".equals(pathInfo)) {
            afficherAudit(request, response);
        } else if ("/admins/modifier".equals(pathInfo)) {
            afficherFormulaireModifierAdmin(request, response);
        } else if ("/stats".equals(pathInfo)) {
            afficherStats(request, response);
        } else if ("/journal".equals(pathInfo)) {
            afficherJournal(request, response);
        } else if ("/historique".equals(pathInfo)) {
            afficherHistorique(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        switch (pathInfo == null ? "" : pathInfo) {
            case "/hopitaux/creer":
                traiterCreerHopital(request, response);
                break;
            case "/hopitaux/modifier":
                traiterModifierHopital(request, response);
                break;
            case "/hopitaux/desactiver":
                traiterDesactiverHopital(request, response);
                break;
            case "/hopitaux/reactiver":
                traiterReactiverHopital(request, response);
                break;
            case "/admins/creer":
                traiterCreerAdmin(request, response);
                break;
            case "/admins/modifier":
                traiterModifierAdmin(request, response);
                break;
            case "/admins/desactiver":
                traiterDesactiverAdmin(request, response);
                break;
            case "/admins/reactiver":
                traiterReactiverAdmin(request, response);
                break;
            case "/audit/filtrer":
                traiterFiltrerAudit(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================
    // HOPITAUX (CRUD ETABLISSEMENT)
    // =========================================================

    private void afficherHopitaux(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String filtre = request.getParameter("filtre");
        int page = ServletUtils.parseIntOuZero(request.getParameter("page"));
        String tri = request.getParameter("tri");
        String ordre = request.getParameter("ordre");
        request.setAttribute("hopitaux", etablissementService.findAll(filtre, page, tri, ordre));
        request.setAttribute("admins", authService.findAllAdmins());
        request.setAttribute("filtre", filtre);
        request.setAttribute("page", page);
        request.setAttribute("tri", tri);
        request.setAttribute("ordre", ordre);
        long totalCount = etablissementService.countAll(filtre);
        int totalPages = (int) Math.ceil((double) totalCount / ServletUtils.TAILLE_PAGE);
        request.setAttribute("totalPages", totalPages);
        ServletUtils.forward(request, response, "/WEB-INF/views/superadmin/hopitaux.jsp");
    }

    private void traiterCreerHopital(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String nom = request.getParameter("nom");
        String adresse = request.getParameter("adresse");
        String typeEtablissement = request.getParameter("typeEtablissement");
        String email = request.getParameter("email");
        String telephone = request.getParameter("telephone");

        if (nom == null || nom.isBlank()) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.required").replace("{0}", "Nom"));
            return;
        }
        if (!ServletUtils.isValidMaxLength(nom, ServletUtils.MAX_LENGTH)) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.maxlength").replace("{0}", "Nom").replace("{1}", "100"));
            return;
        }
        if (adresse == null || adresse.isBlank()) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.required").replace("{0}", "Adresse"));
            return;
        }
        if (email != null && !email.isBlank() && !ServletUtils.isValidEmail(email)) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.email"));
            return;
        }
        if (telephone != null && !telephone.isBlank() && !ServletUtils.isValidTelephone(telephone)) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.telephone"));
            return;
        }

        try {
            etablissementService.creerEtablissement(nom.trim(), adresse.trim(), typeEtablissement, email, telephone);
            response.sendRedirect(request.getContextPath() + "/superadmin/hopitaux?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    private void traiterModifierHopital(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long idEtablissement = ServletUtils.parseLongOuNull(request.getParameter("idEtablissement"));
        if (idEtablissement == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", "Établissement introuvable.");
            return;
        }
        try {
            etablissementService.modifierEtablissement(idEtablissement,
                    ServletUtils.videSiVide(request.getParameter("nom")),
                    ServletUtils.videSiVide(request.getParameter("adresse")),
                    ServletUtils.videSiVide(request.getParameter("typeEtablissement")),
                    ServletUtils.videSiVide(request.getParameter("email")),
                    ServletUtils.videSiVide(request.getParameter("telephone")));
            response.sendRedirect(request.getContextPath() + "/superadmin/hopitaux?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    private void traiterDesactiverHopital(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long idEtablissement = ServletUtils.parseLongOuNull(request.getParameter("idEtablissement"));
        if (idEtablissement == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", "Établissement introuvable.");
            return;
        }
        try {
            etablissementService.desactiverEtablissement(idEtablissement);
            response.sendRedirect(request.getContextPath() + "/superadmin/hopitaux?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    private void traiterReactiverHopital(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long idEtablissement = ServletUtils.parseLongOuNull(request.getParameter("idEtablissement"));
        if (idEtablissement == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", "Établissement introuvable.");
            return;
        }
        try {
            etablissementService.reactiverEtablissement(idEtablissement);
            response.sendRedirect(request.getContextPath() + "/superadmin/hopitaux?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    // =========================================================
    // CREATION COMPTE ADMIN
    // =========================================================

    private void traiterCreerAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String motDePasseTemporaire = request.getParameter("motDePasseTemporaire");
        Long idEtablissement = ServletUtils.parseLongOuNull(request.getParameter("idEtablissement"));

        if (fullName == null || fullName.isBlank()) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.fullname.required"));
            return;
        }
        if (!ServletUtils.isValidMaxLength(fullName, ServletUtils.MAX_LENGTH)) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.fullname.length"));
            return;
        }
        if (email == null || email.isBlank() || !ServletUtils.isValidEmail(email)) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.email"));
            return;
        }
        if (motDePasseTemporaire == null || motDePasseTemporaire.length() < 8) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.password.min"));
            return;
        }
        if (idEtablissement == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.required").replace("{0}", "Établissement"));
            return;
        }

        try {
            authService.creerCompteAdmin(fullName.trim(), email.trim(), motDePasseTemporaire, idEtablissement);
            response.sendRedirect(request.getContextPath() + "/superadmin/hopitaux?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    // =========================================================
    // GESTION COMPTES ADMIN
    // =========================================================

    private void afficherFormulaireModifierAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long idUtilisateur = ServletUtils.parseLongOuNull(request.getParameter("idUtilisateur"));
        if (idUtilisateur == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", "Administrateur introuvable.");
            return;
        }
        try {
            Utilisateur admin = authService.getUtilisateurById(idUtilisateur);
            request.setAttribute("admin", admin);
            request.setAttribute("hopitaux", etablissementService.findAll(0));
            ServletUtils.forward(request, response, "/WEB-INF/views/superadmin/admin-modifier.jsp");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    private void traiterModifierAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long idUtilisateur = ServletUtils.parseLongOuNull(request.getParameter("idUtilisateur"));
        if (idUtilisateur == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", "Administrateur introuvable.");
            return;
        }
        String fullName = request.getParameter("fullName");
        if (fullName != null && !fullName.isBlank() && !ServletUtils.isValidMaxLength(fullName, ServletUtils.MAX_LENGTH)) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.fullname.length"));
            return;
        }
        String email = request.getParameter("email");
        if (email != null && !email.isBlank() && !ServletUtils.isValidEmail(email)) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux",
                    ServletUtils.message(request, "error.validation.email"));
            return;
        }
        try {
            authService.modifierAdmin(idUtilisateur,
                    ServletUtils.videSiVide(fullName),
                    ServletUtils.videSiVide(email),
                    ServletUtils.parseLongOuNull(request.getParameter("idEtablissement")));
            response.sendRedirect(request.getContextPath() + "/superadmin/hopitaux?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    private void traiterDesactiverAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long idUtilisateur = ServletUtils.parseLongOuNull(request.getParameter("idUtilisateur"));
        if (idUtilisateur == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", "Administrateur introuvable.");
            return;
        }
        try {
            authService.desactiverUtilisateur(idUtilisateur);
            response.sendRedirect(request.getContextPath() + "/superadmin/hopitaux?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    private void traiterReactiverAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long idUtilisateur = ServletUtils.parseLongOuNull(request.getParameter("idUtilisateur"));
        if (idUtilisateur == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", "Administrateur introuvable.");
            return;
        }
        try {
            authService.reactiverUtilisateur(idUtilisateur);
            response.sendRedirect(request.getContextPath() + "/superadmin/hopitaux?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/superadmin/hopitaux", e.getMessage());
        }
    }

    // =========================================================
    // STATISTIQUES RESEAU — L08
    // =========================================================

    private void afficherStats(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, Object> stats = etablissementService.getStatistiques(Role.SUPER_ADMIN, null, null);
        request.setAttribute("stats", stats);
        ServletUtils.forward(request, response, "/WEB-INF/views/superadmin/stats.jsp");
    }

    // =========================================================
    // JOURNAL GLOBAL — L10
    // =========================================================

    private void afficherJournal(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = ServletUtils.parseIntOuZero(request.getParameter("page"));
        request.setAttribute("journal", dossierService.getJournalAccesGlobal(page));
        request.setAttribute("page", page);
        long totalCount = dossierService.countJournalAccesGlobal();
        int totalPages = (int) Math.ceil((double) totalCount / ServletUtils.TAILLE_PAGE);
        request.setAttribute("totalPages", totalPages);
        ServletUtils.forward(request, response, "/WEB-INF/views/superadmin/journal.jsp");
    }

    // =========================================================
    // HISTORIQUE GLOBAL — L18
    // =========================================================

    private void afficherHistorique(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = ServletUtils.parseIntOuZero(request.getParameter("page"));
        request.setAttribute("historique", dossierService.getHistoriqueModificationsGlobal(page));
        request.setAttribute("page", page);
        long totalCount = dossierService.countHistoriqueModificationsGlobal();
        int totalPages = (int) Math.ceil((double) totalCount / ServletUtils.TAILLE_PAGE);
        request.setAttribute("totalPages", totalPages);
        ServletUtils.forward(request, response, "/WEB-INF/views/superadmin/historique.jsp");
    }

    // =========================================================
    // DASHBOARD — SUPER_ADMIN
    // =========================================================

    private void afficherDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, Object> stats = etablissementService.getStatistiques(Role.SUPER_ADMIN, null, null);
        request.setAttribute("stats", stats);

        @SuppressWarnings("unchecked")
        List<String> hopitauxSansAdmin = (List<String>) stats.get("hopitauxSansAdmin");
        request.setAttribute("hopitauxSansAdmin", hopitauxSansAdmin);
        request.setAttribute("comptesDesactives", stats.get("comptesDesactives"));
        request.setAttribute("servicesInactifs", stats.get("servicesInactifs"));

        ServletUtils.forward(request, response, "/WEB-INF/views/superadmin/dashboard.jsp");
    }

    // =========================================================
    // AUDIT
    // =========================================================

    private void afficherAudit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = ServletUtils.parseIntOuZero(request.getParameter("page"));
        String filtreModule = ServletUtils.videSiVide(request.getParameter("module"));
        String filtreNiveau = ServletUtils.videSiVide(request.getParameter("niveau"));
        String filtreRecherche = ServletUtils.videSiVide(request.getParameter("recherche"));
        LocalDate dateDebut = parseDate(request.getParameter("dateDebut"));
        LocalDate dateFin = parseDate(request.getParameter("dateFin"));

        request.setAttribute("logs", auditService.getLogs(page, filtreModule, filtreNiveau, filtreRecherche, dateDebut, dateFin));
        request.setAttribute("statsLog", auditService.getStatsAudit());
        request.setAttribute("actionsParModule", auditService.getActionsParModule());
        request.setAttribute("actionsParNiveau", auditService.getActionsParNiveau());
        request.setAttribute("activite7Jours", auditService.getActivite7Jours());
        request.setAttribute("page", page);
        long totalCount = auditService.countLogs(filtreModule, filtreNiveau, filtreRecherche, dateDebut, dateFin);
        int totalPages = (int) Math.ceil((double) totalCount / ServletUtils.TAILLE_PAGE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("filtreModule", filtreModule);
        request.setAttribute("filtreNiveau", filtreNiveau);
        request.setAttribute("filtreRecherche", filtreRecherche);
        request.setAttribute("dateDebut", dateDebut != null ? dateDebut.toString() : "");
        request.setAttribute("dateFin", dateFin != null ? dateFin.toString() : "");

        ServletUtils.forward(request, response, "/WEB-INF/views/superadmin/audit.jsp");
    }

    private void traiterFiltrerAudit(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        StringBuilder params = new StringBuilder();
        String module = request.getParameter("module");
        if (module != null && !module.isBlank()) params.append("&module=").append(module);
        String niveau = request.getParameter("niveau");
        if (niveau != null && !niveau.isBlank()) params.append("&niveau=").append(niveau);
        String recherche = request.getParameter("recherche");
        if (recherche != null && !recherche.isBlank()) params.append("&recherche=").append(java.net.URLEncoder.encode(recherche, java.nio.charset.StandardCharsets.UTF_8));
        String dateDebut = request.getParameter("dateDebut");
        if (dateDebut != null && !dateDebut.isBlank()) params.append("&dateDebut=").append(dateDebut);
        String dateFin = request.getParameter("dateFin");
        if (dateFin != null && !dateFin.isBlank()) params.append("&dateFin=").append(dateFin);

        response.sendRedirect(request.getContextPath() + "/superadmin/audit?page=0" + params.toString());
    }

    private LocalDate parseDate(String valeur) {
        if (valeur == null || valeur.isBlank()) return null;
        try {
            return LocalDate.parse(valeur, DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (Exception e) {
            return null;
        }
    }
}
