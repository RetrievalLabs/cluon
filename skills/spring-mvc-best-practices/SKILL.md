---
name: spring-mvc-best-practices
description: Use this skill when creating, reviewing, upgrading, or modernizing Spring MVC applications, including annotated controllers, REST controllers, request mappings, DTO API contracts, Bean Validation, ControllerAdvice, ExceptionHandler, ProblemDetail, WebMvcConfigurer, path matching, content negotiation, transactions around service operations, javax-to-jakarta migration, virtual-thread evaluation, WebFlux migration decisions, Spring MVC 4 through 7 version upgrades, API versioning, Jackson compatibility, Servlet compatibility, or migration safety.
metadata:
  mcpmarket-version: 1.0.0
---

# Spring MVC Best Practices

Use this skill for Spring MVC application work where HTTP contract stability, thin controllers, framework-version compatibility, and controlled modernization matter.

## Workflow

1. Identify Spring Framework/Spring Boot version, Java version, Servlet/Jakarta level, and existing MVC configuration style.
2. Preserve endpoint paths, HTTP methods, request/response formats, status codes, headers, validation behavior, authorization behavior, and exception semantics unless user requests change.
3. Keep controllers focused on HTTP input, validation, delegation, and response translation.
4. Put business logic in services and persistence logic in repositories.
5. Separate required compatibility fixes from optional modernization.
6. Verify with focused controller, service, integration, serialization, and contract tests based on change risk.

## Reference Routing

- Read `references/core-practices.md` before creating, reviewing, or changing Spring MVC code.
- Read `references/version-guidance.md` before Spring MVC 4.x, 5.x, 5.3+, 6.x, 6.1+, or 7.x migration work.
- Read `references/migration-safety.md` before non-trivial upgrades, rewrites, or reviews that affect public HTTP behavior.

## Guardrails

- Do not introduce unrelated modernization during version migration.
- Do not expose persistence entities as public API contracts without a deliberate reason.
- Do not put transaction boundaries or business workflows in controllers.
- Do not add `@EnableWebMvc` in Spring Boot applications unless intentionally replacing Boot MVC auto-configuration.
- Do not migrate Spring MVC to WebFlux solely for scalability.
- When user asks for latest/current Spring MVC facts, verify official Spring documentation first.

## Composition Guidance

- Spring MVC is available in Spring Boot through the web starter and Boot auto-configuration; Spring MVC and Spring Boot are not mutually exclusive choices.
- Keep Maven and Gradle plugin requirements specific to the selected build tool. Boot's Maven and Gradle plugins are alternatives, not simultaneous requirements.
- Spring MVC can run in JAR or WAR packaging. Check servlet-container and view requirements before declaring a packaging conflict.
