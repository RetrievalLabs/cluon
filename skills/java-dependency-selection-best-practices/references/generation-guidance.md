# Java Dependency Generation Guidance

Use this reference before dependency generation changes or version selection. Verify latest/current versions from official project pages when exact versions matter.

## Spring Generations

```text
Spring Boot 2.x
    -> Spring Framework 5
    -> Spring Security 5
    -> Spring Data 2
    -> Hibernate 5
    -> JPA 2.x / javax.persistence
    -> javax.validation
    -> JUnit 5 available, JUnit 4 common in older code

Spring Boot 3.x
    -> Spring Framework 6
    -> Spring Security 6
    -> Spring Data 3
    -> Hibernate 6
    -> Jakarta Persistence 3.x / jakarta.persistence
    -> jakarta.validation
    -> Java 17+

Spring Boot 4.x
    -> Spring Framework 7
    -> Spring Security 7
    -> Spring Data 4
    -> Hibernate 7 likely common for JPA stacks
    -> Jakarta EE 11 API level
    -> Jackson 3 support path
```

Keep generations aligned. Do not mix Spring Boot 2 era `javax.*` dependencies with Spring Boot 3+ Jakarta-based dependencies.

## Application Framework Selection

Prefer Spring Boot for most application services.

Prefer Jakarta EE runtime when application is deployed to and intentionally managed by an application server such as WildFly, Payara, GlassFish, or Open Liberty.

Prefer plain Spring Framework only for libraries, existing non-Boot applications, or environments where Boot is intentionally not used.

## Web Stack Selection

Use Spring MVC for conventional synchronous web applications.

Use WebFlux only when the application needs reactive/non-blocking I/O and all major downstream dependencies support that model.

Do not choose WebFlux solely because it is newer.

## Persistence Stack Selection

For Spring Boot service using relational database and object persistence, default to:

```text
Spring Data JPA
Jakarta Persistence
Hibernate ORM
JDBC driver
database
Flyway or Liquibase
```

For SQL-heavy services where query shape and database features dominate, use Spring JDBC or jOOQ rather than forcing ORM.

For simple key-value/document workloads, choose the matching Spring Data module only when datastore is actually used.

## Testing Stack Selection

Use JUnit Jupiter for new tests.

Use Mockito for mocks, AssertJ for fluent assertions where project already uses it, Spring Test for Spring integration, and Testcontainers for real infrastructure integration tests.

Keep JUnit Vintage only while JUnit 4 tests still need to run.

JUnit 6 requires Java 17+ runtime; verify build, IDE, CI, Spring Test, and Mockito support before migrating.

## JSON Selection

Use Jackson for Spring Boot/Spring MVC default JSON.

For Jakarta EE portability, JSON-B may be appropriate if runtime and project standardize on it.

For Android or small standalone tools, Gson may be acceptable if already standardized.

Do not add multiple JSON libraries casually.

## Validation Selection

Use Bean Validation API:

```text
javax.validation    Spring Boot 2 / Spring Framework 5 generation
jakarta.validation  Spring Boot 3+ / Spring Framework 6+ generation
```

Use Hibernate Validator as common implementation unless runtime/platform supplies a compatible provider.

## Version Selection Rule

Prefer:

```text
platform-managed stable release
        > direct stable version override
        > milestone / RC
        > snapshot / development build
```

Use milestones, RCs, snapshots, or development releases only when user explicitly targets them or a required fix exists only there.

## Compatibility Checks

Before changing dependency generations, check:

- Java runtime and bytecode target,
- Spring Boot BOM,
- Spring Framework generation,
- Servlet/Jakarta level,
- Hibernate/JPA generation,
- Spring Data generation,
- Spring Security generation,
- Jackson major,
- test framework and build plugin compatibility,
- application server or container support,
- native/AOT requirements if used.
