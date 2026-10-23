# Spring Security Migration And Review

Use this reference before non-trivial Spring Security upgrades, rewrites, or reviews.

## Migration Workflow

1. Identify current Spring Security, Spring Framework, Spring Boot, Java, Servlet/Jakarta, and dependency versions.
2. Inventory security behavior: public paths, protected paths, roles, authorities, method security, login/logout, sessions, CSRF, CORS, headers, OAuth2/OIDC/SAML/LDAP, custom filters.
3. Add or identify tests for allowed and denied cases before changing behavior.
4. Upgrade within current major to latest patch first where practical.
5. Apply bridge-release migrations before major-version upgrades: `5.8` before `6.x`, `6.5` before `7.x`.
6. Make smallest compatibility changes.
7. Compile and run security tests early.
8. Verify browser and API behavior with realistic clients where relevant.
9. Apply optional modernization only after behavior is preserved.

## Required Compatibility Changes

Examples:

```text
WebSecurityConfigurerAdapter -> SecurityFilterChain
authorizeRequests -> authorizeHttpRequests
antMatchers / mvcMatchers / regexMatchers -> requestMatchers
javax servlet dependencies -> Jakarta-era stack through Spring Framework 6+
old method-security setup -> modern method-security setup
removed session-management APIs -> supported alternatives
deprecated authorization APIs -> AuthorizationManager model
```

## Optional Modernization

Examples:

```text
legacy hash migration -> DelegatingPasswordEncoder with rehashing
custom JWT filter -> OAuth2 Resource Server
custom access-decision code -> AuthorizationManager
XML config -> Java config
manual public endpoint checks -> explicit request matchers
controller authorization -> service method security
```

Apply optional modernization only when it improves correctness, security, maintainability, or compatibility and tests verify behavior.

## Review Checklist

Check:

- Are all endpoints covered by explicit allow/deny rules?
- Is there a secure default for unmatched requests?
- Are public paths intentionally public?
- Are actuator/admin/debug endpoints protected?
- Is server-side authorization preserved?
- Are method-security rules tested?
- Are unannotated service methods still protected through URL or service design where required?
- Is CSRF enabled for browser/session applications?
- Is CSRF disabled only for valid stateless API cases?
- Are CORS rules narrow and environment-appropriate?
- Are password encoders secure and migration-compatible?
- Are secrets excluded from source, logs, error messages, and test fixtures?
- Are JWTs validated by issuer/signature/expiry and audience where required?
- Are authorities mapped consistently from users, roles, groups, scopes, or claims?
- Are session policies deliberate?
- Are logout and session invalidation behavior preserved?
- Are security headers preserved or narrowly customized?
- Are custom filters ordered intentionally?
- Are authentication and authorization failures returning expected status codes or redirects?
- Are tests covering denied access, not only happy paths?

## Testing Targets

Test:

```text
anonymous access
authenticated access
role/authority denied access
method-security denied access
login success
login failure
logout
CSRF missing/invalid/valid token
session timeout or stateless behavior
CORS preflight where relevant
JWT valid/expired/wrong issuer/wrong audience
security headers
custom filters
actuator/admin endpoint access
```

Use Spring Security test support such as `@WithMockUser`, MockMvc security integration, CSRF request post-processors, and resource-server test helpers where appropriate.

## Common Risk Patterns

Avoid:

```java
.requestMatchers("/**").permitAll()
```

unless the entire application is intentionally public.

Avoid:

```java
.csrf(csrf -> csrf.disable())
```

for browser/session applications unless a specific threat-model decision exists.

Avoid custom JWT parsing in controllers. Prefer resource-server support.

Avoid `web.ignoring()` for endpoints that should still receive security headers or CSRF handling. Prefer `permitAll()` for public application endpoints unless static-resource bypass is intentional.

Avoid using production credentials, tokens, or real private keys in tests.

## Security Preservation Rule

If a migration breaks tests, fix the migrated security configuration or tests to represent intended behavior. Do not weaken access control just to make tests pass.
