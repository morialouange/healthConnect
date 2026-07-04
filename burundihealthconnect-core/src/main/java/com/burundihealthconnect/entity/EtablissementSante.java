package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Hôpital du réseau MediCentral.
 * Table GLOBALE : géré uniquement par le SUPER_ADMIN.
 * Toutes les données "privées" (médecins, services, rdv, créneaux)
 * sont rattachées à un établissement via id_etablissement.
 */
@Entity
@Table(name = "etablissement_santes")
public class EtablissementSante {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_etablissement")
    private Long idEtablissement;

    @Column(name = "nom", nullable = false, length = 150)
    private String nom;

    @Column(name = "adresse", nullable = false, length = 255)
    private String adresse;

    @Column(name = "type_etablissement", nullable = false, length = 100)
    private String typeEtablissement;

    @Column(name = "email", unique = true, length = 150)
    private String email;

    @Column(name = "telephone", length = 20)
    private String telephone;

    @Column(name = "actif", nullable = false)
    private Boolean actif = true;

    @Column(name = "date_inscription", nullable = false)
    private LocalDateTime dateInscription;

    @OneToMany(mappedBy = "etablissement", cascade = CascadeType.PERSIST)
    private List<Utilisateur> utilisateurs = new ArrayList<>();

    public EtablissementSante() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateInscription == null) {
            dateInscription = LocalDateTime.now();
        }
        if (actif == null) {
            actif = true;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdEtablissement() {
        return idEtablissement;
    }

    public void setIdEtablissement(Long idEtablissement) {
        this.idEtablissement = idEtablissement;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getAdresse() {
        return adresse;
    }

    public void setAdresse(String adresse) {
        this.adresse = adresse;
    }

    public String getTypeEtablissement() {
        return typeEtablissement;
    }

    public void setTypeEtablissement(String typeEtablissement) {
        this.typeEtablissement = typeEtablissement;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public Boolean getActif() {
        return actif;
    }

    public void setActif(Boolean actif) {
        this.actif = actif;
    }

    public LocalDateTime getDateInscription() {
        return dateInscription;
    }

    public void setDateInscription(LocalDateTime dateInscription) {
        this.dateInscription = dateInscription;
    }

    public List<Utilisateur> getUtilisateurs() {
        return utilisateurs;
    }

    public void setUtilisateurs(List<Utilisateur> utilisateurs) {
        this.utilisateurs = utilisateurs;
    }
}