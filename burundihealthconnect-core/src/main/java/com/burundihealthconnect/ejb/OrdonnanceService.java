package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.Ordonance;
import com.burundihealthconnect.entity.Patient;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import com.burundihealthconnect.ejb.AuditService;
import jakarta.inject.Inject;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.util.List;

@Stateless
public class OrdonnanceService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    private static final int TAILLE_PAGE = 10;

    /** Retourne toutes les ordonnances rédigées par un médecin, tri par date décroissante. */
    public List<Ordonance> getOrdonnancesByMedecin(Long idMedecin, int page) {
        return em.createQuery(
                        "SELECT o FROM Ordonance o " +
                                "WHERE o.consultation.medecin.idMedecin = :idMed " +
                                "ORDER BY o.createdAt DESC",
                        Ordonance.class)
                .setParameter("idMed", idMedecin)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    public List<Ordonance> getOrdonnancesByMedecin(Long idMedecin, String filtre, int page) {
        String jpql = "SELECT o FROM Ordonance o WHERE o.consultation.medecin.idMedecin = :idMed";
        if (filtre != null && !filtre.isBlank()) {
            jpql += " AND LOWER(o.consultation.dossier.patient.utilisateur.fullName) LIKE :filtre";
        }
        jpql += " ORDER BY o.createdAt DESC";
        TypedQuery<Ordonance> q = em.createQuery(jpql, Ordonance.class);
        q.setParameter("idMed", idMedecin);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        return q.setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    public long countOrdonnancesByMedecin(Long idMedecin, String filtre) {
        String jpql = "SELECT COUNT(o) FROM Ordonance o WHERE o.consultation.medecin.idMedecin = :idMed";
        if (filtre != null && !filtre.isBlank()) {
            jpql += " AND LOWER(o.consultation.dossier.patient.utilisateur.fullName) LIKE :filtre";
        }
        TypedQuery<Long> q = em.createQuery(jpql, Long.class);
        q.setParameter("idMed", idMedecin);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        return q.getSingleResult();
    }

    public boolean verifierAllergie(Long idPatient, String medicament) {
        Patient patient = em.find(Patient.class, idPatient);
        if (patient == null) {
            throw new EntiteIntrouvableException("Patient", idPatient);
        }
        String allergies = patient.getAllergies();
        if (allergies == null || allergies.isBlank() || medicament == null || medicament.isBlank()) {
            return false;
        }
        return allergies.toLowerCase().contains(medicament.toLowerCase());
    }
}
