package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.DossierMedical;
import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.Patient;
import com.burundihealthconnect.entity.Service;
import com.burundihealthconnect.entity.Utilisateur;
import com.burundihealthconnect.entity.enums.Role;
import com.burundihealthconnect.entity.enums.Sexe;
import com.burundihealthconnect.exception.AccesInterditException;
import com.burundihealthconnect.exception.DoublonPatientException;
import com.burundihealthconnect.exception.EntiteIntrouvableException;
import com.burundihealthconnect.util.PasswordHasher;

import com.burundihealthconnect.ejb.AuditService;
import jakarta.inject.Inject;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Year;
import java.util.List;

/**
 * AuthService — Session Bean Stateless.
 * Logiques couvertes : L01 (génération numéros), L03 (doublon patient),
 * L12 (inscription + complétion profil en 2 temps), L13 (redirection
 * intelligente).
 */
@Stateless
public class AuthService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    // =========================================================
    // LOGIN / LOGOUT
    // =========================================================

    public Utilisateur login(String email, String motDePasseClair) {
        Utilisateur utilisateur;
        try {
            TypedQuery<Utilisateur> query = em.createQuery(
                    "SELECT u FROM Utilisateur u WHERE u.email = :email", Utilisateur.class);
            query.setParameter("email", email);
            utilisateur = query.getSingleResult();
        } catch (NoResultException e) {
            auditService.enregistrer("CONNEXION_ECHOUEE", "AUTH", "WARNING", null, null, "Échec connexion: email introuvable", null, null);
            throw new AccesInterditException("Email ou mot de passe incorrect.");
        }

        if (!Boolean.TRUE.equals(utilisateur.getActif())) {
            auditService.enregistrer("CONNEXION_ECHOUEE", "AUTH", "WARNING", null, null, "Échec connexion: compte désactivé", null, null);
            throw new AccesInterditException("Ce compte a été désactivé. Contactez votre administrateur.");
        }

        if (!PasswordHasher.verifier(motDePasseClair, utilisateur.getPasswordHash())) {
            auditService.enregistrer("CONNEXION_ECHOUEE", "AUTH", "WARNING", null, null, "Échec connexion", null, null);
            throw new AccesInterditException("Email ou mot de passe incorrect.");
        }

        // Migration transparente : un ancien hash (SHA-256) est converti en
        // bcrypt à la prochaine connexion réussie, pour durcir le stockage.
        if (!PasswordHasher.estBcrypt(utilisateur.getPasswordHash())) {
            utilisateur.setPasswordHash(PasswordHasher.hash(motDePasseClair));
        }

        utilisateur.setDerniereConnexion(LocalDateTime.now());
        em.merge(utilisateur);
        auditService.enregistrer("CONNEXION", "AUTH", "INFO", "UTILISATEUR", utilisateur.getIdUtilisateur(), "Connexion réussie: " + email, utilisateur, null);
        return utilisateur;
    }

    public void logout(Long idUtilisateur) {
        auditService.enregistrer("DECONNEXION", "AUTH", "INFO", "UTILISATEUR", idUtilisateur, "Déconnexion", null, null);
        // Aucune opération base de données nécessaire pour le logout.
    }

    // =========================================================
    // INSCRIPTION (PATIENT) — L03, L12
    // =========================================================

    public boolean patientDejaExistant(String email) {
        TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(u) FROM Utilisateur u WHERE u.email = :email", Long.class);
        query.setParameter("email", email);
        return query.getSingleResult() > 0;
    }

    public Utilisateur inscrirePatient(String fullName, String email, String motDePasseClair) {
        if (patientDejaExistant(email)) {
            throw new DoublonPatientException(email);
        }

        Utilisateur utilisateur = new Utilisateur();
        utilisateur.setFullName(fullName);
        utilisateur.setEmail(email);
        utilisateur.setPasswordHash(PasswordHasher.hash(motDePasseClair));
        utilisateur.setRole(Role.PATIENT);
        utilisateur.setActif(true);
        utilisateur.setProfilComplete(false);

        em.persist(utilisateur);
        em.flush();
        auditService.enregistrer("CREATION_PATIENT", "PATIENT", "INFO", "PATIENT", utilisateur.getIdUtilisateur(), "Création patient: " + email, utilisateur, null);
        return utilisateur;
    }

    /** L23 — L'ADMIN crée un compte MEDECIN pour son établissement. */
    public Utilisateur creerCompteMedecin(String fullName, String email, String motDePasseTemporaire,
                                           Long idEtablissement) {
        if (patientDejaExistant(email)) {
            throw new DoublonPatientException(email);
        }
        EtablissementSante etablissement = em.find(EtablissementSante.class, idEtablissement);
        if (etablissement == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
        }

        Utilisateur utilisateur = new Utilisateur();
        utilisateur.setEtablissement(etablissement);
        utilisateur.setFullName(fullName);
        utilisateur.setEmail(email);
        utilisateur.setPasswordHash(PasswordHasher.hash(motDePasseTemporaire));
        utilisateur.setRole(Role.MEDECIN);
        utilisateur.setActif(true);
        utilisateur.setProfilComplete(false);
        em.persist(utilisateur);
        em.flush();
        auditService.enregistrer("CREATION_MEDECIN", "MEDECIN", "INFO", "MEDECIN", utilisateur.getIdUtilisateur(), "Création médecin: " + email, utilisateur, null);
        return utilisateur;
    }

    /** Le SUPER_ADMIN crée un compte ADMIN pour un établissement du réseau. */
    public Utilisateur creerCompteAdmin(String fullName, String email, String motDePasseTemporaire,
                                         Long idEtablissement) {
        if (patientDejaExistant(email)) {
            throw new DoublonPatientException(email);
        }
        EtablissementSante etablissement = em.find(EtablissementSante.class, idEtablissement);
        if (etablissement == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
        }

        Utilisateur utilisateur = new Utilisateur();
        utilisateur.setEtablissement(etablissement);
        utilisateur.setFullName(fullName);
        utilisateur.setEmail(email);
        utilisateur.setPasswordHash(PasswordHasher.hash(motDePasseTemporaire));
        utilisateur.setRole(Role.ADMIN);
        utilisateur.setActif(true);
        utilisateur.setProfilComplete(true);
        em.persist(utilisateur);
        em.flush();
        return utilisateur;
    }

    // =========================================================
    // COMPLETION DE PROFIL (1er login) — L01, L12
    // =========================================================

    public Patient completerProfilPatient(Long idUtilisateur, LocalDate dateNaissance, Sexe sexe,
                                           String telephone, String groupeSanguin,
                                           String allergies, String adresse) {

        Utilisateur utilisateur = em.find(Utilisateur.class, idUtilisateur);
        if (utilisateur == null) {
            throw new EntiteIntrouvableException("Utilisateur", idUtilisateur);
        }
        if (utilisateur.getRole() != Role.PATIENT) {
            throw new AccesInterditException("Seul un PATIENT peut compléter ce profil.");
        }
        if (Boolean.TRUE.equals(utilisateur.getProfilComplete())) {
            throw new AccesInterditException("Le profil a déjà été complété.");
        }

        Patient patient = new Patient();
        patient.setUtilisateur(utilisateur);
        patient.setNumeroPatient(genererNumeroPatient());
        patient.setDateNaissance(dateNaissance);
        patient.setSexe(sexe);
        patient.setTelephone(telephone);
        patient.setGroupeSanguin(groupeSanguin);
        patient.setAllergies(allergies);
        patient.setAdresse(adresse);
        em.persist(patient);
        em.flush();

        DossierMedical dossier = new DossierMedical();
        dossier.setPatient(patient);
        dossier.setNumeroUnique(genererNumeroDossier());
        em.persist(dossier);

        utilisateur.setProfilComplete(true);
        em.merge(utilisateur);

        return patient;
    }

    public Medecin completerProfilMedecin(Long idUtilisateur, String specialite, Integer experience, Long idService) {
        Utilisateur utilisateur = em.find(Utilisateur.class, idUtilisateur);
        if (utilisateur == null) {
            throw new EntiteIntrouvableException("Utilisateur", idUtilisateur);
        }
        if (utilisateur.getRole() != Role.MEDECIN) {
            throw new AccesInterditException("Seul un MEDECIN peut compléter ce profil.");
        }
        if (Boolean.TRUE.equals(utilisateur.getProfilComplete())) {
            throw new AccesInterditException("Le profil a déjà été complété.");
        }
        if (idService == null) {
            throw new AccesInterditException("Veuillez sélectionner un service de rattachement.");
        }

        EtablissementSante etablissement = utilisateur.getEtablissement();
        Service service = em.find(Service.class, idService);
        if (service == null || !service.getActif()
                || !service.getEtablissement().getIdEtablissement().equals(etablissement.getIdEtablissement())) {
            throw new AccesInterditException("Le service sélectionné n'existe pas ou n'appartient pas à votre établissement.");
        }

        Medecin medecin = new Medecin();
        medecin.setUtilisateur(utilisateur);
        medecin.setService(service);
        medecin.setSpecialite(specialite);
        medecin.setExperience(experience);
        medecin.setNumeroOrdre(genererNumeroOrdre());
        em.persist(medecin);

        utilisateur.setProfilComplete(true);
        em.merge(utilisateur);

        return medecin;
    }

    // =========================================================
    // GESTION DES ADMINISTRATEURS (SUPER_ADMIN)
    // =========================================================

    /** SUPER_ADMIN — Liste tous les comptes ADMIN du réseau. */
    public List<Utilisateur> findAllAdmins() {
        List<Utilisateur> result = em.createQuery(
                        "SELECT u FROM Utilisateur u JOIN FETCH u.etablissement WHERE u.role = :role ORDER BY u.etablissement.nom, u.fullName",
                        Utilisateur.class)
                .setParameter("role", Role.ADMIN)
                .getResultList();
        return result;
    }

    /** SUPER_ADMIN — Trouve un utilisateur par son ID. */
    public Utilisateur getUtilisateurById(Long idUtilisateur) {
        Utilisateur u = em.find(Utilisateur.class, idUtilisateur);
        if (u == null) {
            throw new EntiteIntrouvableException("Utilisateur", idUtilisateur);
        }
        if (u.getEtablissement() != null) {
            u.getEtablissement().getIdEtablissement();
        }
        return u;
    }

    /** SUPER_ADMIN — Modifie les infos d'un compte ADMIN (nom, email, établissement). */
    public void modifierAdmin(Long idUtilisateur, String fullName, String email, Long idEtablissement) {
        Utilisateur utilisateur = getUtilisateurById(idUtilisateur);
        if (utilisateur.getRole() != Role.ADMIN) {
            throw new AccesInterditException("Seul un compte ADMIN peut être modifié via cette méthode.");
        }
        if (fullName != null && !fullName.isBlank()) {
            utilisateur.setFullName(fullName.trim());
        }
        if (email != null && !email.isBlank()) {
            utilisateur.setEmail(email.trim());
        }
        if (idEtablissement != null) {
            EtablissementSante etablissement = em.find(EtablissementSante.class, idEtablissement);
            if (etablissement == null) {
                throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
            }
            utilisateur.setEtablissement(etablissement);
        }
        em.merge(utilisateur);
    }

    /** SUPER_ADMIN — Désactive un compte utilisateur. */
    public void desactiverUtilisateur(Long idUtilisateur) {
        Utilisateur u = getUtilisateurById(idUtilisateur);
        u.setActif(false);
        em.merge(u);
    }

    /** SUPER_ADMIN — Réactive un compte utilisateur. */
    public void reactiverUtilisateur(Long idUtilisateur) {
        Utilisateur u = getUtilisateurById(idUtilisateur);
        u.setActif(true);
        em.merge(u);
    }

    public String genererNumeroOrdre() {
        int annee = Year.now().getValue();
        long count = em.createQuery(
                        "SELECT COUNT(m) FROM Medecin m WHERE m.numeroOrdre LIKE :prefixe", Long.class)
                .setParameter("prefixe", "OM-" + annee + "-%")
                .getSingleResult();
        return String.format("OM-%d-%03d", annee, count + 1);
    }

    // =========================================================
    // CONTROLE DE ROLE
    // =========================================================

    public boolean validerRole(Utilisateur utilisateur, Role roleAttendu) {
        return utilisateur != null && utilisateur.getRole() == roleAttendu;
    }

    // =========================================================
    // GENERATION DES NUMEROS UNIQUES — L01
    // =========================================================

    private String genererNumeroPatient() {
        int annee = Year.now().getValue();
        long compte = em.createQuery(
                        "SELECT COUNT(p) FROM Patient p WHERE p.numeroPatient LIKE :prefixe", Long.class)
                .setParameter("prefixe", "PAT-" + annee + "-%")
                .getSingleResult();
        long prochainNumero = compte + 1;
        return String.format("PAT-%d-%05d", annee, prochainNumero);
    }

    private String genererNumeroDossier() {
        int annee = Year.now().getValue();
        long compte = em.createQuery(
                        "SELECT COUNT(d) FROM DossierMedical d WHERE d.numeroUnique LIKE :prefixe", Long.class)
                .setParameter("prefixe", "DOS-" + annee + "-%")
                .getSingleResult();
        long prochainNumero = compte + 1;
        return String.format("DOS-%d-%05d", annee, prochainNumero);
    }
}