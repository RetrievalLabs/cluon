# Spring Security Core Practices

Use these practices for Spring Security applications across supported framework generations.

## Preserve Security Behavior First

During a security upgrade, preserve observable behavior unless a behavior change is explicitly required.

Preserve:

- URL access rules,
- method-security rules,
- login and logout behavior,
- session creation policy,
- CSRF behavior,
- CORS behavior,
- security headers,
- OAuth2/OIDC client behavior,
- JWT or opaque token validation behavior,
- authorities and role mapping,
- error status codes and redirects.

Do not combine a Spring Security version migration with unrelated authentication redesign.

## Prefer Explicit Modern Configuration

For modern Spring Security, prefer component-based configuration with `SecurityFilterChain`:

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers("/actuator/health").permitAll()
                        .anyRequest().authenticated())
                .build();
    }
}
```

Use narrowly scoped rules. Avoid broad catch-all `permitAll()` except for intentionally public applications.

## Keep Authorization Server-Side

Frontend route checks improve user experience but are not authorization.

Enforce access through:

- URL-level authorization in `HttpSecurity`,
- method-level authorization such as `@PreAuthorize`,
- domain/service authorization for object-level rules.

Example:

```java
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) {
    ...
}
```

When annotation-based method security is used, remember that unannotated methods are not secured by the annotation. Keep appropriate catch-all URL rules.

## Use Method Security For Fine-Grained Rules

Use request-level authorization for coarse URL access and method security for fine-grained service rules.

Prefer `@PreAuthorize` where authorization depends on method arguments, domain identity, or service operation semantics.

Test both allowed and denied cases:

```java
@WithMockUser(roles = "ADMIN")
@Test
void deleteUserWithAdminRoleAllowsAccess() {
    service.deleteUser(1L);
}

@WithMockUser(roles = "USER")
@Test
void deleteUserWithUserRoleDeniesAccess() {
    assertThatExceptionOfType(AccessDeniedException.class)
            .isThrownBy(() -> service.deleteUser(1L));
}
```

## Password Storage

Use `PasswordEncoder` and prefer `DelegatingPasswordEncoder` for upgradeable password storage:

```java
@Bean
PasswordEncoder passwordEncoder() {
    return PasswordEncoderFactories.createDelegatingPasswordEncoder();
}
```

Do not store plaintext passwords. Do not use `NoOpPasswordEncoder` outside tests or deliberate short-lived legacy transition code.

When migrating legacy hashes, support old encodings long enough to verify existing users can authenticate, then rehash on successful login where practical.

## CSRF

Spring Security enables CSRF protection by default for unsafe browser requests.

Do not disable CSRF merely because tests fail.

Keep CSRF enabled for browser-backed session applications. For stateless APIs that do not use browser cookies for authentication, disabling CSRF may be valid but should be explicit and documented.

For SPAs using cookie-backed authentication, configure CSRF token exposure and refresh behavior deliberately. Verify login, logout, token refresh, and unsafe methods such as `POST`, `PUT`, `PATCH`, and `DELETE`.

## Sessions And Stateless APIs

Choose session behavior based on authentication model.

Use sessions for form-login/browser applications when server-side session state is part of behavior.

Use stateless policy for bearer-token APIs:

```java
http.sessionManagement(session -> session
        .sessionCreationPolicy(SessionCreationPolicy.STATELESS));
```

Do not convert stateful browser applications to stateless APIs during version migration unless required.

## OAuth2 Resource Servers

For APIs protected by bearer tokens, prefer Spring Security OAuth2 Resource Server support.

Use JWT when resource server can validate signed tokens locally. Use opaque-token introspection when token validation must call authorization server.

Verify:

- issuer,
- audience where required,
- signature keys or introspection endpoint,
- clock skew,
- authority/role claim mapping,
- token expiry behavior,
- unauthorized and forbidden response semantics.

Do not parse JWTs manually in controllers or filters when Resource Server support satisfies the requirement.

## Security Headers

Keep default security headers unless there is a deliberate compatibility reason.

Customize headers narrowly:

```java
http.headers(headers -> headers
        .frameOptions(frameOptions -> frameOptions.sameOrigin()));
```

Do not disable all security headers to fix one integration. Adjust only the header causing the issue and test browser behavior.

## Custom Filters

Spring Security is filter-based. Add custom filters only when existing authentication, authorization, CSRF, headers, session, OAuth2, or bearer-token support cannot model the requirement.

When adding filters, place them intentionally relative to built-in filters. Verify authentication context, exception handling, and authorization still behave correctly.

## Logging And Secrets

Never log:

- passwords,
- bearer tokens,
- authorization headers,
- refresh tokens,
- session IDs,
- client secrets,
- private keys,
- sensitive identity claims.

Use structured audit logs for important security events without exposing credentials.
