---
name: spring-boot-best-practices
description: Use this skill when creating, reviewing, or modernizing Spring Boot 2.2 through 4.1 applications, including controllers, services, DTOs, validation, exception handling, transactions, JPA/Hibernate performance, dependency management, typed configuration, secrets, Spring Security, observability, external call timeouts, retries, MVC versus WebFlux, async execution, tests, feature package organization, Spring extension points, javax-to-jakarta migration, or Spring Boot generation compatibility.
metadata:
  mcpmarket-version: 1.0.0
---

# Spring Boot Best Practices

Use this skill for Spring Boot application changes across Spring Boot 2.2 through 4.1. Prefer simple, explicit, testable, secure, observable, and maintainable code that fits the target Spring Boot generation.

## Workflow

1. Identify Spring Boot generation, Java version, build tool, and existing project style.
2. Preserve current behavior unless user asks for a behavior change.
3. Apply only practices relevant to touched code.
4. Keep controllers thin; put business behavior in services or domain code.
5. Keep framework-generation boundaries explicit, especially `javax.*` versus `jakarta.*`.
6. Verify with focused unit, slice, integration, or build checks based on change risk.

## Reference Routing

- Read `references/spring-boot-practices.md` before making non-trivial Spring Boot changes or reviews.
- Use the reference sections matching touched areas: web, validation, persistence, security, configuration, observability, external calls, async, tests, package organization, migration.

## Guardrails

- Do not modernize only to use newer annotations or APIs.
- Do not weaken authorization to fix tests or framework upgrade errors.
- Do not expose JPA entities directly from APIs.
- Do not add abstractions, configuration, or retries unless required by current behavior or request.
- Do not blindly replace every `javax.*`; JDK packages such as `javax.sql`, `javax.crypto`, and `javax.xml` remain valid.
