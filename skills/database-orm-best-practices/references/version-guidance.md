# Database / ORM Version Guidance

Verify current version status from official project pages when the user asks for latest/current guidance.

As of August 27, 2026:

- Hibernate ORM release pages list 7.4 as latest stable and 8.0 as development.
- Hibernate ORM 7.4.6.Final was released on August 23, 2026.
- Hibernate ORM 8.0.0.Beta1 targets Jakarta Persistence 4.0 and is development, not production default.
- Spring Data JPA project/docs list 4.1.1 as current stable.
- Jakarta Persistence 3.2 is the Jakarta EE 11 Persistence specification.

## JPA 2.x / Hibernate 5.x / Spring Data JPA 2.x

Typical older Spring Boot 2-era applications.

Use `javax.persistence`:

```java
import javax.persistence.Entity;
import javax.persistence.EntityManager;
import javax.persistence.Id;
```

Prefer JPA APIs over Hibernate-specific APIs unless provider-specific behavior is actually required.

Keep transactions in service layer. Avoid eager relationships by default. Detect N+1 queries. Do not expose entities directly as API models. Use Flyway or Liquibase for production schema migration.

## JPA 2.2 To Jakarta Persistence 3.0

This is major namespace migration introduced with Jakarta EE 9.

Most important persistence API change:

```java
javax.persistence.*
```

becomes:

```java
jakarta.persistence.*
```

Example:

```java
import javax.persistence.Entity;
import javax.persistence.Id;
```

becomes:

```java
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
```

This is not merely cosmetic. Persistence stack libraries must be mutually compatible.

Treat migration as:

```text
javax.persistence
       -> jakarta.persistence

Spring Boot 2
       -> Spring Boot 3+

Hibernate 5
       -> Hibernate 6+
```

Avoid mixing old `javax.persistence` dependencies with modern Jakarta-based Hibernate/Spring Data versions.

## Jakarta Persistence 3.1 / Hibernate 6.x / Spring Data JPA 3.x

Important modern generation used heavily with Spring Boot 3.

Hibernate 6 introduced substantial internal and query-model changes. Treat Hibernate 5 to 6 as a real persistence migration, not only dependency bump.

New code should use:

```java
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
```

not:

```java
javax.persistence.*
```

Review custom JPQL/HQL:

```java
@Query(...)
entityManager.createQuery(...)
```

Also review dynamically generated queries. Do not assume query accepted by Hibernate 5 behaves identically under Hibernate 6.

Prefer typed queries:

```java
TypedQuery<User> query =
        entityManager.createQuery(
                "select u from User u where u.email = :email",
                User.class);
```

Use repository projections when only subset is required:

```java
public interface UserSummary {
    Long getId();
    String getName();
}
```

Use pagination for potentially large queries:

```java
Page<User> findAll(Pageable pageable);
```

Avoid unbounded `List<User> findAll()` on large tables.

Be deliberate about cascading. Avoid applying `cascade = CascadeType.ALL` automatically.

Choose cascade types according to actual relationship lifecycle:

```text
PERSIST
MERGE
REMOVE
REFRESH
DETACH
```

Use `orphanRemoval = true` only when child lifecycle truly belongs to parent. Removing child from collection can cause database delete.

## Hibernate 6.2+

Hibernate 6.2 improved support for newer Java and database capabilities, including records and SQL/database features.

Records can be useful for immutable DTOs, projections, embeddable/value-style objects, and query results:

```java
public record UserSummary(
        Long id,
        String name) {
}
```

Do not mechanically convert mutable entities into records.

Prefer modern Java time types where domain semantics permit:

```java
Instant
LocalDate
LocalDateTime
OffsetDateTime
```

over:

```java
Date
Calendar
```

## Jakarta Persistence 3.2 / Hibernate 7.x

Hibernate 7 moved to Jakarta Persistence 3.2 and modern Java baselines.

Prefer standard JPA functionality where newer Jakarta Persistence versions standardize behavior previously requiring provider-specific APIs.

Use Hibernate-specific APIs where they solve a real problem, not as default abstraction.

Treat ORM upgrades as semantic migrations. Test entity mappings, JPQL/HQL, native queries, lazy loading, cascades, transaction boundaries, generated IDs, dirty checking, locking, pagination, and batch operations.

Do not validate ORM upgrade only by checking compilation.

## Hibernate 7.4+

As of August 2026, Hibernate ORM 7.4 is latest stable series while Hibernate 8.0 is development.

Do not automatically migrate production applications to development releases merely because they are newer.

Prefer:

```text
stable supported release
        > latest experimental release
```

unless project specifically needs preview capability.

## Spring Data JPA 4.x

Spring Data JPA 4.x is current generation; official documentation currently lists 4.1.1 as stable.

Spring Data JPA remains repository abstraction over Jakarta Persistence, not replacement for Hibernate or JPA.

Keep layering clear:

```text
Application
    -> Spring Data JPA
    -> Jakarta Persistence
    -> Hibernate
    -> JDBC
    -> Database
```
