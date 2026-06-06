package com.doit.api.auth;

import java.time.Instant;
import java.util.Locale;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

    private static final int MIN_PASSWORD_LENGTH = 8;

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;

    public AuthService(
        UserAccountRepository userAccountRepository,
        PasswordEncoder passwordEncoder,
        TokenService tokenService
    ) {
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenService = tokenService;
    }

    public AuthResponse login(LoginRequest request) {
        var username = normalizeUsername(request.username());
        var password = requirePassword(request.password());

        var user = userAccountRepository.findByUsernameIgnoreCase(username)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials."));

        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials.");
        }

        return createAuthResponse(user);
    }

    public AuthResponse register(RegisterRequest request) {
        var username = normalizeUsername(request.username());
        var password = requirePassword(request.password());
        var displayName = requireDisplayName(request.displayName());

        if (userAccountRepository.existsByUsernameIgnoreCase(username)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User with this email already exists.");
        }

        var user = userAccountRepository.save(
            new UserAccount(
                UUID.randomUUID(),
                username,
                passwordEncoder.encode(password),
                displayName,
                Instant.now()
            )
        );

        return createAuthResponse(user);
    }

    public CurrentUserResponse currentUser(UUID userId) {
        var user = userAccountRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        return new CurrentUserResponse(
            user.getId(),
            user.getUsername(),
            user.getDisplayName(),
            user.getRegisteredAt()
        );
    }

    public void logout(String accessToken) {
        if (!StringUtils.hasText(accessToken)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Access token is required.");
        }

        tokenService.revoke(accessToken);
    }

    private AuthResponse createAuthResponse(UserAccount user) {
        var issuedToken = tokenService.issue(user);
        return new AuthResponse(
            issuedToken.value(),
            issuedToken.expiresAt(),
            user.getId(),
            user.getUsername(),
            user.getDisplayName()
        );
    }

    private String normalizeUsername(String username) {
        if (!StringUtils.hasText(username)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username is required.");
        }

        return username.trim().toLowerCase(Locale.ROOT);
    }

    private String requirePassword(String password) {
        if (!StringUtils.hasText(password)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password is required.");
        }

        if (password.length() < MIN_PASSWORD_LENGTH) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Password must be at least 8 characters long."
            );
        }

        return password;
    }

    private String requireDisplayName(String displayName) {
        if (!StringUtils.hasText(displayName)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Display name is required.");
        }

        return displayName.trim();
    }
}
