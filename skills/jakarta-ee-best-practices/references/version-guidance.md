# Jakarta EE Version Guidance

Verify current release status with official Jakarta EE pages when the user asks for latest/current guidance. As of August 27, 2026, official Jakarta EE release pages list Jakarta EE 11 as the current released version and Jakarta EE 12 as under development.

## Platform Progression

```text
Jakarta EE 8
    -> Jakarta EE 9
    -> Jakarta EE 9.1  -> Java SE 11 support
    -> Jakarta EE 10   -> Java SE 11 / 17
    -> Jakarta EE 11   -> Java SE 17+
                       -> Java 21 enhancements
```

Do not select Java version based only on specification theory. Verify actual application server support.

## Jakarta EE 8

Jakarta EE 8 is the baseline inherited from Java EE 8 and still uses the `javax.*` namespace.

Best practices:

- Keep Jakarta EE 8 applications on `javax.*`.
- Do not prematurely replace imports with `jakarta.*`.
- Prefer CDI for dependency injection.
- Prefer Jakarta REST/JAX-RS for REST APIs.
- Use Jakarta Persistence/JPA for persistence.
- Use Bean Validation for declarative validation.
- Prefer container-managed transactions and resources.
- Keep business logic separate from Servlet/JAX-RS transport code.
- Remove unnecessary vendor-specific dependencies where practical.

Migration goal: before moving to Jakarta EE 9, establish a clean baseline and useful test coverage. Do not perform namespace transition before runtime and dependencies are ready.

## Jakarta EE 9

Jakarta EE 9 introduced the major namespace transition:

```text
javax.*
   -> jakarta.*
```

Treat namespace migration as the primary change.

Update Jakarta API dependencies, application server/runtime, persistence provider, CDI extensions, REST libraries, validation libraries, servlet filters/listeners, and third-party Jakarta integrations. Then migrate Jakarta EE imports.

Example:

```java
import javax.persistence.Entity;
```

becomes:

```java
import jakarta.persistence.Entity;
```

Do not run uncontrolled global replacement. Only migrate packages belonging to specifications that moved to the Jakarta namespace.

A dependency compiled against a legacy Jakarta/Java EE API may not work with the new namespace. Check framework and library compatibility explicitly.

During Jakarta EE 8 to 9 migration, avoid simultaneous changes to persistence architecture, REST API design, dependency-injection strategy, threading model, DTO structure, ID generation, or application packaging unless required.

## Jakarta EE 9.1

Jakarta EE 9.1 is primarily Jakarta EE 9 plus Java SE 11 support. It does not represent a major new Jakarta programming model.

Focus on runtime compatibility:

- move to a supported Java version,
- update build plugins,
- update annotation processors,
- verify reflection-heavy libraries,
- verify application-server compatibility,
- remove obsolete JVM flags,
- test startup and deployment behavior.

Do not interpret a Java upgrade as a requirement to modernize all Java syntax. Avoid unnecessary transformations such as POJO to record, loops to streams, switch to modern switch, and threads to new concurrency architecture unless independently justified.

## Jakarta EE 10

Jakarta EE 10 introduced substantial platform modernization, Java SE 11/17 support, Core Profile, and CDI Lite.

Prefer CDI as the default Jakarta dependency-injection mechanism. Use explicit scopes:

```java
@ApplicationScoped
@RequestScoped
@SessionScoped
@Dependent
```

Consider Core Profile for lightweight services that only need limited Jakarta APIs. Do not migrate an existing application to Core Profile unless all required specifications are available.

When using Jakarta REST implementations that support Jakarta EE 10 APIs, prefer standardized multipart handling over vendor-specific multipart APIs.

Where Jakarta Security provides required authentication capability, prefer standard platform mechanisms over custom application-server-specific security integrations. Do not replace working custom security without verifying equivalent behavior.

Jakarta Persistence provides standardized UUID support. Use UUID identifiers where appropriate for the domain and data model. Do not change existing numeric identifiers solely because UUID support exists; primary-key migrations affect database, indexing, API, storage, and compatibility.

Prefer Jakarta Concurrency for asynchronous work executed within the Jakarta runtime. Avoid unmanaged executors unless deployment architecture explicitly requires them.

## Jakarta EE 11

Jakarta EE 11 requires Java SE 17 or newer and includes enhancements that integrate well with Java 21.

Key changes include:

- Jakarta Data 1.0
- improved Java record support
- runtime-aware virtual-thread support
- removal of Managed Beans
- removal of SecurityManager requirement
- updated Persistence, CDI, REST, Validation, Security, Servlet, and Concurrency specifications

### Managed Beans to CDI

Legacy Managed Beans are removed from Jakarta EE 11 platform. Prefer CDI:

```java
@ApplicationScoped
public class OrderService {
}
```

When migrating legacy code, replace Managed Bean functionality with CDI while preserving lifecycle and injection semantics.

### Jakarta Data

Consider Jakarta Data when repositories contain repetitive CRUD/query boilerplate.

Use Jakarta Data when target runtime supports it, repository semantics map cleanly, behavior is covered by tests, and implementation becomes simpler.

Do not automatically rewrite complex JPA repositories. Keep explicit persistence code for complex joins, locking, batching, specialized queries, persistence lifecycle behavior, and performance-sensitive logic.

### Prefer `java.time`

For new code, prefer modern Java time types such as `Instant`, `LocalDate`, `LocalDateTime`, `OffsetDateTime`, `ZonedDateTime`, and `Year`.

When migrating existing fields, verify database column semantics, timezone assumptions, serialization formats, API compatibility, and historical data. Do not perform mechanical `Date` to `Instant` conversions without understanding semantics.

### Records

Use records for immutable data carriers where appropriate:

- REST request DTOs
- REST response DTOs
- value objects
- immutable projections

Do not automatically convert JPA entities, lifecycle-heavy components, mutable domain aggregates, or classes whose identity is not purely their state.

Jakarta Persistence 3.2 improves record support for specific persistence constructs such as embeddables and ID classes.

### Virtual Threads

Jakarta EE 11 can use Java 21 virtual threads through runtime-aware managed concurrency support.

Consider virtual threads for high-concurrency, blocking-I/O-heavy workloads. Check application-server implementation support, JDBC/database connection-pool limits, downstream service limits, thread-local assumptions, transaction/context propagation, and monitoring behavior.

Virtual threads reduce thread-management cost but do not increase capacity of limited downstream resources.

### SecurityManager Removal

Do not design new Jakarta EE applications around Java `SecurityManager`.

When migrating legacy applications, identify code depending on `SecurityManager`, policy files, permission checks, or `AccessController`, then replace those assumptions with appropriate modern security boundaries.

## Jakarta EE 12

Jakarta EE 12 is under development. Do not treat proposed APIs or milestone behavior as stable production guidance unless the user explicitly targets a milestone or preview runtime.

For Jakarta EE 12 readiness work, verify current specification pages, release plan, target runtime support, and migration notes before editing code.
