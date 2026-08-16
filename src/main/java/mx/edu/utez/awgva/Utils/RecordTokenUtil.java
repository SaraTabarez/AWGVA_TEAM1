package mx.edu.utez.awgva.Utils;

import jakarta.servlet.http.HttpSession;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;

public final class RecordTokenUtil {
    private static final String SESSION_KEY_ATTRIBUTE = RecordTokenUtil.class.getName() + ".SESSION_KEY";
    private static final String ALGORITHM = "AES/GCM/NoPadding";
    private static final int KEY_LENGTH = 32;
    private static final int IV_LENGTH = 12;
    private static final int TAG_LENGTH = 128;
    private static final Duration TOKEN_DURATION = Duration.ofMinutes(30);
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private RecordTokenUtil() {
    }

    public static String issue(HttpSession session, Long userId, String purpose, Long internalId) {
        if (session == null || userId == null || userId < 1 || internalId == null || internalId < 1
                || purpose == null || !purpose.matches("[A-Za-z0-9:_-]{1,80}")) {
            throw new IllegalArgumentException("No fue posible generar la referencia.");
        }

        String payload = purpose + "\n" + internalId + "\n" + userId + "\n"
                + Instant.now().plus(TOKEN_DURATION).getEpochSecond();
        byte[] iv = new byte[IV_LENGTH];
        SECURE_RANDOM.nextBytes(iv);

        try {
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key(session, true), "AES"),
                    new GCMParameterSpec(TAG_LENGTH, iv));
            byte[] encrypted = cipher.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(
                    ByteBuffer.allocate(iv.length + encrypted.length).put(iv).put(encrypted).array());
        } catch (GeneralSecurityException exception) {
            throw new IllegalStateException("No fue posible proteger la referencia.", exception);
        }
    }

    public static Long requireId(HttpSession session, Long userId, String purpose, String token) {
        if (session == null || userId == null || purpose == null || token == null
                || token.isBlank() || token.length() > 600) {
            throw new IllegalArgumentException("La referencia no es válida.");
        }

        try {
            byte[] decoded = Base64.getUrlDecoder().decode(token);
            if (decoded.length <= IV_LENGTH) {
                throw new IllegalArgumentException("La referencia no es válida.");
            }
            byte[] iv = new byte[IV_LENGTH];
            byte[] encrypted = new byte[decoded.length - IV_LENGTH];
            System.arraycopy(decoded, 0, iv, 0, IV_LENGTH);
            System.arraycopy(decoded, IV_LENGTH, encrypted, 0, encrypted.length);

            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(key(session, false), "AES"),
                    new GCMParameterSpec(TAG_LENGTH, iv));
            String[] values = new String(cipher.doFinal(encrypted), StandardCharsets.UTF_8)
                    .split("\\n", -1);
            if (values.length != 4) {
                throw new IllegalArgumentException("La referencia no es válida.");
            }
            long id = Long.parseLong(values[1]);
            long tokenUser = Long.parseLong(values[2]);
            long expiration = Long.parseLong(values[3]);
            if (!purpose.equals(values[0]) || userId.longValue() != tokenUser || id < 1
                    || expiration < Instant.now().getEpochSecond()) {
                throw new IllegalArgumentException("La referencia expiró o no te pertenece.");
            }
            return id;
        } catch (GeneralSecurityException | IllegalArgumentException exception) {
            throw new IllegalArgumentException("La referencia expiró o no es válida.");
        }
    }

    private static byte[] key(HttpSession session, boolean create) {
        Object current = session.getAttribute(SESSION_KEY_ATTRIBUTE);
        if (current instanceof byte[] bytes && bytes.length == KEY_LENGTH) {
            return bytes;
        }
        if (!create) {
            throw new IllegalArgumentException("La referencia expiró o no es válida.");
        }
        synchronized (session) {
            current = session.getAttribute(SESSION_KEY_ATTRIBUTE);
            if (current instanceof byte[] bytes && bytes.length == KEY_LENGTH) {
                return bytes;
            }
            byte[] bytes = new byte[KEY_LENGTH];
            SECURE_RANDOM.nextBytes(bytes);
            session.setAttribute(SESSION_KEY_ATTRIBUTE, bytes);
            return bytes;
        }
    }
}