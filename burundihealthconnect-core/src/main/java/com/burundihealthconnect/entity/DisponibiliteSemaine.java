package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Déclaration de disponibilité d'un médecin pour une semaine donnée (L14).
 * Génère des CreneauDisponible découpés selon dureeCreneauMin.
 * Contrainte unique (id_medecin, id_etablissement, date_debut_semaine).
 */
@Entity
@Table(name = "disponibilite_semaine")
public class DisponibiliteSemaine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_disponibilite")
    private Long idDisponibilite;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_medecin", nullable = false)
    private Medecin medecin;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @Column(name = "date_debut_semaine", nullable = false)
    private LocalDate dateDebutSemaine;

    @Column(name = "date_fin_semaine", nullable = false)
    private LocalDate dateFinSemaine;

    @Column(name = "duree_creneau_min", nullable = false)
    private Integer dureeCreneauMin;

    @Column(name = "actif", nullable = false)
    private Boolean actif = true;

    @OneToMany(mappedBy = "disponibilite", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<JourTravail> jours = new ArrayList<>();

    @OneToMany(mappedBy = "disponibilite", cascade = CascadeType.PERSIST)
    private List<CreneauDisponible> creneaux = new ArrayList<>();

    public DisponibiliteSemaine() {
    }

    @PrePersist
    protected void onCreate() {
        if (actif == null) {
            actif = true;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdDisponibilite() {
        return idDisponibilite;
    }

    public void setIdDisponibilite(Long idDisponibilite) {
        this.idDisponibilite = idDisponibilite;
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

    public LocalDate getDateDebutSemaine() {
        return dateDebutSemaine;
    }

    public void setDateDebutSemaine(LocalDate dateDebutSemaine) {
        this.dateDebutSemaine = dateDebutSemaine;
    }

    public LocalDate getDateFinSemaine() {
        return dateFinSemaine;
    }

    public void setDateFinSemaine(LocalDate dateFinSemaine) {
        this.dateFinSemaine = dateFinSemaine;
    }

    public Integer getDureeCreneauMin() {
        return dureeCreneauMin;
    }

    public void setDureeCreneauMin(Integer dureeCreneauMin) {
        this.dureeCreneauMin = dureeCreneauMin;
    }

    public Boolean getActif() {
        return actif;
    }

    public void setActif(Boolean actif) {
        this.actif = actif;
    }

    public List<JourTravail> getJours() {
        return jours;
    }

    public void setJours(List<JourTravail> jours) {
        this.jours = jours;
    }

    public List<CreneauDisponible> getCreneaux() {
        return creneaux;
    }

    public void setCreneaux(List<CreneauDisponible> creneaux) {
        this.creneaux = creneaux;
    }
}