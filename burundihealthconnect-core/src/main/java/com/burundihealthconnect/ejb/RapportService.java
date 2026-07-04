package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.enums.StatutRdv;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.Map;

/**
 * RapportService — Session Bean Stateless.
 * Logique couverte : L15 — Rapport mensuel par établissement.
 */
@Stateless
public class RapportService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    /**
     * L15 — Construit le rapport mensuel d'un établissement :
     * - nombre total de RDV créés dans le mois (tous statuts)
     * - nombre de RDV TERMINE
     * - nombre de RDV RDV_ANNULE
     * - nombre de consultations VERSEE_AU_DOSSIER dans le mois
     * - nombre de patients distincts ayant eu un RDV ce mois
     */
    public Map<String, Object> getRapportMensuel(Long idEtablissement, YearMonth moisCible) {
        if (em.find(com.burundihealthconnect.entity.EtablissementSante.class, idEtablissement) == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
        }

        LocalDateTime debutMois = moisCible.atDay(1).atStartOfDay();
        LocalDateTime finMois = moisCible.plusMonths(1).atDay(1).atStartOfDay();

        Map<String, Object> rapport = new HashMap<>();
        rapport.put("etablissementId", idEtablissement);
        rapport.put("mois", moisCible.toString());

        long totalRdv = em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r " +
                                "WHERE r.etablissement.idEtablissement = :idEtab " +
                                "AND r.createdAt >= :debut AND r.createdAt < :fin",
                        Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        rapport.put("totalRdv", totalRdv);

        long rdvTermines = em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r " +
                                "WHERE r.etablissement.idEtablissement = :idEtab " +
                                "AND r.statut = :statut " +
                                "AND r.createdAt >= :debut AND r.createdAt < :fin",
                        Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("statut", StatutRdv.TERMINE)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        rapport.put("rdvTermines", rdvTermines);

        long rdvAnnules = em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r " +
                                "WHERE r.etablissement.idEtablissement = :idEtab " +
                                "AND r.statut = :statut " +
                                "AND r.createdAt >= :debut AND r.createdAt < :fin",
                        Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("statut", StatutRdv.RDV_ANNULE)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        rapport.put("rdvAnnules", rdvAnnules);

        long consultationsVersees = em.createQuery(
                        "SELECT COUNT(c) FROM Consultation c " +
                                "WHERE c.etablissement.idEtablissement = :idEtab " +
                                "AND c.statut = com.burundihealthconnect.entity.enums.StatutConsultation.VERSEE_AU_DOSSIER " +
                                "AND c.dateConsultation >= :debut AND c.dateConsultation < :fin",
                        Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        rapport.put("consultationsVersees", consultationsVersees);

        long patientsDistincts = em.createQuery(
                        "SELECT COUNT(DISTINCT r.patient) FROM RendezVous r " +
                                "WHERE r.etablissement.idEtablissement = :idEtab " +
                                "AND r.createdAt >= :debut AND r.createdAt < :fin",
                        Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        rapport.put("patientsDistincts", patientsDistincts);

        return rapport;
    }
}