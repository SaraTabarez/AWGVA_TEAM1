package mx.edu.utez.awgva.Utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Objects;

public final class CsrfTokenUtil {

    public static final String SESSION_ATTRIBUTE = "csrfToken";
    public static final String REQUEST_PARAMETER = "csrfToken";
    public static final String REQUEST_HEADER = "X-CSRF-Token";

    private static final int TOKEN_BYTES = 32;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private CsrfTokenUtil() {
    }

    public static String getOrCreate(HttpSession session) {
        Objects.requireNonNull(session, "La sesión es obligatoria.");

        Object storedToken = session.getAttribute(SESSION_ATTRIBUTE);

        if (storedToken instanceof String token && !token.isBlank()) {
            return token;
        }

        return rotate(session);
    }

    public static String rotate(HttpSession session) {
        Objects.requireNonNull(session, "La sesión es obligatoria.");

        byte[] randomBytes = new byte[TOKEN_BYTES];
        SECURE_RANDOM.nextBytes(randomBytes);

        String token = Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(randomBytes);

        session.setAttribute(SESSION_ATTRIBUTE, token);

        return token;
    }

    public static boolean matches(HttpServletRequest request) {
        if (request == null) {
            return false;
        }

        HttpSession session = request.getSession(false);
        String submittedToken = request.getParameter(REQUEST_PARAMETER);

        if (submittedToken == null || submittedToken.isBlank()) {
            submittedToken = request.getHeader(REQUEST_HEADER);
        }

        return matches(session, submittedToken);
    }

    public static boolean matches(HttpSession session, String submittedToken) {
        if (session == null || submittedToken == null || submittedToken.isBlank()) {
            return false;
        }

        Object storedToken = session.getAttribute(SESSION_ATTRIBUTE);

        if (!(storedToken instanceof String expectedToken) || expectedToken.isBlank()) {
            return false;
        }

        byte[] expectedBytes = expectedToken.getBytes(StandardCharsets.UTF_8);
        byte[] submittedBytes = submittedToken.getBytes(StandardCharsets.UTF_8);

        return MessageDigest.isEqual(expectedBytes, submittedBytes);
    }

    public static void invalidate(HttpSession session) {
        if (session != null) {
            session.removeAttribute(SESSION_ATTRIBUTE);
        }
    }
}