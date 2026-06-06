package com.doit.api.auth;

import java.util.UUID;

public record AuthenticatedUserPrincipal(UUID userId, String username, String displayName) {
}
