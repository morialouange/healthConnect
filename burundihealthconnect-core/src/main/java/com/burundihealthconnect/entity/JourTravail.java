package com.burundihealthconnect.entity;

import jakarta.persistence.*;
import java.time.DayOfWeek;
import java.time.LocalTime;

@Entity
@Table(name = "jour_travail")
public class JourTravail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_jour_travail")
    private Long idJourTravail;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_disponibilite", nullable = false)
    private DisponibiliteSemaine disponibilite;

    @Enumerated(EnumType.STRING)
    @Column(name = "jour_semaine", nullable = false, length = 10)
    private DayOfWeek jourSemaine;

    @Column(name = "heure_debut", nullable = false)
    private LocalTime heureDebut;

    @Column(name = "heure_fin", nullable = false)
    private LocalTime heureFin;

    public JourTravail() {}

    public Long getIdJourTravail() { return idJourTravail; }
    public void setIdJourTravail(Long idJourTravail) { this.idJourTravail = idJourTravail; }

    public DisponibiliteSemaine getDisponibilite() { return disponibilite; }
    public void setDisponibilite(DisponibiliteSemaine disponibilite) { this.disponibilite = disponibilite; }

    public DayOfWeek getJourSemaine() { return jourSemaine; }
    public void setJourSemaine(DayOfWeek jourSemaine) { this.jourSemaine = jourSemaine; }

    public LocalTime getHeureDebut() { return heureDebut; }
    public void setHeureDebut(LocalTime heureDebut) { this.heureDebut = heureDebut; }

    public LocalTime getHeureFin() { return heureFin; }
    public void setHeureFin(LocalTime heureFin) { this.heureFin = heureFin; }
}
