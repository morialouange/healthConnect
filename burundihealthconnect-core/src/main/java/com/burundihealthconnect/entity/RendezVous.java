package com.burundihealthconnect.entity;

import com.burundihealthconnect.entity.enums.Priorite;
import com.burundihealthconnect.entity.enums.StatutRdv;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Rendez-vous patient/médecin.
 * Workflow (L02) :
 *   RDV_DEMANDE  -> créé par PATIENT
 *   RDV_CONFIRME -> confirmé par MEDECIN
 *   RDV_ANNULE   -> refusé par MEDECIN ou annulé par PATIENT (L21, si RDV_DEMANDE)
 *   TERMINE      -> marqué par MEDECIN après consultation
 * priorite (L16) : NORMAL | URGENT | CRITIQUE — modifiable par le médecin.
 */
@Entity
@Table(name = "rendez_vous")
public class RendezVous {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_rendez")
    private Long idRendez;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_patient", nullable = false)
    private Patient patient;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_medecin", nullable = false)
    private Medecin medecin;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_service")
    private Service service;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_creneau", unique = true)
    private CreneauDisponible creneau;

    @Column(name = "motif", nullable = false, length = 255)
    private String motif;

    @Column(name = "date_rendez", nullable = false)
    private LocalDateTime dateRendez;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false)
    private StatutRdv statut = StatutRdv.RDV_DEMANDE;

    @Enumerated(EnumType.STRING)
    @Column(name = "priorite", nullable = false)
    private Priorite priorite = Priorite.NORMAL;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    public RendezVous() {
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (statut == null) {
            statut = StatutRdv.RDV_DEMANDE;
        }
        if (priorite == null) {
            priorite = Priorite.NORMAL;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdRendez() {
        return idRendez;
    }

    public void setIdRendez(Long idRendez) {
        this.idRendez = idRendez;
    }

    public Patient getPatient() {
        return patient;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
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

    public Service getService() {
        return service;
    }

    public void setService(Service service) {
        this.service = service;
    }

    public CreneauDisponible getCreneau() {
        return creneau;
    }

    public void setCreneau(CreneauDisponible creneau) {
        this.creneau = creneau;
    }

    public String getMotif() {
        return motif;
    }

    public void setMotif(String motif) {
        this.motif = motif;
    }

    public LocalDateTime getDateRendez() {
        return dateRendez;
    }

    public void setDateRendez(LocalDateTime dateRendez) {
        this.dateRendez = dateRendez;
    }

    public StatutRdv getStatut() {
        return statut;
    }

    public void setStatut(StatutRdv statut) {
        this.statut = statut;
    }

    public Priorite getPriorite() {
        return priorite;
    }

    public void setPriorite(Priorite priorite) {
        this.priorite = priorite;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}