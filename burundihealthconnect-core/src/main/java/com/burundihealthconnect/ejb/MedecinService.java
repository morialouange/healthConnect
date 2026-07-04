package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.CongeMedecin;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.RendezVous;
import com.burundihealthconnect.entity.enums.StatutConge;
import com.burundihealthconnect.entity.enums.StatutRdv;
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
import java.time.YearMonth;
import java.util.List;

@Stateless
public class MedecinService {

    private static final int TAILLE_PAGE = 10;

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    @EJB
    private NotificationService notificationService;

    public List<Medecin> getMedecinsByEtablissement(Long idEtablissement, String filtre, int page) {
        return getMedecinsByEtablissement(idEtablissement, filtre, page, null, null);
    }

    public List<Medecin> getMedecinsByEtablissement(Long idEtablissement, String filtre, int page, String tri, String ordre) {
        StringBuilder jpql = new StringBuilder(
                "SELECT m FROM Medecin m WHERE m.utilisateur.etablissement.idEtablissement = :idEtab ");
        if (filtre != null && !filtre.isBlank()) {
            jpql.append("AND LOWER(m.utilisateur.fullName) LIKE :filtre ");
        }
        String sortField = "m.utilisateur.fullName";
        if ("specialite".equals(tri)) sortField = "m.specialite";
        else if ("experience".equals(tri)) sortField = "m.experience";
        else if ("email".equals(tri)) sortField = "m.utilisateur.email";
        String sortDir = "desc".equalsIgnoreCase(ordre) ? "DESC" : "ASC";
        jpql.append("ORDER BY ").append(sortField).append(" ").append(sortDir);

        TypedQuery<Medecin> q = em.createQuery(jpql.toString(), Medecin.class);
        q.setParameter("idEtab", idEtablissement);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        q.setFirstResult(page * TAILLE_PAGE);
        q.setMaxResults(TAILLE_PAGE);
        return q.getResultList();
    }

    public long countMedecinsByEtablissement(Long idEtablissement, String filtre) {
        String jpql = "SELECT COUNT(m) FROM Medecin m WHERE m.utilisateur.etablissement.idEtablissement = :idEtab";
        if (filtre != null && !filtre.isBlank()) {
            jpql += " AND LOWER(m.utilisateur.fullName) LIKE :filtre";
        }
        TypedQuery<Long> q = em.createQuery(jpql, Long.class);
        q.setParameter("idEtab", idEtablissement);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        return q.getSingleResult();
    }

    public Medecin getMedecinDetail(Long idMedecin, Long idEtablissement) {
        return chargerEtVerifierEtablissement(idMedecin, idEtablissement);
    }

    public long compterRdvTotaux(Long idMedecin) {
        return em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :id",
                        Long.class)
                .setParameter("id", idMedecin)
                .getSingleResult();
    }

    public long compterConsultationsMois(Long idMedecin, YearMonth mois) {
        LocalDate debut = mois.atDay(1);
        LocalDate fin = mois.atEndOfMonth();
        return em.createQuery(
                        "SELECT COUNT(c) FROM Consultation c WHERE c.medecin.idMedecin = :id " +
                                "AND c.dateConsultation BETWEEN :debut AND :fin",
                        Long.class)
                .setParameter("id", idMedecin)
                .setParameter("debut", debut.atStartOfDay())
                .setParameter("fin", fin.atTime(23, 59, 59))
                .getSingleResult();
    }

    public List<RendezVous> getProchainsRdv(Long idMedecin, int max) {
        return em.createQuery(
                        "SELECT r FROM RendezVous r WHERE r.medecin.idMedecin = :id " +
                                "AND r.dateRendez >= :aujourdhui " +
                                "ORDER BY r.dateRendez ASC",
                        RendezVous.class)
                .setParameter("id", idMedecin)
                .setParameter("aujourdhui", LocalDate.now().atStartOfDay())
                .setMaxResults(max)
                .getResultList();
    }

    public List<CongeMedecin> getCongesEnCours(Long idMedecin) {
        return em.createQuery(
                        "SELECT c FROM CongeMedecin c WHERE c.medecin.idMedecin = :id " +
                                "AND c.statut = :statut " +
                                "ORDER BY c.dateDebut DESC",
                        CongeMedecin.class)
                .setParameter("id", idMedecin)
                .setParameter("statut", StatutConge.APPROUVE)
                .getResultList();
    }

    public Medecin modifierMedecin(Long idMedecin, Long idEtablissement, ModifierMedecinDTO dto) {
        Medecin medecin = chargerEtVerifierEtablissement(idMedecin, idEtablissement);

        if (dto.fullName != null) {
            medecin.getUtilisateur().setFullName(dto.fullName);
        }
        if (dto.email != null) {
            medecin.getUtilisateur().setEmail(dto.email);
        }
        if (dto.specialite != null) {
            medecin.setSpecialite(dto.specialite);
        }
        if (dto.experience != null) {
            medecin.setExperience(dto.experience);
        }
        // numeroOrdre is NEVER modified here - it was set at profile completion
        // if (dto.numeroOrdre != null) {
        //     medecin.setNumeroOrdre(dto.numeroOrdre);
        // }

        em.merge(medecin.getUtilisateur());
        em.merge(medecin);
        auditService.enregistrer("MODIFICATION_MEDECIN", "MEDECIN", "INFO", "MEDECIN", idMedecin, "Modification médecin", null, null);
        return medecin;
    }

    public void desactiverMedecin(Long idMedecin, Long idEtablissement) {
        Medecin medecin = chargerEtVerifierEtablissement(idMedecin, idEtablissement);

        long rdvConfirmesAVenir = em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r " +
                                "WHERE r.medecin.idMedecin = :idMedecin " +
                                "AND r.statut = :statut " +
                                "AND r.dateRendez >= :aujourdhui",
                        Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("statut", StatutRdv.RDV_CONFIRME)
                .setParameter("aujourdhui", LocalDate.now().atStartOfDay())
                .getSingleResult();

        if (rdvConfirmesAVenir > 0) {
            throw new AccesInterditException(
                    "Impossible de désactiver ce médecin : il a " + rdvConfirmesAVenir
                            + " rendez-vous confirmé(s) à venir. Annulez-les ou transférez-les d'abord.");
        }

        medecin.getUtilisateur().setActif(false);
        em.merge(medecin.getUtilisateur());

        em.createQuery(
                        "UPDATE EtabliUtilisateur e SET e.actif = false " +
                                "WHERE e.medecin.idMedecin = :idMedecin " +
                                "AND e.etablissement.idEtablissement = :idEtab")
                .setParameter("idMedecin", idMedecin)
                .setParameter("idEtab", idEtablissement)
                .executeUpdate();

        notificationService.creerNotification(
                medecin.getUtilisateur().getIdUtilisateur(),
                "Votre compte a été désactivé par l'administrateur de votre établissement.",
                "COMPTE_DESACTIVE");
        auditService.enregistrer("DESACTIVATION_MEDECIN", "MEDECIN", "INFO", "MEDECIN", idMedecin, "Désactivation médecin", null, null);
    }

    private Medecin chargerEtVerifierEtablissement(Long idMedecin, Long idEtablissement) {
        Medecin medecin = em.find(Medecin.class, idMedecin);
        if (medecin == null) {
            throw new EntiteIntrouvableException("Medecin", idMedecin);
        }
        if (!medecin.getUtilisateur().getEtablissement().getIdEtablissement().equals(idEtablissement)) {
            throw new AccesInterditException("Ce médecin n'appartient pas à votre établissement.");
        }
        return medecin;
    }

    public boolean detecterDoublonMedecin(String email) {
        Long count = em.createQuery(
                        "SELECT COUNT(u) FROM Utilisateur u WHERE u.email = :email AND u.role = :role",
                        Long.class)
                .setParameter("email", email)
                .setParameter("role", com.burundihealthconnect.entity.enums.Role.MEDECIN)
                .getSingleResult();
        return count > 0;
    }

    public static class ModifierMedecinDTO {
        public String fullName;
        public String email;
        public String specialite;
        public Integer experience;
        public String numeroOrdre;
    }
}
