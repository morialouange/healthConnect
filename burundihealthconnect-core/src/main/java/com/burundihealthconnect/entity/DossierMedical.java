package com.burundihealthconnect.entity;

import com.burundihealthconnect.entity.enums.NiveauConfidentialite;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Dossier médical — GLOBAL au réseau (pas d'id_etablissement).
 * Visible/modifiable par tout médecin du réseau (L05), avec traçabilité
 * complète des accès (L10, table acces_dossier) et des modifications
 * (L18, table historique_modifications).
 */
@Entity
@Table(name = "dossier_medicals")
public class DossierMedical {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_dossier")
    private Long idDossier;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_patient", nullable = false, unique = true)
    private Patient patient;

    @Column(name = "numero_unique", nullable = false, unique = true, length = 30)
    private String numeroUnique;

    @Lob
    @Column(name = "antecedents")
    private String antecedents;

    @Enumerated(EnumType.STRING)
    @Column(name = "niveau_confidentialite", nullable = false, length = 20)
    private NiveauConfidentialite niveauConfidentialite = NiveauConfidentialite.NORMAL;

    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation;

    @Column(name = "date_mise_jour")
    private LocalDateTime dateMiseAJour;

    @OneToMany(mappedBy = "dossier", cascade = CascadeType.PERSIST)
    private List<Consultation> consultations = new ArrayList<>();

    @OneToMany(mappedBy = "dossier", cascade = CascadeType.PERSIST)
    private List<AccesDossier> acces = new ArrayList<>();

    @OneToMany(mappedBy = "dossier", cascade = CascadeType.PERSIST)
    private List<HistoriqueModification> historique = new ArrayList<>();

    public DossierMedical() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateCreation == null) {
            dateCreation = LocalDateTime.now();
        }
        if (dateMiseAJour == null) {
            dateMiseAJour = dateCreation;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdDossier() {
        return idDossier;
    }

    public void setIdDossier(Long idDossier) {
        this.idDossier = idDossier;
    }

    public Patient getPatient() {
        return patient;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
    }

    public String getNumeroUnique() {
        return numeroUnique;
    }

    public void setNumeroUnique(String numeroUnique) {
        this.numeroUnique = numeroUnique;
    }

    public String getAntecedents() {
        return antecedents;
    }

    public void setAntecedents(String antecedents) {
        this.antecedents = antecedents;
    }

    public LocalDateTime getDateCreation() {
        return dateCreation;
    }

    public void setDateCreation(LocalDateTime dateCreation) {
        this.dateCreation = dateCreation;
    }

    public LocalDateTime getDateMiseAJour() {
        return dateMiseAJour;
    }

    public NiveauConfidentialite getNiveauConfidentialite() {
        return niveauConfidentialite;
    }

    public void setNiveauConfidentialite(NiveauConfidentialite niveauConfidentialite) {
        this.niveauConfidentialite = niveauConfidentialite;
    }

    public void setDateMiseAJour(LocalDateTime dateMiseAJour) {
        this.dateMiseAJour = dateMiseAJour;
    }

    public List<Consultation> getConsultations() {
        return consultations;
    }

    public void setConsultations(List<Consultation> consultations) {
        this.consultations = consultations;
    }

    public List<AccesDossier> getAcces() {
        return acces;
    }

    public void setAcces(List<AccesDossier> acces) {
        this.acces = acces;
    }

    public List<HistoriqueModification> getHistorique() {
        return historique;
    }

    public void setHistorique(List<HistoriqueModification> historique) {
        this.historique = historique;
    }
}