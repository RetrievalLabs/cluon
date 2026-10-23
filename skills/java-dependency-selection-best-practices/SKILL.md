---
name: java-dependency-selection-best-practices
description: Use this skill when selecting, reviewing, upgrading, or standardizing Java application dependencies, including Spring Boot, Spring Framework, Spring MVC, Spring WebFlux, Spring DI, Jakarta EE APIs, Hibernate ORM, Spring Data JPA, Flyway, Liquibase, Spring Security, Jackson, Jakarta Validation, Hibernate Validator, JUnit 5/Jupiter, Mockito, Testcontainers, AssertJ, SLF4J, Logback, Micrometer, Resilience4j, MapStruct, springdoc-openapi, Maven BOMs, Gradle platforms, Spring Boot dependency management, Java version compatibility, dependency replacement, or incremental library modernization.
metadata:
  mcpmarket-version: 1.0.0
---

# Java Dependency Selection Best Practices

Use this skill to choose mainstream Java dependencies that fit the project's framework generation while preserving behavior and avoiding unnecessary library churn.

## Workflow

1. Identify Java version, framework generation, build tool, runtime, deployment model, and existing dependency-management source.
2. Prefer platform-managed versions: Spring Boot BOM/starters, Jakarta EE runtime APIs, Maven BOMs, or Gradle platforms.
3. Keep compatible generations together; do not mix `javax`-era and Jakarta-era dependencies.
4. Choose boring, widely adopted libraries before niche alternatives unless project constraints require otherwise.
5. Separate required compatibility upgrades from optional dependency modernization.
6. Verify with compile, tests, dependency tree, runtime startup, and representative integration checks.

## Reference Routing

- Read `references/default-catalog.md` when choosing or reviewing common Java dependencies by category.
- Read `references/generation-guidance.md` before Java, Spring Boot, Jakarta EE, Hibernate, Spring Data, JUnit, or Mockito generation changes.
- Read `references/migration-review.md` before replacing libraries, overriding managed versions, or doing dependency cleanup.

## Guardrails

- Do not pin versions manually when Spring Boot or another platform BOM should manage them.
- Do not introduce duplicate libraries for same role without a reason.
- Do not replace stable dependencies only because a newer or trendier option exists.
- Do not upgrade production code to milestone, RC, snapshot, or development releases unless user explicitly targets them.
- When user asks for latest/current dependency facts, verify official project documentation first.
