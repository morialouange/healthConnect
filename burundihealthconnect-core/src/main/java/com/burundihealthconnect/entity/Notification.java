package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Notification interne (sans email) — affichée en badge dans le header (L17).
 * Générée notamment par L19 (réponse congé) et L21 (annulation RDV).
 */
@Entity
@Table(name = "notifications")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_notif")
    private Long idNotif;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_utilisateur", nullable = false)
    private Utilisateur utilisateur;

    @Column(name = "message", nullable = false, length = 500)
    private String message;

    @Column(name = "lue", nullable = false)
    private Boolean lue = false;

    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation;

    @Column(name = "type_notif", length = 50)
    private String typeNotif;

    public Notification() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateCreation == null) {
            dateCreation = LocalDateTime.now();
        }
        if (lue == null) {
            lue = false;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdNotif() {
        return idNotif;
    }

    public void setIdNotif(Long idNotif) {
        this.idNotif = idNotif;
    }

    public Utilisateur getUtilisateur() {
        return utilisateur;
    }

    public void setUtilisateur(Utilisateur utilisateur) {
        this.utilisateur = utilisateur;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Boolean getLue() {
        return lue;
    }

    public void setLue(Boolean lue) {
        this.lue = lue;
    }

    public LocalDateTime getDateCreation() {
        return dateCreation;
    }

    public void setDateCreation(LocalDateTime dateCreation) {
        this.dateCreation = dateCreation;
    }

    public String getTypeNotif() {
        return typeNotif;
    }

    public void setTypeNotif(String typeNotif) {
        this.typeNotif = typeNotif;
    }
}