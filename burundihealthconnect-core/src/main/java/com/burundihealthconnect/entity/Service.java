package com.burundihealthconnect.entity;

import com.burundihealthconnect.entity.enums.CategorieService;
import jakarta.persistence.*;

/**
 * Service hospitalier (ex. URGENCE, CONSULTATION...).
 * Géré entièrement par l'ADMIN de son hôpital (L24).
 * Désactivation logique uniquement (actif=false), jamais de suppression
 * physique car lié à des rendez_vous historiques.
 */
@Entity
@Table(name = "services")
public class Service {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_service")
    private Long idService;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @Column(name = "nom", nullable = false, length = 100)
    private String nom;

    @Enumerated(EnumType.STRING)
    @Column(name = "categorie", nullable = false)
    private CategorieService categorie;

    @Column(name = "actif", nullable = false)
    private Boolean actif = true;

    public Service() {
    }

    @PrePersist
    protected void onCreate() {
        if (actif == null) {
            actif = true;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdService() {
        return idService;
    }

    public void setIdService(Long idService) {
        this.idService = idService;
    }

    public EtablissementSante getEtablissement() {
        return etablissement;
    }

    public void setEtablissement(EtablissementSante etablissement) {
        this.etablissement = etablissement;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public CategorieService getCategorie() {
        return categorie;
    }

    public void setCategorie(CategorieService categorie) {
        this.categorie = categorie;
    }

    public Boolean getActif() {
        return actif;
    }

    public void setActif(Boolean actif) {
        this.actif = actif;
    }
}