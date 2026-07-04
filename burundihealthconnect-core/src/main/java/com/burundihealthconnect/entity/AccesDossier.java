package com.burundihealthconnect.entity;

import com.burundihealthconnect.entity.enums.TypeAcces;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Trace chaque accès (LECTURE/MODIFICATION) au dossier médical (L10).
 * Créée automatiquement par DossierService.ouvrirDossier() — jamais
 * saisie manuellement par l'utilisateur.
 */
@Entity
@Table(name = "acces_dossier")
public class AccesDossier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_acces")
    private Long idAcces;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_dossier", nullable = false)
    private DossierMedical dossier;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_medecin", nullable = false)
    private Medecin medecin;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement", nullable = false)
    private EtablissementSante etablissement;

    @Enumerated(EnumType.STRING)
    @Column(name = "type_acces", nullable = false)
    private TypeAcces typeAcces = TypeAcces.LECTURE;

    @Column(name = "date_acces", nullable = false)
    private LocalDateTime dateAcces;

    @Column(name = "motif_acces", length = 255)
    private String motifAcces;

    public AccesDossier() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateAcces == null) {
            dateAcces = LocalDateTime.now();
        }
        if (typeAcces == null) {
            typeAcces = TypeAcces.LECTURE;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdAcces() {
        return idAcces;
    }

    public void setIdAcces(Long idAcces) {
        this.idAcces = idAcces;
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

    public TypeAcces getTypeAcces() {
        return typeAcces;
    }

    public void setTypeAcces(TypeAcces typeAcces) {
        this.typeAcces = typeAcces;
    }

    public LocalDateTime getDateAcces() {
        return dateAcces;
    }

    public void setDateAcces(LocalDateTime dateAcces) {
        this.dateAcces = dateAcces;
    }

    public String getMotifAcces() {
        return motifAcces;
    }

    public void setMotifAcces(String motifAcces) {
        this.motifAcces = motifAcces;
    }
}