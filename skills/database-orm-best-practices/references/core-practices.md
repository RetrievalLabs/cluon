# Database / ORM Core Practices

Applies to Jakarta Persistence/JPA, Hibernate ORM, and Spring Data JPA.

Use these practices incrementally when modernizing older Java applications. Preserve existing persistence behavior first; adopt newer capabilities only when they provide a clear benefit.

## Keep Layers Clear

```text
Application
    -> Spring Data JPA
    -> Jakarta Persistence
    -> Hibernate
    -> JDBC
    -> Database
```

Spring Data JPA is repository convenience. Jakarta Persistence is standard contract. Hibernate is ORM implementation. JDBC is database communication. Database is actual persistence.

Do not leak Spring Data repositories throughout every layer. Do not treat Hibernate-specific APIs as default application abstraction.

## Prefer JPA APIs Over Hibernate-Specific APIs

For portable application code, use standard persistence APIs when they satisfy the requirement:

```java
import javax.persistence.Entity;
import javax.persistence.EntityManager;
import javax.persistence.Id;
```

or, for Jakarta-based generations:

```java
import jakarta.persistence.Entity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Id;
```

Prefer:

```java
entityManager.persist(entity);
entityManager.find(User.class, id);
```

over direct coupling to:

```java
Session
SessionFactory
```

Use Hibernate-specific APIs when they solve a real problem, not as default abstraction.

## Keep Transactions In Service Layer

Prefer:

```java
@Transactional
public void createOrder(Order order) {
    orderRepository.save(order);
}
```

Avoid transaction management scattered across controllers and repositories.

## Avoid Eager Relationships By Default

Prefer:

```java
@OneToMany(fetch = FetchType.LAZY)
private List<Order> orders;
```

Be careful with:

```java
fetch = FetchType.EAGER
```

Large object graphs can load unexpectedly.

## Detect N+1 Queries

Code such as:

```java
List<User> users = repository.findAll();

for (User user : users) {
    user.getOrders().size();
}
```

can result in:

```text
1 query for users
+ N queries for orders
```

Use appropriate fetch joins, entity graphs, projections, batch fetching, or explicit queries when related data is actually required.

## Do Not Expose Entities Directly As API Models

Avoid:

```text
Controller
   -> JPA Entity
   -> JSON
```

Prefer:

```text
Controller
   -> DTO
   -> Service
   -> Entity
```

Persistence models and API contracts usually evolve for different reasons.

## Use Schema Migration Tools

Prefer Flyway or Liquibase rather than relying on:

```properties
spring.jpa.hibernate.ddl-auto=update
```

in production.

`ddl-auto=update` can be useful during development, but should not be production schema-management strategy.

## Use Spring Data JPA For Repository Boilerplate

A normal repository can remain:

```java
public interface UserRepository extends JpaRepository<User, Long> {
}
```

Do not create custom repository implementations for ordinary CRUD operations Spring Data already provides:

```text
UserRepository
    -> UserRepositoryImpl
    -> EntityManager
```

## Use Derived Queries For Simple Conditions

Good:

```java
findByEmail(String email);
findByStatus(OrderStatus status);
findByCreatedAtAfter(Instant time);
```

For complex logic, switch to explicit JPQL, Criteria, specifications, Querydsl, or another suitable query mechanism rather than creating unreadable method names.

Avoid:

```java
findByStatusAndCreatedAtAfterAndUserNameContainingAndArchivedFalse...
```

## Use `@Modifying` For Mutation Queries

Example:

```java
@Modifying
@Query("""
    update User u
       set u.active = false
     where u.lastLogin < :cutoff
""")
int deactivateInactiveUsers(Instant cutoff);
```

Bulk updates bypass ordinary entity dirty checking and can make currently managed entities stale.
