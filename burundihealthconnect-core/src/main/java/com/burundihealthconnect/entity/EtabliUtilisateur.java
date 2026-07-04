package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Table d'affectation d'un médecin à un établissement.
 * Utilisée par L23 (désactivation logique : actif=false en plus de
 * Utilisateur.actif=false).
 */
@Entity
@Table(name = "etabli_utilisateurs")
public class EtabliUtilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_medecin", nullable = false)
    private Medecin medecin;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @Column(name = "date_affectation")
    private LocalDateTime dateAffectation;

    @Column(name = "role_dans_hopital", length = 100)
    private String roleDansHopital;

    @Column(name = "actif", nullable = false)
    private Boolean actif = true;

    public EtabliUtilisateur() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateAffectation == null) {
            dateAffectation = LocalDateTime.now();
        }
        if (actif == null) {
            actif = true;
        }
    }

    // ===== Getters / Setters =====

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public LocalDateTime getDateAffectation() {
        return dateAffectation;
    }

    public void setDateAffectation(LocalDateTime dateAffectation) {
        this.dateAffectation = dateAffectation;
    }

    public String getRoleDansHopital() {
        return roleDansHopital;
    }

    public void setRoleDansHopital(String roleDansHopital) {
        this.roleDansHopital = roleDansHopital;
    }

    public Boolean getActif() {
        return actif;
    }

    public void setActif(Boolean actif) {
        this.actif = actif;
    }
}