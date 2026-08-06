package mx.edu.utez.awgva.Service;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.HexFormat;
import java.util.Locale;

/**
 * Genera hashes PBKDF2 con sal aleatoria y permite migrar contraseñas antiguas
 * en texto plano o SHA-256 en el siguiente inicio de sesión exitoso.
 */
public class PasswordService {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final String PREFIX = "pbkdf2";
    private static final int ITERATIONS = 210_000;
    private static final int SALT_BYTES = 16;
    private static final int HASH_BYTES = 32;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    public String hash(String password) {
        if (password == null || password.isBlank()) {
            throw new IllegalArgumentException("La contraseña no puede estar vacía.");
        }

        byte[] salt = new byte[SALT_BYTES];
        SECURE_RANDOM.nextBytes(salt);
        byte[] derivedKey = derive(password.toCharArray(), salt, ITERATIONS, HASH_BYTES);

        return PREFIX + "$" + ITERATIONS + "$"
                + HexFormat.of().formatHex(salt) + "$"
                + HexFormat.of().formatHex(derivedKey);
    }

    public Verification verify(String password, String storedHash) {
        if (password == null || storedHash == null || storedHash.isBlank()) {
            return Verification.invalid();
        }

        if (storedHash.startsWith(PREFIX + "$")) {
            return verifyPbkdf2(password, storedHash);
        }

        // Compatibilidad temporal: las versiones anteriores guardaban texto
        // plano al registrar y SHA-256 al restablecer la contraseña.
        if (storedHash.matches("(?i)^[0-9a-f]{64}$")) {
            byte[] actual = sha256(password);
            byte[] expected = HexFormat.of().parseHex(storedHash.toLowerCase(Locale.ROOT));
            return new Verification(MessageDigest.isEqual(actual, expected), true);
        }

        boolean matchesPlainText = MessageDigest.isEqual(
                password.getBytes(StandardCharsets.UTF_8),
                storedHash.getBytes(StandardCharsets.UTF_8)
        );
        return new Verification(matchesPlainText, true);
    }

    private Verification verifyPbkdf2(String password, String storedHash) {
        try {
            String[] parts = storedHash.split("\\$");
            if (parts.length != 4) {
                return Verification.invalid();
            }

            int iterations = Integer.parseInt(parts[1]);
            if (iterations < 100_000 || iterations > 1_000_000) {
                return Verification.invalid();
            }

            byte[] salt = HexFormat.of().parseHex(parts[2]);
            byte[] expected = HexFormat.of().parseHex(parts[3]);
            byte[] actual = derive(password.toCharArray(), salt, iterations, expected.length);

            return new Verification(
                    MessageDigest.isEqual(actual, expected),
                    iterations < ITERATIONS
            );
        } catch (IllegalArgumentException exception) {
            return Verification.invalid();
        }
    }

    private byte[] derive(char[] password, byte[] salt, int iterations, int bytes) {
        PBEKeySpec specification = new PBEKeySpec(password, salt, iterations, bytes * 8);
        try {
            return SecretKeyFactory.getInstance(ALGORITHM)
                    .generateSecret(specification)
                    .getEncoded();
        } catch (GeneralSecurityException exception) {
            throw new IllegalStateException("No fue posible proteger la contraseña.", exception);
        } finally {
            specification.clearPassword();
        }
    }

    private byte[] sha256(String password) {
        try {
            return MessageDigest.getInstance("SHA-256")
                    .digest(password.getBytes(StandardCharsets.UTF_8));
        } catch (GeneralSecurityException exception) {
            throw new IllegalStateException("SHA-256 no está disponible.", exception);
        }
    }

    public record Verification(boolean valid, boolean needsRehash) {
        public static Verification invalid() {
            return new Verification(false, false);
        }
    }
}
