package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.Notification;
import com.burundihealthconnect.entity.Utilisateur;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.util.List;

/**
 * NotificationService — Session Bean Stateless.
 * Logique couverte : L17 (notifications internes par rôle), utilisée
 * également par L19 (réponse à une demande de congé) et L21 (annulation
 * de RDV par le patient) pour avertir l'autre partie.
 *
 * Notifications INTERNES uniquement (badge dans le header) — aucun email,
 * aucune dépendance Jakarta Mail (technologie interdite par le sujet).
 */
@Stateless
public class NotificationService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    private static final int TAILLE_PAGE = 10;

    /** Crée une notification non lue pour un utilisateur donné. */
    public Notification creerNotification(Long idUtilisateur, String message, String typeNotif) {
        Utilisateur utilisateur = em.find(Utilisateur.class, idUtilisateur);
        if (utilisateur == null) {
            throw new EntiteIntrouvableException("Utilisateur", idUtilisateur);
        }

        Notification notification = new Notification();
        notification.setUtilisateur(utilisateur);
        notification.setMessage(message);
        notification.setTypeNotif(typeNotif);
        notification.setLue(false);
        em.persist(notification);
        return notification;
    }

    /** L17 — Liste les notifications non lues d'un utilisateur (les plus récentes en premier), pour le badge header. */
    public List<Notification> getNonLues(Long idUtilisateur) {
        TypedQuery<Notification> q = em.createQuery(
                "SELECT n FROM Notification n " +
                        "WHERE n.utilisateur.idUtilisateur = :id AND n.lue = false " +
                        "ORDER BY n.dateCreation DESC",
                Notification.class);
        q.setParameter("id", idUtilisateur);
        return q.getResultList();
    }

    /** Liste TOUTES les notifications d'un utilisateur (lues + non lues). */
    public List<Notification> getToutes(Long idUtilisateur, int page) {
        TypedQuery<Notification> q = em.createQuery(
                "SELECT n FROM Notification n " +
                        "WHERE n.utilisateur.idUtilisateur = :id " +
                        "ORDER BY n.dateCreation DESC",
                Notification.class);
        q.setParameter("id", idUtilisateur);
        q.setFirstResult(page * TAILLE_PAGE);
        q.setMaxResults(TAILLE_PAGE);
        return q.getResultList();
    }

    /** Liste les N notifications les plus récentes (lues + non lues) — dashboard patient. */
    public List<Notification> getRecentes(Long idUtilisateur, int max) {
        TypedQuery<Notification> q = em.createQuery(
                "SELECT n FROM Notification n " +
                        "WHERE n.utilisateur.idUtilisateur = :id " +
                        "ORDER BY n.dateCreation DESC",
                Notification.class);
        q.setParameter("id", idUtilisateur);
        q.setMaxResults(max);
        return q.getResultList();
    }

    /** Marque une notification comme lue. */
    public void marquerCommeLue(Long idNotif) {
        Notification notification = em.find(Notification.class, idNotif);
        if (notification == null) {
            throw new EntiteIntrouvableException("Notification", idNotif);
        }
        notification.setLue(true);
        em.merge(notification);
    }

    public long countToutes(Long idUtilisateur) {
        TypedQuery<Long> q = em.createQuery(
            "SELECT COUNT(n) FROM Notification n WHERE n.utilisateur.idUtilisateur = :id",
            Long.class);
        q.setParameter("id", idUtilisateur);
        return q.getSingleResult();
    }

    public long countNonLues(Long idUtilisateur) {
        TypedQuery<Long> q = em.createQuery(
            "SELECT COUNT(n) FROM Notification n WHERE n.utilisateur.idUtilisateur = :id AND n.lue = false",
            Long.class);
        q.setParameter("id", idUtilisateur);
        return q.getSingleResult();
    }

    /** Marque toutes les notifications d'un utilisateur comme lues. */
    public void marquerToutesCommeLues(Long idUtilisateur) {
        em.createQuery(
                        "UPDATE Notification n SET n.lue = true " +
                                "WHERE n.utilisateur.idUtilisateur = :id AND n.lue = false")
                .setParameter("id", idUtilisateur)
                .executeUpdate();
    }
}