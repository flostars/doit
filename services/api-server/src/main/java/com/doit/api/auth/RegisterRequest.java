package com.doit.api.auth;

public record RegisterRequest(String username, String password, String displayName) {
}
