package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.CreneauDisponible;
import com.burundihealthconnect.entity.HistoriqueRdv;
import com.burundihealthconnect.entity.Patient;
import com.burundihealthconnect.entity.RendezVous;
import com.burundihealthconnect.entity.Service;
import com.burundihealthconnect.entity.enums.Priorite;
import com.burundihealthconnect.entity.enums.StatutRdv;
import com.burundihealthconnect.exception.AccesInterditException;
import com.burundihealthconnect.exception.BusinessException;
import com.burundihealthconnect.exception.EntiteIntrouvableException;
import com.burundihealthconnect.exception.LimiteRdvAtteintException;

import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * RendezVousService — Session Bean Stateless.
 * Logiques couvertes :
 *   L02 — Workflow RDV contrôlé par le MEDECIN
 *   L07 — Pagination des listes (10/page)
 *   L09 — Filtre de recherche (JPQL LIKE)
 *   L11 — Isolation par établissement
 *   L16 — Priorités de RDV
 *   L20 — Limite de 2 RDV par patient par jour
 *   L21 — Annulation par le patient (si RDV_DEMANDE uniquement)
 */
@Stateless
public class RendezVousService {

    private static final int TAILLE_PAGE = 10;

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @EJB
    private DisponibiliteService disponibiliteService;

    @EJB
    private NotificationService notificationService;

    @EJB
    private AuditService auditService;

    // =========================================================
    // LECTURE PAGINEE / FILTREE — L07, L09, L11
    // =========================================================

    /**
     * L07 + L09 + L11 — Liste paginée des RDV d'un médecin, dans son
     * établissement, avec filtre optionnel sur le nom du patient.
     *
     * @param page 0-indexé
     * @param filtreNomPatient peut être null/vide -> pas de filtre
     */
    public List<RendezVous> getRdvParMedecin(Long idMedecin, Long idEtablissement, int page, String filtreNomPatient) {
        expirerRdvNonConfirmes();
        StringBuilder jpql = new StringBuilder(
                "SELECT r FROM RendezVous r WHERE r.medecin.idMedecin = :idMedecin " +
                        "AND r.etablissement.idEtablissement = :idEtab ");
        if (filtreNomPatient != null && !filtreNomPatient.isBlank()) {
            jpql.append("AND LOWER(r.patient.utilisateur.fullName) LIKE :filtre ");
        }
        jpql.append("ORDER BY r.dateRendez ASC");

        TypedQuery<RendezVous> q = em.createQuery(jpql.toString(), RendezVous.class);
        q.setParameter("idMedecin", idMedecin);
        q.setParameter("idEtab", idEtablissement);
        if (filtreNomPatient != null && !filtreNomPatient.isBlank()) {
            q.setParameter("filtre", "%" + filtreNomPatient.toLowerCase() + "%");
        }
        q.setFirstResult(page * TAILLE_PAGE);
        q.setMaxResults(TAILLE_PAGE);
        return q.getResultList();
    }

    public long countRdvParMedecin(Long idMedecin, String filtreNomPatient) {
        expirerRdvNonConfirmes();
        String jpql = "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :idMed";
        if (filtreNomPatient != null && !filtreNomPatient.isBlank()) {
            jpql += " AND LOWER(r.patient.utilisateur.fullName) LIKE :filtre";
        }
        TypedQuery<Long> q = em.createQuery(jpql, Long.class);
        q.setParameter("idMed", idMedecin);
        if (filtreNomPatient != null && !filtreNomPatient.isBlank()) {
            q.setParameter("filtre", "%" + filtreNomPatient.toLowerCase() + "%");
        }
        return q.getSingleResult();
    }

    /** L16 — Liste les RDV en attente d'un établissement, triés par priorité décroissante (CRITIQUE en premier). */
    public List<RendezVous> getRdvParPriorite(Long idEtablissement) {
        expirerRdvNonConfirmes();
        return em.createQuery(
                        "SELECT r FROM RendezVous r " +
                                "WHERE r.etablissement.idEtablissement = :idEtab " +
                                "AND r.statut IN (:demande, :confirme) " +
                                "ORDER BY CASE r.priorite " +
                                "  WHEN :critique THEN 0 " +
                                "  WHEN :urgent THEN 1 " +
                                "  ELSE 2 END, r.dateRendez ASC",
                        RendezVous.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("demande", StatutRdv.RDV_DEMANDE)
                .setParameter("confirme", StatutRdv.RDV_CONFIRME)
                .setParameter("critique", Priorite.CRITIQUE)
                .setParameter("urgent", Priorite.URGENT)
                .getResultList();
    }

    // =========================================================
    // CREATION — L14 (créneau), L20 (limite)
    // =========================================================

    /**
     * L20 — Vérifie que le patient n'a pas déjà 2 RDV actifs (RDV_DEMANDE
     * ou RDV_CONFIRME) pour la date donnée.
     *
     * @throws LimiteRdvAtteintException si la limite est atteinte
     */
    public void verifierLimiteRdv(Long idPatient, LocalDate date) {
        LocalDateTime debutJour = date.atStartOfDay();
        LocalDateTime finJour = date.plusDays(1).atStartOfDay();

        long compte = em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r " +
                                "WHERE r.patient.idPatient = :idPatient " +
                                "AND r.statut IN (:demande, :confirme) " +
                                "AND r.dateRendez >= :debut AND r.dateRendez < :fin",
                        Long.class)
                .setParameter("idPatient", idPatient)
                .setParameter("demande", StatutRdv.RDV_DEMANDE)
                .setParameter("confirme", StatutRdv.RDV_CONFIRME)
                .setParameter("debut", debutJour)
                .setParameter("fin", finJour)
                .getSingleResult();

        if (compte >= 2) {
            throw new LimiteRdvAtteintException();
        }
    }

    /**
     * Crée un RDV en réservant atomiquement un créneau libre (L14).
     * Vérifie d'abord la limite quotidienne (L20).
     *
     * @throws LimiteRdvAtteintException si le patient a déjà 2 RDV ce jour
     * @throws com.burundihealthconnect.exception.CreneauDejaReserveException
     *         si le créneau a été pris entre temps par un autre patient
     */
    public RendezVous creerRdvAvecCreneau(Long idPatient, Long idCreneau, Long idServiceOptionnel, String motif) {
        Patient patient = em.find(Patient.class, idPatient);
        if (patient == null) {
            throw new EntiteIntrouvableException("Patient", idPatient);
        }

        // Réservation atomique du créneau AVANT toute autre opération (L14).
        CreneauDisponible creneau = disponibiliteService.reserverCreneau(idCreneau);

        LocalDateTime dateRendez = creneau.getDateCreneau().atTime(creneau.getHeureDebut());
        verifierLimiteRdv(idPatient, dateRendez.toLocalDate());

        RendezVous rdv = new RendezVous();
        rdv.setPatient(patient);
        rdv.setMedecin(creneau.getMedecin());
        rdv.setEtablissement(creneau.getEtablissement());
        rdv.setCreneau(creneau);
        rdv.setMotif(motif);
        rdv.setDateRendez(dateRendez);
        rdv.setStatut(StatutRdv.RDV_DEMANDE);
        rdv.setPriorite(Priorite.NORMAL);

        if (idServiceOptionnel != null) {
            Service service = em.find(Service.class, idServiceOptionnel);
            rdv.setService(service);
        }

        em.persist(rdv);
        return rdv;
    }

    // =========================================================
    // WORKFLOW — L02 (transitions MEDECIN)
    // =========================================================

    /** L02 — Le médecin confirme un RDV en attente. */
    public RendezVous confirmerRdv(Long idRendezVous, Long idMedecin) {
        RendezVous rdv = chargerEtVerifierProprietaire(idRendezVous, idMedecin);
        if (rdv.getStatut() != StatutRdv.RDV_DEMANDE) {
            throw new AccesInterditException("Seul un RDV_DEMANDE peut être confirmé.");
        }
        String ancienStatut = rdv.getStatut().name();
        rdv.setStatut(StatutRdv.RDV_CONFIRME);
        em.merge(rdv);
        tracerChangementStatut(rdv, ancienStatut, StatutRdv.RDV_CONFIRME.name(), idMedecin, "MEDECIN");
        return rdv;
    }

    /** L02 — Le médecin refuse un RDV : libère le créneau et notifie le patient. */
    public RendezVous refuserRdv(Long idRendezVous, Long idMedecin) {
        RendezVous rdv = chargerEtVerifierProprietaire(idRendezVous, idMedecin);
        if (rdv.getStatut() != StatutRdv.RDV_DEMANDE) {
            throw new AccesInterditException("Seul un RDV_DEMANDE peut être refusé.");
        }
        String ancienStatut = rdv.getStatut().name();
        rdv.setStatut(StatutRdv.RDV_ANNULE);
        em.merge(rdv);

        if (rdv.getCreneau() != null) {
            disponibiliteService.libererCreneau(rdv.getCreneau().getIdCreneau());
        }

        notificationService.creerNotification(
                rdv.getPatient().getUtilisateur().getIdUtilisateur(),
                "Votre rendez-vous du " + rdv.getDateRendez() + " a été refusé par le médecin.",
                "RDV_REFUSE");

        tracerChangementStatut(rdv, ancienStatut, StatutRdv.RDV_ANNULE.name(), idMedecin, "MEDECIN");
        return rdv;
    }

    /** L02 — Le médecin marque un RDV confirmé comme terminé (après consultation). */
    public RendezVous marquerTermine(Long idRendezVous, Long idMedecin) {
        RendezVous rdv = chargerEtVerifierProprietaire(idRendezVous, idMedecin);
        if (rdv.getStatut() != StatutRdv.RDV_CONFIRME) {
            throw new AccesInterditException("Seul un RDV_CONFIRME peut être marqué TERMINE.");
        }
        String ancienStatut = rdv.getStatut().name();
        rdv.setStatut(StatutRdv.TERMINE);
        em.merge(rdv);
        tracerChangementStatut(rdv, ancienStatut, StatutRdv.TERMINE.name(), idMedecin, "MEDECIN");
        return rdv;
    }

    /** L16 — Le médecin change la priorité d'un RDV (NORMAL / URGENT / CRITIQUE). */
    public RendezVous changerPriorite(Long idRendezVous, Long idMedecin, Priorite nouvellePriorite) {
        RendezVous rdv = chargerEtVerifierProprietaire(idRendezVous, idMedecin);
        String anciennePriorite = rdv.getPriorite().name();
        rdv.setPriorite(nouvellePriorite);
        em.merge(rdv);
        tracerChangementStatut(rdv, "PRIORITE:" + anciennePriorite, "PRIORITE:" + nouvellePriorite.name(), idMedecin, "MEDECIN");
        return rdv;
    }

    // =========================================================
    // ANNULATION PATIENT — L21
    // =========================================================

    /**
     * L21 — Le patient annule lui-même son RDV, UNIQUEMENT si son statut
     * est encore RDV_DEMANDE (pas encore confirmé par le médecin).
     * Libère le créneau et notifie le médecin.
     *
     * @throws AccesInterditException si le RDV n'appartient pas au patient,
     *         ou si son statut n'est plus RDV_DEMANDE
     */
    public RendezVous annulerParPatient(Long idRendezVous, Long idPatient) {
        RendezVous rdv = em.find(RendezVous.class, idRendezVous);
        if (rdv == null) {
            throw new EntiteIntrouvableException("RendezVous", idRendezVous);
        }
        if (!rdv.getPatient().getIdPatient().equals(idPatient)) {
            throw new AccesInterditException("Ce rendez-vous n'appartient pas à ce patient.");
        }
        if (rdv.getStatut() != StatutRdv.RDV_DEMANDE) {
            throw new AccesInterditException(
                    "Seul un rendez-vous en attente (RDV_DEMANDE) peut être annulé par le patient.");
        }

        String ancienStatut = rdv.getStatut().name();
        rdv.setStatut(StatutRdv.RDV_ANNULE);
        em.merge(rdv);

        if (rdv.getCreneau() != null) {
            disponibiliteService.libererCreneau(rdv.getCreneau().getIdCreneau());
        }

        notificationService.creerNotification(
                rdv.getMedecin().getUtilisateur().getIdUtilisateur(),
                "Le patient " + rdv.getPatient().getUtilisateur().getFullName()
                        + " a annulé son rendez-vous du " + rdv.getDateRendez() + ".",
                "RDV_ANNULE");

        tracerChangementStatut(rdv, ancienStatut, StatutRdv.RDV_ANNULE.name(), idPatient, "PATIENT");
        return rdv;
    }

    // =========================================================
    // LECTURE
    // =========================================================

    /** Charge un RDV par son id et vérifie qu'il appartient au médecin. */
    public RendezVous getRendezVousById(Long idRendezVous, Long idMedecin) {
        return chargerEtVerifierProprietaire(idRendezVous, idMedecin);
    }

    // =========================================================
    // HISTORIQUE RDV
    // =========================================================

    public void tracerChangementStatut(RendezVous rdv, String ancienStatut, String nouveauStatut, Long idUtilisateur, String role) {
        HistoriqueRdv histo = new HistoriqueRdv();
        histo.setRendezVous(rdv);
        histo.setAncienStatut(ancienStatut);
        histo.setNouveauStatut(nouveauStatut);
        histo.setModifiePar(role);
        histo.setIdModificateur(idUtilisateur);
        em.persist(histo);

        auditService.enregistrer(
                "CHANGEMENT_STATUT_RDV",
                "RDV",
                "INFO",
                "RENDEZ_VOUS",
                rdv.getIdRendez(),
                "Statut: " + ancienStatut + " -> " + nouveauStatut + " par " + role + "(" + idUtilisateur + ")",
                null, null);
    }

    public int expirerRdvNonConfirmes() {
        List<RendezVous> expires = em.createQuery(
                        "SELECT r FROM RendezVous r WHERE r.statut = :demande AND r.dateRendez < :now",
                        RendezVous.class)
                .setParameter("demande", StatutRdv.RDV_DEMANDE)
                .setParameter("now", LocalDateTime.now())
                .getResultList();

        for (RendezVous rdv : expires) {
            String ancienStatut = rdv.getStatut().name();
            rdv.setStatut(StatutRdv.RDV_ANNULE);
            em.merge(rdv);
            if (rdv.getCreneau() != null) {
                disponibiliteService.libererCreneau(rdv.getCreneau().getIdCreneau());
            }
            tracerChangementStatut(rdv, ancienStatut, StatutRdv.RDV_ANNULE.name(), null, "SYSTEME");
        }
        return expires.size();
    }

    public void verifierNonChevauchementDisponibilite(Long idMedecin, LocalDate dateDebut, LocalDate dateFin) {
        Long overlap = em.createQuery(
                        "SELECT COUNT(s) FROM DisponibiliteSemaine s WHERE s.medecin.idMedecin = :idMed " +
                                "AND ((s.dateDebutSemaine <= :fin AND s.dateFinSemaine >= :debut) " +
                                "OR (s.dateDebutSemaine >= :debut AND s.dateDebutSemaine <= :fin))",
                        Long.class)
                .setParameter("idMed", idMedecin)
                .setParameter("debut", dateDebut)
                .setParameter("fin", dateFin)
                .getSingleResult();
        if (overlap > 0) {
            throw new BusinessException("Une disponibilité existe déjà pour cette période.");
        }
    }

    public List<HistoriqueRdv> getHistoriqueRdv(Long idRendezVous) {
        return em.createQuery(
                        "SELECT h FROM HistoriqueRdv h WHERE h.rendezVous.idRendez = :id ORDER BY h.dateModification ASC",
                        HistoriqueRdv.class)
                .setParameter("id", idRendezVous)
                .getResultList();
    }

    // =========================================================
    // PRIVE
    // =========================================================

    private RendezVous chargerEtVerifierProprietaire(Long idRendezVous, Long idMedecin) {
        RendezVous rdv = em.find(RendezVous.class, idRendezVous);
        if (rdv == null) {
            throw new EntiteIntrouvableException("RendezVous", idRendezVous);
        }
        if (!rdv.getMedecin().getIdMedecin().equals(idMedecin)) {
            throw new AccesInterditException("Ce rendez-vous n'appartient pas à ce médecin.");
        }
        return rdv;
    }
}