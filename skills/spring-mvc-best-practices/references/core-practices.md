# Spring MVC Core Practices

Use these practices when changing Spring MVC code across framework generations.

## Core Principles

Regardless of Spring MVC version:

- Keep controllers thin.
- Keep business logic in services.
- Keep persistence logic in repositories.
- Use constructor injection.
- Validate requests at HTTP boundary.
- Use DTOs for API contracts instead of exposing persistence entities.
- Use centralized exception handling.
- Follow HTTP method and status-code semantics.
- Preserve existing API contracts unless a change is explicitly required.
- Do not introduce unrelated modernization during a version migration.

```text
HTTP Request
     -> Controller
     -> Service
     -> Repository
     -> Database
```

Controllers should primarily parse HTTP input, validate input, call application/service layer, and translate results into HTTP responses.

## Annotated Controllers

Prefer annotation-driven MVC and REST controllers for JSON APIs:

```java
@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public UserResponse getUser(@PathVariable Long id) {
        return userService.getUser(id);
    }
}
```

Prefer:

- `@Controller`
- `@RestController`
- `@RequestMapping`
- `@GetMapping`
- `@PostMapping`
- `@PutMapping`
- `@PatchMapping`
- `@DeleteMapping`
- `ResponseEntity`
- `@ControllerAdvice`
- `@RestControllerAdvice`

Avoid legacy controller styles such as `implements Controller` and `implements HttpRequestHandler` unless required by existing application architecture.

Avoid repeating `@Controller` plus `@ResponseBody` when every method is REST-oriented. Prefer `@RestController`.

## Request Mappings

Prefer specialized HTTP mapping annotations:

```java
@GetMapping("/{id}")
@PostMapping
@PutMapping("/{id}")
@PatchMapping("/{id}")
@DeleteMapping("/{id}")
```

Use method-specific mappings instead of method-level `@RequestMapping(method = RequestMethod.GET)` unless existing style or framework constraints require otherwise.

Always declare supported HTTP methods. A generic `@RequestMapping` without methods can match more methods than intended.

Use `consumes` and `produces` when content-type or response media type is part of the contract:

```java
@PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
@GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
```

## Thin Controllers

Avoid:

```java
@PostMapping
public OrderResponse create(...) {
    repository.save(...);
    calculateDiscount(...);
    updateInventory(...);
    sendEmail(...);
}
```

Prefer:

```java
@PostMapping
public OrderResponse create(
        @Valid @RequestBody CreateOrderRequest request) {

    return orderService.create(request);
}
```

Business rules belong in service or domain layer.

## DTO API Contracts

Do not expose persistence entities directly:

```java
@GetMapping("/{id}")
public UserEntity getUser(@PathVariable Long id) {
    return repository.findById(id).orElseThrow();
}
```

Prefer:

```java
@GetMapping("/{id}")
public UserResponse getUser(@PathVariable Long id) {
    return userService.getUser(id);
}
```

DTO example:

```java
public record UserResponse(
        Long id,
        String name,
        String email) {
}
```

This separates database model from public API contract and avoids leaking persistence lifecycle, lazy-loading behavior, and internal relationships.

## Records For DTOs

When Java version supports records, immutable request/response DTOs are good candidates:

```java
public record UserResponse(
        Long id,
        String username) {
}
```

Do not automatically convert stateful framework-managed classes or persistence entities to records.

Avoid blindly converting:

```java
@Entity
public class User {
    ...
}
```

## Validate At HTTP Boundary

Prefer Bean Validation:

```java
public record CreateUserRequest(
        @NotBlank String name,
        @Email String email) {
}
```

Controller:

```java
@PostMapping
public UserResponse create(
        @Valid @RequestBody CreateUserRequest request) {

    return userService.create(request);
}
```

Use validation annotations for structural input requirements. Keep business rules in domain/service layer.

For Spring MVC 6.1+, handle both `MethodArgumentNotValidException` and `HandlerMethodValidationException` where relevant, because controller signatures can trigger either validation path.

## Centralized Exception Handling

Use `@ControllerAdvice`, `@RestControllerAdvice`, and `@ExceptionHandler` for consistent HTTP error mapping:

```java
@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(UserNotFoundException.class)
    public ProblemDetail handle(UserNotFoundException ex) {
        return ProblemDetail.forStatusAndDetail(
                HttpStatus.NOT_FOUND,
                ex.getMessage());
    }
}
```

For modern Spring MVC APIs, prefer `ProblemDetail` and Spring MVC error response support where appropriate.

Do not leak stack traces, SQL, database implementation details, internal class names, credentials, or infrastructure details through API errors.

## MVC Configuration

Prefer:

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor);
    }
}
```

In Spring Boot applications, do not add `@EnableWebMvc` unless intentionally taking control of MVC configuration. Prefer extending Boot MVC configuration through `WebMvcConfigurer`.

## Transactions

Transactions belong around application/business operations:

```java
@Service
public class OrderService {

    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        ...
    }
}
```

Avoid:

```java
@Transactional
@PostMapping
public OrderResponse createOrder(...) {
    ...
}
```

Controllers should not normally define transaction boundaries.
