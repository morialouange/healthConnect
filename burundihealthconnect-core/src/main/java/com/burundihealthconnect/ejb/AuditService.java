package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.AuditLog;
import com.burundihealthconnect.entity.Utilisateur;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Stateless
public class AuditService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    private static final int TAILLE_PAGE = 10;

    public void enregistrer(String action, String module, String niveau,
                            String cibleType, Long cibleId, String description,
                            Utilisateur utilisateur, HttpServletRequest request) {
        AuditLog log = new AuditLog();
        log.setAction(action);
        log.setModule(module);
        log.setNiveau(niveau);
        log.setCibleType(cibleType);
        log.setCibleId(cibleId);
        log.setDescription(description);
        log.setDateAction(LocalDateTime.now());

        if (utilisateur != null) {
            log.setIdUtilisateur(utilisateur.getIdUtilisateur());
            log.setNomUtilisateur(utilisateur.getFullName());
            log.setRoleUtilisateur(utilisateur.getRole().name());
            if (utilisateur.getEtablissement() != null) {
                log.setIdEtablissement(utilisateur.getEtablissement().getIdEtablissement());
                log.setNomEtablissement(utilisateur.getEtablissement().getNom());
            }
        } else {
            log.setNomUtilisateur("SYSTEME");
            log.setRoleUtilisateur("INCONNU");
        }

        if (request != null) {
            log.setAdresseIp(request.getRemoteAddr());
            String ua = request.getHeader("User-Agent");
            if (ua != null && ua.length() > 500) {
                ua = ua.substring(0, 500);
            }
            log.setUserAgent(ua);
        }

        em.persist(log);
    }

    public List<AuditLog> getLogs(int page, String filtreModule, String filtreNiveau,
                                  String filtreRecherche, LocalDate dateDebut, LocalDate dateFin) {
        StringBuilder jpql = new StringBuilder("SELECT a FROM AuditLog a WHERE 1=1");

        if (filtreModule != null && !filtreModule.isBlank()) {
            jpql.append(" AND a.module = :module");
        }
        if (filtreNiveau != null && !filtreNiveau.isBlank()) {
            jpql.append(" AND a.niveau = :niveau");
        }
        if (filtreRecherche != null && !filtreRecherche.isBlank()) {
            jpql.append(" AND (LOWER(a.nomUtilisateur) LIKE :recherche OR LOWER(a.description) LIKE :recherche OR LOWER(a.action) LIKE :recherche)");
        }
        if (dateDebut != null) {
            jpql.append(" AND a.dateAction >= :debut");
        }
        if (dateFin != null) {
            jpql.append(" AND a.dateAction < :fin");
        }

        jpql.append(" ORDER BY a.dateAction DESC");

        TypedQuery<AuditLog> q = em.createQuery(jpql.toString(), AuditLog.class);

        if (filtreModule != null && !filtreModule.isBlank()) {
            q.setParameter("module", filtreModule);
        }
        if (filtreNiveau != null && !filtreNiveau.isBlank()) {
            q.setParameter("niveau", filtreNiveau);
        }
        if (filtreRecherche != null && !filtreRecherche.isBlank()) {
            q.setParameter("recherche", "%" + filtreRecherche.toLowerCase() + "%");
        }
        if (dateDebut != null) {
            q.setParameter("debut", dateDebut.atStartOfDay());
        }
        if (dateFin != null) {
            q.setParameter("fin", dateFin.plusDays(1).atStartOfDay());
        }

        return q.setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    public long countLogs(String filtreModule, String filtreNiveau,
                          String filtreRecherche, LocalDate dateDebut, LocalDate dateFin) {
        StringBuilder jpql = new StringBuilder("SELECT COUNT(a) FROM AuditLog a WHERE 1=1");

        if (filtreModule != null && !filtreModule.isBlank()) {
            jpql.append(" AND a.module = :module");
        }
        if (filtreNiveau != null && !filtreNiveau.isBlank()) {
            jpql.append(" AND a.niveau = :niveau");
        }
        if (filtreRecherche != null && !filtreRecherche.isBlank()) {
            jpql.append(" AND (LOWER(a.nomUtilisateur) LIKE :recherche OR LOWER(a.description) LIKE :recherche OR LOWER(a.action) LIKE :recherche)");
        }
        if (dateDebut != null) {
            jpql.append(" AND a.dateAction >= :debut");
        }
        if (dateFin != null) {
            jpql.append(" AND a.dateAction < :fin");
        }

        TypedQuery<Long> q = em.createQuery(jpql.toString(), Long.class);

        if (filtreModule != null && !filtreModule.isBlank()) {
            q.setParameter("module", filtreModule);
        }
        if (filtreNiveau != null && !filtreNiveau.isBlank()) {
            q.setParameter("niveau", filtreNiveau);
        }
        if (filtreRecherche != null && !filtreRecherche.isBlank()) {
            q.setParameter("recherche", "%" + filtreRecherche.toLowerCase() + "%");
        }
        if (dateDebut != null) {
            q.setParameter("debut", dateDebut.atStartOfDay());
        }
        if (dateFin != null) {
            q.setParameter("fin", dateFin.plusDays(1).atStartOfDay());
        }

        return q.getSingleResult();
    }

    public Map<String, Object> getStatsAudit() {
        Map<String, Object> stats = new HashMap<>();

        LocalDateTime debutAujourdhui = LocalDate.now().atStartOfDay();
        LocalDateTime finAujourdhui = LocalDate.now().plusDays(1).atStartOfDay();

        long actionsAujourdhui = em.createQuery(
                "SELECT COUNT(a) FROM AuditLog a WHERE a.dateAction >= :debut AND a.dateAction < :fin", Long.class)
                .setParameter("debut", debutAujourdhui)
                .setParameter("fin", finAujourdhui)
                .getSingleResult();
        stats.put("actionsAujourdhui", actionsAujourdhui);

        long actionsCritiques = em.createQuery(
                "SELECT COUNT(a) FROM AuditLog a WHERE a.niveau = 'CRITICAL'", Long.class)
                .getSingleResult();
        stats.put("actionsCritiques", actionsCritiques);

        long connexionsEchouees = em.createQuery(
                "SELECT COUNT(a) FROM AuditLog a WHERE a.action = 'CONNEXION_ECHOUEE'", Long.class)
                .getSingleResult();
        stats.put("connexionsEchouees", connexionsEchouees);

        long modificationsDossier = em.createQuery(
                "SELECT COUNT(a) FROM AuditLog a WHERE a.module = 'DOSSIER' AND a.action LIKE 'MODIFICATION_%'", Long.class)
                .getSingleResult();
        stats.put("modificationsDossier", modificationsDossier);

        long actionsAdmin = em.createQuery(
                "SELECT COUNT(a) FROM AuditLog a WHERE a.roleUtilisateur = 'SUPER_ADMIN' OR a.roleUtilisateur = 'ADMIN'", Long.class)
                .getSingleResult();
        stats.put("actionsAdmin", actionsAdmin);

        long accesDossiers = em.createQuery(
                "SELECT COUNT(a) FROM AuditLog a WHERE a.cibleType = 'DOSSIER' AND a.action LIKE 'ACCES_%'", Long.class)
                .getSingleResult();
        stats.put("accesDossiers", accesDossiers);

        return stats;
    }

    public List<AuditLog> getLogsCritiquesRecents(int max) {
        return em.createQuery(
                "SELECT a FROM AuditLog a WHERE a.niveau = 'CRITICAL' ORDER BY a.dateAction DESC", AuditLog.class)
                .setMaxResults(max)
                .getResultList();
    }

    public List<String[]> getActionsParModule() {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                "SELECT a.module, COUNT(a) FROM AuditLog a GROUP BY a.module ORDER BY COUNT(a) DESC", Object[].class)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{(String) row[0], String.valueOf(row[1])});
        }
        return result;
    }

    public List<String[]> getActionsParNiveau() {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                "SELECT a.niveau, COUNT(a) FROM AuditLog a GROUP BY a.niveau ORDER BY COUNT(a) DESC", Object[].class)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{(String) row[0], String.valueOf(row[1])});
        }
        return result;
    }

    public List<String[]> getActivite7Jours() {
        List<String[]> result = new ArrayList<>();
        LocalDate today = LocalDate.now();
        String[] jours = {"Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"};
        for (int i = 6; i >= 0; i--) {
            LocalDate jour = today.minusDays(i);
            LocalDateTime debut = jour.atStartOfDay();
            LocalDateTime fin = jour.plusDays(1).atStartOfDay();
            long nb = em.createQuery(
                    "SELECT COUNT(a) FROM AuditLog a WHERE a.dateAction >= :d AND a.dateAction < :f", Long.class)
                    .setParameter("d", debut)
                    .setParameter("f", fin)
                    .getSingleResult();
            result.add(new String[]{jours[jour.getDayOfWeek().getValue() % 7], String.valueOf(nb)});
        }
        return result;
    }
}
