package com.burundihealthconnect.exception;

import jakarta.ejb.ApplicationException;

/**
 * Exception métier de base de l'application.
 * Annotée @ApplicationException(rollback=true) afin que le conteneur EJB
 * NE LA TRANSFORME PAS en EJBException (exception système) et déclenche
 * bien le rollback de la transaction JTA en cours.
 * Toutes les exceptions métier (doublon, accès refusé, etc.) héritent
 * de celle-ci.
 */
@ApplicationException(rollback = true)
public class BusinessException extends RuntimeException {

    public BusinessException(String message) {
        super(message);
    }

    public BusinessException(String message, Throwable cause) {
        super(message, cause);
    }
}