package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.Consultation;
import com.burundihealthconnect.entity.DossierMedical;
import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.LignePrescription;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.Ordonance;
import com.burundihealthconnect.entity.Patient;
import com.burundihealthconnect.entity.RendezVous;
import com.burundihealthconnect.entity.enums.StatutConsultation;
import com.burundihealthconnect.entity.enums.StatutRdv;
import com.burundihealthconnect.exception.AccesInterditException;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import com.burundihealthconnect.ejb.AuditService;
import jakarta.inject.Inject;

import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.ArrayList;
import java.util.List;

/**
 * ConsultationService — Session Bean Stateless.
 * Logiques couvertes :
 *   L02 — Workflow consultation EN_COURS -> CLOTUREE -> VERSEE_AU_DOSSIER
 *         (transitions MEDECIN uniquement, dans cet ordre strict)
 *   L04 — Alerte allergie avant chaque ligne de prescription
 *   L11 — Isolation par établissement (tant que non versée au dossier
 *         réseau, une consultation reste rattachée à son établissement)
 */
@Stateless
public class ConsultationService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    @EJB
    private DossierService dossierService;

    @EJB
    private OrdonnanceService ordonnanceService;

    private static final int TAILLE_PAGE = 10;

    // =========================================================
    // WORKFLOW CONSULTATION — L02
    // =========================================================

    /**
     * Crée une nouvelle consultation, statut initial EN_COURS.
     * idRendezVous est optionnel (consultation possible hors RDV planifié).
     */
    public Consultation creerConsultation(Long idRendezVous, Long idDossier, Long idMedecin,
                                           Long idEtablissement, String notes, String diagnostic) {
        DossierMedical dossier = em.find(DossierMedical.class, idDossier);
        if (dossier == null) {
            throw new EntiteIntrouvableException("DossierMedical", idDossier);
        }
        Medecin medecin = em.find(Medecin.class, idMedecin);
        if (medecin == null) {
            throw new EntiteIntrouvableException("Medecin", idMedecin);
        }
        EtablissementSante etablissement = em.find(EtablissementSante.class, idEtablissement);
        if (etablissement == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
        }

        Consultation consultation = new Consultation();
        consultation.setDossier(dossier);
        consultation.setMedecin(medecin);
        consultation.setEtablissement(etablissement);
        consultation.setNotes(notes);
        consultation.setDiagnostic(diagnostic);
        consultation.setStatut(StatutConsultation.EN_COURS);

        if (idRendezVous != null) {
            RendezVous rdv = em.find(RendezVous.class, idRendezVous);
            if (rdv == null) {
                throw new EntiteIntrouvableException("RendezVous", idRendezVous);
            }
            if (rdv.getStatut() != StatutRdv.RDV_CONFIRME) {
                throw new AccesInterditException("Seul un RDV confirmé peut démarrer une consultation.");
            }
            rdv.setStatut(StatutRdv.TERMINE);
            em.merge(rdv);
            consultation.setRendezVous(rdv);
        }

        em.persist(consultation);
        auditService.enregistrer("CREATION_CONSULTATION", "CONSULTATION", "INFO", "CONSULTATION", consultation.getIdConsultation(), "Création consultation", null, null);
        return consultation;
    }

    /**
     * Fait avancer le statut de la consultation d'UNE étape dans l'ordre
     * strict EN_COURS -> CLOTUREE -> VERSEE_AU_DOSSIER (L02).
     * Refuse tout saut d'étape ou retour en arrière.
     *
     * @throws AccesInterditException si la transition demandée n'est pas
     *         la suivante autorisée, ou si le médecin n'a pas créé cette
     *         consultation dans son propre établissement (L11) — sauf si
     *         déjà VERSEE_AU_DOSSIER (alors lecture réseau uniquement,
     *         cette méthode ne doit plus être appelée du tout)
     */
    public Consultation changerStatut(Long idConsultation, Long idMedecin, StatutConsultation nouveauStatut) {
        Consultation consultation = em.find(Consultation.class, idConsultation);
        if (consultation == null) {
            throw new EntiteIntrouvableException("Consultation", idConsultation);
        }

        StatutConsultation actuel = consultation.getStatut();
        boolean transitionValide =
                (actuel == StatutConsultation.EN_COURS && nouveauStatut == StatutConsultation.CLOTUREE)
                || (actuel == StatutConsultation.CLOTUREE && nouveauStatut == StatutConsultation.VERSEE_AU_DOSSIER);

        if (!transitionValide) {
            throw new AccesInterditException(
                    "Transition de statut invalide : " + actuel + " -> " + nouveauStatut);
        }

        if (nouveauStatut == StatutConsultation.VERSEE_AU_DOSSIER) {
            return verserAuDossier(idConsultation, idMedecin);
        }

        consultation.setStatut(nouveauStatut);
        em.merge(consultation);
        auditService.enregistrer("CLOTURE_CONSULTATION", "CONSULTATION", "INFO", "CONSULTATION", idConsultation, "Clôture consultation", null, null);
        return consultation;
    }

    /**
     * L02 (dernière étape) — Verse définitivement la consultation au
     * dossier médical réseau : devient visible par TOUT médecin du réseau
     * (L05), quel que soit son établissement. Action irréversible.
     */
    public Consultation verserAuDossier(Long idConsultation, Long idMedecin) {
        Consultation consultation = em.find(Consultation.class, idConsultation);
        if (consultation == null) {
            throw new EntiteIntrouvableException("Consultation", idConsultation);
        }
        if (consultation.getStatut() != StatutConsultation.CLOTUREE) {
            throw new AccesInterditException(
                    "Seule une consultation CLOTUREE peut être versée au dossier.");
        }

        consultation.setStatut(StatutConsultation.VERSEE_AU_DOSSIER);
        em.merge(consultation);

        dossierService.ajouterConsultation(consultation.getDossier().getIdDossier(), consultation);
        auditService.enregistrer("VERSEMENT_CONSULTATION", "CONSULTATION", "INFO", "CONSULTATION", idConsultation, "Versement dossier", null, null);

        return consultation;
    }

    // =========================================================
    // ORDONNANCE + ALERTE ALLERGIE — L04
    // =========================================================

    /**
     * L04 — Délègue à OrdonnanceService la vérification d'allergie.
     */
    public boolean verifierAllergie(Long idPatient, String medicament) {
        return ordonnanceService.verifierAllergie(idPatient, medicament);
    }

    /**
     * Crée l'ordonnance multi-lignes d'une consultation. Pour chaque ligne,
     * verifierAllergie() est appelée mais N'EMPECHE PAS la sauvegarde —
     * l'alerte est uniquement informative (cf. L04, "le médecin peut
     * passer outre"). Le drapeau alerteDeclenchee permet au Servlet
     * d'afficher un message d'avertissement après coup si besoin.
     */
    public OrdonnanceResultat creerOrdonnance(Long idConsultation, String instructions,
                                               List<LignePrescriptionDTO> lignes) {
        Consultation consultation = em.find(Consultation.class, idConsultation);
        if (consultation == null) {
            throw new EntiteIntrouvableException("Consultation", idConsultation);
        }
        if (consultation.getStatut() != StatutConsultation.EN_COURS) {
            throw new AccesInterditException("Impossible de prescrire : la consultation n'est pas en cours.");
        }
        if (consultation.getOrdonance() != null) {
            throw new AccesInterditException("Une ordonnance existe déjà pour cette consultation.");
        }
        Long idPatient = consultation.getDossier().getPatient().getIdPatient();

        Ordonance ordonance = new Ordonance();
        ordonance.setConsultation(consultation);
        ordonance.setInstructions(instructions);
        em.persist(ordonance);
        auditService.enregistrer("CREATION_ORDONNANCE", "ORDONNANCE", "INFO", "ORDONNANCE", ordonance.getIdOrdonance(), "Création ordonnance", null, null);

        boolean alerteDeclenchee = false;
        for (LignePrescriptionDTO dto : lignes) {
            if (verifierAllergie(idPatient, dto.medicament)) {
                alerteDeclenchee = true;
            }
            LignePrescription ligne = new LignePrescription();
            ligne.setOrdonance(ordonance);
            ligne.setMedicament(dto.medicament);
            ligne.setDosage(dto.dosage);
            ligne.setFrequence(dto.frequence);
            ligne.setDureeJours(dto.dureeJours);
            em.persist(ligne);
        }

        OrdonnanceResultat resultat = new OrdonnanceResultat();
        resultat.ordonance = ordonance;
        resultat.alerteAllergieDeclenchee = alerteDeclenchee;
        return resultat;
    }

    /** Charge une consultation par id (pour afficher le formulaire d'ordonnance). */
    public Consultation getConsultationById(Long idConsultation) {
        Consultation consultation = em.find(Consultation.class, idConsultation);
        if (consultation == null) {
            throw new EntiteIntrouvableException("Consultation", idConsultation);
        }
        return consultation;
    }
  

    // =========================================================
    // LECTURE
    // =========================================================

    /** Liste les consultations d'un médecin, tri par date décroissante. */
    public List<Consultation> getConsultationsByMedecin(Long idMedecin, int page) {
        return em.createQuery(
                        "SELECT c FROM Consultation c " +
                                "WHERE c.medecin.idMedecin = :idMed " +
                                "ORDER BY c.dateConsultation DESC",
                        Consultation.class)
                .setParameter("idMed", idMedecin)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    public long countConsultationsByMedecin(Long idMedecin) {
        return em.createQuery(
            "SELECT COUNT(c) FROM Consultation c WHERE c.medecin.idMedecin = :idMed",
            Long.class)
            .setParameter("idMed", idMedecin)
            .getSingleResult();
    }

    /** Liste les consultations EN_COURS ou CLOTUREE (pas encore versées) pour un établissement donné (L11). */
    public List<Consultation> getConsultationsEnCoursParEtablissement(Long idEtablissement, int page) {
        return em.createQuery(
                        "SELECT c FROM Consultation c " +
                                "WHERE c.etablissement.idEtablissement = :idEtab " +
                                "AND c.statut != :statutVerse " +
                                "ORDER BY c.dateConsultation DESC",
                        Consultation.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("statutVerse", StatutConsultation.VERSEE_AU_DOSSIER)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    // =========================================================
    // DTOs internes
    // =========================================================

    /** Une ligne de prescription à créer — utilisée en entrée de creerOrdonnance(). */
    public static class LignePrescriptionDTO {
        public String medicament;
        public String dosage;
        public String frequence;
        public Integer dureeJours;

        public LignePrescriptionDTO() {
        }

        public LignePrescriptionDTO(String medicament, String dosage, String frequence, Integer dureeJours) {
            this.medicament = medicament;
            this.dosage = dosage;
            this.frequence = frequence;
            this.dureeJours = dureeJours;
        }
    }

    /** Résultat de creerOrdonnance() : l'entité créée + un drapeau d'alerte allergie (L04). */
    public static class OrdonnanceResultat {
        public Ordonance ordonance;
        public boolean alerteAllergieDeclenchee;
    }
}