package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.Patient;
import com.burundihealthconnect.entity.enums.Role;
import com.burundihealthconnect.entity.enums.StatutRdv;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * EtablissementService — Session Bean Stateless.
 * Logiques couvertes :
 *   L08 — Tableau de bord avec statistiques, différentes par rôle
 *   L11 — Isolation par établissement (toutes les requêtes filtrent
 *         par id_etablissement, sauf findAll() réservé au SUPER_ADMIN)
 */
@Stateless
public class EtablissementService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    private static final int TAILLE_PAGE = 10;

    /** Liste tous les établissements du réseau — usage SUPER_ADMIN + formulaire d'inscription patient. */
    public List<EtablissementSante> findAll(int page) {
        return em.createQuery("SELECT e FROM EtablissementSante e ORDER BY e.nom ASC", EtablissementSante.class)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    /** SUPER_ADMIN — Liste des établissements avec filtre texte (pour la page hopitaux). */
    public List<EtablissementSante> findAll(String filtre, int page) {
        return findAll(filtre, page, "nom", "asc");
    }

    /** SUPER_ADMIN — Liste des établissements avec filtre + tri. */
    public List<EtablissementSante> findAll(String filtre, int page, String tri, String ordre) {
        String jpql = "SELECT e FROM EtablissementSante e WHERE 1=1";
        if (filtre != null && !filtre.isBlank()) {
            jpql += " AND LOWER(e.nom) LIKE :filtre";
        }
        String sortField = "e.nom";
        if ("type".equals(tri)) sortField = "e.typeEtablissement";
        else if ("adresse".equals(tri)) sortField = "e.adresse";
        else if ("actif".equals(tri)) sortField = "e.actif";
        String sortDir = "desc".equalsIgnoreCase(ordre) ? "DESC" : "ASC";
        jpql += " ORDER BY " + sortField + " " + sortDir;
        TypedQuery<EtablissementSante> q = em.createQuery(jpql, EtablissementSante.class);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        return q.setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    public long countAll(String filtre) {
        String jpql = "SELECT COUNT(e) FROM EtablissementSante e WHERE 1=1";
        if (filtre != null && !filtre.isBlank()) {
            jpql += " AND LOWER(e.nom) LIKE :filtre";
        }
        TypedQuery<Long> q = em.createQuery(jpql, Long.class);
        if (filtre != null && !filtre.isBlank()) {
            q.setParameter("filtre", "%" + filtre.toLowerCase() + "%");
        }
        return q.getSingleResult();
    }

    /** SUPER_ADMIN — Crée un nouvel établissement dans le réseau. */
    public EtablissementSante creerEtablissement(String nom, String adresse, String typeEtablissement,
                                                  String email, String telephone) {
        EtablissementSante etablissement = new EtablissementSante();
        etablissement.setNom(nom);
        etablissement.setAdresse(adresse);
        etablissement.setTypeEtablissement(typeEtablissement);
        etablissement.setEmail(email);
        etablissement.setTelephone(telephone);
        etablissement.setActif(true);
        em.persist(etablissement);
        return etablissement;
    }

    /** SUPER_ADMIN — Modifie un établissement existant. */
    public EtablissementSante modifierEtablissement(Long idEtablissement, String nom, String adresse,
                                                      String typeEtablissement, String email, String telephone) {
        EtablissementSante etablissement = getById(idEtablissement);
        if (nom != null) {
            etablissement.setNom(nom);
        }
        if (adresse != null) {
            etablissement.setAdresse(adresse);
        }
        if (typeEtablissement != null) {
            etablissement.setTypeEtablissement(typeEtablissement);
        }
        if (email != null) {
            etablissement.setEmail(email);
        }
        if (telephone != null) {
            etablissement.setTelephone(telephone);
        }
        em.merge(etablissement);
        return etablissement;
    }

    /** SUPER_ADMIN — Désactivation logique d'un établissement (jamais de suppression physique). */
    public void desactiverEtablissement(Long idEtablissement) {
        EtablissementSante etablissement = getById(idEtablissement);
        etablissement.setActif(false);
        em.merge(etablissement);
    }

    /** SUPER_ADMIN — Réactive un établissement précédemment désactivé. */
    public void reactiverEtablissement(Long idEtablissement) {
        EtablissementSante etablissement = getById(idEtablissement);
        etablissement.setActif(true);
        em.merge(etablissement);
    }

    /** Retourne tous les établissements sauf celui dont l'id est fourni. */
    public List<EtablissementSante> getAllSauf(Long idEtablissement) {
        return em.createQuery(
                        "SELECT e FROM EtablissementSante e WHERE e.idEtablissement != :id ORDER BY e.nom ASC",
                        EtablissementSante.class)
                .setParameter("id", idEtablissement)
                .getResultList();
    }

    /** L11 — Liste les médecins actifs d'un établissement donné (filtré). */
    public List<Medecin> getMedecinsByEtablissement(Long idEtablissement) {
        return em.createQuery(
                        "SELECT m FROM Medecin m " +
                                "WHERE m.utilisateur.etablissement.idEtablissement = :idEtab " +
                                "AND m.utilisateur.actif = true " +
                                "ORDER BY m.utilisateur.fullName ASC",
                        Medecin.class)
                .setParameter("idEtab", idEtablissement)
                .getResultList();
    }

    // =========================================================
    // L08 — STATISTIQUES PAR ROLE
    // =========================================================

    /**
     * Dispatcheur générique correspondant à la signature exigée par le
     * document logique : EtablissementService.getStatistiques(). Renvoie
     * une Map<String,Object> directement exploitable en JSTL EL
     * (${stats.rdvAVenir}, etc. — utiliser plutôt les méthodes typées
     * ci-dessous depuis les Servlets pour plus de clarté ; cette méthode
     * sert de point d'entrée unique si besoin).
     */
    public Map<String, Object> getStatistiques(Role role, Long idEntiteSpecifique, Long idEtablissement) {
        switch (role) {
            case PATIENT:
                return statistiquesPatient(idEntiteSpecifique);
            case MEDECIN:
                return statistiquesMedecin(idEntiteSpecifique, idEtablissement);
            case ADMIN:
                return statistiquesAdmin(idEtablissement);
            case SUPER_ADMIN:
                return statistiquesSuperAdmin();
            default:
                return new HashMap<>();
        }
    }

    /** PATIENT : prochain RDV à venir + date de la dernière consultation versée au dossier. */
    private Map<String, Object> statistiquesPatient(Long idPatient) {
        Map<String, Object> stats = new HashMap<>();

        TypedQuery<Long> qRdv = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r " +
                        "WHERE r.patient.idPatient = :idPatient " +
                        "AND r.statut IN (:demande, :confirme) " +
                        "AND r.dateRendez >= :maintenant",
                Long.class);
        qRdv.setParameter("idPatient", idPatient);
        qRdv.setParameter("demande", StatutRdv.RDV_DEMANDE);
        qRdv.setParameter("confirme", StatutRdv.RDV_CONFIRME);
        qRdv.setParameter("maintenant", LocalDateTime.now());
        stats.put("rdvAVenir", qRdv.getSingleResult());

        TypedQuery<LocalDateTime> qDerniere = em.createQuery(
                "SELECT MAX(c.dateConsultation) FROM Consultation c " +
                        "WHERE c.dossier.patient.idPatient = :idPatient",
                LocalDateTime.class);
        qDerniere.setParameter("idPatient", idPatient);
        stats.put("derniereConsultation", qDerniere.getSingleResult());

        stats.put("chartRdvParMois", chartRdvParMoisPatient(idPatient));
        stats.put("chartRdvParStatut", chartRdvParStatutPatient(idPatient));

        // Enhanced patient stats
        Patient patient = em.find(Patient.class, idPatient);
        if (patient != null) {
            stats.put("numeroPatient", patient.getNumeroPatient());
            stats.put("groupeSanguin", patient.getGroupeSanguin() != null ? patient.getGroupeSanguin() : "");
            stats.put("allergies", patient.getAllergies() != null ? patient.getAllergies() : "");

            if (patient.getDossierMedical() != null) {
                stats.put("numeroDossier", patient.getDossierMedical().getNumeroUnique());
                stats.put("derniereMiseAJour", patient.getDossierMedical().getDateMiseAJour());
            } else {
                stats.put("numeroDossier", "");
                stats.put("derniereMiseAJour", null);
            }

            // Profile completion
            int totalFields = 6;
            int filled = 0;
            if (patient.getDateNaissance() != null) filled++;
            if (patient.getSexe() != null) filled++;
            if (patient.getTelephone() != null && !patient.getTelephone().isBlank()) filled++;
            if (patient.getGroupeSanguin() != null && !patient.getGroupeSanguin().isBlank()) filled++;
            if (patient.getAllergies() != null && !patient.getAllergies().isBlank()) filled++;
            if (patient.getAdresse() != null && !patient.getAdresse().isBlank()) filled++;
            stats.put("profilComplete", (filled * 100) / totalFields);
        } else {
            stats.put("numeroPatient", "");
            stats.put("numeroDossier", "");
            stats.put("groupeSanguin", "");
            stats.put("allergies", "");
            stats.put("derniereMiseAJour", null);
            stats.put("profilComplete", 0);
        }

        // Prochain RDV detail
        List<Object[]> prochainRdv = em.createQuery(
                "SELECT r.dateRendez, r.medecin.utilisateur.fullName, r.etablissement.nom, r.statut, r.idRendez FROM RendezVous r " +
                        "WHERE r.patient.idPatient = :idPatient AND r.dateRendez >= :maintenant ORDER BY r.dateRendez ASC", Object[].class)
                .setParameter("idPatient", idPatient)
                .setParameter("maintenant", LocalDateTime.now())
                .setMaxResults(1)
                .getResultList();
        if (!prochainRdv.isEmpty()) {
            Object[] row = prochainRdv.get(0);
            Map<String, Object> rdv = new HashMap<>();
            rdv.put("date", row[0]);
            rdv.put("medecin", row[1]);
            rdv.put("hopital", row[2]);
            rdv.put("statut", row[3]);
            rdv.put("idRendez", row[4]);
            stats.put("prochainRdv", rdv);
        } else {
            stats.put("prochainRdv", null);
        }

        // Prochain passage detail
        List<Object[]> prochainPassage = em.createQuery(
                "SELECT r.dateRendez, r.etablissement.nom, r.medecin.utilisateur.fullName, r.statut, r.idRendez, r.priorite, r.medecin.specialite, r.service.nom FROM RendezVous r " +
                        "WHERE r.patient.idPatient = :idPatient AND r.dateRendez >= :maintenant AND r.statut != :annule ORDER BY r.dateRendez ASC", Object[].class)
                .setParameter("idPatient", idPatient)
                .setParameter("maintenant", LocalDateTime.now())
                .setParameter("annule", StatutRdv.RDV_ANNULE)
                .setMaxResults(1)
                .getResultList();
        if (!prochainPassage.isEmpty()) {
            Object[] row = prochainPassage.get(0);
            Map<String, Object> passage = new HashMap<>();
            passage.put("date", row[0]);
            passage.put("hopital", row[1]);
            passage.put("medecin", row[2]);
            passage.put("statut", row[3]);
            passage.put("idRendez", row[4]);
            passage.put("priorite", row[5]);
            passage.put("specialite", row[6]);
            passage.put("service", row[7]);
            passage.put("annulable", row[3] == StatutRdv.RDV_DEMANDE);
            stats.put("prochainPassage", passage);
        } else {
            stats.put("prochainPassage", null);
        }

        // Derniere consultation detail
        List<Object[]> derniereConsult = em.createQuery(
                "SELECT c.dateConsultation, c.medecin.utilisateur.fullName, c.etablissement.nom, c.diagnostic FROM Consultation c " +
                        "WHERE c.dossier.patient.idPatient = :idPatient AND c.statut = :versee ORDER BY c.dateConsultation DESC", Object[].class)
                .setParameter("idPatient", idPatient)
                .setParameter("versee", com.burundihealthconnect.entity.enums.StatutConsultation.VERSEE_AU_DOSSIER)
                .setMaxResults(1)
                .getResultList();
        if (!derniereConsult.isEmpty()) {
            Object[] row = derniereConsult.get(0);
            Map<String, Object> dc = new HashMap<>();
            dc.put("date", row[0]);
            dc.put("medecin", row[1]);
            dc.put("hopital", row[2]);
            dc.put("diagnostic", row[3]);
            stats.put("derniereConsultationDetail", dc);
        } else {
            stats.put("derniereConsultationDetail", null);
        }

        long ordonnancesDisponibles = em.createQuery(
                "SELECT COUNT(o) FROM Ordonance o WHERE o.consultation.dossier.patient.idPatient = :idPatient", Long.class)
                .setParameter("idPatient", idPatient)
                .getSingleResult();
        stats.put("ordonnancesDisponibles", ordonnancesDisponibles);

        long referenementsRecus = em.createQuery(
                "SELECT COUNT(r) FROM Referenement r WHERE r.consultation.dossier.patient.idPatient = :idPatient", Long.class)
                .setParameter("idPatient", idPatient)
                .getSingleResult();
        stats.put("referenementsRecus", referenementsRecus);

        long notificationsNonLues = em.createQuery(
                "SELECT COUNT(n) FROM Notification n WHERE n.utilisateur.idUtilisateur = (SELECT u.idUtilisateur FROM Patient p JOIN p.utilisateur u WHERE p.idPatient = :idPatient) AND n.lue = false", Long.class)
                .setParameter("idPatient", idPatient)
                .getSingleResult();
        stats.put("notificationsNonLues", notificationsNonLues);

        long rdvEnAttenteConfirmation = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.patient.idPatient = :idPatient AND r.statut = :demande", Long.class)
                .setParameter("idPatient", idPatient)
                .setParameter("demande", StatutRdv.RDV_DEMANDE)
                .getSingleResult();
        stats.put("rdvEnAttenteConfirmation", rdvEnAttenteConfirmation);

        long rdvAnnulables = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.patient.idPatient = :idPatient AND r.statut = :demande AND r.dateRendez >= :maintenant", Long.class)
                .setParameter("idPatient", idPatient)
                .setParameter("demande", StatutRdv.RDV_DEMANDE)
                .setParameter("maintenant", LocalDateTime.now())
                .getSingleResult();
        stats.put("rdvAnnulables", rdvAnnulables);

        long consultationsVersees = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.dossier.patient.idPatient = :idPatient AND c.statut = :versee", Long.class)
                .setParameter("idPatient", idPatient)
                .setParameter("versee", com.burundihealthconnect.entity.enums.StatutConsultation.VERSEE_AU_DOSSIER)
                .getSingleResult();
        stats.put("consultationsVersees", consultationsVersees);

        long totalRdv = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.patient.idPatient = :idPatient", Long.class)
                .setParameter("idPatient", idPatient)
                .getSingleResult();
        long rdvTermines = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.patient.idPatient = :idPatient AND r.statut = :termine", Long.class)
                .setParameter("idPatient", idPatient)
                .setParameter("termine", StatutRdv.TERMINE)
                .getSingleResult();
        stats.put("tauxPresence", totalRdv > 0 ? (rdvTermines * 100 / totalRdv) : 0);

        stats.put("chartTimelineMedicale", chartTimelineMedicalePatient(idPatient));
        stats.put("statutRdvComplet", chartRdvParStatutCompletPatient(idPatient));

        // Historique récent des rendez-vous (dashboard patient)
        java.time.format.DateTimeFormatter rdvDateFmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
        java.time.format.DateTimeFormatter rdvHeureFmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
        List<Object[]> rdvRecentsRows = em.createQuery(
                "SELECT r.dateRendez, r.medecin.utilisateur.fullName, r.medecin.specialite, r.statut FROM RendezVous r " +
                        "WHERE r.patient.idPatient = :idPatient ORDER BY r.dateRendez DESC", Object[].class)
                .setParameter("idPatient", idPatient)
                .setMaxResults(5)
                .getResultList();
        List<Map<String, Object>> rdvRecents = new ArrayList<>();
        for (Object[] row : rdvRecentsRows) {
            Map<String, Object> rr = new HashMap<>();
            if (row[0] instanceof java.time.LocalDateTime) {
                java.time.LocalDateTime ldt = (java.time.LocalDateTime) row[0];
                rr.put("date", ldt.toLocalDate().format(rdvDateFmt));
                rr.put("heure", ldt.toLocalTime().format(rdvHeureFmt));
            } else {
                rr.put("date", row[0] != null ? String.valueOf(row[0]) : "");
                rr.put("heure", "");
            }
            rr.put("medecin", row[1] != null ? String.valueOf(row[1]) : "");
            rr.put("specialite", row[2] != null ? String.valueOf(row[2]) : "");
            rr.put("statut", row[3] != null ? String.valueOf(row[3]) : "");
            rdvRecents.add(rr);
        }
        stats.put("rdvRecents", rdvRecents);

        // Ordonnances actives : lignes de prescription récentes (dashboard patient)
        List<Object[]> ordRows = em.createQuery(
                "SELECT l.medicament, l.dosage, l.frequence, l.dureeJours, o.consultation.medecin.utilisateur.fullName " +
                        "FROM LignePrescription l JOIN l.ordonance o " +
                        "WHERE o.consultation.dossier.patient.idPatient = :idPatient ORDER BY o.createdAt DESC", Object[].class)
                .setParameter("idPatient", idPatient)
                .setMaxResults(6)
                .getResultList();
        List<Map<String, Object>> ordonnancesActives = new ArrayList<>();
        for (Object[] row : ordRows) {
            Map<String, Object> orm = new HashMap<>();
            orm.put("medicament", row[0] != null ? String.valueOf(row[0]) : "");
            orm.put("dosage", row[1] != null ? String.valueOf(row[1]) : "");
            orm.put("frequence", row[2] != null ? String.valueOf(row[2]) : "");
            orm.put("dureeJours", row[3] != null ? row[3] : "");
            orm.put("medecin", row[4] != null ? String.valueOf(row[4]) : "");
            ordonnancesActives.add(orm);
        }
        stats.put("ordonnancesActives", ordonnancesActives);

        // JSP aliases
        stats.put("chartPatientMois", stats.get("chartRdvParMois"));
        stats.put("chartPatientStatuts", stats.get("chartRdvParStatut"));
        stats.put("derniereMaj", stats.get("derniereMiseAJour"));

        // String display for prochainRdv (JSP uses it as simple value)
        if (stats.get("prochainRdv") != null) {
            @SuppressWarnings("unchecked")
            Map<String, Object> rdvMap = (Map<String, Object>) stats.get("prochainRdv");
            Object dateRdv = rdvMap.get("date");
            stats.put("prochainRdv", dateRdv != null ? dateRdv.toString() : "—");
        } else {
            stats.put("prochainRdv", "—");
        }

        // prochainRdvDetail with extra fields for the detail card
        if (stats.get("prochainPassage") != null) {
            @SuppressWarnings("unchecked")
            Map<String, Object> passage = (Map<String, Object>) stats.get("prochainPassage");
            Map<String, Object> detail = new HashMap<>();
            Object d = passage.get("date");
            if (d instanceof java.time.LocalDateTime) {
                java.time.LocalDateTime ldt = (java.time.LocalDateTime) d;
                detail.put("date", ldt.toLocalDate().toString());
                detail.put("heure", ldt.toLocalTime().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm")));
            } else {
                detail.put("date", d != null ? d.toString() : "");
                detail.put("heure", "");
            }
            detail.put("medecin", passage.getOrDefault("medecin", ""));
            detail.put("specialite", passage.getOrDefault("specialite", ""));
            detail.put("hopital", passage.getOrDefault("hopital", ""));
            detail.put("service", passage.getOrDefault("service", ""));
            detail.put("statut", passage.getOrDefault("statut", ""));
            detail.put("idRendezVous", passage.getOrDefault("idRendez", ""));
            stats.put("prochainRdvDetail", detail);
        } else {
            stats.put("prochainRdvDetail", null);
        }

        // derniereConsultationDetail as string for JSP simple display
        if (stats.get("derniereConsultationDetail") != null) {
            @SuppressWarnings("unchecked")
            Map<String, Object> dc = (Map<String, Object>) stats.get("derniereConsultationDetail");
            Object d = dc.get("date");
            stats.put("derniereConsultationDetail", d != null ? d.toString() : "—");
        } else {
            stats.put("derniereConsultationDetail", "—");
        }

        // Timeline medicale as list of maps for JSP
        java.time.format.DateTimeFormatter dateFmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
        List<Object[]> consRows = em.createQuery(
                "SELECT c.dateConsultation, c.medecin.utilisateur.fullName, c.diagnostic FROM Consultation c " +
                        "WHERE c.dossier.patient.idPatient = :idPatient ORDER BY c.dateConsultation DESC", Object[].class)
                .setParameter("idPatient", idPatient)
                .setMaxResults(20)
                .getResultList();
        List<Map<String, Object>> tlList = new ArrayList<>();
        for (Object[] row : consRows) {
            Map<String, Object> tm = new HashMap<>();
            tm.put("date", row[0] != null ? ((java.time.LocalDateTime) row[0]).format(dateFmt) : "");
            tm.put("medecin", row[1] != null ? row[1] : "");
            tm.put("motif", row[2] != null ? row[2] : "");
            tlList.add(tm);
        }
        stats.put("timelineMedicale", tlList);

        // Trends KPI (vs jour précédent / vs mois précédent)
        LocalDateTime debutHier = LocalDate.now().minusDays(1).atStartOfDay();
        LocalDateTime finHier = LocalDate.now().atStartOfDay();

        long attenteHier = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.patient.idPatient = :id AND r.statut = :s AND r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                .setParameter("id", idPatient).setParameter("s", StatutRdv.RDV_DEMANDE).setParameter("d", debutHier).setParameter("f", finHier)
                .getSingleResult();
        stats.put("trendRdvEnAttenteConfirmation", calculerTrend(rdvEnAttenteConfirmation, attenteHier));

        LocalDateTime debutMois = YearMonth.now().atDay(1).atStartOfDay();
        LocalDateTime finMois = YearMonth.now().plusMonths(1).atDay(1).atStartOfDay();
        LocalDateTime debutMoisPrec = YearMonth.now().minusMonths(1).atDay(1).atStartOfDay();
        LocalDateTime finMoisPrec = YearMonth.now().atDay(1).atStartOfDay();

        long ordonnancesMoisPrec = em.createQuery(
                "SELECT COUNT(o) FROM Ordonance o WHERE o.consultation.dossier.patient.idPatient = :id AND o.createdAt >= :d AND o.createdAt < :f", Long.class)
                .setParameter("id", idPatient).setParameter("d", debutMoisPrec).setParameter("f", finMoisPrec)
                .getSingleResult();
        stats.put("trendOrdonnances", calculerTrend(ordonnancesDisponibles, ordonnancesMoisPrec));

        long consVerseesMois = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.dossier.patient.idPatient = :id AND c.statut = :s AND c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                .setParameter("id", idPatient)
                .setParameter("s", com.burundihealthconnect.entity.enums.StatutConsultation.VERSEE_AU_DOSSIER)
                .setParameter("d", debutMois).setParameter("f", finMois)
                .getSingleResult();
        long consVerseesMoisPrec = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.dossier.patient.idPatient = :id AND c.statut = :s AND c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                .setParameter("id", idPatient)
                .setParameter("s", com.burundihealthconnect.entity.enums.StatutConsultation.VERSEE_AU_DOSSIER)
                .setParameter("d", debutMoisPrec).setParameter("f", finMoisPrec)
                .getSingleResult();
        stats.put("trendConsultationsVersees", calculerTrend(consVerseesMois, consVerseesMoisPrec));

        return stats;
    }

    private static final String[] MOIS_ABREGES = {
            "JAN", "FEV", "MAR", "AVR", "MAI", "JUIN", "JUIL", "AO\u00DBT", "SEP", "OCT", "NOV", "DEC"
    };

    private static String moisAbrege(YearMonth ym) {
        return MOIS_ABREGES[ym.getMonthValue() - 1];
    }

    private List<String[]> chartTimelineMedicalePatient(Long idPatient) {
        List<String[]> result = new ArrayList<>();
        for (int i = 11; i >= 0; i--) {
            java.time.YearMonth ym = java.time.YearMonth.now().minusMonths(i);
            LocalDateTime debut = ym.atDay(1).atStartOfDay();
            LocalDateTime fin = ym.plusMonths(1).atDay(1).atStartOfDay();
            long nb = em.createQuery(
                    "SELECT COUNT(c) FROM Consultation c WHERE c.dossier.patient.idPatient = :id AND c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                    .setParameter("id", idPatient)
                    .setParameter("d", debut).setParameter("f", fin)
                    .getSingleResult();
            result.add(new String[]{moisAbrege(ym), String.valueOf(nb)});
        }
        return result;
    }

    private List<String[]> chartRdvParMoisPatient(Long idPatient) {
        List<String[]> result = new ArrayList<>();
        for (int i = 5; i >= 0; i--) {
            YearMonth ym = YearMonth.now().minusMonths(i);
            LocalDateTime debut = ym.atDay(1).atStartOfDay();
            LocalDateTime fin = ym.plusMonths(1).atDay(1).atStartOfDay();
            long nb = em.createQuery(
                            "SELECT COUNT(r) FROM RendezVous r WHERE r.patient.idPatient = :id AND r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                    .setParameter("id", idPatient)
                    .setParameter("d", debut).setParameter("f", fin)
                    .getSingleResult();
            result.add(new String[]{moisAbrege(ym), String.valueOf(nb)});
        }
        return result;
    }

    private List<String[]> chartRdvParStatutPatient(Long idPatient) {
        List<String[]> result = new ArrayList<>();
        for (StatutRdv s : StatutRdv.values()) {
            long nb = em.createQuery(
                            "SELECT COUNT(r) FROM RendezVous r WHERE r.patient.idPatient = :id AND r.statut = :s", Long.class)
                    .setParameter("id", idPatient)
                    .setParameter("s", s)
                    .getSingleResult();
            if (nb > 0) {
                result.add(new String[]{s.name(), String.valueOf(nb)});
            }
        }
        return result;
    }

    private List<String[]> chartRdvParStatutCompletPatient(Long idPatient) {
        List<String[]> result = new ArrayList<>();
        for (StatutRdv s : StatutRdv.values()) {
            long nb = em.createQuery(
                            "SELECT COUNT(r) FROM RendezVous r WHERE r.patient.idPatient = :id AND r.statut = :s", Long.class)
                    .setParameter("id", idPatient)
                    .setParameter("s", s)
                    .getSingleResult();
            result.add(new String[]{s.name(), String.valueOf(nb)});
        }
        return result;
    }

    /** MEDECIN : RDV du jour, RDV en attente, consultations en cours. */
    private Map<String, Object> statistiquesMedecin(Long idMedecin, Long idEtablissement) {
        Map<String, Object> stats = new HashMap<>();
        LocalDateTime debutJour = LocalDate.now().atStartOfDay();
        LocalDateTime finJour = LocalDate.now().plusDays(1).atStartOfDay();

        long rdvDuJour = em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r " +
                                "WHERE r.medecin.idMedecin = :idMedecin " +
                                "AND r.dateRendez >= :debut AND r.dateRendez < :fin",
                        Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("debut", debutJour)
                .setParameter("fin", finJour)
                .getSingleResult();
        stats.put("rdvDuJour", rdvDuJour);

        long rdvEnAttente = em.createQuery(
                        "SELECT COUNT(r) FROM RendezVous r " +
                                "WHERE r.medecin.idMedecin = :idMedecin AND r.statut = :statut",
                        Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("statut", StatutRdv.RDV_DEMANDE)
                .getSingleResult();
        stats.put("rdvEnAttente", rdvEnAttente);

        long consultationsEnCours = em.createQuery(
                        "SELECT COUNT(c) FROM Consultation c " +
                                "WHERE c.medecin.idMedecin = :idMedecin " +
                                "AND c.statut = com.burundihealthconnect.entity.enums.StatutConsultation.EN_COURS",
                        Long.class)
                .setParameter("idMedecin", idMedecin)
                .getSingleResult();
        stats.put("consultationsEnCours", consultationsEnCours);

        stats.put("chartRdvParSemaine", chartRdvParSemaine(idMedecin));
        stats.put("chartRdvParPriorite", chartRdvParPriorite(idMedecin));

        // Enhanced medecin stats
        long rdvUrgentsCritiques = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :idMedecin AND r.priorite IN (:urgent, :critique) AND r.statut != :annule", Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("urgent", com.burundihealthconnect.entity.enums.Priorite.URGENT)
                .setParameter("critique", com.burundihealthconnect.entity.enums.Priorite.CRITIQUE)
                .setParameter("annule", StatutRdv.RDV_ANNULE)
                .getSingleResult();
        stats.put("rdvUrgentsCritiques", rdvUrgentsCritiques);

        long consultationsAVerser = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.medecin.idMedecin = :idMedecin AND c.statut = :cloturee", Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("cloturee", com.burundihealthconnect.entity.enums.StatutConsultation.CLOTUREE)
                .getSingleResult();
        stats.put("consultationsAVerser", consultationsAVerser);

        YearMonth moisCourant = YearMonth.now();
        LocalDateTime debutMois = moisCourant.atDay(1).atStartOfDay();
        LocalDateTime finMois = moisCourant.plusMonths(1).atDay(1).atStartOfDay();

        long ordonnancesCeMois = em.createQuery(
                "SELECT COUNT(o) FROM Ordonance o WHERE o.consultation.medecin.idMedecin = :idMedecin AND o.createdAt >= :debut AND o.createdAt < :fin", Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        stats.put("ordonnancesCeMois", ordonnancesCeMois);

        long referenementsEnvoyes = em.createQuery(
                "SELECT COUNT(r) FROM Referenement r WHERE r.consultation.medecin.idMedecin = :idMedecin", Long.class)
                .setParameter("idMedecin", idMedecin)
                .getSingleResult();
        stats.put("referenementsEnvoyes", referenementsEnvoyes);

        long notificationsNonLues = em.createQuery(
                "SELECT COUNT(n) FROM Notification n WHERE n.utilisateur.idUtilisateur = (SELECT u.idUtilisateur FROM Medecin m JOIN m.utilisateur u WHERE m.idMedecin = :idMedecin) AND n.lue = false", Long.class)
                .setParameter("idMedecin", idMedecin)
                .getSingleResult();
        stats.put("notificationsNonLues", notificationsNonLues);

        List<Object[]> congesRecents = em.createQuery(
                "SELECT c.dateDebut, c.dateFin, c.statut FROM CongeMedecin c WHERE c.medecin.idMedecin = :idMedecin ORDER BY c.dateDebut DESC", Object[].class)
                .setParameter("idMedecin", idMedecin)
                .setMaxResults(5)
                .getResultList();
        List<Map<String, Object>> conges = new ArrayList<>();
        for (Object[] row : congesRecents) {
            Map<String, Object> cm = new HashMap<>();
            cm.put("debut", row[0]);
            cm.put("fin", row[1]);
            cm.put("statut", row[2]);
            conges.add(cm);
        }
        stats.put("congesRecents", conges);

        long totalRdvConfirmes = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :idMedecin AND r.statut IN (:confirme, :termine)", Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("confirme", StatutRdv.RDV_CONFIRME)
                .setParameter("termine", StatutRdv.TERMINE)
                .getSingleResult();
        long rdvTermines = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :idMedecin AND r.statut = :termine", Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("termine", StatutRdv.TERMINE)
                .getSingleResult();
        stats.put("tauxRdvTermines", totalRdvConfirmes > 0 ? (rdvTermines * 100 / totalRdvConfirmes) : 0);

        // Timeline today
        List<Object[]> timeline = em.createQuery(
                "SELECT r.dateRendez, r.patient.utilisateur.fullName, r.statut, r.priorite, r.motif FROM RendezVous r " +
                        "WHERE r.medecin.idMedecin = :idMedecin AND r.dateRendez >= :debut AND r.dateRendez < :fin ORDER BY r.dateRendez ASC", Object[].class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("debut", debutJour)
                .setParameter("fin", finJour)
                .getResultList();
        List<Map<String, Object>> timelineList = new ArrayList<>();
        for (Object[] row : timeline) {
            Map<String, Object> tm = new HashMap<>();
            tm.put("heure", row[0]);
            tm.put("patient", row[1]);
            tm.put("statut", row[2]);
            tm.put("priorite", row[3]);
            tm.put("motif", row[4]);
            timelineList.add(tm);
        }
        stats.put("timelineDuJour", timelineList);

        // Patients a traiter
        List<Object[]> patients = em.createQuery(
                "SELECT r.patient.numeroPatient, r.patient.utilisateur.fullName, r.dateRendez, r.priorite, r.motif, r.idRendez, d.idDossier, r.statut FROM RendezVous r LEFT JOIN r.patient.dossierMedical d " +
                        "WHERE r.medecin.idMedecin = :idMedecin AND r.dateRendez >= :debut AND r.dateRendez < :fin AND r.statut IN (:confirme, :demande) ORDER BY r.priorite DESC, r.dateRendez ASC", Object[].class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("debut", debutJour)
                .setParameter("fin", finJour)
                .setParameter("confirme", StatutRdv.RDV_CONFIRME)
                .setParameter("demande", StatutRdv.RDV_DEMANDE)
                .getResultList();
        List<Map<String, Object>> patientsList = new ArrayList<>();
        java.time.format.DateTimeFormatter timeFmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
        for (Object[] row : patients) {
            Map<String, Object> pm = new HashMap<>();
            pm.put("numeroPatient", row[0]);
            pm.put("nom", row[1]);
            pm.put("patientName", row[1]); // alias for JSP
            pm.put("dateRendez", row[2]);
            pm.put("heureRdv", row[2] != null ? ((java.time.LocalDateTime) row[2]).format(timeFmt) : "");
            pm.put("priorite", row[3]);
            pm.put("motif", row[4]);
            pm.put("idRendez", row[5]);
            pm.put("idRendezVous", row[5]); // alias for JSP
            pm.put("idDossier", row[6]);
            pm.put("statut", row[7] != null ? row[7].toString() : "");
            patientsList.add(pm);
        }
        stats.put("patientsATraiter", patientsList);

        stats.put("chartActiviteMensuelle", chartActiviteMensuelleMedecin(idMedecin));

        // Chart aliases for JSP
        stats.put("chartMedecinConsultations7j", chartRdvParSemaine(idMedecin));
        stats.put("chartMedecinRdvStatut", chartRdvParStatutForMedecin(idMedecin));
        stats.put("chartMedecinPriorites", chartRdvParPriorite(idMedecin));

        // Consultations versées percentage
        long totalConsMedecin = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.medecin.idMedecin = :idMedecin", Long.class)
                .setParameter("idMedecin", idMedecin)
                .getSingleResult();
        long consVerseesMedecin = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.medecin.idMedecin = :idMedecin AND c.statut = :versee", Long.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("versee", com.burundihealthconnect.entity.enums.StatutConsultation.VERSEE_AU_DOSSIER)
                .getSingleResult();
        stats.put("consultationsVersees", totalConsMedecin > 0 ? (consVerseesMedecin * 100 / totalConsMedecin) : 0);

        // Trends KPI (vs jour précédent)
        LocalDateTime debutHier = LocalDate.now().minusDays(1).atStartOfDay();
        LocalDateTime finHier = LocalDate.now().atStartOfDay();

        long rdvHier = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :id AND r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                .setParameter("id", idMedecin).setParameter("d", debutHier).setParameter("f", finHier)
                .getSingleResult();
        stats.put("trendRdvDuJour", calculerTrend(rdvDuJour, rdvHier));

        long attenteHier = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :id AND r.statut = :s AND r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                .setParameter("id", idMedecin).setParameter("s", StatutRdv.RDV_DEMANDE).setParameter("d", debutHier).setParameter("f", finHier)
                .getSingleResult();
        stats.put("trendRdvEnAttente", calculerTrend(rdvEnAttente, attenteHier));

        long urgentsHier = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :id AND r.priorite IN (:urgent, :critique) AND r.statut != :annule AND r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                .setParameter("id", idMedecin)
                .setParameter("urgent", com.burundihealthconnect.entity.enums.Priorite.URGENT)
                .setParameter("critique", com.burundihealthconnect.entity.enums.Priorite.CRITIQUE)
                .setParameter("annule", StatutRdv.RDV_ANNULE)
                .setParameter("d", debutHier).setParameter("f", finHier)
                .getSingleResult();
        stats.put("trendUrgentsCritiques", calculerTrend(rdvUrgentsCritiques, urgentsHier));

        long consHier = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.medecin.idMedecin = :id AND c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                .setParameter("id", idMedecin).setParameter("d", debutHier).setParameter("f", finHier)
                .getSingleResult();
        stats.put("trendConsultationsEnCours", calculerTrend(consultationsEnCours, consHier));

        return stats;
    }

    private List<String[]> chartActiviteMensuelleMedecin(Long idMedecin) {
        List<String[]> result = new ArrayList<>();
        for (int i = 5; i >= 0; i--) {
            YearMonth ym = YearMonth.now().minusMonths(i);
            LocalDateTime debut = ym.atDay(1).atStartOfDay();
            LocalDateTime fin = ym.plusMonths(1).atDay(1).atStartOfDay();
            long nb = em.createQuery(
                    "SELECT COUNT(c) FROM Consultation c WHERE c.medecin.idMedecin = :id AND c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                    .setParameter("id", idMedecin)
                    .setParameter("d", debut).setParameter("f", fin)
                    .getSingleResult();
            result.add(new String[]{ym.getMonth().toString().substring(0, 3), String.valueOf(nb)});
        }
        return result;
    }

    private List<String[]> chartRdvParSemaine(Long idMedecin) {
        List<String[]> result = new ArrayList<>();
        String[] jours = {"Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"};
        LocalDate debutSemaine = LocalDate.now().with(java.time.DayOfWeek.MONDAY);
        for (int i = 0; i < 7; i++) {
            LocalDate jour = debutSemaine.plusDays(i);
            LocalDateTime debut = jour.atStartOfDay();
            LocalDateTime fin = jour.plusDays(1).atStartOfDay();
            long nb = em.createQuery(
                            "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :id AND r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                    .setParameter("id", idMedecin)
                    .setParameter("d", debut).setParameter("f", fin)
                    .getSingleResult();
            result.add(new String[]{jours[i], String.valueOf(nb)});
        }
        return result;
    }

    private List<String[]> chartRdvParPriorite(Long idMedecin) {
        List<String[]> result = new ArrayList<>();
        String[] priorites = {"CRITIQUE", "URGENT", "NORMAL"};
        for (String p : priorites) {
            long nb = em.createQuery(
                            "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :id AND r.priorite = :p", Long.class)
                    .setParameter("id", idMedecin)
                    .setParameter("p", com.burundihealthconnect.entity.enums.Priorite.valueOf(p))
                    .getSingleResult();
            if (nb > 0) {
                result.add(new String[]{p, String.valueOf(nb)});
            }
        }
        return result;
    }

    private List<String[]> chartRdvParStatutForMedecin(Long idMedecin) {
        List<String[]> result = new ArrayList<>();
        for (StatutRdv s : StatutRdv.values()) {
            long nb = em.createQuery(
                    "SELECT COUNT(r) FROM RendezVous r WHERE r.medecin.idMedecin = :id AND r.statut = :s", Long.class)
                    .setParameter("id", idMedecin)
                    .setParameter("s", s)
                    .getSingleResult();
            if (nb > 0) {
                result.add(new String[]{s.name(), String.valueOf(nb)});
            }
        }
        return result;
    }

    /** ADMIN : médecins actifs de son hôpital, consultations versées ce mois-ci. */
    private Map<String, Object> statistiquesAdmin(Long idEtablissement) {
        Map<String, Object> stats = new HashMap<>();

        long medecinsActifs = em.createQuery(
                        "SELECT COUNT(m) FROM Medecin m " +
                                "WHERE m.utilisateur.etablissement.idEtablissement = :idEtab " +
                                "AND m.utilisateur.actif = true",
                        Long.class)
                .setParameter("idEtab", idEtablissement)
                .getSingleResult();
        stats.put("medecinsActifs", medecinsActifs);

        YearMonth moisCourant = YearMonth.now();
        LocalDateTime debutMois = moisCourant.atDay(1).atStartOfDay();
        LocalDateTime finMois = moisCourant.plusMonths(1).atDay(1).atStartOfDay();

        long consultationsCeMois = em.createQuery(
                        "SELECT COUNT(c) FROM Consultation c " +
                                "WHERE c.etablissement.idEtablissement = :idEtab " +
                                "AND c.dateConsultation >= :debut AND c.dateConsultation < :fin",
                        Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        stats.put("consultationsCeMois", consultationsCeMois);

        stats.put("chartConsultations7jours", chartConsultations7jours(idEtablissement));
        stats.put("chartConsultations30jours", chartConsultations30jours(idEtablissement));
        stats.put("chartRdvStatus", chartRdvStatusAdmin(idEtablissement));

        // Enhanced admin stats
        LocalDateTime debutJour = LocalDate.now().atStartOfDay();
        LocalDateTime finJour = LocalDate.now().plusDays(1).atStartOfDay();

        long rdvAujourdhui = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :idEtab AND r.dateRendez >= :debut AND r.dateRendez < :fin", Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("debut", debutJour)
                .setParameter("fin", finJour)
                .getSingleResult();
        stats.put("rdvAujourdhui", rdvAujourdhui);

        long rdvEnAttente = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :idEtab AND r.statut = :demande", Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("demande", StatutRdv.RDV_DEMANDE)
                .getSingleResult();
        stats.put("rdvEnAttente", rdvEnAttente);

        long totalRdv = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :idEtab", Long.class)
                .setParameter("idEtab", idEtablissement)
                .getSingleResult();
        long rdvConfirmes = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :idEtab AND r.statut = :confirme", Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("confirme", StatutRdv.RDV_CONFIRME)
                .getSingleResult();
        long rdvAnnules = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :idEtab AND r.statut = :annule", Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("annule", StatutRdv.RDV_ANNULE)
                .getSingleResult();

        stats.put("tauxConfirmation", totalRdv > 0 ? (rdvConfirmes * 100 / totalRdv) : 0);
        stats.put("tauxAnnulation", totalRdv > 0 ? (rdvAnnules * 100 / totalRdv) : 0);

        long servicesActifs = em.createQuery(
                "SELECT COUNT(s) FROM Service s WHERE s.etablissement.idEtablissement = :idEtab AND s.actif = true", Long.class)
                .setParameter("idEtab", idEtablissement)
                .getSingleResult();
        stats.put("servicesActifs", servicesActifs);

        long medecinsIndisponibles = em.createQuery(
                "SELECT COUNT(DISTINCT c.medecin.idMedecin) FROM CongeMedecin c WHERE c.etablissement.idEtablissement = :idEtab AND c.dateDebut <= :today AND c.dateFin >= :today AND c.statut = :approuve", Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("today", LocalDate.now())
                .setParameter("approuve", com.burundihealthconnect.entity.enums.StatutConge.APPROUVE)
                .getSingleResult();
        stats.put("medecinsIndisponibles", medecinsIndisponibles);

        long consultationsVersees = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.etablissement.idEtablissement = :idEtab AND c.statut = :versee", Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("versee", com.burundihealthconnect.entity.enums.StatutConsultation.VERSEE_AU_DOSSIER)
                .getSingleResult();
        stats.put("consultationsVersees", consultationsVersees);
        stats.put("tauxConsultationsVersees", consultationsCeMois > 0 ? (consultationsVersees * 100 / consultationsCeMois) : 0);

        // Priority counts for badge display
        List<String[]> priorites = chartPrioritesRdv(idEtablissement);
        long normalCount = 0, urgentCount = 0, critiqueCount = 0;
        for (String[] p : priorites) {
            switch (p[0]) {
                case "NORMAL": normalCount = Long.parseLong(p[1]); break;
                case "URGENT": urgentCount = Long.parseLong(p[1]); break;
                case "CRITIQUE": critiqueCount = Long.parseLong(p[1]); break;
            }
        }
        stats.put("normalCount", normalCount);
        stats.put("urgentCount", urgentCount);
        stats.put("critiqueCount", critiqueCount);

        stats.put("chartTop5Services", chartTop5Services(idEtablissement));
        stats.put("chartTop5ServicesMois", chartTop5ServicesPeriode(idEtablissement, debutMois, finMois));
        int trimestre = ((moisCourant.getMonthValue() - 1) / 3) * 3 + 1;
        LocalDateTime debutTrimestre = YearMonth.of(moisCourant.getYear(), trimestre).atDay(1).atStartOfDay();
        stats.put("chartTop5ServicesTrimestre", chartTop5ServicesPeriode(idEtablissement, debutTrimestre, finMois));
        stats.put("chartChargeParMedecin", chartChargeParMedecin(idEtablissement));
        stats.put("chartPrioritesRdv", priorites);

        // Congés en attente (badge actions rapides + alerte)
        long congesEnAttente = em.createQuery(
                "SELECT COUNT(c) FROM CongeMedecin c " +
                        "WHERE c.etablissement.idEtablissement = :idEtab AND c.statut = :attente", Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("attente", com.burundihealthconnect.entity.enums.StatutConge.EN_ATTENTE)
                .getSingleResult();
        stats.put("congesEnAttente", congesEnAttente);

        // RDV sensibles (URGENT / CRITIQUE) encore en demande
        long rdvCritiquesUrgents = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r " +
                        "WHERE r.etablissement.idEtablissement = :idEtab " +
                        "AND r.statut = :demande AND (r.priorite = :urgent OR r.priorite = :critique)", Long.class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("demande", StatutRdv.RDV_DEMANDE)
                .setParameter("urgent", com.burundihealthconnect.entity.enums.Priorite.URGENT)
                .setParameter("critique", com.burundihealthconnect.entity.enums.Priorite.CRITIQUE)
                .getSingleResult();
        stats.put("rdvCritiquesUrgents", rdvCritiquesUrgents);

        // Charge détaillée par médecin (nom, spécialité, RDV du mois, id) + max pour échelle
        List<String[]> chargeMedecins = chartChargeParMedecinDetail(idEtablissement);
        long maxChargeMedecin = 0;
        for (String[] m : chargeMedecins) {
            long nb = Long.parseLong(m[2]);
            if (nb > maxChargeMedecin) {
                maxChargeMedecin = nb;
            }
        }
        stats.put("chargeMedecins", chargeMedecins);
        stats.put("maxChargeMedecin", maxChargeMedecin);

        // Trends KPI (vs jour précédent / vs mois précédent)
        LocalDateTime debutHier = LocalDate.now().minusDays(1).atStartOfDay();
        LocalDateTime finHier = LocalDate.now().atStartOfDay();

        long rdvHier = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :id AND r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                .setParameter("id", idEtablissement).setParameter("d", debutHier).setParameter("f", finHier)
                .getSingleResult();
        stats.put("trendRdvAujourdhui", calculerTrend(rdvAujourdhui, rdvHier));

        long attenteHier = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :id AND r.statut = :s AND r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                .setParameter("id", idEtablissement).setParameter("s", StatutRdv.RDV_DEMANDE).setParameter("d", debutHier).setParameter("f", finHier)
                .getSingleResult();
        stats.put("trendRdvEnAttente", calculerTrend(rdvEnAttente, attenteHier));

        YearMonth moisPrecedent = YearMonth.now().minusMonths(1);
        LocalDateTime debutMoisPrec = moisPrecedent.atDay(1).atStartOfDay();
        LocalDateTime finMoisPrec = moisPrecedent.plusMonths(1).atDay(1).atStartOfDay();

        long consMoisPrec = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.etablissement.idEtablissement = :id AND c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                .setParameter("id", idEtablissement).setParameter("d", debutMoisPrec).setParameter("f", finMoisPrec)
                .getSingleResult();
        stats.put("trendConsultationsCeMois", calculerTrend(consultationsCeMois, consMoisPrec));

        return stats;
    }

    private List<String[]> chartTop5Services(Long idEtablissement) {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                "SELECT s.nom, COUNT(r) FROM RendezVous r JOIN r.service s WHERE s.etablissement.idEtablissement = :idEtab GROUP BY s.nom ORDER BY COUNT(r) DESC", Object[].class)
                .setParameter("idEtab", idEtablissement)
                .setMaxResults(5)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{(String) row[0], String.valueOf(row[1])});
        }
        return result;
    }

    private List<String[]> chartChargeParMedecin(Long idEtablissement) {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                "SELECT m.utilisateur.fullName, COUNT(r) FROM RendezVous r JOIN r.medecin m WHERE m.utilisateur.etablissement.idEtablissement = :idEtab GROUP BY m.utilisateur.fullName ORDER BY COUNT(r) DESC", Object[].class)
                .setParameter("idEtab", idEtablissement)
                .setMaxResults(10)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{(String) row[0], String.valueOf(row[1])});
        }
        return result;
    }

    private List<String[]> chartPrioritesRdv(Long idEtablissement) {
        List<String[]> result = new ArrayList<>();
        for (com.burundihealthconnect.entity.enums.Priorite p : com.burundihealthconnect.entity.enums.Priorite.values()) {
            long nb = em.createQuery(
                    "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :idEtab AND r.priorite = :p", Long.class)
                    .setParameter("idEtab", idEtablissement)
                    .setParameter("p", p)
                    .getSingleResult();
            if (nb > 0) {
                result.add(new String[]{p.name(), String.valueOf(nb)});
            }
        }
        return result;
    }

    private List<String[]> chartConsultations7jours(Long idEtablissement) {
        List<String[]> result = new ArrayList<>();
        String[] jours = {"Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"};
        LocalDate debutSemaine = LocalDate.now().with(java.time.DayOfWeek.MONDAY);
        for (int i = 0; i < 7; i++) {
            LocalDate jour = debutSemaine.plusDays(i);
            LocalDateTime debut = jour.atStartOfDay();
            LocalDateTime fin = jour.plusDays(1).atStartOfDay();
            long nb = em.createQuery(
                            "SELECT COUNT(c) FROM Consultation c WHERE c.etablissement.idEtablissement = :id AND c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                    .setParameter("id", idEtablissement)
                    .setParameter("d", debut).setParameter("f", fin)
                    .getSingleResult();
            result.add(new String[]{jours[i], String.valueOf(nb)});
        }
        return result;
    }

    private List<String[]> chartRdvStatusAdmin(Long idEtablissement) {
        List<String[]> result = new ArrayList<>();
        for (StatutRdv s : StatutRdv.values()) {
            long nb = em.createQuery(
                            "SELECT COUNT(r) FROM RendezVous r WHERE r.etablissement.idEtablissement = :id AND r.statut = :s", Long.class)
                    .setParameter("id", idEtablissement)
                    .setParameter("s", s)
                    .getSingleResult();
            if (nb > 0) {
                result.add(new String[]{s.name(), String.valueOf(nb)});
            }
        }
        return result;
    }

    private List<String[]> chartConsultations30jours(Long idEtablissement) {
        List<String[]> result = new ArrayList<>();
        LocalDate debut = LocalDate.now().minusDays(29);
        for (int i = 0; i < 30; i++) {
            LocalDate jour = debut.plusDays(i);
            LocalDateTime d = jour.atStartOfDay();
            LocalDateTime f = jour.plusDays(1).atStartOfDay();
            long nb = em.createQuery(
                            "SELECT COUNT(c) FROM Consultation c WHERE c.etablissement.idEtablissement = :id AND c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                    .setParameter("id", idEtablissement)
                    .setParameter("d", d).setParameter("f", f)
                    .getSingleResult();
            result.add(new String[]{String.valueOf(jour.getDayOfMonth()), String.valueOf(nb)});
        }
        return result;
    }

    private List<String[]> chartTop5ServicesPeriode(Long idEtablissement, LocalDateTime debut, LocalDateTime fin) {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                "SELECT s.nom, COUNT(r) FROM RendezVous r JOIN r.service s " +
                        "WHERE s.etablissement.idEtablissement = :idEtab " +
                        "AND r.dateRendez >= :debut AND r.dateRendez < :fin " +
                        "GROUP BY s.nom ORDER BY COUNT(r) DESC", Object[].class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("debut", debut)
                .setParameter("fin", fin)
                .setMaxResults(5)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{(String) row[0], String.valueOf(row[1])});
        }
        return result;
    }

    private List<String[]> chartChargeParMedecinDetail(Long idEtablissement) {
        List<String[]> result = new ArrayList<>();
        YearMonth moisCourant = YearMonth.now();
        LocalDateTime debutMois = moisCourant.atDay(1).atStartOfDay();
        LocalDateTime finMois = moisCourant.plusMonths(1).atDay(1).atStartOfDay();

        Map<Long, Long> counts = new HashMap<>();
        List<Object[]> rows = em.createQuery(
                "SELECT r.medecin.idMedecin, COUNT(r) FROM RendezVous r " +
                        "WHERE r.etablissement.idEtablissement = :idEtab " +
                        "AND r.dateRendez >= :debut AND r.dateRendez < :fin " +
                        "GROUP BY r.medecin.idMedecin", Object[].class)
                .setParameter("idEtab", idEtablissement)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getResultList();
        for (Object[] row : rows) {
            counts.put(((Number) row[0]).longValue(), ((Number) row[1]).longValue());
        }

        List<Object[]> medecins = em.createQuery(
                "SELECT m.idMedecin, m.utilisateur.fullName, m.specialite FROM Medecin m " +
                        "WHERE m.utilisateur.etablissement.idEtablissement = :idEtab AND m.utilisateur.actif = true " +
                        "ORDER BY m.utilisateur.fullName ASC", Object[].class)
                .setParameter("idEtab", idEtablissement)
                .getResultList();
        for (Object[] m : medecins) {
            Long idM = ((Number) m[0]).longValue();
            long count = counts.getOrDefault(idM, 0L);
            String spec = m[2] != null ? (String) m[2] : "";
            result.add(new String[]{ (String) m[1], spec, String.valueOf(count), String.valueOf(idM) });
        }
        return result;
    }

    /** SUPER_ADMIN : hôpitaux actifs du réseau, total patients réseau. */
    private Map<String, Object> statistiquesSuperAdmin() {
        Map<String, Object> stats = new HashMap<>();

        long hopitauxActifs = em.createQuery(
                        "SELECT COUNT(e) FROM EtablissementSante e WHERE e.actif = true", Long.class)
                .getSingleResult();
        stats.put("hopitauxActifs", hopitauxActifs);

        long patientsReseau = em.createQuery("SELECT COUNT(p) FROM Patient p", Long.class)
                .getSingleResult();
        stats.put("patientsReseau", patientsReseau);

        long totalHopitaux = em.createQuery("SELECT COUNT(e) FROM EtablissementSante e", Long.class)
                .getSingleResult();

        long medecinsActifs = em.createQuery(
                "SELECT COUNT(m) FROM Medecin m WHERE m.utilisateur.actif = true", Long.class)
                .getSingleResult();
        stats.put("medecinsActifs", medecinsActifs);

        long totalMedecins = em.createQuery("SELECT COUNT(m) FROM Medecin m", Long.class)
                .getSingleResult();

        long adminsActifs = em.createQuery(
                "SELECT COUNT(u) FROM Utilisateur u WHERE u.role = :role AND u.actif = true", Long.class)
                .setParameter("role", Role.ADMIN)
                .getSingleResult();
        stats.put("adminsActifs", adminsActifs);

        long totalAdmins = em.createQuery(
                "SELECT COUNT(u) FROM Utilisateur u WHERE u.role = :role", Long.class)
                .setParameter("role", Role.ADMIN)
                .getSingleResult();

        YearMonth moisCourant = YearMonth.now();
        LocalDateTime debutMois = moisCourant.atDay(1).atStartOfDay();
        LocalDateTime finMois = moisCourant.plusMonths(1).atDay(1).atStartOfDay();

        long consultationsCeMois = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.dateConsultation >= :debut AND c.dateConsultation < :fin", Long.class)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        stats.put("consultationsCeMois", consultationsCeMois);

        long accesDossiersMois = em.createQuery(
                "SELECT COUNT(a) FROM AccesDossier a WHERE a.dateAcces >= :debut AND a.dateAcces < :fin", Long.class)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        stats.put("accesDossiersMois", accesDossiersMois);

        long rdvReseauMois = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.dateRendez >= :debut AND r.dateRendez < :fin", Long.class)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        stats.put("rdvReseauMois", rdvReseauMois);

        long dossiersCentralises = em.createQuery("SELECT COUNT(d) FROM DossierMedical d", Long.class)
                .getSingleResult();
        stats.put("dossiersCentralises", dossiersCentralises);

        long modifsDossiersMois = em.createQuery(
                "SELECT COUNT(h) FROM HistoriqueModification h WHERE h.dateModification >= :debut AND h.dateModification < :fin", Long.class)
                .setParameter("debut", debutMois)
                .setParameter("fin", finMois)
                .getSingleResult();
        stats.put("modifsDossiersMois", modifsDossiersMois);

        long referenementsInterHopitaux = em.createQuery(
                "SELECT COUNT(r) FROM Referenement r WHERE r.dateRef >= :debut AND r.dateRef < :fin", Long.class)
                .setParameter("debut", moisCourant.atDay(1))
                .setParameter("fin", moisCourant.plusMonths(1).atDay(1))
                .getSingleResult();
        stats.put("referenementsInterHopitaux", referenementsInterHopitaux);

        // Charts
        stats.put("chartConsultations30Jours", chartConsultations30Jours());
        stats.put("chartTopHopitauxActifs", chartTopHopitauxActifs());
        stats.put("chartRdvStatutReseau", chartRdvStatutReseau());
        stats.put("chartAccesParHopital", chartAccesParHopital());
        stats.put("chartPatientsParHopital", chartPatientsParHopital());
        stats.put("chartRepartitionRoles", chartRepartitionRoles());

        // Taux
        stats.put("tauxHopitauxActifs", totalHopitaux > 0 ? (hopitauxActifs * 100 / totalHopitaux) : 0);
        stats.put("tauxAdminsActifs", totalAdmins > 0 ? (adminsActifs * 100 / totalAdmins) : 0);
        stats.put("tauxMedecinsActifs", totalMedecins > 0 ? (medecinsActifs * 100 / totalMedecins) : 0);

        long consultationsVersees = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.statut = :versee", Long.class)
                .setParameter("versee", com.burundihealthconnect.entity.enums.StatutConsultation.VERSEE_AU_DOSSIER)
                .getSingleResult();
        stats.put("tauxConsultationsVersees", consultationsCeMois > 0 ? (consultationsVersees * 100 / consultationsCeMois) : 0);

        long dossiersAvecConsultation = em.createQuery(
                "SELECT COUNT(DISTINCT c.dossier.idDossier) FROM Consultation c", Long.class)
                .getSingleResult();
        long totalDossiers = em.createQuery("SELECT COUNT(d) FROM DossierMedical d", Long.class)
                .getSingleResult();
        stats.put("tauxDossiersAvecConsultation", totalDossiers > 0 ? (dossiersAvecConsultation * 100 / totalDossiers) : 0);

        // Hopitaux sans ADMIN actif
        List<String> hopitauxSansAdmin = em.createQuery(
                "SELECT e.nom FROM EtablissementSante e WHERE e.idEtablissement NOT IN (" +
                        "SELECT DISTINCT u.etablissement.idEtablissement FROM Utilisateur u WHERE u.role = :role AND u.actif = true" +
                        ") ORDER BY e.nom", String.class)
                .setParameter("role", Role.ADMIN)
                .getResultList();
        stats.put("hopitauxSansAdmin", hopitauxSansAdmin);

        long comptesDesactives = em.createQuery(
                "SELECT COUNT(u) FROM Utilisateur u WHERE u.actif = false", Long.class)
                .getSingleResult();
        stats.put("comptesDesactives", comptesDesactives);

        long servicesInactifs = em.createQuery(
                "SELECT COUNT(s) FROM Service s WHERE s.actif = false", Long.class)
                .getSingleResult();
        stats.put("servicesInactifs", servicesInactifs);

        // Trends KPI (vs mois précédent)
        YearMonth moisPrecedent = YearMonth.now().minusMonths(1);
        LocalDateTime debutMoisPrec = moisPrecedent.atDay(1).atStartOfDay();
        LocalDateTime finMoisPrec = moisPrecedent.plusMonths(1).atDay(1).atStartOfDay();

        long consMoisPrec = em.createQuery(
                "SELECT COUNT(c) FROM Consultation c WHERE c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                .setParameter("d", debutMoisPrec).setParameter("f", finMoisPrec)
                .getSingleResult();
        stats.put("trendConsultationsCeMois", calculerTrend(consultationsCeMois, consMoisPrec));

        long rdvMoisPrec = em.createQuery(
                "SELECT COUNT(r) FROM RendezVous r WHERE r.dateRendez >= :d AND r.dateRendez < :f", Long.class)
                .setParameter("d", debutMoisPrec).setParameter("f", finMoisPrec)
                .getSingleResult();
        stats.put("trendRdvReseauMois", calculerTrend(rdvReseauMois, rdvMoisPrec));

        long accesMoisPrec = em.createQuery(
                "SELECT COUNT(a) FROM AccesDossier a WHERE a.dateAcces >= :d AND a.dateAcces < :f", Long.class)
                .setParameter("d", debutMoisPrec).setParameter("f", finMoisPrec)
                .getSingleResult();
        stats.put("trendAccesDossiersMois", calculerTrend(accesDossiersMois, accesMoisPrec));

        return stats;
    }

    private List<String[]> chartConsultations30Jours() {
        List<String[]> result = new ArrayList<>();
        for (int i = 29; i >= 0; i--) {
            LocalDate jour = LocalDate.now().minusDays(i);
            LocalDateTime debut = jour.atStartOfDay();
            LocalDateTime fin = jour.plusDays(1).atStartOfDay();
            long nb = em.createQuery(
                    "SELECT COUNT(c) FROM Consultation c WHERE c.dateConsultation >= :d AND c.dateConsultation < :f", Long.class)
                    .setParameter("d", debut).setParameter("f", fin)
                    .getSingleResult();
            result.add(new String[]{String.valueOf(jour.getDayOfMonth()), String.valueOf(nb)});
        }
        return result;
    }

    private List<String[]> chartTopHopitauxActifs() {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                "SELECT e.nom, COUNT(c) FROM Consultation c JOIN c.etablissement e GROUP BY e.nom ORDER BY COUNT(c) DESC", Object[].class)
                .setMaxResults(5)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{(String) row[0], String.valueOf(row[1])});
        }
        return result;
    }

    private List<String[]> chartRdvStatutReseau() {
        List<String[]> result = new ArrayList<>();
        for (StatutRdv s : StatutRdv.values()) {
            long nb = em.createQuery(
                    "SELECT COUNT(r) FROM RendezVous r WHERE r.statut = :s", Long.class)
                    .setParameter("s", s)
                    .getSingleResult();
            if (nb > 0) {
                result.add(new String[]{s.name(), String.valueOf(nb)});
            }
        }
        return result;
    }

    private List<String[]> chartAccesParHopital() {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                "SELECT e.nom, COUNT(a) FROM AccesDossier a JOIN a.etablissement e GROUP BY e.nom ORDER BY COUNT(a) DESC", Object[].class)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{(String) row[0], String.valueOf(row[1])});
        }
        return result;
    }

    private List<String[]> chartPatientsParHopital() {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                        "SELECT e.nom, COUNT(p) FROM Patient p JOIN p.utilisateur u JOIN u.etablissement e GROUP BY e.nom ORDER BY e.nom", Object[].class)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{(String) row[0], String.valueOf(row[1])});
        }
        return result;
    }

    private List<String[]> chartRepartitionRoles() {
        List<String[]> result = new ArrayList<>();
        List<Object[]> rows = em.createQuery(
                        "SELECT u.role, COUNT(u) FROM Utilisateur u GROUP BY u.role ORDER BY u.role", Object[].class)
                .getResultList();
        for (Object[] row : rows) {
            result.add(new String[]{((Enum) row[0]).name(), String.valueOf(row[1])});
        }
        return result;
    }

    /** Variation en % entre deux compteurs (pour les trends KPI "vs hier / vs mois"). */
    private long calculerTrend(long actuel, long precedent) {
        if (precedent == 0) {
            return actuel == 0 ? 0 : 100;
        }
        return Math.round((actuel - precedent) * 100.0 / precedent);
    }

    /** Charge un établissement par id, lève EntiteIntrouvableException si absent. */
    public EtablissementSante getById(Long idEtablissement) {
        EtablissementSante etab = em.find(EtablissementSante.class, idEtablissement);
        if (etab == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
        }
        return etab;
    }
}