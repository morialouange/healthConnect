package com.burundihealthconnect.entity;

import com.burundihealthconnect.entity.enums.StatutReferenement;
import jakarta.persistence.*;
import java.time.LocalDate;

/**
 * Référencement d'un patient vers un autre établissement (L06).
 * Workflow : EN_ATTENTE -> ACCEPTE -> RETOUR_RECU -> CLOTURE.
 * fichier_courrier : nom de fichier stocké en base (pièce jointe simple,
 * exigence du sujet — pas d'upload binaire en base).
 */
@Entity
@Table(name = "referenements")
public class Referenement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_ref")
    private Long idRef;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_consultation", nullable = false)
    private Consultation consultation;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_etablissement_dest", nullable = false)
    private EtablissementSante etablissementDest;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_medecin_dest")
    private Medecin medecinDest;

    @Lob
    @Column(name = "motif", nullable = false)
    private String motif;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false)
    private StatutReferenement statut = StatutReferenement.EN_ATTENTE;

    @Column(name = "fichier_courrier", length = 255)
    private String fichierCourrier;

    @Column(name = "date_ref", nullable = false)
    private LocalDate dateRef;

    @Lob
    @Column(name = "retour")
    private String retour;

    public Referenement() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateRef == null) {
            dateRef = LocalDate.now();
        }
        if (statut == null) {
            statut = StatutReferenement.EN_ATTENTE;
        }
    }

    // ===== Getters / Setters =====

    public Long getIdRef() {
        return idRef;
    }

    public void setIdRef(Long idRef) {
        this.idRef = idRef;
    }

    public Consultation getConsultation() {
        return consultation;
    }

    public void setConsultation(Consultation consultation) {
        this.consultation = consultation;
    }

    public EtablissementSante getEtablissementDest() {
        return etablissementDest;
    }

    public void setEtablissementDest(EtablissementSante etablissementDest) {
        this.etablissementDest = etablissementDest;
    }

    public Medecin getMedecinDest() {
        return medecinDest;
    }

    public void setMedecinDest(Medecin medecinDest) {
        this.medecinDest = medecinDest;
    }

    public String getMotif() {
        return motif;
    }

    public void setMotif(String motif) {
        this.motif = motif;
    }

    public StatutReferenement getStatut() {
        return statut;
    }

    public void setStatut(StatutReferenement statut) {
        this.statut = statut;
    }

    public String getFichierCourrier() {
        return fichierCourrier;
    }

    public void setFichierCourrier(String fichierCourrier) {
        this.fichierCourrier = fichierCourrier;
    }

    public LocalDate getDateRef() {
        return dateRef;
    }

    public void setDateRef(LocalDate dateRef) {
        this.dateRef = dateRef;
    }

    public String getRetour() {
        return retour;
    }

    public void setRetour(String retour) {
        this.retour = retour;
    }
}