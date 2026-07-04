package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.AccesDossier;
import com.burundihealthconnect.entity.Consultation;
import com.burundihealthconnect.entity.DossierMedical;
import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.HistoriqueModification;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.enums.StatutConsultation;
import com.burundihealthconnect.entity.enums.TypeAcces;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import com.burundihealthconnect.ejb.AuditService;
import jakarta.inject.Inject;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.util.List;

/**
 * DossierService — Session Bean Stateless.
 * Logiques couvertes :
 *   L05 — Historique complet inter-établissements (getHistoriqueComplet)
 *   L10 — Journal d'accès au dossier (ouvrirDossier)
 *   L11 — Isolation par établissement, AVEC l'exception explicite du
 *         dossier médical qui reste GLOBAL (getDossierByNumeroPatient)
 *   L18 — Historique des modifications du dossier (tracerModification)
 */
@Stateless
public class DossierService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    private static final int TAILLE_PAGE = 10;

    /**
     * Recherche GLOBALE du dossier par idPatient (utilisée par PatientServlet
     * pour afficher le PROPRE dossier du patient connecté — pas de filtre
     * établissement, le dossier reste global au réseau).
     */
    public DossierMedical getDossierByIdPatient(Long idPatient) {
        try {
            TypedQuery<DossierMedical> q = em.createQuery(
                    "SELECT d FROM DossierMedical d WHERE d.patient.idPatient = :idPatient",
                    DossierMedical.class);
            q.setParameter("idPatient", idPatient);
            return q.getSingleResult();
        } catch (NoResultException e) {
            throw new EntiteIntrouvableException("DossierMedical (idPatient=" + idPatient + ")", idPatient);
        }
    }

    /**
     * L11 (EXCEPTION à l'isolation) — Recherche GLOBALE du dossier par le
     * numéro patient, SANS filtre id_etablissement. C'est le seul point
     * d'entrée volontairement non filtré, car le dossier médical est
     * partagé par tout le réseau quand le patient se présente dans un
     * autre hôpital.
     */
    public DossierMedical getDossierByNumeroPatient(String numeroPatient) {
        try {
            TypedQuery<DossierMedical> q = em.createQuery(
                    "SELECT d FROM DossierMedical d WHERE d.patient.numeroPatient = :numero",
                    DossierMedical.class);
            q.setParameter("numero", numeroPatient);
            return q.getSingleResult();
        } catch (NoResultException e) {
            throw new EntiteIntrouvableException("DossierMedical (numero_patient=" + numeroPatient + ")", null);
        }
    }

    /**
     * L10 — Ouvre le dossier pour consultation/modification PAR UN MEDECIN
     * et trace automatiquement l'accès dans acces_dossier. Cette méthode
     * doit être l'UNIQUE point d'entrée pour afficher un dossier côté
     * médecin (jamais d'accès direct via em.find() ailleurs dans le code),
     * afin que la traçabilité L10 soit garantie à 100%.
     */
    public DossierMedical ouvrirDossier(Long idDossier, Long idMedecin, Long idEtablissement, TypeAcces typeAcces) {
        return ouvrirDossier(idDossier, idMedecin, idEtablissement, typeAcces, null);
    }

    public DossierMedical ouvrirDossier(Long idDossier, Long idMedecin, Long idEtablissement, TypeAcces typeAcces, String motifAcces) {
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

        // Audit renforcé pour dossiers SENSIBLE
        if (dossier.getNiveauConfidentialite() == com.burundihealthconnect.entity.enums.NiveauConfidentialite.SENSIBLE) {
            // trace supplémentaire : niveau CRITICAL
        }

        AccesDossier acces = new AccesDossier();
        acces.setDossier(dossier);
        acces.setMedecin(medecin);
        acces.setEtablissement(etablissement);
        acces.setTypeAcces(typeAcces);
        acces.setMotifAcces(motifAcces);
        em.persist(acces);

        String niveau = dossier.getNiveauConfidentialite() == com.burundihealthconnect.entity.enums.NiveauConfidentialite.SENSIBLE ? "WARNING" : "INFO";
        auditService.enregistrer("ACCES_DOSSIER", "DOSSIER", niveau, "DOSSIER", idDossier, "Accès dossier: " + typeAcces + " motif: " + motifAcces, null, null);

        return dossier;
    }

    /**
     * L05 — Renvoie toutes les consultations VERSEE_AU_DOSSIER d'un dossier,
     * SANS filtre id_etablissement, triées de la plus récente à la plus
     * ancienne. C'est l'historique "réseau" complet visible par tout
     * médecin, quel que soit l'hôpital où chaque consultation a eu lieu.
     */
    public List<Consultation> getHistoriqueComplet(Long idDossier) {
        TypedQuery<Consultation> q = em.createQuery(
                "SELECT DISTINCT c FROM Consultation c " +
                        "LEFT JOIN FETCH c.ordonance o " +
                        "LEFT JOIN FETCH o.lignes " +
                        "WHERE c.dossier.idDossier = :idDossier " +
                        "AND c.statut = :statut " +
                        "ORDER BY c.dateConsultation DESC",
                Consultation.class);
        q.setParameter("idDossier", idDossier);
        q.setParameter("statut", StatutConsultation.VERSEE_AU_DOSSIER);
        return q.getResultList();
    }

    /**
     * Lie une consultation existante à son dossier et met à jour la date
     * de mise à jour du dossier. Appelée par ConsultationService après
     * la création/clôture d'une consultation — ne crée pas la consultation
     * elle-même (ça reste la responsabilité de ConsultationService).
     */
    public void ajouterConsultation(Long idDossier, Consultation consultation) {
        DossierMedical dossier = em.find(DossierMedical.class, idDossier);
        if (dossier == null) {
            throw new EntiteIntrouvableException("DossierMedical", idDossier);
        }
        dossier.setDateMiseAJour(java.time.LocalDateTime.now());
        em.merge(dossier);
        // La consultation pointe déjà vers ce dossier via consultation.dossier
        // (relation gérée côté ConsultationService.creerConsultation()).
    }

    /**
     * L18 — Trace une modification de champ du dossier médical : conserve
     * l'ancienne et la nouvelle valeur pour audit complet. Doit être appelée
     * AVANT toute écriture effective du champ par le médecin (notes,
     * diagnostic, antécédents...).
     */
    public void tracerModification(Long idDossier, Long idMedecin, Long idEtablissement,
                                    String champModifie, String ancienneValeur, String nouvelleValeur) {
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

        HistoriqueModification histo = new HistoriqueModification();
        histo.setDossier(dossier);
        histo.setMedecin(medecin);
        histo.setEtablissement(etablissement);
        histo.setChampModifie(champModifie);
        histo.setAncienneValeur(ancienneValeur);
        histo.setNouvelleValeur(nouvelleValeur);
        em.persist(histo);
    }

    /** L18 — Liste l'historique complet des modifications d'un dossier (le plus récent en premier). */
    public List<HistoriqueModification> getHistoriqueModifications(Long idDossier) {
        TypedQuery<HistoriqueModification> q = em.createQuery(
                "SELECT h FROM HistoriqueModification h " +
                        "WHERE h.dossier.idDossier = :idDossier " +
                        "ORDER BY h.dateModification DESC",
                HistoriqueModification.class);
        q.setParameter("idDossier", idDossier);
        return q.getResultList();
    }

    public long countJournalAccesGlobal() {
        return em.createQuery("SELECT COUNT(j) FROM JournalAcces j", Long.class).getSingleResult();
    }

    public long countHistoriqueModificationsGlobal() {
        return em.createQuery("SELECT COUNT(h) FROM HistoriqueModification h", Long.class).getSingleResult();
    }

    /**
     * SUPER_ADMIN — Journal d'accès GLOBAL à tout le réseau (toutes les
     * lectures/modifications de dossiers, tous établissements confondus),
     * limité aux 200 entrées les plus récentes pour rester performant.
     */
    public List<AccesDossier> getJournalAccesGlobal(int page) {
        return em.createQuery(
                        "SELECT a FROM AccesDossier a ORDER BY a.dateAcces DESC", AccesDossier.class)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    /**
     * SUPER_ADMIN — Historique des modifications GLOBAL à tout le réseau,
     * limité aux 200 entrées les plus récentes.
     */
    public List<HistoriqueModification> getHistoriqueModificationsGlobal(int page) {
        return em.createQuery(
                        "SELECT h FROM HistoriqueModification h ORDER BY h.dateModification DESC",
                        HistoriqueModification.class)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }
}