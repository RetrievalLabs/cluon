# Query, Transaction, Entity, Schema, And Performance Practices

These practices apply across JPA, Hibernate ORM, and Spring Data JPA versions.

## Query Practices

Avoid N+1:

```text
SELECT users
SELECT orders for user 1
SELECT orders for user 2
SELECT orders for user 3
...
```

Use appropriate:

```text
JOIN FETCH
@EntityGraph
projection
batch fetching
explicit query
```

Choose based on access pattern.

Avoid loading unnecessary columns. If only `id` and `name` are required, do not load a large entity graph. Use DTO or interface projections where useful.

Bound result sets. Avoid queries capable of unintentionally returning millions of rows.

Use:

```text
pagination
LIMIT
business-level bounds
streaming/batching where appropriate
```

Index according to query patterns. If application frequently executes:

```sql
SELECT *
FROM users
WHERE email = ?
```

database likely needs an index on `email`. ORM usage does not eliminate database design.

## Transaction Practices

Keep transaction boundaries around business operations:

```java
@Transactional
public void transferMoney(...) {
    debit(...);
    credit(...);
}
```

Avoid separate transactions around each repository call when one business operation must be atomic.

Keep transactions as short as practical. Avoid:

```text
BEGIN TRANSACTION

call external HTTP API
wait
perform unrelated computation
send another HTTP call
write DB

COMMIT
```

Long-running transactions increase lock contention and resource usage.

## Entity Practices

Use entities for persistence state, not generic objects passed everywhere.

Be careful implementing:

```java
equals()
hashCode()
```

using generated database IDs because IDs can change from:

```text
null
-> generated value
```

after persistence.

Avoid putting lazy relationships into:

```java
toString()
equals()
hashCode()
```

because doing so can unexpectedly trigger database access.

Do not change ID strategies, relationship mappings, fetching behavior, or schema semantics merely because newer Jakarta/Hibernate version makes another approach available. Such changes require dedicated migration analysis.

## Cascade And Orphan Removal

Avoid applying:

```java
cascade = CascadeType.ALL
```

automatically.

Example:

```java
@OneToMany(
        mappedBy = "order",
        cascade = CascadeType.ALL)
private List<OrderLine> lines;
```

This can cause unexpected persistence or deletion behavior.

Choose cascade types according to relationship lifecycle:

```text
PERSIST
MERGE
REMOVE
REFRESH
DETACH
```

Use:

```java
orphanRemoval = true
```

only when child object lifecycle truly belongs to parent. Removing child from collection can result in database delete.

## Database Schema Practices

Use explicit migrations:

```text
V1__create_users.sql
V2__add_email_index.sql
V3__create_orders.sql
```

with Flyway or Liquibase.

Treat Java entity model and database schema as related but independently managed artifacts.

Do not assume Hibernate should automatically own production schema evolution.

In Spring Boot, understand `spring.jpa.hibernate.ddl-auto` defaults. Embedded databases without Flyway/Liquibase may default to `create-drop`; real databases generally default to `none`. Set behavior explicitly for production environments.

## Performance Practices

For high-volume operations, consider:

```text
JDBC batching
Hibernate batching
bulk update/delete
projections
pagination
appropriate fetch strategies
database indexes
connection-pool tuning
```

Do not solve database performance problems solely by adding caches. Measure first.

## Generated SQL Review

For important persistence paths, verify what actually reaches the database.

A repository method that looks harmless:

```java
repository.findSomething();
```

could generate:

```text
multiple joins
N+1 queries
large result sets
unnecessary columns
additional selects
```

SQL behavior matters more than repository method elegance.
