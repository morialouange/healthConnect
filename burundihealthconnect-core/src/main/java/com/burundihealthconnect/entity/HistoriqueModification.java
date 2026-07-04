package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Trace chaque modification d'un champ du dossier médical (L18).
 * Créée automatiquement par DossierService.tracerModification() à
 * chaque écriture, AVANT/APRES, pour audit complet.
 */
@Entity
@Table(name = "historique_modifications")
public class HistoriqueModification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_histo")
    private Long idHisto;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_dossier", nullable = false)
    private DossierMedical dossier;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_medecin", nullable = false)
    private Medecin medecin;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @Column(name = "champ_modifie", nullable = false, length = 100)
    private String champModifie;

    @Lob
    @Column(name = "ancienne_valeur")
    private String ancienneValeur;

    @Lob
    @Column(name = "nouvelle_valeur")
    private String nouvelleValeur;

    @Column(name = "date_modification", nullable = false)
    private LocalDateTime dateModification;

    public HistoriqueModification() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateModification == null) {
            dateModification = LocalDateTime.now();
        }
    }

    // ===== Getters / Setters =====

    public Long getIdHisto() {
        return idHisto;
    }

    public void setIdHisto(Long idHisto) {
        this.idHisto = idHisto;
    }

    public DossierMedical getDossier() {
        return dossier;
    }

    public void setDossier(DossierMedical dossier) {
        this.dossier = dossier;
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

    public String getChampModifie() {
        return champModifie;
    }

    public void setChampModifie(String champModifie) {
        this.champModifie = champModifie;
    }

    public String getAncienneValeur() {
        return ancienneValeur;
    }

    public void setAncienneValeur(String ancienneValeur) {
        this.ancienneValeur = ancienneValeur;
    }

    public String getNouvelleValeur() {
        return nouvelleValeur;
    }

    public void setNouvelleValeur(String nouvelleValeur) {
        this.nouvelleValeur = nouvelleValeur;
    }

    public LocalDateTime getDateModification() {
        return dateModification;
    }

    public void setDateModification(LocalDateTime dateModification) {
        this.dateModification = dateModification;
    }
}