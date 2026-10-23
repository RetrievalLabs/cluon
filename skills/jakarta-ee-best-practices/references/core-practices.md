# Core Jakarta EE Practices

Use these practices for Jakarta EE application code across supported platform generations.

## Preserve Behavior First

During an upgrade, preserve observable behavior unless a behavior change is explicitly required.

Prefer this sequence:

```text
upgrade platform
-> compile
-> fix compatibility issues
-> run tests
-> verify behavior
-> modernize selectively
```

Avoid combining platform upgrade with unrelated redesign, persistence rewrites, DTO replacement, concurrency changes, or syntax modernization.

## Prefer Standard Jakarta APIs

Prefer Jakarta EE specifications when they satisfy the requirement:

- CDI for dependency injection
- Jakarta REST for HTTP APIs
- Jakarta Persistence for ORM
- Jakarta Transactions for transaction management
- Jakarta Validation for validation
- Jakarta Security for security
- Jakarta Concurrency for managed concurrency
- Jakarta Messaging for messaging
- Jakarta Data where appropriate on Jakarta EE 11+

Avoid coupling application code directly to internal WildFly, Payara, GlassFish, Open Liberty, or other vendor implementation classes unless necessary.

## Dependency Injection

Prefer CDI-managed components. Use constructor injection for required dependencies when practical:

```java
@ApplicationScoped
public class OrderService {

    private final OrderRepository repository;

    @Inject
    public OrderService(OrderRepository repository) {
        this.repository = repository;
    }
}
```

Avoid manually constructing container-managed dependencies:

```java
OrderRepository repository = new OrderRepository();
```

Avoid service-locator patterns when CDI injection is sufficient. Keep dependencies explicit and easy to test.

## Layering

Keep transport, business, and persistence responsibilities separated.

```text
REST Resource
    -> Application / Service
    -> Repository
    -> Persistence
```

REST resources should primarily handle HTTP input, validation, status codes, serialization, and delegation. Business rules belong in service or domain code. Persistence logic belongs in repositories or dedicated persistence components.

## REST APIs

Use Jakarta REST for HTTP APIs. Keep resources thin:

```java
@Path("/orders")
@Produces(MediaType.APPLICATION_JSON)
public class OrderResource {

    private final OrderService service;

    @Inject
    public OrderResource(OrderService service) {
        this.service = service;
    }

    @GET
    @Path("/{id}")
    public OrderResponse get(@PathParam("id") long id) {
        return service.get(id);
    }
}
```

Do not put complex database queries, transaction orchestration, or business workflows directly in resource methods. Use `ExceptionMapper` for consistent HTTP error mapping where appropriate.

## DTOs and Persistence Entities

Do not expose persistence entities directly as public API contracts unless there is a strong reason.

Prefer:

```text
HTTP request
-> request DTO
-> business/domain logic
-> entity
-> response DTO
```

This prevents API contracts from becoming tightly coupled to database schema, persistence lifecycle, lazy-loading behavior, and internal relationships.

Records are appropriate for immutable DTOs when the target Java and Jakarta version supports them well. Do not automatically convert all classes to records.

## Validation

Use Jakarta Validation for declarative input validation:

```java
public record CreateUserRequest(
        @NotBlank String name,
        @Email String email
) {
}
```

Prefer standard constraints over repetitive manual checks. Keep business-rule validation in the service or domain layer when it depends on application state.

Structural input validation example: `@NotBlank`.

Business validation example: `customer may only cancel an unpaid order`.

## Transactions

Define transaction boundaries at the service/application layer:

```java
@ApplicationScoped
public class TransferService {

    @Transactional
    public void transfer(...) {
        ...
    }
}
```

Avoid scattering transaction management across REST resources and repositories. Do not manually manage transactions when container-managed transactions satisfy the use case. Keep external network calls out of long-running database transactions where possible.

## Persistence

Use Jakarta Persistence carefully. Avoid uncontrolled lazy loading, accidental N+1 queries, loading entire object graphs unnecessarily, exposing managed entities outside their intended lifecycle, and keeping persistence contexts open longer than necessary.

Use explicit queries when doing so makes performance or intent clearer.

Do not change ID strategies, relationship mappings, fetching behavior, or schema semantics merely because a newer Jakarta version makes another approach available. Such changes require dedicated migration analysis.

## Managed Resources

Let the container manage lifecycle-sensitive infrastructure whenever possible.

Prefer container-managed `DataSource`, `EntityManager`, transactions, executors, messaging resources, and security context.

Avoid manually creating resources that the Jakarta runtime should manage.

## Concurrency

Do not create unmanaged application-server threads casually. Avoid these for container-managed application workloads:

```java
new Thread(...);
Executors.newFixedThreadPool(...);
```

Prefer Jakarta Concurrency.

On Java 21+ and Jakarta EE 11, virtual threads may provide benefit, but use them through container-supported managed concurrency facilities where possible.

Do not convert every executor or thread pool to virtual threads solely because they are available. Evaluate workload type, blocking behavior, runtime support, transaction/context propagation, resource limits, and observability.

## Application Server Portability

Do not assume all Jakarta-compatible runtimes behave identically in non-standard areas.

When vendor-specific behavior is required:

1. Isolate it behind an abstraction.
2. Document why it is required.
3. Test it against the target runtime.
4. Avoid leaking vendor types throughout business logic.
