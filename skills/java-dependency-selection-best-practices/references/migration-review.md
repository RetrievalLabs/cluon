# Java Dependency Migration And Review

Use this reference before replacing libraries, overriding managed versions, or doing dependency cleanup.

## Dependency Review Workflow

1. Inventory current dependencies with Maven or Gradle dependency tree.
2. Identify platform BOMs and managed versions.
3. Identify duplicate libraries for same role.
4. Identify incompatible generations.
5. Identify direct dependencies that should be transitive through starters.
6. Identify unused dependencies only with build/test evidence.
7. Make smallest dependency change that satisfies compatibility or user request.
8. Run compile, tests, startup, and targeted integration checks.

## Maven Checks

Use:

```bash
mvn dependency:tree
mvn dependency:analyze
mvn test
```

For Spring Boot, prefer parent/BOM management:

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>...</version>
</parent>
```

or:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>...</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

## Gradle Checks

Use:

```bash
./gradlew dependencies
./gradlew dependencyInsight --dependency <name>
./gradlew test
```

Prefer Spring Boot plugin or platform management:

```kotlin
dependencies {
    implementation(platform("org.springframework.boot:spring-boot-dependencies:..."))
}
```

## Avoid Manual Version Overrides

In Spring Boot applications, avoid manually overriding Spring Framework, Spring Security, Hibernate, Jackson, Micrometer, Tomcat/Jetty/Undertow, and core testing library versions unless required.

Manual overrides can create unsupported combinations even when compilation succeeds.

## Duplicate Role Review

Avoid duplicate libraries for same role unless deliberate:

```text
Jackson + Gson + JSON-B
Logback + Log4j2 + JUL bridge loops
Flyway + Liquibase
JUnit 4-only + Jupiter-only without Vintage plan
Spring MVC + WebFlux
multiple HTTP client abstractions
multiple mocking frameworks
```

If both exist, determine whether one is legacy, transitive, test-only, or required by a specific integration.

## Required Versus Optional Changes

Required compatibility examples:

```text
Spring Boot 2 -> 3 requires Jakarta generation alignment
Spring Framework 6 requires Java 17+
Hibernate 5 -> 6 requires query/mapping review
Spring Security 5 -> 6 requires component-based config migration
JUnit 4 -> Jupiter requires JUnit Platform support
Jackson 2 -> 3 requires serialization compatibility review
```

Optional modernization examples:

```text
RestTemplate -> RestClient
JUnit 4 tests -> Jupiter style
custom JWT filter -> Spring Security Resource Server
manual DTO mapping -> MapStruct
custom retries -> Resilience4j
handwritten schema scripts without tracking -> Flyway/Liquibase
```

Apply optional modernization only when it provides concrete benefit and tests can verify behavior.

## Dependency Selection Checklist

Check:

- Does project already have a platform BOM or parent controlling versions?
- Is dependency needed directly, or should starter/transitive dependency provide it?
- Does dependency match Java runtime?
- Does dependency match Spring/Jakarta generation?
- Does dependency duplicate an existing library role?
- Is dependency actively maintained?
- Is license acceptable for project?
- Does it affect public API, serialization, persistence, security, or runtime startup?
- Are tests covering behavior affected by this dependency?
- Are exact versions needed, or should platform manage them?

## Target Outcome

Good dependency selection leaves project:

- generation-compatible,
- behaviorally equivalent unless change requested,
- free of unnecessary duplicate libraries,
- aligned with platform dependency management,
- using mainstream stable libraries for common needs,
- tested where dependency behavior matters.
