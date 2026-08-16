package mx.edu.utez.awgva.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;

public class LoginAttemptService {

    private static final int MAX_ATTEMPTS = 5;
    private static final Duration BLOCK_DURATION = Duration.ofMinutes(15);
    private final ConcurrentHashMap<String, Attempt> attempts = new ConcurrentHashMap<>();

    public boolean isBlocked(String key) {
        Attempt attempt = attempts.get(key);

        if (attempt == null) {
            return false;
        }

        if (attempt.blockedUntil() != null
                && attempt.blockedUntil().isAfter(Instant.now())) {
            return true;
        }

        if (attempt.blockedUntil() != null) {
            attempts.remove(key, attempt);
        }

        return false;
    }

    public void recordFailure(String key) {
        attempts.compute(key, (ignored, current) -> {
            int failures = current == null
                    ? 1
                    : current.failures() + 1;

            Instant blockedUntil = failures >= MAX_ATTEMPTS
                    ? Instant.now().plus(BLOCK_DURATION)
                    : null;

            return new Attempt(failures, blockedUntil);
        });
    }

    public void recordSuccess(String key) {
        attempts.remove(key);
    }

    private record Attempt(int failures, Instant blockedUntil) {
    }
}