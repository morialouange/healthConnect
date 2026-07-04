package com.burundihealthconnect.entity;

import com.burundihealthconnect.entity.enums.StatutConsultation;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Consultation médicale liée à un RDV (optionnel — id_rendez nullable pour
 * permettre une consultation hors RDV planifié) et à un dossier (toujours
 * obligatoire, dossier global).
 * Workflow (L02) : EN_COURS -> CLOTUREE -> VERSEE_AU_DOSSIER (médecin uniquement).
 * Une fois VERSEE_AU_DOSSIER, visible par tout médecin du réseau (L05).
 */
@Entity
@Table(name = "consultations")
public class Consultation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_consultation")
    private Long idConsultation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_rendez")
    private RendezVous rendezVous;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_dossier", nullable = false)
    private DossierMedical dossier;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_medecin", nullable = false)
    private Medecin medecin;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @Lob
    @Column(name = "notes")
    private String notes;

    @Lob
    @Column(name = "diagnostic")
    private String diagnostic;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false)
    private StatutConsultation statut = StatutConsultation.EN_COURS;

    @Column(name = "date_consultation", nullable = false)
    private LocalDateTime dateConsultation;

    @OneToOne(mappedBy = "consultation", cascade = CascadeType.PERSIST)
    private Ordonance ordonance;

    public Consultation() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateConsultation == null) {
            dateConsultation = LocalDateTime.now();
        }
        if (statut == null) {
            statut = StatutConsultation.EN_COURS;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdConsultation() {
        return idConsultation;
    }

    public void setIdConsultation(Long idConsultation) {
        this.idConsultation = idConsultation;
    }

    public RendezVous getRendezVous() {
        return rendezVous;
    }

    public void setRendezVous(RendezVous rendezVous) {
        this.rendezVous = rendezVous;
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

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getDiagnostic() {
        return diagnostic;
    }

    public void setDiagnostic(String diagnostic) {
        this.diagnostic = diagnostic;
    }

    public StatutConsultation getStatut() {
        return statut;
    }

    public void setStatut(StatutConsultation statut) {
        this.statut = statut;
    }

    public LocalDateTime getDateConsultation() {
        return dateConsultation;
    }

    public void setDateConsultation(LocalDateTime dateConsultation) {
        this.dateConsultation = dateConsultation;
    }

    public Ordonance getOrdonance() {
        return ordonance;
    }

    public void setOrdonance(Ordonance ordonance) {
        this.ordonance = ordonance;
    }
}