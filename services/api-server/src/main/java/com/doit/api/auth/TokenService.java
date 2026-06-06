package com.doit.api.auth;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import org.springframework.stereotype.Service;

@Service
public class TokenService {

    private static final int TOKEN_SIZE = 32;

    private final AuthProperties authProperties;
    private final SecureRandom secureRandom = new SecureRandom();
    private final ConcurrentMap<String, StoredToken> tokens = new ConcurrentHashMap<>();

    public TokenService(AuthProperties authProperties) {
        this.authProperties = authProperties;
    }

    public IssuedToken issue(UserAccount user) {
        evictExpiredTokens();

        var token = generateToken();
        var expiresAt = Instant.now().plus(authProperties.getTokenTtl());

        tokens.put(
            token,
            new StoredToken(user.getId(), user.getUsername(), user.getDisplayName(), expiresAt)
        );

        return new IssuedToken(token, expiresAt);
    }

    public Optional<AuthenticatedUserPrincipal> resolve(String rawToken) {
        evictExpiredTokens();

        var token = tokens.get(rawToken);
        if (token == null) {
            return Optional.empty();
        }

        if (token.expiresAt().isBefore(Instant.now())) {
            tokens.remove(rawToken);
            return Optional.empty();
        }

        return Optional.of(
            new AuthenticatedUserPrincipal(token.userId(), token.username(), token.displayName())
        );
    }

    public void revoke(String rawToken) {
        tokens.remove(rawToken);
    }

    private void evictExpiredTokens() {
        var now = Instant.now();
        tokens.entrySet().removeIf(entry -> entry.getValue().expiresAt().isBefore(now));
    }

    private String generateToken() {
        var tokenBytes = new byte[TOKEN_SIZE];
        secureRandom.nextBytes(tokenBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);
    }

    private record StoredToken(
        java.util.UUID userId,
        String username,
        String displayName,
        Instant expiresAt
    ) {
    }
}
