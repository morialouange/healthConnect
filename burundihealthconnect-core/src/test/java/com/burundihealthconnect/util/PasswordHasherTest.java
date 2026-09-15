package com.burundihealthconnect.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Base64;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests unitaires pour PasswordHasher.
 *
 * La couverture porte sur les trois formats de stockage supportés :
 *   1. Bcrypt (format natif actuel)
 *   2. Ancien format salé  base64(sel):base64(hash SHA-256)
 *   3. Ancien format hex   SHA2(password, 256) du script de données de test
 */
class PasswordHasherTest {

    // =============================================================
    // BCrypt
    // =============================================================

    @Test
    @DisplayName("hash() produit un hash bcrypt de 60 caractères")
    void hashProduitUnHashBcrypt() {
        String hash = PasswordHasher.hash("motDePasse123");

        assertNotNull(hash);
        assertTrue(hash.startsWith("$2a$"), "Le hash doit commencer par $2a$");
        // bcrypt 2a produit toujours 60 caractères
        assertEquals(60, hash.length());
    }

    @Test
    @DisplayName("hash() est déterministe dans la validation (sel aléatoire donc hash différent à chaque appel)")
    void hashEstAleatoire() {
        String h1 = PasswordHasher.hash("memeMotDePasse");
        String h2 = PasswordHasher.hash("memeMotDePasse");

        // Chaque appel génère un sel différent
        assertNotEquals(h1, h2);
        // Mais les deux valident le bon mot de passe
        assertTrue(PasswordHasher.verifier("memeMotDePasse", h1));
        assertTrue(PasswordHasher.verifier("memeMotDePasse", h2));
    }

    @Test
    @DisplayName("verifier() retourne true avec un mot de passe valide (bcrypt)")
    void verifierMotDePasseValide() {
        String hash = PasswordHasher.hash("secret123");

        assertTrue(PasswordHasher.verifier("secret123", hash));
    }

    @Test
    @DisplayName("verifier() retourne false avec un mot de passe invalide (bcrypt)")
    void verifierMotDePasseInvalide() {
        String hash = PasswordHasher.hash("secret123");

        assertFalse(PasswordHasher.verifier("autreMotDePasse", hash));
    }

    // =============================================================
    // Ancien format salé (base64:base64)
    // =============================================================

    @Test
    @DisplayName("verifier() accepte l'ancien format salé base64(sel):base64(hash)")
    void verifierAncienFormatSale() {
        // Arrange : on construit manuellement un hash du vieux format
        byte[] sel = new byte[]{1, 2, 3, 4, 5, 6, 7, 8};
        String motDePasse = "ancienSecret";
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            digest.update(sel);
            byte[] hashBytes = digest.digest(motDePasse.getBytes("UTF-8"));
            String ancienHash = Base64.getEncoder().encodeToString(sel)
                    + ":"
                    + Base64.getEncoder().encodeToString(hashBytes);

            assertTrue(PasswordHasher.verifier(motDePasse, ancienHash));
            assertFalse(PasswordHasher.verifier("mauvaisMotDePasse", ancienHash));
        } catch (Exception e) {
            fail("Algorithme de hachage indisponible", e);
        }
    }

    @Test
    @DisplayName("verifier() retourne false pour un format colonne malformé")
    void verifierFormatColonneMalforme() {
        assertFalse(PasswordHasher.verifier("test", "base64Invalid:"));
    }

    // =============================================================
    // Ancien format hex (SHA2 du script SQL)
    // =============================================================

    @Test
    @DisplayName("verifier() accepte le hash hex SHA256 du script de seed SQL")
    void verifierHexSha256SeedSql() {
        // SHA2('admin123', 256) en hexadécimal
        String hashHexAdmin123 =
                "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9";

        assertTrue(PasswordHasher.verifier("admin123", hashHexAdmin123));
        assertFalse(PasswordHasher.verifier("mauvais", hashHexAdmin123));
    }

    @Test
    @DisplayName("verifier() accepte le hash hex SHA256 avec mélange casse (majuscule/minuscule)")
    void verifierHexSha256CasInsensible() {
        String hashHexMajuscule =
                "240BE518FABD2724DDB6F04EEB1DA5967448D7E831C08C8FA822809F74C720A9";

        assertTrue(PasswordHasher.verifier("admin123", hashHexMajuscule));
    }

    // =============================================================
    // estBcrypt()
    // =============================================================

    @Test
    @DisplayName("estBcrypt() identifie correctement un hash bcrypt")
    void estBcryptTrue() {
        String hash = PasswordHasher.hash("test");
        assertTrue(PasswordHasher.estBcrypt(hash));
        assertTrue(PasswordHasher.estBcrypt("$2a$10$abcdefghijklmnopqrstuu12345678901234567890"));
        assertTrue(PasswordHasher.estBcrypt("$2b$10$abcdefghijklmnopqrstuu12345678901234567890"));
        assertTrue(PasswordHasher.estBcrypt("$2y$10$abcdefghijklmnopqrstuu12345678901234567890"));
    }

    @Test
    @DisplayName("estBcrypt() retourne false pour les anciens formats")
    void estBcryptFalse() {
        assertFalse(PasswordHasher.estBcrypt("240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9"));
        assertFalse(PasswordHasher.estBcrypt("dGVzdHNlbHQ6aGFzaA=="));
        assertFalse(PasswordHasher.estBcrypt(null));
        assertFalse(PasswordHasher.estBcrypt(""));
    }

    // =============================================================
    // Cas limites
    // =============================================================

    @Test
    @DisplayName("verifier() retourne false si le hash stocké est null")
    void verifierHashNull() {
        assertFalse(PasswordHasher.verifier("test", null));
    }

    @Test
    @DisplayName("hash() fonctionne avec un mot de passe vide (même si déconseillé)")
    void hashMotDePasseVide() {
        String hash = PasswordHasher.hash("");
        assertNotNull(hash);
        assertTrue(PasswordHasher.verifier("", hash));
    }

    @Test
    @DisplayName("hash() fonctionne avec un mot de passe très long (>72 octets, tronqué par bcrypt)")
    void hashMotDePasseLong() {
        String motDePasseLong = "a".repeat(100);
        String hash = PasswordHasher.hash(motDePasseLong);
        assertNotNull(hash);
        assertTrue(PasswordHasher.verifier(motDePasseLong, hash));
    }
}
