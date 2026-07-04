package com.burundihealthconnect.ejb;

import com.burundihealthconnect.entity.Medecin;
import com.burundihealthconnect.entity.Patient;
import com.burundihealthconnect.exception.EntiteIntrouvableException;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Stateless
public class ProfilCompletudeService {

    @PersistenceContext(unitName = "bhcPU")
    private EntityManager em;

    public int calculerCompletudePatient(Long idPatient) {
        Patient patient = em.find(Patient.class, idPatient);
        if (patient == null) {
            throw new EntiteIntrouvableException("Patient", idPatient);
        }

        int total = 4;
        int remplis = 0;

        if (patient.getTelephone() != null && !patient.getTelephone().isBlank()) {
            remplis++;
        }
        if (patient.getAdresse() != null && !patient.getAdresse().isBlank()) {
            remplis++;
        }
        if (patient.getGroupeSanguin() != null && !patient.getGroupeSanguin().isBlank()) {
            remplis++;
        }
        if (patient.getAllergies() != null && !patient.getAllergies().isBlank()) {
            remplis++;
        }

        return (int) Math.round((double) remplis / total * 100);
    }

    public int calculerCompletudeMedecin(Long idMedecin) {
        Medecin medecin = em.find(Medecin.class, idMedecin);
        if (medecin == null) {
            throw new EntiteIntrouvableException("Medecin", idMedecin);
        }

        int total = 4;
        int remplis = 0;

        if (medecin.getSpecialite() != null && !medecin.getSpecialite().isBlank()) {
            remplis++;
        }
        if (medecin.getExperience() != null) {
            remplis++;
        }
        if (medecin.getNumeroOrdre() != null && !medecin.getNumeroOrdre().isBlank()) {
            remplis++;
        }
        if (medecin.getService() != null) {
            remplis++;
        }

        return (int) Math.round((double) remplis / total * 100);
    }
}
