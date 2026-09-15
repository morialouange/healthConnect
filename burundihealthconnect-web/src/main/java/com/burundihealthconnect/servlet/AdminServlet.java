package com.burundihealthconnect.servlet;

import com.burundihealthconnect.ejb.AuthService;
import com.burundihealthconnect.ejb.CongeService;
import com.burundihealthconnect.ejb.EtablissementService;
import com.burundihealthconnect.ejb.MedecinService;
import com.burundihealthconnect.ejb.ReferenementService;
import com.burundihealthconnect.ejb.RapportService;
import com.burundihealthconnect.ejb.ServiceService;
import com.burundihealthconnect.entity.CongeMedecin;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.Service;
import com.burundihealthconnect.entity.enums.CategorieService;
import com.burundihealthconnect.entity.enums.Role;
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
import java.time.YearMonth;
import java.util.Date;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    @Inject
    private EtablissementService etablissementService;

    @Inject
    private MedecinService medecinService;

    @Inject
    private ServiceService serviceService;

    @Inject
    private CongeService congeService;

    @Inject
    private RapportService rapportService;

    @Inject
    private AuthService authService;

    @Inject
    private ReferenementService referenementService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/auth");
            return;
        }
        Long idEtablissement = (Long) session.getAttribute(SessionKeys.ID_ETABLISSEMENT);

        if (pathInfo == null || "/dashboard".equals(pathInfo)) {
            afficherDashboard(request, response, idEtablissement);
        } else if ("/medecins".equals(pathInfo)) {
            afficherMedecins(request, response, idEtablissement);
        } else if ("/medecins/creer".equals(pathInfo)) {
            afficherMedecins(request, response, idEtablissement, true);
        } else if ("/medecins/detail".equals(pathInfo)) {
            afficherDetailMedecin(request, response, idEtablissement);
        } else if ("/medecins/modifier".equals(pathInfo)) {
            afficherFormulaireModifierMedecin(request, response, idEtablissement);
        } else if ("/services".equals(pathInfo)) {
            afficherServices(request, response, idEtablissement);
        } else if ("/services/creer".equals(pathInfo)) {
            afficherServices(request, response, idEtablissement, true);
        } else if ("/services/detail".equals(pathInfo)) {
            afficherDetailService(request, response, idEtablissement);
        } else if ("/services/modifier".equals(pathInfo)) {
            afficherFormulaireModifierService(request, response, idEtablissement);
        } else if ("/conges".equals(pathInfo)) {
            afficherConges(request, response, idEtablissement);
        } else if ("/referenements".equals(pathInfo)) {
            afficherReferenements(request, response, idEtablissement);
        } else if ("/rapport".equals(pathInfo)) {
            afficherRapport(request, response, idEtablissement);
        } else if ("/profil".equals(pathInfo)) {
            response.sendRedirect(request.getContextPath() + "/profil/mon-profil");
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
        Long idEtablissement = (Long) session.getAttribute(SessionKeys.ID_ETABLISSEMENT);

        switch (pathInfo == null ? "" : pathInfo) {
            case "/medecins/creer":
                traiterCreerMedecin(request, response, idEtablissement);
                break;
            case "/medecins/modifier":
                traiterModifierMedecin(request, response, idEtablissement);
                break;
            case "/medecins/desactiver":
                traiterDesactiverMedecin(request, response, idEtablissement);
                break;
            case "/services/creer":
                traiterCreerService(request, response, idEtablissement);
                break;
            case "/services/modifier":
                traiterModifierService(request, response, idEtablissement);
                break;
            case "/services/desactiver":
                traiterDesactiverService(request, response, idEtablissement);
                break;
            case "/conges/approuver":
                traiterApprouverConge(request, response, idEtablissement);
                break;
            case "/conges/refuser":
                traiterRefuserConge(request, response, idEtablissement);
                break;
            case "/referenement/accepter":
                traiterAccepterReferenement(request, response, idEtablissement);
                break;
            case "/referenement/retour":
                traiterRetourReferenement(request, response, idEtablissement);
                break;
            case "/referenement/cloturer":
                traiterCloturerReferenement(request, response, idEtablissement);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void afficherDashboard(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws ServletException, IOException {
        Map<String, Object> stats = etablissementService.getStatistiques(Role.ADMIN, null, idEtablissement);
        request.setAttribute("stats", stats);

        String periode = request.getParameter("periode");
        if (!"30".equals(periode)) {
            periode = "7";
        }
        String periodeTop = request.getParameter("periodeTop");
        if (!"trimestre".equals(periodeTop)) {
            periodeTop = "mois";
        }
        request.setAttribute("periode", periode);
        request.setAttribute("periodeTop", periodeTop);

        request.setAttribute("pageDateJour", new Date());
        request.setAttribute("pageHeaderButtonHref", request.getContextPath() + "/admin/rapport");
        request.setAttribute("pageHeaderButtonLabel",
                ServletUtils.message(request, "admin.dashboard.generer_rapport"));
        ServletUtils.forward(request, response, "/WEB-INF/views/admin/dashboard.jsp");
    }

    private void afficherMedecins(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws ServletException, IOException {
        afficherMedecins(request, response, idEtablissement, false);
    }

    private void afficherMedecins(HttpServletRequest request, HttpServletResponse response, Long idEtablissement,
                                  boolean afficherFormulaire) throws ServletException, IOException {
        String filtre = request.getParameter("filtre");
        int page = ServletUtils.parseIntOuZero(request.getParameter("page"));
        String tri = request.getParameter("tri");
        String ordre = request.getParameter("ordre");
        request.setAttribute("medecins", medecinService.getMedecinsByEtablissement(idEtablissement, filtre, page, tri, ordre));
        request.setAttribute("filtre", filtre);
        request.setAttribute("page", page);
        request.setAttribute("tri", tri);
        request.setAttribute("ordre", ordre);
        long totalCount = medecinService.countMedecinsByEtablissement(idEtablissement, filtre);
        int totalPages = (int) Math.ceil((double) totalCount / ServletUtils.TAILLE_PAGE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("afficherFormulaire", afficherFormulaire);
        ServletUtils.forward(request, response, "/WEB-INF/views/admin/medecins-liste.jsp");
    }

    private void afficherDetailMedecin(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws ServletException, IOException {
        Long idMedecin = ServletUtils.parseLongOuNull(request.getParameter("idMedecin"));
        if (idMedecin == null) {
            response.sendRedirect(request.getContextPath() + "/admin/medecins");
            return;
        }
        try {
            Medecin medecin = medecinService.getMedecinDetail(idMedecin, idEtablissement);
            request.setAttribute("medecin", medecin);
            request.setAttribute("rdvTotaux", medecinService.compterRdvTotaux(idMedecin));
            request.setAttribute("consultationsMois", medecinService.compterConsultationsMois(idMedecin, YearMonth.now()));
            request.setAttribute("prochainsRdv", medecinService.getProchainsRdv(idMedecin, 5));
            request.setAttribute("congesEnCours", medecinService.getCongesEnCours(idMedecin));
            ServletUtils.forward(request, response, "/WEB-INF/views/admin/medecin-detail.jsp");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins", e.getMessage());
        }
    }

    private void afficherFormulaireModifierMedecin(HttpServletRequest request, HttpServletResponse response,
                                                    Long idEtablissement) throws ServletException, IOException {
        Long idMedecin = ServletUtils.parseLongOuNull(request.getParameter("idMedecin"));
        if (idMedecin == null) {
            response.sendRedirect(request.getContextPath() + "/admin/medecins");
            return;
        }
        try {
            Medecin medecin = medecinService.getMedecinDetail(idMedecin, idEtablissement);
            request.setAttribute("medecin", medecin);
            ServletUtils.forward(request, response, "/WEB-INF/views/admin/medecin-modifier.jsp");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins", e.getMessage());
        }
    }

    private void traiterCreerMedecin(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String motDePasseTemporaire = request.getParameter("motDePasseTemporaire");

        if (fullName == null || fullName.isBlank()) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins",
                    ServletUtils.message(request, "error.validation.fullname.required"));
            return;
        }
        if (!ServletUtils.isValidMaxLength(fullName, ServletUtils.MAX_LENGTH)) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins",
                    ServletUtils.message(request, "error.validation.fullname.length"));
            return;
        }
        if (email == null || email.isBlank() || !ServletUtils.isValidEmail(email)) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins",
                    ServletUtils.message(request, "error.validation.email"));
            return;
        }
        if (motDePasseTemporaire == null || motDePasseTemporaire.length() < 8) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins",
                    ServletUtils.message(request, "error.validation.password.min"));
            return;
        }

        try {
            authService.creerCompteMedecin(fullName.trim(), email.trim(), motDePasseTemporaire, idEtablissement);
            response.sendRedirect(request.getContextPath() + "/admin/medecins?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins", e.getMessage());
        }
    }

    private void traiterModifierMedecin(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idMedecin = ServletUtils.parseLongOuNull(request.getParameter("idMedecin"));
        if (idMedecin == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins", "Médecin introuvable.");
            return;
        }

        MedecinService.ModifierMedecinDTO dto = new MedecinService.ModifierMedecinDTO();
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        if (fullName != null && !fullName.isBlank()) {
            if (!ServletUtils.isValidMaxLength(fullName, ServletUtils.MAX_LENGTH)) {
                ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins",
                        ServletUtils.message(request, "error.validation.fullname.length"));
                return;
            }
            dto.fullName = fullName.trim();
        }
        if (email != null && !email.isBlank()) {
            if (!ServletUtils.isValidEmail(email)) {
                ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins",
                        ServletUtils.message(request, "error.validation.email"));
                return;
            }
            dto.email = email.trim();
        }
        dto.specialite = ServletUtils.videSiVide(request.getParameter("specialite"));
        // numeroOrdre is NOT read from form - it stays readonly
        // dto.numeroOrdre = ServletUtils.videSiVide(request.getParameter("numeroOrdre"));
        String experienceStr = request.getParameter("experience");
        if (experienceStr != null && !experienceStr.isBlank()) {
            if (!ServletUtils.isExperienceValide(experienceStr)) {
                ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins",
                        ServletUtils.message(request, "error.validation.experience.negatif"));
                return;
            }
            dto.experience = Integer.parseInt(experienceStr.replaceAll("[^0-9\\-]", ""));
        }

        try {
            medecinService.modifierMedecin(idMedecin, idEtablissement, dto);
            response.sendRedirect(request.getContextPath()
                    + "/admin/medecins/detail?idMedecin=" + idMedecin + "&succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins", e.getMessage());
        }
    }

    private void traiterDesactiverMedecin(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idMedecin = ServletUtils.parseLongOuNull(request.getParameter("idMedecin"));
        if (idMedecin == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins", "Médecin introuvable.");
            return;
        }
        try {
            medecinService.desactiverMedecin(idMedecin, idEtablissement);
            response.sendRedirect(request.getContextPath() + "/admin/medecins?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/medecins", e.getMessage());
        }
    }

    private void afficherServices(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws ServletException, IOException {
        afficherServices(request, response, idEtablissement, false);
    }

    private void afficherServices(HttpServletRequest request, HttpServletResponse response, Long idEtablissement,
                                  boolean afficherFormulaire) throws ServletException, IOException {
        String filtre = request.getParameter("filtre");
        int page = ServletUtils.parseIntOuZero(request.getParameter("page"));
        request.setAttribute("services", serviceService.getAllServices(idEtablissement, filtre, page));
        request.setAttribute("categories", CategorieService.values());
        request.setAttribute("filtre", filtre);
        request.setAttribute("page", page);
        long totalCount = serviceService.countServices(idEtablissement, filtre);
        int totalPages = (int) Math.ceil((double) totalCount / ServletUtils.TAILLE_PAGE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("afficherFormulaire", afficherFormulaire);
        ServletUtils.forward(request, response, "/WEB-INF/views/admin/services.jsp");
    }

    private void afficherDetailService(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws ServletException, IOException {
        Long idService = ServletUtils.parseLongOuNull(request.getParameter("idService"));
        if (idService == null) {
            response.sendRedirect(request.getContextPath() + "/admin/services");
            return;
        }
        try {
            Service service = serviceService.getServiceDetail(idService, idEtablissement);
            request.setAttribute("service", service);
            request.setAttribute("rdvCeMois", serviceService.compterRdvCeMois(idService, YearMonth.now()));
            request.setAttribute("medecinsDistincts", serviceService.compterMedecinsAyantConsulte(idService));
            ServletUtils.forward(request, response, "/WEB-INF/views/admin/service-detail.jsp");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/services", e.getMessage());
        }
    }

    private void afficherFormulaireModifierService(HttpServletRequest request, HttpServletResponse response,
                                                    Long idEtablissement) throws ServletException, IOException {
        Long idService = ServletUtils.parseLongOuNull(request.getParameter("idService"));
        if (idService == null) {
            response.sendRedirect(request.getContextPath() + "/admin/services");
            return;
        }
        try {
            Service service = serviceService.getServiceById(idService, idEtablissement);
            request.setAttribute("service", service);
            request.setAttribute("categories", CategorieService.values());
            ServletUtils.forward(request, response, "/WEB-INF/views/admin/service-modifier.jsp");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/services", e.getMessage());
        }
    }

    private void traiterCreerService(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        try {
            ServiceService.ServiceDTO dto = new ServiceService.ServiceDTO(
                    ServletUtils.champRequis(request, "nom"),
                    CategorieService.valueOf(ServletUtils.champRequis(request, "categorie")));
            serviceService.creerService(idEtablissement, dto);
            response.sendRedirect(request.getContextPath() + "/admin/services?succes=1");
        } catch (BusinessException | IllegalArgumentException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/services", ServletUtils.message(request, "message.error.required_fields"));
        }
    }

    private void traiterModifierService(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idService = ServletUtils.parseLongOuNull(request.getParameter("idService"));
        if (idService == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/services", "Service introuvable.");
            return;
        }
        try {
            ServiceService.ServiceDTO dto = new ServiceService.ServiceDTO();
            dto.nom = ServletUtils.videSiVide(request.getParameter("nom"));
            String categorieStr = request.getParameter("categorie");
            if (categorieStr != null && !categorieStr.isBlank()) {
                dto.categorie = CategorieService.valueOf(categorieStr);
            }
            serviceService.modifierService(idService, idEtablissement, dto);
            response.sendRedirect(request.getContextPath() + "/admin/services?succes=1");
        } catch (BusinessException | IllegalArgumentException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/services", "Modification impossible.");
        }
    }

    private void traiterDesactiverService(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idService = ServletUtils.parseLongOuNull(request.getParameter("idService"));
        if (idService == null) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/services", "Service introuvable.");
            return;
        }
        try {
            serviceService.desactiverService(idService, idEtablissement);
            response.sendRedirect(request.getContextPath() + "/admin/services?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/services", e.getMessage());
        }
    }

    private void afficherConges(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws ServletException, IOException {
        String filtre = request.getParameter("filtre");
        int page = ServletUtils.parseIntOuZero(request.getParameter("page"));
        List<CongeMedecin> conges = congeService.getDemandesParEtablissement(idEtablissement, filtre, page);
        request.setAttribute("conges", conges);
        request.setAttribute("filtre", filtre);
        request.setAttribute("page", page);
        long totalCount = congeService.countDemandesParEtablissement(idEtablissement, filtre);
        int totalPages = (int) Math.ceil((double) totalCount / ServletUtils.TAILLE_PAGE);
        request.setAttribute("totalPages", totalPages);
        ServletUtils.forward(request, response, "/WEB-INF/views/admin/conges.jsp");
    }

    private void traiterApprouverConge(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idConge = ServletUtils.parseLongOuNull(request.getParameter("idConge"));
        try {
            congeService.approuverConge(idConge, idEtablissement);
            response.sendRedirect(request.getContextPath() + "/admin/conges?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/conges", e.getMessage());
        }
    }

    private void traiterRefuserConge(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idConge = ServletUtils.parseLongOuNull(request.getParameter("idConge"));
        try {
            congeService.refuserConge(idConge, idEtablissement);
            response.sendRedirect(request.getContextPath() + "/admin/conges?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/conges", e.getMessage());
        }
    }

    private void afficherReferenements(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws ServletException, IOException {
        int page = ServletUtils.parseIntOuZero(request.getParameter("page"));
        request.setAttribute("referenements", referenementService.getReferenementsParEtablissementDest(idEtablissement, page));
        request.setAttribute("page", page);
        long totalCount = referenementService.countReferenementsParEtablissementDest(idEtablissement);
        int totalPages = (int) Math.ceil((double) totalCount / ServletUtils.TAILLE_PAGE);
        request.setAttribute("totalPages", totalPages);
        ServletUtils.forward(request, response, "/WEB-INF/views/admin/referenements-liste.jsp");
    }

    private void traiterAccepterReferenement(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idRef = ServletUtils.parseLongOuNull(request.getParameter("idRef"));
        try {
            referenementService.accepterReferenement(idRef, idEtablissement);
            response.sendRedirect(request.getContextPath() + "/admin/referenements?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/referenements", e.getMessage());
        }
    }

    private void traiterRetourReferenement(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idRef = ServletUtils.parseLongOuNull(request.getParameter("idRef"));
        String retour = request.getParameter("retour");
        try {
            referenementService.enregistrerRetour(idRef, idEtablissement, retour);
            response.sendRedirect(request.getContextPath() + "/admin/referenements?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/referenements", e.getMessage());
        }
    }

    private void traiterCloturerReferenement(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws IOException {
        Long idRef = ServletUtils.parseLongOuNull(request.getParameter("idRef"));
        try {
            referenementService.cloturerReferenement(idRef, idEtablissement);
            response.sendRedirect(request.getContextPath() + "/admin/referenements?succes=1");
        } catch (BusinessException e) {
            ServletUtils.redirigerAvecErreur(request, response, "/admin/referenements", e.getMessage());
        }
    }

    private void afficherRapport(HttpServletRequest request, HttpServletResponse response, Long idEtablissement)
            throws ServletException, IOException {
        String moisStr = request.getParameter("mois");
        YearMonth mois = (moisStr != null && !moisStr.isBlank()) ? YearMonth.parse(moisStr) : YearMonth.now();

        Map<String, Object> rapport = rapportService.getRapportMensuel(idEtablissement, mois);
        request.setAttribute("rapport", rapport);
        request.setAttribute("mois", mois.toString());
        ServletUtils.forward(request, response, "/WEB-INF/views/admin/rapport.jsp");
    }
}
