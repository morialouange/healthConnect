package com.burundihealthconnect.exception;

/**
 * L20 — Levée par RendezVousService.verifierLimiteRdv() quand le patient
 * a déjà 2 RDV actifs (statut RDV_DEMANDE ou RDV_CONFIRME) pour la même
 * journée, avant la création d'un nouveau.
 */
public class LimiteRdvAtteintException extends BusinessException {

    public LimiteRdvAtteintException() {
        super("Vous avez déjà atteint la limite de 2 rendez-vous pour cette journée.");
    }
}