package com.burundihealthconnect.servlet;

import com.burundihealthconnect.ejb.AuthService;
import com.burundihealthconnect.ejb.ProfilService;
import com.burundihealthconnect.ejb.ServiceService;
import com.burundihealthconnect.entity.enums.Role;
import com.burundihealthconnect.entity.enums.Sexe;
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
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * ProfilServlet — @WebServlet("/profil/*") [ETENDU]
 * Routes gérées (via getPathInfo()) :
 *   GET  /profil/completer              -> formulaire adapté au rôle (1er login)
 *   POST /profil/completer              -> traite la complétion (L01, L12 — délègue à AuthService)
 *   GET  /profil/mon-profil             -> affiche le profil courant
 *   POST /profil/mon-profil             -> modifie le profil courant (L25 — délègue à ProfilService)
 *   POST /profil/changer-mot-de-passe   -> change le mot de passe (L25)
 *
 * REGLE DE SECURITE : idUtilisateur et role proviennent EXCLUSIVEMENT de
 * la HttpSession, jamais d'un paramètre de requête.
 */
@WebServlet("/profil/*")
public class ProfilServlet extends HttpServlet {

    @Inject
    private ProfilService profilService;

    @Inject
    private AuthService authService;

    @Inject
    private ServiceService serviceService;

    // =========================================================
    // GET — affichage
    // =========================================================

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
        Role role = (Role) session.getAttribute(SessionKeys.ROLE);

        if (idUtilisateur == null) {
            response.sendRedirect(request.getContextPath() + "/auth");
            return;
        }

        if ("/completer".equals(pathInfo)) {
            afficherFormulaireCompletion(request, response, role);
        } else {
            try {
                ProfilService.ProfilDTO dto = profilService.getMonProfil(idUtilisateur, role);
                request.setAttribute("profil", dto);
                forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
            } catch (Exception e) {
                request.setAttribute("erreur", "Impossible de charger votre profil : " + e.getMessage());
                forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
            }
        }
    }

    private void afficherFormulaireCompletion(HttpServletRequest request, HttpServletResponse response, Role role)
            throws ServletException, IOException {
        if (role == null) {
            response.sendRedirect(request.getContextPath() + "/auth");
        } else if (role == Role.PATIENT) {
            forward(request, response, "/WEB-INF/views/profil/completer-patient.jsp");
        } else if (role == Role.MEDECIN) {
            HttpSession session = request.getSession(false);
            Long idEtablissement = (Long) session.getAttribute(SessionKeys.ID_ETABLISSEMENT);
            if (idEtablissement != null) {
                request.setAttribute("services", serviceService.getServicesActifsByEtablissement(idEtablissement));
            }
            request.setAttribute("prochainNumeroOrdre", authService.genererNumeroOrdre());
            forward(request, response, "/WEB-INF/views/profil/completer-medecin.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/auth");
        }
    }

    // =========================================================
    // POST — traitement
    // =========================================================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/auth");
            return;
        }
        Long idUtilisateur = (Long) session.getAttribute(SessionKeys.ID_UTILISATEUR);
        Role role = (Role) session.getAttribute(SessionKeys.ROLE);

        if (idUtilisateur == null) {
            response.sendRedirect(request.getContextPath() + "/auth");
            return;
        }

        if ("/completer".equals(pathInfo)) {
            traiterCompletion(request, response, session, idUtilisateur, role);
        } else if ("/changer-mot-de-passe".equals(pathInfo)) {
            traiterChangementMotDePasse(request, response, idUtilisateur);
        } else {
            traiterModificationProfil(request, response, session, idUtilisateur, role);
        }
    }

    // =========================================================
    // COMPLETION DE PROFIL — L01, L12 (délègue à AuthService)
    // =========================================================

    private void traiterCompletion(HttpServletRequest request, HttpServletResponse response,
                                    HttpSession session, Long idUtilisateur, Role role)
            throws ServletException, IOException {
        try {
            if (role == Role.PATIENT) {
                // L22 — Validation manuelle des champs requis
                String dateNaissanceStr = champRequis(request, "dateNaissance");
                String sexeStr = champRequis(request, "sexe");

                LocalDate dateNaissance = LocalDate.parse(dateNaissanceStr);
                Sexe sexe = Sexe.valueOf(sexeStr);
                String telephone = request.getParameter("telephone");
                String groupeSanguin = request.getParameter("groupeSanguin");
                String allergies = request.getParameter("allergies");
                String adresse = request.getParameter("adresse");

                if (telephone != null && !telephone.isBlank() && !isValidTelephone(telephone)) {
                    request.setAttribute("erreur", message(request, "error.validation.telephone"));
                    afficherFormulaireCompletion(request, response, role);
                    return;
                }
                if (!isValidMaxLength(adresse, 200)) {
                    request.setAttribute("erreur", message(request, "error.validation.maxlength")
                            .replace("{0}", "Adresse").replace("{1}", "200"));
                    afficherFormulaireCompletion(request, response, role);
                    return;
                }

                com.burundihealthconnect.entity.Patient patient = authService.completerProfilPatient(
                        idUtilisateur, dateNaissance, sexe, telephone, groupeSanguin, allergies, adresse);

                session.setAttribute(SessionKeys.PROFIL_COMPLETE, true);
                session.setAttribute(SessionKeys.ID_PATIENT, patient.getIdPatient());
                response.sendRedirect(request.getContextPath() + "/patient/dashboard");

            } else if (role == Role.MEDECIN) {
                String specialite = champRequis(request, "specialite");
                String idServiceStr = champRequis(request, "idService");
                String experienceStr = request.getParameter("experience");
                if (experienceStr != null && !experienceStr.isBlank() && !isExperienceValide(experienceStr)) {
                    request.setAttribute("erreur", message(request, "error.validation.experience.negatif"));
                    afficherFormulaireCompletion(request, response, role);
                    return;
                }
                Integer experience = (experienceStr != null && !experienceStr.isBlank())
                        ? Integer.parseInt(experienceStr.replaceAll("[^0-9\\-]", "")) : null;

                com.burundihealthconnect.entity.Medecin medecin =
                        authService.completerProfilMedecin(idUtilisateur, specialite, experience, Long.valueOf(idServiceStr));

                session.setAttribute(SessionKeys.PROFIL_COMPLETE, true);
                session.setAttribute(SessionKeys.ID_MEDECIN, medecin.getIdMedecin());
                response.sendRedirect(request.getContextPath() + "/medecin/dashboard");

            } else {
                response.sendRedirect(request.getContextPath() + "/auth");
            }
        } catch (BusinessException e) {
            request.setAttribute("erreur", e.getMessage());
            afficherFormulaireCompletion(request, response, role);
        }
    }

    // =========================================================
    // MODIFICATION DE PROFIL — L25
    // =========================================================

    private void traiterModificationProfil(HttpServletRequest request, HttpServletResponse response,
                                            HttpSession session, Long idUtilisateur, Role role)
            throws ServletException, IOException {
        try {
            ProfilService.ModifierProfilDTO dto = new ProfilService.ModifierProfilDTO();
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            if (fullName != null && !fullName.isBlank()) {
                if (!isValidMaxLength(fullName, MAX_LENGTH)) {
                    request.setAttribute("erreur", message(request, "error.validation.fullname.length"));
                    ProfilService.ProfilDTO profilActuel = profilService.getMonProfil(idUtilisateur, role);
                    request.setAttribute("profil", profilActuel);
                    forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
                    return;
                }
                dto.fullName = fullName.trim();
            }
            if (email != null && !email.isBlank()) {
                if (!isValidEmail(email)) {
                    request.setAttribute("erreur", message(request, "error.validation.email"));
                    ProfilService.ProfilDTO profilActuel = profilService.getMonProfil(idUtilisateur, role);
                    request.setAttribute("profil", profilActuel);
                    forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
                    return;
                }
                dto.email = email.trim();
            }
            String telephone = request.getParameter("telephone");
            if (telephone != null && !telephone.isBlank()) {
                if (!isValidTelephone(telephone)) {
                    request.setAttribute("erreur", message(request, "error.validation.telephone"));
                    ProfilService.ProfilDTO profilActuel = profilService.getMonProfil(idUtilisateur, role);
                    request.setAttribute("profil", profilActuel);
                    forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
                    return;
                }
                dto.telephone = telephone.trim();
            }
            dto.adresse = videSiVide(request.getParameter("adresse"));
            dto.allergies = videSiVide(request.getParameter("allergies"));
            dto.groupeSanguin = videSiVide(request.getParameter("groupeSanguin"));
            dto.specialite = videSiVide(request.getParameter("specialite"));
            String experienceStr = request.getParameter("experience");
            if (experienceStr != null && !experienceStr.isBlank()) {
                if (!isExperienceValide(experienceStr)) {
                    request.setAttribute("erreur", message(request, "error.validation.experience.negatif"));
                    ProfilService.ProfilDTO profilActuel = profilService.getMonProfil(idUtilisateur, role);
                    request.setAttribute("profil", profilActuel);
                    forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
                    return;
                }
                dto.experience = Integer.parseInt(experienceStr.replaceAll("[^0-9\\-]", ""));
            }
            // IMPORTANT (L25) : aucune ligne ici ne lit un paramètre "numeroOrdre" —
            // ModifierProfilDTO ne possède même pas ce champ.

            profilService.modifierMonProfil(idUtilisateur, role, dto);

            if (dto.fullName != null) {
                session.setAttribute(SessionKeys.FULL_NAME, dto.fullName);
            }

            request.setAttribute("succes", message(request, "message.success.profil_updated"));
            ProfilService.ProfilDTO profilMisAJour = profilService.getMonProfil(idUtilisateur, role);
            request.setAttribute("profil", profilMisAJour);
            forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");

        } catch (BusinessException e) {
            request.setAttribute("erreur", e.getMessage());
            ProfilService.ProfilDTO profilActuel = profilService.getMonProfil(idUtilisateur, role);
            request.setAttribute("profil", profilActuel);
            forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
        }
    }

    private void traiterChangementMotDePasse(HttpServletRequest request, HttpServletResponse response,
                                              Long idUtilisateur)
            throws ServletException, IOException {
        String ancien = request.getParameter("ancienMotDePasse");
        String nouveau = request.getParameter("nouveauMotDePasse");
        String confirmation = request.getParameter("confirmationMotDePasse");

        if (nouveau == null || !nouveau.equals(confirmation)) {
            request.setAttribute("erreur", message(request, "message.error.password_mismatch"));
            forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
            return;
        }
        if (!isValidMaxLength(nouveau, 50)) {
            request.setAttribute("erreur", message(request, "error.validation.maxlength")
                    .replace("{0}", "Mot de passe").replace("{1}", "50"));
            forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
            return;
        }

        try {
            profilService.changerMotDePasse(idUtilisateur, ancien, nouveau);
            request.setAttribute("succes", message(request, "message.success.password_changed"));
        } catch (BusinessException e) {
            request.setAttribute("erreur", e.getMessage());
        }
        forward(request, response, "/WEB-INF/views/profil/mon-profil.jsp");
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

    private String champRequis(HttpServletRequest request, String nom) {
        String valeur = request.getParameter(nom);
        if (valeur == null || valeur.isBlank()) {
            throw new BusinessException("Le champ '" + nom + "' est obligatoire.");
        }
        return valeur;
    }

    private String videSiVide(String valeur) {
        return (valeur == null || valeur.isBlank()) ? null : valeur.trim();
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