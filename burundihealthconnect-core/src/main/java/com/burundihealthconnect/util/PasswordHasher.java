package com.burundihealthconnect.util;

import org.mindrot.jbcrypt.BCrypt;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

/**
 * Hachage de mots de passe.
 *
 * <p>Le format de stockage natif est désormais <b>bcrypt</b> (via jBCrypt),
 * beaucoup plus robuste que SHA-256 contre les attaques par force brute.
 * Un hash bcrypt commence par le préfixe {@code $2a$}, {@code $2b$} ou {@code $2y$}.</p>
 *
 * <p>Pour permettre une migration progressive sans casser les comptes existants,
 * {@link #verifier(String, String)} accepte aussi les deux anciens formats :</p>
 * <ul>
 *   <li>l'ancien hash salé produit par SHA-256 ({@code base64(sel):base64(hash)}) ;</li>
 *   <li>le hash hexadécimal simple {@code SHA2(password, 256)} issu du script de
 *       données de test SQL.</li>
 * </ul>
 *
 * <p>Lorsqu'un utilisateur se connecte avec un ancien hash, la logique métier
 * ({@code AuthService}) peut le ré-hacher en bcrypt à la volée via
 * {@link #estBcrypt(String)}.</p>
 */
public final class PasswordHasher {

    /** Nombre de tours de dérivation bcrypt. 10 est un bon compromis en 2024+. */
    private static final int LOG_ROUNDS = 10;

    private PasswordHasher() {
    }

    /**
     * Produit un hash bcrypt du mot de passe en clair.
     * Chaque appel génère un sel aléatoire, donc deux appels pour un même
     * mot de passe produisent deux hashs différents.
     */
    public static String hash(String motDePasseClair) {
        return BCrypt.hashpw(motDePasseClair, BCrypt.gensalt(LOG_ROUNDS));
    }

    /**
     * Vérifie un mot de passe en clair contre un hash stocké.
     * Supporte le format bcrypt (natif) ainsi que les anciens formats SHA-256
     * afin de ne pas invalider les comptes créés avant la migration.
     */
    public static boolean verifier(String motDePasseClair, String hashStocke) {
        if (hashStocke == null) {
            return false;
        }
        if (estBcrypt(hashStocke)) {
            return BCrypt.checkpw(motDePasseClair, hashStocke);
        }
        if (hashStocke.contains(":")) {
            // Ancien format salé : base64(sel):base64(hash SHA-256)
            return verifierAncienFormatSale(motDePasseClair, hashStocke);
        }
        // Ancien format hex simple : SHA2(password, 256) du script de test
        return verifierHexSha256(motDePasseClair, hashStocke);
    }

    /** Indique si le hash stocké est au format bcrypt. */
    public static boolean estBcrypt(String hashStocke) {
        return hashStocke != null
                && (hashStocke.startsWith("$2a$") || hashStocke.startsWith("$2b$") || hashStocke.startsWith("$2y$"));
    }

    private static boolean verifierAncienFormatSale(String motDePasseClair, String hashStocke) {
        String[] parties = hashStocke.split(":", 2);
        try {
            byte[] sel = Base64.getDecoder().decode(parties[0]);
            byte[] hashAttendu = Base64.getDecoder().decode(parties[1]);
            byte[] hashCalcule = sha256AvecSel(motDePasseClair, sel);
            return MessageDigest.isEqual(hashAttendu, hashCalcule);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    private static boolean verifierHexSha256(String motDePasseClair, String hashStocke) {
        try {
            String hashHexCalcule = sha256Hex(motDePasseClair);
            return MessageDigest.isEqual(
                    hashHexCalcule.getBytes("UTF-8"),
                    hashStocke.toLowerCase().getBytes("UTF-8"));
        } catch (java.io.UnsupportedEncodingException e) {
            return false;
        }
    }

    private static String sha256Hex(String motDePasseClair) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(motDePasseClair.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException | java.io.UnsupportedEncodingException e) {
            throw new IllegalStateException("Algorithme de hachage indisponible", e);
        }
    }

    private static byte[] sha256AvecSel(String motDePasseClair, byte[] sel) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.update(sel);
            return digest.digest(motDePasseClair.getBytes("UTF-8"));
        } catch (NoSuchAlgorithmException | java.io.UnsupportedEncodingException e) {
            throw new IllegalStateException("Algorithme de hachage indisponible", e);
        }
    }
}
