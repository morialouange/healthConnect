package com.burundihealthconnect.util;

/**
 * Centralise les noms des attributs stockés dans la HttpSession.
 * Utilisé par FiltreSecurite et tous les Servlets pour éviter les
 * fautes de frappe sur des chaînes dupliquées partout dans le code.
 */
public final class SessionKeys {

    private SessionKeys() {
    }

    /** Long — id de l'utilisateur connecté (jamais l'id patient/medecin directement). */
    public static final String ID_UTILISATEUR = "idUtilisateur";

    /** com.burundihealthconnect.entity.enums.Role — rôle de l'utilisateur connecté. */
    public static final String ROLE = "role";

    /** String â€” code du rÃ´le exposÃ© aux vues JSP (ex. "ADMIN"). */
    public static final String ROLE_CODE = "roleCode";

    /** Long — établissement de l'utilisateur connecté (toujours présent, même pour patient/medecin). */
    public static final String ID_ETABLISSEMENT = "idEtablissement";

    /** Boolean — copie en session de utilisateur.profilComplete, pour éviter une requête DB à chaque page. */
    public static final String PROFIL_COMPLETE = "profilComplete";

    /** String — nom complet affiché dans le header, évite une requête DB juste pour ça. */
    public static final String FULL_NAME = "fullName";

    /**
     * Long — présent UNIQUEMENT si role == PATIENT, id de l'entité Patient
     * (différent de idUtilisateur !). Évite de re-charger Patient à chaque
     * requête juste pour avoir son id.
     */
    public static final String ID_PATIENT = "idPatient";

    /** Long — présent UNIQUEMENT si role == MEDECIN, id de l'entité Medecin. */
    public static final String ID_MEDECIN = "idMedecin";

    /** String — code de langue pour l'internationalisation (ex: "fr", "en"). */
    public static final String LANGUE = "langue";

    /**
     * String — jeton CSRF (protocole synchronizer token) stocké en session.
     * Le même jeton est aussi exposé en attribut de requête "csrfToken" par
     * FiltreSecurite pour être injecté dans les pages (meta name="csrf-token").
     */
    public static final String CSRF_TOKEN = "csrfToken";
}
