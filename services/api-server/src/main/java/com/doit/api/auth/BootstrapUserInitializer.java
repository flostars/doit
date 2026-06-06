package com.doit.api.auth;

import java.time.Instant;
import java.util.Locale;
import java.util.UUID;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
public class BootstrapUserInitializer implements ApplicationRunner {

    private final AuthProperties authProperties;
    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;

    public BootstrapUserInitializer(
        AuthProperties authProperties,
        UserAccountRepository userAccountRepository,
        PasswordEncoder passwordEncoder
    ) {
        this.authProperties = authProperties;
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(ApplicationArguments args) {
        var bootstrapUser = authProperties.getBootstrapUser();
        if (
            !StringUtils.hasText(bootstrapUser.getUsername()) ||
            !StringUtils.hasText(bootstrapUser.getPassword()) ||
            !StringUtils.hasText(bootstrapUser.getDisplayName())
        ) {
            return;
        }

        var normalizedUsername = bootstrapUser.getUsername().trim().toLowerCase(Locale.ROOT);
        if (userAccountRepository.existsByUsernameIgnoreCase(normalizedUsername)) {
            return;
        }

        userAccountRepository.save(
            new UserAccount(
                UUID.randomUUID(),
                normalizedUsername,
                passwordEncoder.encode(bootstrapUser.getPassword()),
                bootstrapUser.getDisplayName().trim(),
                Instant.now()
            )
        );
    }
}
