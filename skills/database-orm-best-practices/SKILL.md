---
name: database-orm-best-practices
description: Use this skill when creating, reviewing, upgrading, or modernizing Java persistence code using Jakarta Persistence/JPA, Hibernate ORM, or Spring Data JPA, including entity mappings, repositories, EntityManager usage, Session usage, javax.persistence to jakarta.persistence migration, Hibernate 5 to 6 or 7 upgrades, Spring Data JPA 2 to 3 or 4 upgrades, JPQL/HQL/native queries, N+1 queries, fetch strategies, projections, pagination, transactions, cascades, orphanRemoval, schema migrations with Flyway or Liquibase, generated SQL review, batching, database indexes, or ORM performance.
metadata:
  mcpmarket-version: 1.0.0
---

# Database / ORM Best Practices

Use this skill for Java persistence work where behavior preservation, portable JPA usage, ORM semantics, generated SQL, and controlled modernization matter.

## Workflow

1. Identify framework generation: JPA/Jakarta Persistence, Hibernate ORM, Spring Data JPA, Spring Boot, Java version, database, and migration tool.
2. Preserve existing persistence behavior before refactoring or adopting newer ORM features.
3. Upgrade compatible framework generations together; do not mix `javax.persistence` stacks with Jakarta-based ORM generations.
4. Review custom JPQL/HQL/native queries, entity mappings, fetch behavior, cascades, transactions, and generated SQL for critical paths.
5. Apply Spring Data JPA for repository boilerplate, Jakarta Persistence for portable contracts, and Hibernate APIs only when provider-specific behavior is needed.
6. Verify with focused repository, integration, migration, and SQL behavior checks based on change risk.

## Reference Routing

- Read `references/core-practices.md` before changing persistence code.
- Read `references/version-guidance.md` before JPA/Hibernate/Spring Data JPA version upgrades or current-version guidance.
- Read `references/query-transaction-schema.md` before query, transaction, entity, schema, or performance changes.
- Read `references/migration-review.md` before non-trivial ORM migrations or reviews.

## Guardrails

- Do not validate ORM migration only by compilation.
- Do not use `ddl-auto=update` as production schema-management strategy.
- Do not expose JPA entities directly as public API contracts without deliberate reason.
- Do not change ID strategies, relationship mappings, fetch behavior, cascades, orphan removal, or schema semantics without dedicated migration analysis.
- When user asks for latest/current ORM versions, verify official project documentation first.
