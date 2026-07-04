package com.burundihealthconnect.entity;

import jakarta.persistence.*;

/**
 * Ligne d'une ordonnance multi-lignes.
 * Chaque ligne est vérifiée contre les allergies du patient avant
 * sauvegarde (L04). Le médecin peut passer outre l'alerte.
 */
@Entity
@Table(name = "lignes_prescription")
public class LignePrescription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_ligne")
    private Long idLigne;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_ordonance", nullable = false)
    private Ordonance ordonance;

    @Column(name = "medicament", nullable = false, length = 150)
    private String medicament;

    @Column(name = "dosage", nullable = false, length = 100)
    private String dosage;

    @Column(name = "frequence", nullable = false, length = 100)
    private String frequence;

    @Column(name = "duree_jours", nullable = false)
    private Integer dureeJours;

    public LignePrescription() {
    }

    // ===== Getters / Setters =====

    public Long getIdLigne() {
        return idLigne;
    }

    public void setIdLigne(Long idLigne) {
        this.idLigne = idLigne;
    }

    public Ordonance getOrdonance() {
        return ordonance;
    }

    public void setOrdonance(Ordonance ordonance) {
        this.ordonance = ordonance;
    }

    public String getMedicament() {
        return medicament;
    }

    public void setMedicament(String medicament) {
        this.medicament = medicament;
    }

    public String getDosage() {
        return dosage;
    }

    public void setDosage(String dosage) {
        this.dosage = dosage;
    }

    public String getFrequence() {
        return frequence;
    }

    public void setFrequence(String frequence) {
        this.frequence = frequence;
    }

    public Integer getDureeJours() {
        return dureeJours;
    }

    public void setDureeJours(Integer dureeJours) {
        this.dureeJours = dureeJours;
    }
}