package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.Consultation;
import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.Referenement;
import com.burundihealthconnect.entity.enums.StatutReferenement;
import com.burundihealthconnect.exception.AccesInterditException;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import com.burundihealthconnect.ejb.AuditService;
import jakarta.inject.Inject;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.util.List;

@Stateless
public class ReferenementService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    private static final int TAILLE_PAGE = 10;

    public Referenement creerReferenement(Long idConsultation, Long idEtablissementDest,
                                           Long idMedecinDest, String motif) {
        Consultation consultation = em.find(Consultation.class, idConsultation);
        if (consultation == null) {
            throw new EntiteIntrouvableException("Consultation", idConsultation);
        }
        EtablissementSante etablissementDest = em.find(EtablissementSante.class, idEtablissementDest);
        if (etablissementDest == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissementDest);
        }
        Medecin medecinDest = null;
        if (idMedecinDest != null) {
            medecinDest = em.find(Medecin.class, idMedecinDest);
            if (medecinDest == null) {
                throw new EntiteIntrouvableException("Medecin", idMedecinDest);
            }
        }

        Referenement ref = new Referenement();
        ref.setConsultation(consultation);
        ref.setEtablissementDest(etablissementDest);
        ref.setMedecinDest(medecinDest);
        ref.setMotif(motif);
        ref.setStatut(StatutReferenement.EN_ATTENTE);
        ref.setDateRef(LocalDate.now());
        em.persist(ref);
        auditService.enregistrer("CREATION_REFERENCEMENT", "REFERENCEMENT", "INFO", "REFERENCEMENT", ref.getIdRef(), "Création référencement", null, null);
        return ref;
    }

    public Referenement accepterReferenement(Long idRef, Long idEtablissement) {
        Referenement ref = chargerEtVerifierEtablissementDest(idRef, idEtablissement);
        if (ref.getStatut() != StatutReferenement.EN_ATTENTE) {
            throw new AccesInterditException("Seul un référencement EN_ATTENTE peut être accepté.");
        }
        ref.setStatut(StatutReferenement.ACCEPTE);
        em.merge(ref);
        auditService.enregistrer("CHANGEMENT_STATUT_REFERENCEMENT", "REFERENCEMENT", "INFO", "REFERENCEMENT", idRef, "Statut ref: ACCEPTE", null, null);
        return ref;
    }

    public Referenement enregistrerRetour(Long idRef, Long idEtablissement, String retour) {
        Referenement ref = chargerEtVerifierEtablissementDest(idRef, idEtablissement);
        if (ref.getStatut() != StatutReferenement.ACCEPTE) {
            throw new AccesInterditException("Seul un référencement ACCEPTE peut recevoir un retour.");
        }
        ref.setRetour(retour);
        ref.setStatut(StatutReferenement.RETOUR_RECU);
        em.merge(ref);
        return ref;
    }

    public Referenement cloturerReferenement(Long idRef, Long idEtablissement) {
        Referenement ref = chargerEtVerifierEtablissementDest(idRef, idEtablissement);
        if (ref.getStatut() != StatutReferenement.RETOUR_RECU) {
            throw new AccesInterditException("Seul un référencement RETOUR_RECU peut être clôturé.");
        }
        ref.setStatut(StatutReferenement.CLOTURE);
        em.merge(ref);
        return ref;
    }

    public List<Referenement> getReferenementsParMedecin(Long idMedecin, int page) {
        return em.createQuery(
                        "SELECT r FROM Referenement r " +
                                "WHERE r.consultation.medecin.idMedecin = :idMed " +
                                "ORDER BY r.dateRef DESC",
                        Referenement.class)
                .setParameter("idMed", idMedecin)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    public List<Referenement> getReferenementsParEtablissementSource(Long idEtablissement, int page) {
        return em.createQuery(
                        "SELECT r FROM Referenement r " +
                                "WHERE r.consultation.etablissement.idEtablissement = :idEtab " +
                                "ORDER BY r.dateRef DESC",
                        Referenement.class)
                .setParameter("idEtab", idEtablissement)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    public List<Referenement> getReferenementsParEtablissementDest(Long idEtablissement, int page) {
        return em.createQuery(
                        "SELECT r FROM Referenement r " +
                                "WHERE r.etablissementDest.idEtablissement = :idEtab " +
                                "ORDER BY r.dateRef DESC",
                        Referenement.class)
                .setParameter("idEtab", idEtablissement)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    public long countReferenementsParMedecin(Long idMedecin) {
        return em.createQuery(
            "SELECT COUNT(r) FROM Referenement r WHERE r.consultation.medecin.idMedecin = :idMed",
            Long.class)
            .setParameter("idMed", idMedecin)
            .getSingleResult();
    }

    public long countReferenementsParEtablissementDest(Long idEtablissement) {
        return em.createQuery(
            "SELECT COUNT(r) FROM Referenement r WHERE r.etablissementDest.idEtablissement = :idEtab",
            Long.class)
            .setParameter("idEtab", idEtablissement)
            .getSingleResult();
    }

    public long countReferenementsParEtablissementSource(Long idEtablissement) {
        return em.createQuery(
            "SELECT COUNT(r) FROM Referenement r WHERE r.consultation.etablissement.idEtablissement = :idEtab",
            Long.class)
            .setParameter("idEtab", idEtablissement)
            .getSingleResult();
    }

    private Referenement chargerEtVerifierEtablissementDest(Long idRef, Long idEtablissement) {
        Referenement ref = em.find(Referenement.class, idRef);
        if (ref == null) {
            throw new EntiteIntrouvableException("Referenement", idRef);
        }
        if (!ref.getEtablissementDest().getIdEtablissement().equals(idEtablissement)) {
            throw new AccesInterditException("Ce référencement ne concerne pas votre établissement.");
        }
        return ref;
    }
}
