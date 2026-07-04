package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "historique_rdv")
public class HistoriqueRdv {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_histo_rdv")
    private Long idHistoRdv;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_rendez", nullable = false)
    private RendezVous rendezVous;

    @Column(name = "ancien_statut", length = 50)
    private String ancienStatut;

    @Column(name = "nouveau_statut", nullable = false, length = 50)
    private String nouveauStatut;

    @Column(name = "modifie_par", nullable = false, length = 50)
    private String modifiePar;

    @Column(name = "id_modificateur")
    private Long idModificateur;

    @Column(name = "date_modification", nullable = false)
    private LocalDateTime dateModification;

    public HistoriqueRdv() {
    }

    @PrePersist
    protected void onCreate() {
        if (dateModification == null) {
            dateModification = LocalDateTime.now();
        }
    }

    public Long getIdHistoRdv() {
        return idHistoRdv;
    }

    public void setIdHistoRdv(Long idHistoRdv) {
        this.idHistoRdv = idHistoRdv;
    }

    public RendezVous getRendezVous() {
        return rendezVous;
    }

    public void setRendezVous(RendezVous rendezVous) {
        this.rendezVous = rendezVous;
    }

    public String getAncienStatut() {
        return ancienStatut;
    }

    public void setAncienStatut(String ancienStatut) {
        this.ancienStatut = ancienStatut;
    }

    public String getNouveauStatut() {
        return nouveauStatut;
    }

    public void setNouveauStatut(String nouveauStatut) {
        this.nouveauStatut = nouveauStatut;
    }

    public String getModifiePar() {
        return modifiePar;
    }

    public void setModifiePar(String modifiePar) {
        this.modifiePar = modifiePar;
    }

    public Long getIdModificateur() {
        return idModificateur;
    }

    public void setIdModificateur(Long idModificateur) {
        this.idModificateur = idModificateur;
    }

    public LocalDateTime getDateModification() {
        return dateModification;
    }

    public void setDateModification(LocalDateTime dateModification) {
        this.dateModification = dateModification;
    }
}
