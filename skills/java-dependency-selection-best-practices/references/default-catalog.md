# Java Dependency Default Catalog

Use this as a conservative default catalog for mainstream Java applications. Prefer project conventions and managed platform versions over hard-coded versions.

## Application Framework

Default: Spring Boot.

Use Spring Boot for most new Spring applications because it provides dependency management, auto-configuration, Actuator integration, testing support, and production defaults.

Prefer starters instead of raw dependency sets:

```text
spring-boot-starter-web
spring-boot-starter-validation
spring-boot-starter-data-jpa
spring-boot-starter-security
spring-boot-starter-actuator
spring-boot-starter-test
```

Use plain Spring Framework only when application explicitly avoids Boot auto-configuration or runs inside another managed container.

Use Jakarta EE APIs and a Jakarta EE runtime when project is container-first and portability across compatible application servers matters.

## Web / REST

Default for synchronous applications: Spring MVC through `spring-boot-starter-web`.

Use Spring MVC when application uses blocking stacks such as JDBC, JPA, Hibernate, Servlet filters, traditional MVC integrations, or blocking SDKs.

Use Spring WebFlux through `spring-boot-starter-webflux` only when reactive/non-blocking I/O is a real requirement and dependencies are non-blocking end to end.

Use Jakarta REST when building Jakarta EE container applications.

Do not add both Spring MVC and WebFlux without understanding auto-configuration and runtime behavior.

## Server-Side Templates

Default JSP replacement for Spring MVC applications: Thymeleaf `3.1.5.RELEASE`.

Use Thymeleaf when migrating JSP views in Spring MVC applications and template
behavior can be preserved without keeping JSP-specific runtime features.

## Dependency Injection

Default in Spring applications: Spring DI.

Use constructor injection for required dependencies. Avoid field injection.

Default in Jakarta EE applications: CDI.

Do not introduce a second DI container such as Guice into Spring/Jakarta applications unless legacy architecture requires it.

## Database / ORM

Default ORM implementation in Spring Boot JPA applications: Hibernate ORM through `spring-boot-starter-data-jpa`.

Default repository abstraction: Spring Data JPA when repository boilerplate can be reduced without hiding important queries.

Use Jakarta Persistence/JPA APIs for portable persistence contracts:

```java
import jakarta.persistence.Entity;
import jakarta.persistence.EntityManager;
```

Use Hibernate-specific APIs only when provider-specific behavior is actually required.

For simple JDBC workloads or performance-sensitive SQL-first services, use Spring JDBC or jOOQ instead of forcing ORM.

## Database Migrations

Default: Flyway for SQL-first, linear migrations.

Use Flyway when migrations are mostly SQL scripts and straightforward versioned schema changes:

```text
V1__create_users.sql
V2__add_email_index.sql
```

Use Liquibase when project needs database-agnostic changelogs, XML/YAML/JSON changelog workflows, rollback metadata, or richer change management.

Do not rely on `spring.jpa.hibernate.ddl-auto=update` for production schema evolution.

## Security

Default for Spring applications: Spring Security.

Use Spring Security for authentication, authorization, CSRF, headers, session management, OAuth2 login, resource server JWT/opaque token support, and method security.

Prefer `SecurityFilterChain` in modern applications. Do not use frontend-only authorization as security boundary.

Use Jakarta Security when building Jakarta EE container applications and standard platform security satisfies requirements.

## JSON

Default in Spring Boot applications: Jackson through Boot-managed dependencies.

Use Jackson for Spring MVC/WebFlux JSON serialization/deserialization unless project is deliberately standardized on another JSON library.

Keep JSON contract stable when upgrading Jackson. Test custom `ObjectMapper`, modules, serializers, deserializers, message converters, date/time formats, and null handling.

Use Gson or JSON-B only when project has existing standardization, runtime constraints, or Jakarta EE portability requirements.

## Validation

Default in Spring applications: Jakarta Bean Validation through `spring-boot-starter-validation`, commonly backed by Hibernate Validator.

Use `jakarta.validation.*` in Spring Boot 3+/Spring Framework 6+ and `javax.validation.*` in Spring Boot 2/Spring Framework 5 era.

Apply validation at boundaries and keep stateful business validation in service/domain code.

## Testing

Default unit/integration test stack:

```text
JUnit Jupiter / JUnit 5
Mockito
AssertJ
Spring Test / spring-boot-starter-test
Testcontainers
```

Use JUnit Jupiter for new tests. Use JUnit Vintage temporarily when older JUnit 4 tests must keep running during migration.

Use Mockito for collaborator mocks. Prefer real objects for simple domain/value types.

Use AssertJ when already present or when fluent assertions improve clarity.

Use Testcontainers for integration tests where real PostgreSQL, MySQL, Kafka, Redis, RabbitMQ, MongoDB, or similar infrastructure behavior matters.

## Logging

Default API: SLF4J.

Default implementation in Spring Boot: Logback.

Use structured logging:

```java
log.info("Order created orderId={} customerId={}", orderId, customerId);
```

Do not add multiple logging implementations. Do not log passwords, tokens, authorization headers, or secrets.

Use Log4j 2 only when project is already standardized on it or needs specific Log4j capabilities.

## Observability

Default in Spring Boot: Spring Boot Actuator plus Micrometer.

Use Actuator for health, readiness/liveness, metrics, and operational endpoints. Use Micrometer for metrics and observation/tracing integration.

Do not expose sensitive Actuator endpoints publicly.

## HTTP Clients

Default modern Spring synchronous client: `RestClient` where available.

Use `WebClient` for reactive/non-blocking clients or where project already standardizes on it.

Use `RestTemplate` mainly for existing codebases; do not rewrite solely for style unless migration requires it.

Use OpenFeign through Spring Cloud OpenFeign when declarative HTTP clients are already a project pattern or service-to-service contracts benefit from it.

Always configure timeouts for external HTTP calls.

## Resilience

Default library: Resilience4j for circuit breakers, retries, rate limits, bulkheads, and time limiters in Spring/Java applications.

Use retries only for transient and safely retryable operations. Account for idempotency, maximum attempts, backoff, and duplicate side effects.

Do not implement infinite retries.

## Object Mapping

Default compile-time mapper: MapStruct when DTO/entity mapping is repetitive and hand-written mapping becomes noisy.

Prefer hand-written mapping for small or behavior-rich transformations.

Avoid reflection-heavy mappers for critical paths unless project already uses them and behavior is tested.

## API Documentation

Default for Spring applications: springdoc-openapi when OpenAPI generation is required.

Use OpenAPI docs to document HTTP contracts, not as replacement for controller tests or contract validation.

## Utility Libraries

Use Java standard library first.

Use Apache Commons or Guava only when they provide clear value and are already accepted by project conventions.

Avoid adding utility dependencies for one method that Java standard library already covers.
