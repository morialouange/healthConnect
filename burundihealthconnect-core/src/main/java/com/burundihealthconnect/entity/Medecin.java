package com.burundihealthconnect.entity;

import com.burundihealthconnect.entity.Service;
import jakarta.persistence.*;

/**
 * Données métier spécifiques au médecin (lié 1-1 à Utilisateur).
 * numero_ordre modifiable UNIQUEMENT par l'ADMIN (L23) — jamais par le
 * médecin lui-même via son propre profil (L25).
 */
@Entity
@Table(name = "medecins")
public class Medecin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_medecin")
    private Long idMedecin;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_utilisateur", nullable = false, unique = true)
    private Utilisateur utilisateur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_service")
    private Service service;

    @Column(name = "specialite", length = 100)
    private String specialite;

    @Column(name = "experience")
    private Integer experience;

    @Column(name = "numero_ordre", length = 50)
    private String numeroOrdre;

    public Medecin() {
    }

    // ===== Getters / Setters =====

    public Long getIdMedecin() {
        return idMedecin;
    }

    public void setIdMedecin(Long idMedecin) {
        this.idMedecin = idMedecin;
    }

    public Utilisateur getUtilisateur() {
        return utilisateur;
    }

    public void setUtilisateur(Utilisateur utilisateur) {
        this.utilisateur = utilisateur;
    }

    public Service getService() {
        return service;
    }

    public void setService(Service service) {
        this.service = service;
    }

    public String getSpecialite() {
        return specialite;
    }

    public void setSpecialite(String specialite) {
        this.specialite = specialite;
    }

    public Integer getExperience() {
        return experience;
    }

    public void setExperience(Integer experience) {
        this.experience = experience;
    }

    public String getNumeroOrdre() {
        return numeroOrdre;
    }

    public void setNumeroOrdre(String numeroOrdre) {
        this.numeroOrdre = numeroOrdre;
    }
}