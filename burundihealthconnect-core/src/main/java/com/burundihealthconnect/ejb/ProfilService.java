package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.Patient;
import com.burundihealthconnect.entity.Utilisateur;
import com.burundihealthconnect.entity.enums.Role;
import com.burundihealthconnect.exception.AccesInterditException;
import com.burundihealthconnect.exception.EntiteIntrouvableException;
import com.burundihealthconnect.exception.MotDePasseIncorrectException;
import com.burundihealthconnect.util.PasswordHasher;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

/**
 * ProfilService — Session Bean Stateless.
 * Logique couverte : L25 (modification du propre profil par chaque
 * utilisateur, changement de mot de passe).
 *
 * REGLE DE SECURITE CAPITALE :
 * Toutes les méthodes de ce bean prennent idUtilisateur en paramètre,
 * et CET ID DOIT PROVENIR EXCLUSIVEMENT DE LA HttpSession côté Servlet
 * — jamais d'un paramètre de formulaire. Le Servlet appelant est
 * responsable de cette règle ; ce bean fait confiance à l'id reçu.
 */
@Stateless
public class ProfilService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    /**
     * Charge le profil complet de l'utilisateur connecté, adapté à son rôle.
     * PATIENT  -> renvoie aussi l'entité Patient associée
     * MEDECIN  -> renvoie aussi l'entité Medecin associée
     * ADMIN / SUPER_ADMIN -> Utilisateur seul (pas de table spécifique)
     */
    public ProfilDTO getMonProfil(Long idUtilisateur, Role role) {
        Utilisateur utilisateur = em.find(Utilisateur.class, idUtilisateur);
        if (utilisateur == null) {
            throw new EntiteIntrouvableException("Utilisateur", idUtilisateur);
        }

        ProfilDTO dto = new ProfilDTO();
        dto.utilisateur = utilisateur;

        if (role == Role.PATIENT) {
            dto.patient = chargerPatientParUtilisateur(idUtilisateur);
        } else if (role == Role.MEDECIN) {
            dto.medecin = chargerMedecinParUtilisateur(idUtilisateur);
        }
        // ADMIN / SUPER_ADMIN : seul utilisateur est renseigné

        return dto;
    }

    /**
     * Modifie le profil de l'utilisateur connecté selon son rôle.
     * Chaque rôle ne peut modifier QUE ses champs autorisés (L25) :
     * - PATIENT  : full_name, telephone, adresse, allergies, groupe_sanguin
     * - MEDECIN  : full_name, telephone, specialite, experience
     *              (JAMAIS numero_ordre — réservé à l'ADMIN, L23)
     * - ADMIN / SUPER_ADMIN : full_name, email
     *
     * @throws AccesInterditException si idUtilisateur ne correspond à rien,
     *         ou si on tente de modifier un champ non autorisé pour ce rôle
     */
    public void modifierMonProfil(Long idUtilisateur, Role role, ModifierProfilDTO dto) {
        Utilisateur utilisateur = em.find(Utilisateur.class, idUtilisateur);
        if (utilisateur == null) {
            throw new EntiteIntrouvableException("Utilisateur", idUtilisateur);
        }
        if (utilisateur.getRole() != role) {
            throw new AccesInterditException("Rôle incohérent avec la session.");
        }

        switch (role) {
            case PATIENT:
                modifierProfilPatient(utilisateur, dto);
                break;
            case MEDECIN:
                modifierProfilMedecin(utilisateur, dto);
                break;
            case ADMIN:
            case SUPER_ADMIN:
                modifierProfilAdmin(utilisateur, dto);
                break;
            default:
                throw new AccesInterditException("Rôle non géré pour la modification de profil.");
        }
    }

    /**
     * Change le mot de passe de l'utilisateur connecté.
     *
     * @throws MotDePasseIncorrectException si l'ancien mot de passe est faux
     * @throws AccesInterditException si le nouveau mot de passe ne respecte
     *         pas la règle minimale (>= 8 caractères)
     */
    public void changerMotDePasse(Long idUtilisateur, String ancienMotDePasse, String nouveauMotDePasse) {
        Utilisateur utilisateur = em.find(Utilisateur.class, idUtilisateur);
        if (utilisateur == null) {
            throw new EntiteIntrouvableException("Utilisateur", idUtilisateur);
        }

        if (!PasswordHasher.verifier(ancienMotDePasse, utilisateur.getPasswordHash())) {
            throw new MotDePasseIncorrectException();
        }
        if (nouveauMotDePasse == null || nouveauMotDePasse.length() < 8) {
            throw new AccesInterditException("Le nouveau mot de passe doit contenir au moins 8 caractères.");
        }

        utilisateur.setPasswordHash(PasswordHasher.hash(nouveauMotDePasse));
        em.merge(utilisateur);

        auditService.enregistrer("CHANGEMENT_MDP", "AUTH", "INFO", "UTILISATEUR",
                idUtilisateur, "Mot de passe modifié", null, null);
    }

    // =========================================================
    // METHODES PRIVEES
    // =========================================================

    private Patient chargerPatientParUtilisateur(Long idUtilisateur) {
        try {
            TypedQuery<Patient> q = em.createQuery(
                    "SELECT p FROM Patient p WHERE p.utilisateur.idUtilisateur = :id", Patient.class);
            q.setParameter("id", idUtilisateur);
            return q.getSingleResult();
        } catch (NoResultException e) {
            throw new EntiteIntrouvableException("Patient (profil non encore complété ?)", idUtilisateur);
        }
    }

    private Medecin chargerMedecinParUtilisateur(Long idUtilisateur) {
        try {
            TypedQuery<Medecin> q = em.createQuery(
                    "SELECT m FROM Medecin m WHERE m.utilisateur.idUtilisateur = :id", Medecin.class);
            q.setParameter("id", idUtilisateur);
            return q.getSingleResult();
        } catch (NoResultException e) {
            throw new EntiteIntrouvableException("Medecin (profil non encore complété ?)", idUtilisateur);
        }
    }

    private void modifierProfilPatient(Utilisateur utilisateur, ModifierProfilDTO dto) {
        if (dto.fullName != null) {
            utilisateur.setFullName(dto.fullName);
        }
        em.merge(utilisateur);

        Patient patient = chargerPatientParUtilisateur(utilisateur.getIdUtilisateur());
        if (dto.telephone != null) {
            patient.setTelephone(dto.telephone);
        }
        if (dto.adresse != null) {
            patient.setAdresse(dto.adresse);
        }
        if (dto.allergies != null) {
            patient.setAllergies(dto.allergies);
        }
        if (dto.groupeSanguin != null) {
            patient.setGroupeSanguin(dto.groupeSanguin);
        }
        em.merge(patient);
    }

    private void modifierProfilMedecin(Utilisateur utilisateur, ModifierProfilDTO dto) {
        if (dto.fullName != null) {
            utilisateur.setFullName(dto.fullName);
        }
        em.merge(utilisateur);

        Medecin medecin = chargerMedecinParUtilisateur(utilisateur.getIdUtilisateur());
        if (dto.specialite != null) {
            medecin.setSpecialite(dto.specialite);
        }
        if (dto.experience != null) {
            medecin.setExperience(dto.experience);
        }
        // IMPORTANT (L25) : numero_ordre n'est JAMAIS lu depuis ce DTO,
        // même si le formulaire JSP venait à en contenir un par erreur —
        // aucune ligne ici ne touche medecin.setNumeroOrdre().
        em.merge(medecin);
    }

    private void modifierProfilAdmin(Utilisateur utilisateur, ModifierProfilDTO dto) {
        if (dto.fullName != null) {
            utilisateur.setFullName(dto.fullName);
        }
        if (dto.email != null) {
            utilisateur.setEmail(dto.email);
        }
        em.merge(utilisateur);
    }

    // =========================================================
    // DTOs internes simples (pas de bibliothèque externe)
    // =========================================================

    /** Conteneur de retour pour getMonProfil() — regroupe utilisateur + profil spécifique. */
    public static class ProfilDTO {
        public Utilisateur utilisateur;
        public Patient patient;
        public Medecin medecin;

        public Utilisateur getUtilisateur() { return utilisateur; }
        public Patient getPatient() { return patient; }
        public Medecin getMedecin() { return medecin; }
    }

    /** Conteneur d'entrée pour modifierMonProfil() — champs nullables = non modifiés. */
    public static class ModifierProfilDTO {
        public String fullName;
        public String email;
        public String telephone;
        public String adresse;
        public String allergies;
        public String groupeSanguin;
        public String specialite;
        public Integer experience;
    }
}