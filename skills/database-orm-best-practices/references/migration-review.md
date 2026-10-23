# Database / ORM Migration And Review

Use this reference before non-trivial ORM migrations or reviews.

## Migration Rules

When modernizing:

```text
JPA 2 / Hibernate 5 / Spring Data 2
                 -> Jakarta Persistence 3 / Hibernate 6 / Spring Data 3
                 -> Jakarta Persistence 3.2 / Hibernate 7 / Spring Data 4
```

follow these rules:

1. Preserve persistence behavior before refactoring.
2. Upgrade compatible framework generations together.
3. Handle `javax.persistence -> jakarta.persistence` explicitly.
4. Review Hibernate-specific APIs.
5. Re-test every custom HQL/JPQL/native query.
6. Verify generated SQL for critical paths.
7. Test lazy-loading behavior and transaction boundaries.
8. Test cascade and orphan-removal behavior.
9. Validate schema migrations separately from ORM mappings.
10. Optimize only after functional equivalence is established.

## Migration Workflow

1. Identify current persistence stack: JPA/Jakarta Persistence API, Hibernate version, Spring Data JPA version, Spring Boot version, Java version, database, JDBC driver, connection pool, schema tool.
2. Identify target generation and compatibility matrix.
3. Upgrade dependencies in compatible groups.
4. Compile after small changes.
5. Fix namespace, removed API, provider API, and query compatibility issues.
6. Run repository and service tests.
7. Run database integration tests against representative database.
8. Review SQL for critical paths.
9. Validate schema migrations independently.
10. Apply optional modernization only after behavior is preserved.

## Required Compatibility Changes

Examples:

```text
javax.persistence -> jakarta.persistence
legacy Hibernate API -> supported API
Hibernate 5 query assumptions -> Hibernate 6/7 compatible query semantics
old Spring Data signatures -> current repository APIs
schema generation assumptions -> explicit migration behavior
```

## Optional Modernization

Examples:

```text
entity DTOs -> records or projections
legacy Date/Calendar -> java.time
custom CRUD repository code -> Spring Data repository methods
Hibernate-specific behavior -> standard Jakarta Persistence API
unbounded queries -> pageable or bounded queries
manual schema update -> Flyway/Liquibase migrations
```

Apply optional modernization only when it provides concrete value, preserves behavior, is dependency-compatible, and is covered by tests.

## Review Checklist

Check:

- Is persistence behavior preserved?
- Are compatible framework generations used together?
- Are `javax.persistence` and `jakarta.persistence` dependencies not mixed incorrectly?
- Are standard JPA APIs preferred where sufficient?
- Are Hibernate APIs isolated to real provider-specific needs?
- Are transactions at service/business-operation boundaries?
- Are queries typed where practical?
- Are custom JPQL/HQL/native queries retested?
- Are N+1 and lazy-loading risks controlled?
- Are large result sets bounded?
- Are projections used where only subsets are needed?
- Are cascades and orphan removal deliberate?
- Are generated IDs handled safely in `equals()` and `hashCode()`?
- Are lazy relationships excluded from `toString()`, `equals()`, and `hashCode()`?
- Are schema migrations explicit and environment-safe?
- Is generated SQL reviewed for critical paths?
- Are performance changes measured?
- Are API DTOs separated from persistence entities where appropriate?

## Testing Targets

Test:

```text
entity mappings
JPQL/HQL
native queries
lazy loading
cascades
orphan removal
transaction boundaries
generated IDs
dirty checking
locking
pagination
batch operations
schema migrations
serialization boundaries
```

For migrations, prefer tests that establish behavior before the change and verify same behavior afterward.
