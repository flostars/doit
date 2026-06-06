package com.doit.api.auth;

import java.time.Instant;
import java.util.UUID;

public record AuthResponse(
    String accessToken,
    Instant expiresAt,
    UUID userId,
    String username,
    String displayName
) {
}
