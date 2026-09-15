package com.burundihealthconnect.exception;

/**
 * Exception générique levée par tous les Session Beans quand un
 * EntityManager.find() retourne null pour un identifiant donné
 * (ex. medecinService.getMedecinDetail(id) avec id inexistant).
 */
public class EntiteIntrouvableException extends BusinessException {

    public EntiteIntrouvableException(String entite, Long id) {
        super(entite + " introuvable avec l'identifiant : " + id);
    }

    public EntiteIntrouvableException(String entite, String id) {
        super(entite + " introuvable avec l'identifiant : " + id);
    }
}