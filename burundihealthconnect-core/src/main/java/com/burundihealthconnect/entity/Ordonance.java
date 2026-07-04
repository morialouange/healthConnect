package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Ordonnance liée à UNE consultation (relation 1-1).
 * Contient plusieurs LignePrescription (multi-lignes).
 * Avant chaque ligne, le médecin doit vérifier les allergies du
 * patient (L04 — OrdonanceService.verifierAllergie()).
 */
@Entity
@Table(name = "ordonances")
public class Ordonance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_ordonance")
    private Long idOrdonance;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_consultation", nullable = false, unique = true)
    private Consultation consultation;

    @Lob
    @Column(name = "instructions")
    private String instructions;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "ordonance", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<LignePrescription> lignes = new ArrayList<>();

    public Ordonance() {
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    // ===== Getters / Setters =====

    public Long getIdOrdonance() {
        return idOrdonance;
    }

    public void setIdOrdonance(Long idOrdonance) {
        this.idOrdonance = idOrdonance;
    }

    public Consultation getConsultation() {
        return consultation;
    }

    public void setConsultation(Consultation consultation) {
        this.consultation = consultation;
    }

    public String getInstructions() {
        return instructions;
    }

    public void setInstructions(String instructions) {
        this.instructions = instructions;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<LignePrescription> getLignes() {
        return lignes;
    }

    public void setLignes(List<LignePrescription> lignes) {
        this.lignes = lignes;
    }
}