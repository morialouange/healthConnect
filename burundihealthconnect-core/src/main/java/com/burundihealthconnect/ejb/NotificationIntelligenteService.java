package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.CongeMedecin;
import com.burundihealthconnect.entity.Referenement;
import com.burundihealthconnect.entity.RendezVous;
import com.burundihealthconnect.entity.Utilisateur;
import com.burundihealthconnect.entity.enums.Role;

import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

@Stateless
public class NotificationIntelligenteService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    @EJB
    private NotificationService notificationService;

    public void notifierPatientRdvConfirme(RendezVous rdv) {
        notificationService.creerNotification(
                rdv.getPatient().getUtilisateur().getIdUtilisateur(),
                "Votre rendez-vous du " + rdv.getDateRendez() + " avec Dr " + rdv.getMedecin().getUtilisateur().getFullName() + " a été confirmé.",
                "RDV_CONFIRME");
    }

    public void notifierPatientRdvRefuse(RendezVous rdv) {
        notificationService.creerNotification(
                rdv.getPatient().getUtilisateur().getIdUtilisateur(),
                "Votre rendez-vous du " + rdv.getDateRendez() + " a été refusé.",
                "RDV_REFUSE");
    }

    public void notifierAdminCongeDemande(CongeMedecin conge) {
        List<Utilisateur> admins = em.createQuery(
                        "SELECT u FROM Utilisateur u WHERE u.etablissement.idEtablissement = :idEtab AND u.role = :role",
                        Utilisateur.class)
                .setParameter("idEtab", conge.getMedecin().getUtilisateur().getEtablissement().getIdEtablissement())
                .setParameter("role", Role.ADMIN)
                .getResultList();
        for (Utilisateur admin : admins) {
            notificationService.creerNotification(
                    admin.getIdUtilisateur(),
                    "Le Dr " + conge.getMedecin().getUtilisateur().getFullName() + " demande un congé du " + conge.getDateDebut() + " au " + conge.getDateFin() + ".",
                    "CONGE_DEMANDE");
        }
    }

    public void notifierMedecinReferenementRecu(Referenement ref) {
        if (ref.getMedecinDest() != null) {
            notificationService.creerNotification(
                    ref.getMedecinDest().getUtilisateur().getIdUtilisateur(),
                    "Un patient vous a été référé : " + ref.getConsultation().getDossier().getPatient().getUtilisateur().getFullName() + " — " + ref.getMotif(),
                    "REFERENEMENT_RECU");
        }
    }
}
