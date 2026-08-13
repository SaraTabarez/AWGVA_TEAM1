package mx.edu.utez.awgva.Utils;

import jakarta.servlet.http.HttpSession;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/** Token CSRF asociado a la sesión. */
public final class CsrfTokenUtil {

    public static final String SESSION_ATTRIBUTE = "csrfToken";
    public static final String PARAMETER_NAME = "csrfToken";
    public static final String HEADER_NAME = "X-CSRF-Token";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private CsrfTokenUtil() {
    }

    public static String getOrCreate(HttpSession session) {
        if (session == null) {
            throw new IllegalArgumentException("La sesión es obligatoria.");
        }
        Object value = session.getAttribute(SESSION_ATTRIBUTE);
        if (value instanceof String token && !token.isBlank()) {
            return token;
        }
        synchronized (session) {
            value = session.getAttribute(SESSION_ATTRIBUTE);
            if (value instanceof String token && !token.isBlank()) {
                return token;
            }
            return rotate(session);
        }
    }

    public static String rotate(HttpSession session) {
        byte[] random = new byte[32];
        SECURE_RANDOM.nextBytes(random);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(random);
        session.setAttribute(SESSION_ATTRIBUTE, token);
        return token;
    }

    public static boolean matches(HttpSession session, String submittedToken) {
        if (session == null || submittedToken == null) {
            return false;
        }

        Object expectedToken = session.getAttribute(SESSION_ATTRIBUTE);
        if (!(expectedToken instanceof String expected)) {
            return false;
        }

        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                submittedToken.getBytes(StandardCharsets.UTF_8)
        );
    }
}
