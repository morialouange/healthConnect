package com.burundihealthconnect.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public final class PasswordHasher {

    private static final int SALT_LENGTH_BYTES = 16;

    private PasswordHasher() {
    }

    public static String hash(String motDePasseClair) {
        byte[] sel = genererSel();
        byte[] hashBytes = hacherAvecSel(motDePasseClair, sel);
        return Base64.getEncoder().encodeToString(sel) + ":" + Base64.getEncoder().encodeToString(hashBytes);
    }

    public static boolean verifier(String motDePasseClair, String hashStocke) {
        if (hashStocke == null) {
            return false;
        }
        if (hashStocke.contains(":")) {
            String[] parties = hashStocke.split(":", 2);
            try {
                byte[] sel = Base64.getDecoder().decode(parties[0]);
                byte[] hashAttendu = Base64.getDecoder().decode(parties[1]);
                byte[] hashCalcule = hacherAvecSel(motDePasseClair, sel);
                return MessageDigest.isEqual(hashAttendu, hashCalcule);
            } catch (IllegalArgumentException e) {
                return false;
            }
        } else {
            try {
                String hashHexCalcule = sha256Hex(motDePasseClair);
                return MessageDigest.isEqual(
                        hashHexCalcule.getBytes("UTF-8"),
                        hashStocke.toLowerCase().getBytes("UTF-8"));
            } catch (java.io.UnsupportedEncodingException e) {
                return false;
            }
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

    private static byte[] genererSel() {
        byte[] sel = new byte[SALT_LENGTH_BYTES];
        new SecureRandom().nextBytes(sel);
        return sel;
    }

    private static byte[] hacherAvecSel(String motDePasseClair, byte[] sel) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.update(sel);
            return digest.digest(motDePasseClair.getBytes("UTF-8"));
        } catch (NoSuchAlgorithmException | java.io.UnsupportedEncodingException e) {
            throw new IllegalStateException("Algorithme de hachage indisponible", e);
        }
    }
}
