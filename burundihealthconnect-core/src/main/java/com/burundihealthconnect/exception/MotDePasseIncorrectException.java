package com.burundihealthconnect.exception;

/**
 * L25 — Levée par ProfilService.changerMotDePasse() quand l'ancien
 * mot de passe fourni ne correspond pas au hash stocké en base.
 */
public class MotDePasseIncorrectException extends BusinessException {

    public MotDePasseIncorrectException() {
        super("L'ancien mot de passe est incorrect.");
    }
}