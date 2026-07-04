package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * Créneau horaire issu du découpage d'une DisponibiliteSemaine (L14).
 * disponible=true tant qu'aucun RDV ne l'occupe.
 * La réservation doit être atomique (verrou optimiste / transaction
 * gérée par DisponibiliteService.reserverCreneau) pour éviter le double
 * réservation -> CreneauDejaReserveException côté EJB.
 */
@Entity
@Table(name = "creneau_disponible")
public class CreneauDisponible {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_creneau")
    private Long idCreneau;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_disponibilite", nullable = false)
    private DisponibiliteSemaine disponibilite;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_medecin", nullable = false)
    private Medecin medecin;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @Column(name = "date_creneau", nullable = false)
    private LocalDate dateCreneau;

    @Column(name = "heure_debut", nullable = false)
    private LocalTime heureDebut;

    @Column(name = "heure_fin", nullable = false)
    private LocalTime heureFin;

    @Column(name = "disponible", nullable = false)
    private Boolean disponible = true;

    /** NULL si libre — renseigné dès que le créneau est réservé par un RDV. */
    @OneToOne(mappedBy = "creneau")
    private RendezVous rendezVous;

    public CreneauDisponible() {
    }

    @PrePersist
    protected void onCreate() {
        if (disponible == null) {
            disponible = true;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdCreneau() {
        return idCreneau;
    }

    public void setIdCreneau(Long idCreneau) {
        this.idCreneau = idCreneau;
    }

    public DisponibiliteSemaine getDisponibilite() {
        return disponibilite;
    }

    public void setDisponibilite(DisponibiliteSemaine disponibilite) {
        this.disponibilite = disponibilite;
    }

    public Medecin getMedecin() {
        return medecin;
    }

    public void setMedecin(Medecin medecin) {
        this.medecin = medecin;
    }

    public EtablissementSante getEtablissement() {
        return etablissement;
    }

    public void setEtablissement(EtablissementSante etablissement) {
        this.etablissement = etablissement;
    }

    public LocalDate getDateCreneau() {
        return dateCreneau;
    }

    public void setDateCreneau(LocalDate dateCreneau) {
        this.dateCreneau = dateCreneau;
    }

    public LocalTime getHeureDebut() {
        return heureDebut;
    }

    public void setHeureDebut(LocalTime heureDebut) {
        this.heureDebut = heureDebut;
    }

    public LocalTime getHeureFin() {
        return heureFin;
    }

    public void setHeureFin(LocalTime heureFin) {
        this.heureFin = heureFin;
    }

    public Boolean getDisponible() {
        return disponible;
    }

    public void setDisponible(Boolean disponible) {
        this.disponible = disponible;
    }

    public RendezVous getRendezVous() {
        return rendezVous;
    }

    public void setRendezVous(RendezVous rendezVous) {
        this.rendezVous = rendezVous;
    }
}