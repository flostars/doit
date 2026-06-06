package com.doit.api.auth;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.emptyOrNullString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:auth-flow;DB_CLOSE_DELAY=-1",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "doit.auth.bootstrap-user.username=",
    "doit.auth.bootstrap-user.password=",
    "doit.auth.bootstrap-user.display-name=",
    "doit.auth.token-ttl=PT8H"
})
class AuthFlowIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserAccountRepository userAccountRepository;

    @BeforeEach
    void clearUsers() {
        userAccountRepository.deleteAll();
    }

    @Test
    void registersUserAndReturnsAccessToken() throws Exception {
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "username": "new.user@doit.local",
                      "password": "SecurePass123!",
                      "displayName": "New User"
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(header().doesNotExist(HttpHeaders.WWW_AUTHENTICATE))
            .andExpect(jsonPath("$.displayName").value("New User"))
            .andExpect(jsonPath("$.username").value("new.user@doit.local"))
            .andExpect(jsonPath("$.userId", not(emptyOrNullString())))
            .andExpect(jsonPath("$.accessToken", not(emptyOrNullString())))
            .andExpect(jsonPath("$.expiresAt").exists());
    }

    @Test
    void rejectsDuplicateRegistration() throws Exception {
        registerDefaultUser();

        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "username": "new.user@doit.local",
                      "password": "SecurePass123!",
                      "displayName": "New User"
                    }
                    """))
            .andExpect(status().isConflict());
    }

    @Test
    void logsInRegisteredUser() throws Exception {
        registerDefaultUser();

        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "username": "new.user@doit.local",
                      "password": "SecurePass123!"
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("new.user@doit.local"))
            .andExpect(jsonPath("$.displayName").value("New User"))
            .andExpect(jsonPath("$.accessToken", not(emptyOrNullString())));
    }

    @Test
    void rejectsInvalidCredentials() throws Exception {
        registerDefaultUser();

        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "username": "new.user@doit.local",
                      "password": "WrongPass123!"
                    }
                    """))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void protectsCurrentUserEndpoint() throws Exception {
        mockMvc.perform(get("/api/v1/users/me"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void protectsLogoutEndpoint() throws Exception {
        mockMvc.perform(post("/api/v1/auth/logout"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void returnsCurrentUserForValidBearerToken() throws Exception {
        var accessToken = registerAndExtractAccessToken();

        mockMvc.perform(get("/api/v1/users/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("new.user@doit.local"))
            .andExpect(jsonPath("$.displayName").value("New User"))
            .andExpect(jsonPath("$.registeredAt").exists());
    }

    @Test
    void logoutRevokesBearerToken() throws Exception {
        var accessToken = registerAndExtractAccessToken();

        mockMvc.perform(post("/api/v1/auth/logout")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken))
            .andExpect(status().isNoContent());

        mockMvc.perform(get("/api/v1/users/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken))
            .andExpect(status().isUnauthorized());
    }

    private void registerDefaultUser() throws Exception {
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "username": "new.user@doit.local",
                      "password": "SecurePass123!",
                      "displayName": "New User"
                    }
                    """))
            .andExpect(status().isCreated());
    }

    private String registerAndExtractAccessToken() throws Exception {
        var registrationResult = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "username": "new.user@doit.local",
                      "password": "SecurePass123!",
                      "displayName": "New User"
                    }
                    """))
            .andExpect(status().isCreated())
            .andReturn();

        var responseBody = registrationResult.getResponse().getContentAsString();
        return responseBody.replaceAll(".*\"accessToken\":\"([^\"]+)\".*", "$1");
    }
}
