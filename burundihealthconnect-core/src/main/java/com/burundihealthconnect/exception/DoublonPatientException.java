package com.burundihealthconnect.exception;

/**
 * L03 — Levée par AuthService.patientDejaExistant() / inscrirePatient()
 * quand l'email est déjà utilisé au niveau réseau (vérification GLOBALE,
 * pas filtrée par établissement, car table utilisateurs.email est unique
 * pour tout le réseau).
 */
public class DoublonPatientException extends BusinessException {

    public DoublonPatientException(String email) {
        super("Un compte existe déjà avec l'adresse e-mail : " + email);
    }
}