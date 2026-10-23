---
name: spring-security-best-practices
description: Use this skill when creating, reviewing, upgrading, or modernizing Spring Security applications, including SecurityFilterChain, HttpSecurity, WebSecurityConfigurerAdapter migration, authorizeRequests to authorizeHttpRequests migration, request matchers, AuthenticationManager, UserDetailsService, PasswordEncoder, DelegatingPasswordEncoder, CSRF, CORS, sessions, stateless APIs, OAuth2 login, OAuth2 resource servers, JWT, opaque tokens, method security, @PreAuthorize, AuthorizationManager, security headers, servlet filter chains, Spring Boot security auto-configuration, Spring Security 4 through 7 upgrades, Spring Boot 2 to 3 or 4 security migration, or security test coverage.
metadata:
  mcpmarket-version: 1.0.0
---

# Spring Security Best Practices

Use this skill for Spring Security work where authentication, authorization, exploit protection, HTTP contract stability, and framework-version compatibility matter.

## Workflow

1. Identify Spring Security, Spring Framework, Spring Boot, Java, Servlet/Jakarta, and authentication/authorization model.
2. Preserve existing access rules, login/logout behavior, sessions, CSRF behavior, headers, OAuth claims, and method-security semantics unless user requests change.
3. Separate required compatibility fixes from optional security modernization.
4. Prefer explicit `SecurityFilterChain` beans and narrowly scoped authorization rules for modern code.
5. Keep server-side authorization authoritative; never rely only on frontend checks.
6. Verify allowed and denied paths, authentication flows, CSRF/session behavior, method security, and security headers.

## Reference Routing

- Read `references/core-practices.md` before creating, reviewing, or changing Spring Security code.
- Read `references/version-guidance.md` before Spring Security 4.x, 5.x, 5.8, 6.x, 6.5, 7.x, or Boot generation migration work.
- Read `references/migration-review.md` before non-trivial upgrades, rewrites, or security reviews.

## Guardrails

- Do not weaken authorization, disable CSRF, or permit broad paths to fix tests or migrations.
- Do not replace stateful browser security with stateless API security unless application behavior requires it.
- Do not store plaintext passwords or use `NoOpPasswordEncoder` outside tests or deliberate legacy transition code.
- Do not log passwords, tokens, authorization headers, session IDs, credentials, or sensitive claims.
- When user asks for latest/current Spring Security facts, verify official Spring documentation first.
