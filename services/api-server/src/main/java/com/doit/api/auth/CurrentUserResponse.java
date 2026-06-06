package com.doit.api.auth;

import java.time.Instant;
import java.util.UUID;

public record CurrentUserResponse(
    UUID userId,
    String username,
    String displayName,
    Instant registeredAt
) {
}
