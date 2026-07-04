package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.Service;
import com.burundihealthconnect.entity.enums.CategorieService;
import com.burundihealthconnect.exception.AccesInterditException;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import com.burundihealthconnect.ejb.AuditService;
import jakarta.inject.Inject;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

@Stateless
public class ServiceService {

    private static final int TAILLE_PAGE = 10;

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @Inject
    private AuditService auditService;

    public List<Service> getServicesActifsByEtablissement(Long idEtablissement) {
        return em.createQuery(
                        "SELECT s FROM Service s WHERE s.etablissement.idEtablissement = :idEtab AND s.actif = true ORDER BY s.nom ASC",
                        Service.class)
                .setParameter("idEtab", idEtablissement)
                .getResultList();
    }

    public List<Service> getAllServices(Long idEtablissement, String filtre, int page) {
        StringBuilder jpql = new StringBuilder(
                "SELECT s FROM Service s WHERE s.etablissement.idEtablissement = :idEtab ");
        if (filtre != null && !filtre.isBlank()) {
            jpql.append("AND LOWER(s.nom) LIKE :filtre ");
        }
        jpql.append("ORDER BY s.nom ASC");

        TypedQuery<Service> q = em.createQuery(jpql.toString(), Service.class);
        q.setParameter("idEtab", idEtablissement);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        q.setFirstResult(page * TAILLE_PAGE);
        q.setMaxResults(TAILLE_PAGE);
        return q.getResultList();
    }

    public long countServices(Long idEtablissement, String filtre) {
        String jpql = "SELECT COUNT(s) FROM Service s WHERE s.etablissement.idEtablissement = :idEtab";
        if (filtre != null && !filtre.isBlank()) {
            jpql += " AND LOWER(s.nom) LIKE :filtre";
        }
        TypedQuery<Long> q = em.createQuery(jpql, Long.class);
        q.setParameter("idEtab", idEtablissement);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        return q.getSingleResult();
    }

    public Service getServiceById(Long idService, Long idEtablissement) {
        return chargerEtVerifierEtablissement(idService, idEtablissement);
    }

    public Service getServiceDetail(Long idService, Long idEtablissement) {
        return chargerEtVerifierEtablissement(idService, idEtablissement);
    }

    public long compterRdvCeMois(Long idService, YearMonth mois) {
        LocalDate debut = mois.atDay(1);
        LocalDate fin = mois.atEndOfMonth();
        return em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r WHERE r.service.idService = :id " +
                                "AND r.dateRendez BETWEEN :debut AND :fin",
                        Long.class)
                .setParameter("id", idService)
                .setParameter("debut", debut.atStartOfDay())
                .setParameter("fin", fin.atTime(23, 59, 59))
                .getSingleResult();
    }

    public long compterMedecinsAyantConsulte(Long idService) {
        return em.createQuery(
                        "SELECT COUNT(DISTINCT r.medecin.idMedecin) FROM RendezVous r WHERE r.service.idService = :id",
                        Long.class)
                .setParameter("id", idService)
                .getSingleResult();
    }

    public Service creerService(Long idEtablissement, ServiceDTO dto) {
        EtablissementSante etablissement = em.find(EtablissementSante.class, idEtablissement);
        if (etablissement == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
        }

        Service service = new Service();
        service.setEtablissement(etablissement);
        service.setNom(dto.nom);
        service.setCategorie(dto.categorie);
        service.setActif(true);
        em.persist(service);
        auditService.enregistrer("CREATION_SERVICE", "SERVICE", "INFO", "SERVICE", service.getIdService(), "Création service: " + dto.nom, null, null);
        return service;
    }

    public Service modifierService(Long idService, Long idEtablissement, ServiceDTO dto) {
        Service service = chargerEtVerifierEtablissement(idService, idEtablissement);
        if (dto.nom != null) {
            service.setNom(dto.nom);
        }
        if (dto.categorie != null) {
            service.setCategorie(dto.categorie);
        }
        em.merge(service);
        auditService.enregistrer("MODIFICATION_SERVICE", "SERVICE", "INFO", "SERVICE", idService, "Modification service", null, null);
        return service;
    }

    public void desactiverService(Long idService, Long idEtablissement) {
        Service service = chargerEtVerifierEtablissement(idService, idEtablissement);
        service.setActif(false);
        em.merge(service);
        auditService.enregistrer("DESACTIVATION_SERVICE", "SERVICE", "INFO", "SERVICE", idService, "Désactivation service", null, null);
    }

    private Service chargerEtVerifierEtablissement(Long idService, Long idEtablissement) {
        Service service = em.find(Service.class, idService);
        if (service == null) {
            throw new EntiteIntrouvableException("Service", idService);
        }
        if (!service.getEtablissement().getIdEtablissement().equals(idEtablissement)) {
            throw new AccesInterditException("Ce service n'appartient pas à votre établissement.");
        }
        return service;
    }

    public static class ServiceDTO {
        public String nom;
        public CategorieService categorie;

        public ServiceDTO() {
        }

        public ServiceDTO(String nom, CategorieService categorie) {
            this.nom = nom;
            this.categorie = categorie;
        }
    }
}
