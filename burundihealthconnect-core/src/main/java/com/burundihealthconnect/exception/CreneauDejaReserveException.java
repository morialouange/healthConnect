package com.burundihealthconnect.exception;

/**
 * L14 — Levée par DisponibiliteService.reserverCreneau() quand deux
 * patients tentent de réserver le même créneau en concurrence.
 * La méthode doit vérifier creneau.disponible == true à l'intérieur
 * de la même transaction juste avant l'écriture pour garantir l'atomicité.
 */
public class CreneauDejaReserveException extends BusinessException {

    public CreneauDejaReserveException(Long idCreneau) {
        super("Le créneau #" + idCreneau + " vient d'être réservé par un autre patient. "
                + "Veuillez en choisir un autre.");
    }
}