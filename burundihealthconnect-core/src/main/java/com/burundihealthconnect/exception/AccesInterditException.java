package com.burundihealthconnect.exception;

/**
 * Levée dans plusieurs cas de contrôle d'accès métier :
 * - L11 : tentative d'accès à une ressource d'un AUTRE établissement
 * - L21 : patient tente d'annuler un RDV qui n'est plus RDV_DEMANDE,
 *         ou qui n'est pas le sien
 * - L25 : tentative de modifier le profil d'un AUTRE utilisateur,
 *         ou tentative de modifier un champ non autorisé pour son rôle
 *         (ex. medecin essayant de changer son propre numero_ordre)
 */
public class AccesInterditException extends BusinessException {

    public AccesInterditException(String message) {
        super(message);
    }
}