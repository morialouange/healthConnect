package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.CongeMedecin;
import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.enums.StatutConge;
import com.burundihealthconnect.exception.AccesInterditException;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import com.burundihealthconnect.ejb.AuditService;
import jakarta.inject.Inject;

import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.util.List;

@Stateless
public class CongeService {

    private static final int TAILLE_PAGE = 10;

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    @EJB
    private DisponibiliteService disponibiliteService;

    @EJB
    private NotificationService notificationService;

    public CongeMedecin demanderConge(Long idMedecin, Long idEtablissement, LocalDate dateDebut,
                                       LocalDate dateFin, String motif) {
        Medecin medecin = em.find(Medecin.class, idMedecin);
        if (medecin == null) {
            throw new EntiteIntrouvableException("Medecin", idMedecin);
        }
        EtablissementSante etablissement = em.find(EtablissementSante.class, idEtablissement);
        if (etablissement == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
        }
        if (dateFin.isBefore(dateDebut)) {
            throw new AccesInterditException("La date de fin ne peut pas être avant la date de début.");
        }

        CongeMedecin conge = new CongeMedecin();
        conge.setMedecin(medecin);
        conge.setEtablissement(etablissement);
        conge.setDateDebut(dateDebut);
        conge.setDateFin(dateFin);
        conge.setMotif(motif);
        conge.setStatut(StatutConge.EN_ATTENTE);
        em.persist(conge);
        auditService.enregistrer("DEMANDE_CONGE", "CONGE", "INFO", "CONGE", conge.getIdConge(), "Demande congé", null, null);
        return conge;
    }

    public CongeMedecin approuverConge(Long idConge, Long idEtablissementAdmin) {
        CongeMedecin conge = chargerEtVerifierEtablissement(idConge, idEtablissementAdmin);
        if (conge.getStatut() != StatutConge.EN_ATTENTE) {
            throw new AccesInterditException("Seule une demande EN_ATTENTE peut être approuvée.");
        }

        conge.setStatut(StatutConge.APPROUVE);
        em.merge(conge);

        int nbCreneauxBloques = disponibiliteService.bloquerCreneauxConge(
                conge.getMedecin().getIdMedecin(), conge.getDateDebut(), conge.getDateFin());

        notificationService.creerNotification(
                conge.getMedecin().getUtilisateur().getIdUtilisateur(),
                "Votre demande de congé du " + conge.getDateDebut() + " au " + conge.getDateFin()
                        + " a été approuvée. " + nbCreneauxBloques + " créneau(x) ont été bloqués.",
                "CONGE");
        auditService.enregistrer("REPONSE_CONGE", "CONGE", "INFO", "CONGE", idConge, "Réponse congé: APPROUVE", null, null);

        return conge;
    }

    public CongeMedecin refuserConge(Long idConge, Long idEtablissementAdmin) {
        CongeMedecin conge = chargerEtVerifierEtablissement(idConge, idEtablissementAdmin);
        if (conge.getStatut() != StatutConge.EN_ATTENTE) {
            throw new AccesInterditException("Seule une demande EN_ATTENTE peut être refusée.");
        }

        conge.setStatut(StatutConge.REFUSE);
        em.merge(conge);

        notificationService.creerNotification(
                conge.getMedecin().getUtilisateur().getIdUtilisateur(),
                "Votre demande de congé du " + conge.getDateDebut() + " au " + conge.getDateFin()
                        + " a été refusée.",
                "CONGE");
        auditService.enregistrer("REPONSE_CONGE", "CONGE", "INFO", "CONGE", idConge, "Réponse congé: REFUSE", null, null);

        return conge;
    }

    public List<CongeMedecin> getDemandesParEtablissement(Long idEtablissement, String filtre, int page) {
        StringBuilder jpql = new StringBuilder(
                "SELECT c FROM CongeMedecin c WHERE c.etablissement.idEtablissement = :idEtab ");
        if (filtre != null && !filtre.isBlank()) {
            jpql.append("AND LOWER(c.medecin.utilisateur.fullName) LIKE :filtre ");
        }
        jpql.append("ORDER BY c.dateDebut DESC");

        TypedQuery<CongeMedecin> q = em.createQuery(jpql.toString(), CongeMedecin.class);
        q.setParameter("idEtab", idEtablissement);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        q.setFirstResult(page * TAILLE_PAGE);
        q.setMaxResults(TAILLE_PAGE);
        return q.getResultList();
    }

    public long countDemandesParEtablissement(Long idEtablissement, String filtre) {
        String jpql = "SELECT COUNT(c) FROM CongeMedecin c WHERE c.medecin.utilisateur.etablissement.idEtablissement = :idEtab";
        if (filtre != null && !filtre.isBlank()) {
            jpql += " AND LOWER(c.medecin.utilisateur.fullName) LIKE :filtre";
        }
        TypedQuery<Long> q = em.createQuery(jpql, Long.class);
        q.setParameter("idEtab", idEtablissement);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        return q.getSingleResult();
    }

    public List<CongeMedecin> getMesDemandes(Long idMedecin, int page) {
        TypedQuery<CongeMedecin> q = em.createQuery(
                "SELECT c FROM CongeMedecin c " +
                        "WHERE c.medecin.idMedecin = :idMedecin " +
                        "ORDER BY c.dateDebut DESC",
                CongeMedecin.class);
        q.setParameter("idMedecin", idMedecin);
        q.setFirstResult(page * TAILLE_PAGE);
        q.setMaxResults(TAILLE_PAGE);
        return q.getResultList();
    }

    private CongeMedecin chargerEtVerifierEtablissement(Long idConge, Long idEtablissementAdmin) {
        CongeMedecin conge = em.find(CongeMedecin.class, idConge);
        if (conge == null) {
            throw new EntiteIntrouvableException("CongeMedecin", idConge);
        }
        if (!conge.getEtablissement().getIdEtablissement().equals(idEtablissementAdmin)) {
            throw new AccesInterditException("Cette demande de congé n'appartient pas à votre établissement.");
        }
        return conge;
    }
}
