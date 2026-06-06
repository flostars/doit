package com.doit.api.auth;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "doit.auth")
public class AuthProperties {

    private Duration tokenTtl = Duration.ofHours(8);
    private final BootstrapUser bootstrapUser = new BootstrapUser();

    public Duration getTokenTtl() {
        return tokenTtl;
    }

    public void setTokenTtl(Duration tokenTtl) {
        this.tokenTtl = tokenTtl;
    }

    public BootstrapUser getBootstrapUser() {
        return bootstrapUser;
    }

    public static class BootstrapUser {

        private String username = "demo@doit.local";
        private String password = "ChangeMe123!";
        private String displayName = "Demo User";

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }

        public String getDisplayName() {
            return displayName;
        }

        public void setDisplayName(String displayName) {
            this.displayName = displayName;
        }
    }
}
