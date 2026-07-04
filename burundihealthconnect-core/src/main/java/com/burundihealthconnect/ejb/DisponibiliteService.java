package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.CreneauDisponible;
import com.burundihealthconnect.entity.DisponibiliteSemaine;
import com.burundihealthconnect.entity.EtablissementSante;
import com.burundihealthconnect.entity.JourTravail;
import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.exception.AccesInterditException;
import com.burundihealthconnect.exception.BusinessException;
import com.burundihealthconnect.exception.CreneauDejaReserveException;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

/**
 * DisponibiliteService — Session Bean Stateless.
 * Logiques couvertes :
 *   L14 — Déclaration de disponibilités par semaine + prise de RDV sur
 *         créneaux libres, réservation ATOMIQUE
 *   L19 — Blocage automatique des créneaux pendant un congé approuvé
 */
@Stateless
public class DisponibiliteService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    private static final int TAILLE_PAGE = 10;

    // =========================================================
    // DECLARATION DE SEMAINE — L14
    // =========================================================

    /**
     * Déclare une semaine de disponibilité et génère immédiatement tous
     * les créneaux découpés selon dureeCreneauMin, pour chaque jour
     * présent dans plagesHoraires avec sa propre plage (heureDebut / heureFin).
     * Persiste également les JourTravail correspondants.
     *
     * @param plagesHoraires map jour -> [heureDebut, heureFin]
     */
    public DisponibiliteSemaine declarerSemaine(Long idMedecin, Long idEtablissement,
                                                 LocalDate dateDebutSemaine, int dureeCreneauMin,
                                                 Map<DayOfWeek, LocalTime[]> plagesHoraires) {
        Medecin medecin = em.find(Medecin.class, idMedecin);
        if (medecin == null) {
            throw new EntiteIntrouvableException("Medecin", idMedecin);
        }
        EtablissementSante etablissement = em.find(EtablissementSante.class, idEtablissement);
        if (etablissement == null) {
            throw new EntiteIntrouvableException("EtablissementSante", idEtablissement);
        }

        verifierNonChevauchement(idMedecin, dateDebutSemaine);

        DisponibiliteSemaine semaine = new DisponibiliteSemaine();
        semaine.setMedecin(medecin);
        semaine.setEtablissement(etablissement);
        semaine.setDateDebutSemaine(dateDebutSemaine);
        semaine.setDateFinSemaine(dateDebutSemaine.plusDays(6));
        semaine.setDureeCreneauMin(dureeCreneauMin);
        em.persist(semaine);
        em.flush();

        genererCreneaux(semaine, plagesHoraires);

        return semaine;
    }

    /** Génère les créneaux de la semaine, jour par jour, avec les plages horaires personnalisées. */
    private void genererCreneaux(DisponibiliteSemaine semaine,
                                  Map<DayOfWeek, LocalTime[]> plagesHoraires) {
        for (int jour = 0; jour < 7; jour++) {
            LocalDate dateJour = semaine.getDateDebutSemaine().plusDays(jour);
            DayOfWeek dayOfWeek = dateJour.getDayOfWeek();
            LocalTime[] plage = plagesHoraires.get(dayOfWeek);
            if (plage == null) {
                continue;
            }

            LocalTime heureDebut = plage[0];
            LocalTime heureFin = plage[1];
            if (heureDebut == null || heureFin == null || !heureDebut.isBefore(heureFin)) {
                continue;
            }

            // Persist JourTravail
            JourTravail jt = new JourTravail();
            jt.setDisponibilite(semaine);
            jt.setJourSemaine(dayOfWeek);
            jt.setHeureDebut(heureDebut);
            jt.setHeureFin(heureFin);
            em.persist(jt);

            // Generate slots
            LocalTime curseur = heureDebut;
            while (curseur.isBefore(heureFin)) {
                LocalTime fin = curseur.plusMinutes(semaine.getDureeCreneauMin());
                if (fin.isAfter(heureFin)) {
                    break;
                }

                CreneauDisponible creneau = new CreneauDisponible();
                creneau.setDisponibilite(semaine);
                creneau.setMedecin(semaine.getMedecin());
                creneau.setEtablissement(semaine.getEtablissement());
                creneau.setDateCreneau(dateJour);
                creneau.setHeureDebut(curseur);
                creneau.setHeureFin(fin);
                creneau.setDisponible(true);
                em.persist(creneau);

                curseur = fin;
            }
        }
    }

    /** L14 — Liste les créneaux libres (disponible=true) d'un médecin sur une période donnée. */
    public List<CreneauDisponible> getCreneauxLibres(Long idMedecin, LocalDate dateDebut, LocalDate dateFin) {
        TypedQuery<CreneauDisponible> q = em.createQuery(
                "SELECT c FROM CreneauDisponible c " +
                        "WHERE c.medecin.idMedecin = :idMedecin " +
                        "AND c.disponible = true " +
                        "AND c.dateCreneau >= :debut AND c.dateCreneau <= :fin " +
                        "ORDER BY c.dateCreneau ASC, c.heureDebut ASC",
                CreneauDisponible.class);
        q.setParameter("idMedecin", idMedecin);
        q.setParameter("debut", dateDebut);
        q.setParameter("fin", dateFin);
        return q.getResultList();
    }

    /**
     * L14 — Réservation ATOMIQUE d'un créneau. Utilise un verrou pessimiste
     * (PESSIMISTIC_WRITE) sur la ligne pour empêcher deux transactions
     * concurrentes de réserver le même créneau simultanément.
     *
     * @throws CreneauDejaReserveException si le créneau n'est plus disponible
     */
    public CreneauDisponible reserverCreneau(Long idCreneau) {
        CreneauDisponible creneau = em.find(CreneauDisponible.class, idCreneau, LockModeType.PESSIMISTIC_WRITE);
        if (creneau == null) {
            throw new EntiteIntrouvableException("CreneauDisponible", idCreneau);
        }
        if (!Boolean.TRUE.equals(creneau.getDisponible())) {
            throw new CreneauDejaReserveException(idCreneau);
        }
        creneau.setDisponible(false);
        em.merge(creneau);
        return creneau;
    }

    /** L14/L21 — Libère un créneau (suite à un refus médecin ou une annulation patient). */
    public void libererCreneau(Long idCreneau) {
        CreneauDisponible creneau = em.find(CreneauDisponible.class, idCreneau);
        if (creneau == null) {
            throw new EntiteIntrouvableException("CreneauDisponible", idCreneau);
        }
        creneau.setDisponible(true);
        em.merge(creneau);
    }

    /** Liste toutes les semaines de disponibilité déclarées par un médecin (les plus récentes en premier). */
    public List<DisponibiliteSemaine> getMesSemaines(Long idMedecin, int page) {
        return em.createQuery(
                        "SELECT s FROM DisponibiliteSemaine s " +
                                "WHERE s.medecin.idMedecin = :idMedecin " +
                                "ORDER BY s.dateDebutSemaine DESC",
                        DisponibiliteSemaine.class)
                .setParameter("idMedecin", idMedecin)
                .setFirstResult(page * TAILLE_PAGE)
                .setMaxResults(TAILLE_PAGE)
                .getResultList();
    }

    /**
     * Supprime un créneau, uniquement s'il est encore libre (jamais un
     * créneau déjà réservé par un RDV — protège l'intégrité des données).
     */
    public void supprimerCreneau(Long idCreneau, Long idMedecin) {
        CreneauDisponible creneau = em.find(CreneauDisponible.class, idCreneau);
        if (creneau == null) {
            throw new EntiteIntrouvableException("CreneauDisponible", idCreneau);
        }
        if (!creneau.getMedecin().getIdMedecin().equals(idMedecin)) {
            throw new AccesInterditException("Ce créneau n'appartient pas à ce médecin.");
        }
        if (!Boolean.TRUE.equals(creneau.getDisponible())) {
            throw new AccesInterditException("Impossible de supprimer un créneau déjà réservé.");
        }
        em.remove(creneau);
    }

    /**
     * Copie le motif d'une semaine existante vers la semaine suivante
     * (mêmes horaires, mêmes jours travaillés, décalés de +7 jours).
     */
    public DisponibiliteSemaine copierSemaineSuivante(Long idDisponibilite) {
        DisponibiliteSemaine semaineOriginale = em.find(DisponibiliteSemaine.class, idDisponibilite);
        if (semaineOriginale == null) {
            throw new EntiteIntrouvableException("DisponibiliteSemaine", idDisponibilite);
        }

        List<JourTravail> joursOriginaux = em.createQuery(
                        "SELECT j FROM JourTravail j WHERE j.disponibilite.idDisponibilite = :id",
                        JourTravail.class)
                .setParameter("id", idDisponibilite)
                .getResultList();

        List<CreneauDisponible> creneauxOriginaux = em.createQuery(
                        "SELECT c FROM CreneauDisponible c WHERE c.disponibilite.idDisponibilite = :id",
                        CreneauDisponible.class)
                .setParameter("id", idDisponibilite)
                .getResultList();

        DisponibiliteSemaine nouvelleSemaine = new DisponibiliteSemaine();
        nouvelleSemaine.setMedecin(semaineOriginale.getMedecin());
        nouvelleSemaine.setEtablissement(semaineOriginale.getEtablissement());
        nouvelleSemaine.setDateDebutSemaine(semaineOriginale.getDateDebutSemaine().plusDays(7));
        nouvelleSemaine.setDateFinSemaine(semaineOriginale.getDateFinSemaine().plusDays(7));
        nouvelleSemaine.setDureeCreneauMin(semaineOriginale.getDureeCreneauMin());
        em.persist(nouvelleSemaine);
        em.flush();

        for (JourTravail original : joursOriginaux) {
            JourTravail copie = new JourTravail();
            copie.setDisponibilite(nouvelleSemaine);
            copie.setJourSemaine(original.getJourSemaine());
            copie.setHeureDebut(original.getHeureDebut());
            copie.setHeureFin(original.getHeureFin());
            em.persist(copie);
        }

        for (CreneauDisponible original : creneauxOriginaux) {
            CreneauDisponible copie = new CreneauDisponible();
            copie.setDisponibilite(nouvelleSemaine);
            copie.setMedecin(original.getMedecin());
            copie.setEtablissement(original.getEtablissement());
            copie.setDateCreneau(original.getDateCreneau().plusDays(7));
            copie.setHeureDebut(original.getHeureDebut());
            copie.setHeureFin(original.getHeureFin());
            copie.setDisponible(true);
            em.persist(copie);
        }

        return nouvelleSemaine;
    }

    // =========================================================
    // BLOCAGE POUR CONGE — L19
    // =========================================================

    /**
     * L19 — Appelée par CongeService.approuverConge() : bloque (disponible=false)
     * tous les créneaux LIBRES d'un médecin sur la période de congé.
     *
     * @return le nombre de créneaux bloqués
     */
    public int bloquerCreneauxConge(Long idMedecin, LocalDate dateDebut, LocalDate dateFin) {
        List<CreneauDisponible> creneauxLibres = em.createQuery(
                        "SELECT c FROM CreneauDisponible c " +
                                "WHERE c.medecin.idMedecin = :idMedecin " +
                                "AND c.disponible = true " +
                                "AND c.dateCreneau >= :debut AND c.dateCreneau <= :fin",
                        CreneauDisponible.class)
                .setParameter("idMedecin", idMedecin)
                .setParameter("debut", dateDebut)
                .setParameter("fin", dateFin)
                .getResultList();

        for (CreneauDisponible creneau : creneauxLibres) {
            creneau.setDisponible(false);
            em.merge(creneau);
        }
        return creneauxLibres.size();
    }

    private void verifierNonChevauchement(Long idMedecin, LocalDate dateDebutSemaine) {
        LocalDate dateFinSemaine = dateDebutSemaine.plusDays(6);
        List<DisponibiliteSemaine> existantes = em.createQuery(
                        "SELECT s FROM DisponibiliteSemaine s WHERE s.medecin.idMedecin = :idMed " +
                                "AND ((s.dateDebutSemaine <= :debut AND s.dateFinSemaine >= :debut) " +
                                "OR (s.dateDebutSemaine <= :fin AND s.dateFinSemaine >= :fin) " +
                                "OR (s.dateDebutSemaine >= :debut AND s.dateFinSemaine <= :fin))",
                        DisponibiliteSemaine.class)
                .setParameter("idMed", idMedecin)
                .setParameter("debut", dateDebutSemaine)
                .setParameter("fin", dateFinSemaine)
                .getResultList();
        if (!existantes.isEmpty()) {
            throw new BusinessException("Une disponibilité existe déjà pour cette période.");
        }
    }
}