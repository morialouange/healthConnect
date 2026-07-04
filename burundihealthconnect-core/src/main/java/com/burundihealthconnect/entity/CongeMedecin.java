package com.burundihealthconnect.entity;

import com.burundihealthconnect.entity.enums.StatutConge;
import jakarta.persistence.*;
import java.time.LocalDate;

/**
 * Demande de congé d'un médecin (L19).
 * Workflow : EN_ATTENTE -> APPROUVE (bloque les créneaux automatiquement
 * via DisponibiliteService.bloquerCreneauxConge) ou REFUSE.
 */
@Entity
@Table(name = "conges_medecin")
public class CongeMedecin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_conge")
    private Long idConge;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_medecin", nullable = false)
    private Medecin medecin;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @Column(name = "date_debut", nullable = false)
    private LocalDate dateDebut;

    @Column(name = "date_fin", nullable = false)
    private LocalDate dateFin;

    @Column(name = "motif", length = 255)
    private String motif;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false)
    private StatutConge statut = StatutConge.EN_ATTENTE;

    public CongeMedecin() {
    }

    @PrePersist
    protected void onCreate() {
        if (statut == null) {
            statut = StatutConge.EN_ATTENTE;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdConge() {
        return idConge;
    }

    public void setIdConge(Long idConge) {
        this.idConge = idConge;
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

    public LocalDate getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDate dateDebut) {
        this.dateDebut = dateDebut;
    }

    public LocalDate getDateFin() {
        return dateFin;
    }

    public void setDateFin(LocalDate dateFin) {
        this.dateFin = dateFin;
    }

    public String getMotif() {
        return motif;
    }

    public void setMotif(String motif) {
        this.motif = motif;
    }

    public StatutConge getStatut() {
        return statut;
    }

    public void setStatut(StatutConge statut) {
        this.statut = statut;
    }
}