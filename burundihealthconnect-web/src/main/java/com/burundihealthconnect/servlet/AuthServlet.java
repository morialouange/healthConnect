package com.burundihealthconnect.servlet;

import com.burundihealthconnect.ejb.AuthService;
import com.burundihealthconnect.ejb.ProfilService;
import com.burundihealthconnect.entity.Utilisateur;
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

/**
 * AuthServlet — @WebServlet("/auth")
 * doGet  : affiche login (défaut) / register (?action=register) / logout (?action=logout)
 * doPost : traite login (défaut) / inscription patient (?action=register)
 *
 * L13 — Après login réussi : redirection intelligente selon role + profilComplete.
 * L22 — Toute donnée de formulaire est revalidée manuellement ici.
 */
@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    @Inject
    private AuthService authService;

    @Inject
    private ProfilService profilService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("logout".equals(action)) {
            traiterLogout(request, response);
            return;
        }

        if ("register".equals(action)) {
            ServletUtils.forward(request, response, "/WEB-INF/views/auth/register.jsp");
        } else {
            ServletUtils.forward(request, response, "/WEB-INF/views/auth/login.jsp");
        }
    }

    /** Invalide la HttpSession et redirige vers la page de login. */
    private void traiterLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Long idUtilisateur = (Long) session.getAttribute(SessionKeys.ID_UTILISATEUR);
            if (idUtilisateur != null) {
                authService.logout(idUtilisateur);
            }
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/auth");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("register".equals(action)) {
            traiterInscription(request, response);
        } else {
            traiterLogin(request, response);
        }
    }

    // =========================================================
    // LOGIN — L13
    // =========================================================

    private void traiterLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String motDePasse = request.getParameter("motDePasse");

        if (email == null || email.isBlank() || motDePasse == null || motDePasse.isBlank()) {
            request.setAttribute("erreur", ServletUtils.message(request, "message.error.required_fields"));
            ServletUtils.forward(request, response, "/WEB-INF/views/auth/login.jsp");
            return;
        }
        if (!ServletUtils.isValidEmail(email.trim())) {
            request.setAttribute("erreur", ServletUtils.message(request, "error.validation.email"));
            ServletUtils.forward(request, response, "/WEB-INF/views/auth/login.jsp");
            return;
        }

        try {
            Utilisateur utilisateur = authService.login(email.trim(), motDePasse);
            ouvrirSession(request, utilisateur);

            response.sendRedirect(request.getContextPath() + urlApresLogin(utilisateur));

        } catch (BusinessException e) {
            request.setAttribute("erreur", e.getMessage());
            ServletUtils.forward(request, response, "/WEB-INF/views/auth/login.jsp");
        }
    }

    /** L13 — Détermine la destination après login selon le rôle et l'état du profil. */
    private String urlApresLogin(Utilisateur utilisateur) {
        boolean profilRequis = (utilisateur.getRole() == Role.PATIENT || utilisateur.getRole() == Role.MEDECIN);

        if (profilRequis && !Boolean.TRUE.equals(utilisateur.getProfilComplete())) {
            return "/profil/completer";
        }

        switch (utilisateur.getRole()) {
            case PATIENT:
                return "/patient/dashboard";
            case MEDECIN:
                return "/medecin/dashboard";
            case ADMIN:
                return "/admin/dashboard";
            case SUPER_ADMIN:
                return "/superadmin/hopitaux";
            default:
                return "/auth";
        }
    }

    /** Crée la HttpSession et y place toutes les informations nécessaires au filtre + aux Servlets. */
    private void ouvrirSession(HttpServletRequest request, Utilisateur utilisateur) {
        HttpSession session = request.getSession(true);
        session.setAttribute(SessionKeys.ID_UTILISATEUR, utilisateur.getIdUtilisateur());
        session.setAttribute(SessionKeys.ROLE, utilisateur.getRole());
        if (utilisateur.getEtablissement() != null) {
            session.setAttribute(SessionKeys.ID_ETABLISSEMENT, utilisateur.getEtablissement().getIdEtablissement());
        }
        session.setAttribute(SessionKeys.PROFIL_COMPLETE, utilisateur.getProfilComplete());
        session.setAttribute(SessionKeys.FULL_NAME, utilisateur.getFullName());

        // Si le profil est déjà complété (pas un 1er login), on charge tout de
        // suite idPatient/idMedecin pour que PatientServlet/MedecinServlet
        // n'aient jamais à les recalculer à chaque requête.
        if (Boolean.TRUE.equals(utilisateur.getProfilComplete())) {
            if (utilisateur.getRole() == Role.PATIENT) {
                ProfilService.ProfilDTO dto = profilService.getMonProfil(
                        utilisateur.getIdUtilisateur(), Role.PATIENT);
                if (dto.patient != null) {
                    session.setAttribute(SessionKeys.ID_PATIENT, dto.patient.getIdPatient());
                }
            } else if (utilisateur.getRole() == Role.MEDECIN) {
                ProfilService.ProfilDTO dto = profilService.getMonProfil(
                        utilisateur.getIdUtilisateur(), Role.MEDECIN);
                if (dto.medecin != null) {
                    session.setAttribute(SessionKeys.ID_MEDECIN, dto.medecin.getIdMedecin());
                }
            }
        }
    }

    // =========================================================
    // INSCRIPTION PATIENT — L03, L12
    // =========================================================

    private void traiterInscription(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String motDePasse = request.getParameter("motDePasse");
        String confirmationMotDePasse = request.getParameter("confirmationMotDePasse");

        StringBuilder erreurs = new StringBuilder();
        if (fullName == null || fullName.isBlank()) {
            erreurs.append(ServletUtils.message(request, "error.validation.fullname.required")).append(" ");
        } else if (!ServletUtils.isValidMaxLength(fullName, ServletUtils.MAX_LENGTH)) {
            erreurs.append(ServletUtils.message(request, "error.validation.fullname.length")).append(" ");
        }
        if (email == null || email.isBlank() || !ServletUtils.isValidEmail(email)) {
            erreurs.append(ServletUtils.message(request, "error.validation.email")).append(" ");
        }
        if (motDePasse == null || motDePasse.isBlank()) {
            erreurs.append(ServletUtils.message(request, "error.validation.password.required")).append(" ");
        } else if (motDePasse.length() < 8) {
            erreurs.append(ServletUtils.message(request, "error.validation.password.min")).append(" ");
        }
        if (motDePasse != null && !motDePasse.equals(confirmationMotDePasse)) {
            erreurs.append(ServletUtils.message(request, "message.error.password_mismatch")).append(" ");
        }
        // Patient non rattaché à un établissement — champ ignoré

        if (erreurs.length() > 0) {
            request.setAttribute("erreur", erreurs.toString());
            ServletUtils.forward(request, response, "/WEB-INF/views/auth/register.jsp");
            return;
        }

        try {
            authService.inscrirePatient(fullName.trim(), email.trim(), motDePasse);
            request.setAttribute("succes", ServletUtils.message(request, "message.success.inscription"));
            ServletUtils.forward(request, response, "/WEB-INF/views/auth/login.jsp");

        } catch (BusinessException e) {
            request.setAttribute("erreur", e.getMessage());
            ServletUtils.forward(request, response, "/WEB-INF/views/auth/register.jsp");
        }
    }
}