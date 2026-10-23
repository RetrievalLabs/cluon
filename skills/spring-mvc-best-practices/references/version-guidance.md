# Spring MVC Version Guidance

Verify current Spring Framework facts from official Spring documentation when the user asks for latest/current guidance.

## Version Map

```text
Spring MVC 4.x
    -> annotation-driven MVC
    -> @RestController
    -> ResponseEntity
    -> @ControllerAdvice

Spring MVC 5.x
    -> @GetMapping / @PostMapping / ...
    -> thin controllers
    -> DTO boundaries
    -> Bean Validation

Spring MVC 5.3+
    -> PathPatternParser direction
    -> avoid suffix-pattern routing
    -> avoid ambiguous wildcard mappings

Spring MVC 6.0+
    -> Java 17+
    -> javax -> jakarta where required
    -> ProblemDetail
    -> modern path matching

Spring MVC 6.1+
    -> Java 21-friendly MVC
    -> evaluate virtual threads
    -> do not unnecessarily migrate to WebFlux

Spring MVC 7.0+
    -> Jakarta EE 11 / Servlet 6.1
    -> built-in API versioning
    -> Jackson 3 compatibility
    -> move away from MVC XML configuration
```

## Spring MVC 4.x

Prefer annotation-driven MVC.

```java
@RestController
@RequestMapping("/users")
public class UserController {

    @GetMapping("/{id}")
    public UserResponse getUser(@PathVariable Long id) {
        return userService.getUser(id);
    }
}
```

Use `@Controller`, `@RestController`, `@RequestMapping`, HTTP-method mapping annotations, `ResponseEntity`, and `@ControllerAdvice`.

Avoid legacy controller styles unless required by existing application:

```java
implements Controller
implements HttpRequestHandler
```

Avoid repeating `@Controller` and `@ResponseBody` when entire controller is REST-oriented. Prefer `@RestController`.

## Spring MVC 5.x

Prefer specialized HTTP mapping annotations:

```java
@GetMapping("/{id}")
@PostMapping
@PutMapping("/{id}")
@PatchMapping("/{id}")
@DeleteMapping("/{id}")
```

Prefer these over:

```java
@RequestMapping(
        value = "/{id}",
        method = RequestMethod.GET)
```

Keep controllers focused on HTTP concerns. Put business rules in service/domain layer.

## Spring MVC 5.3+

Prefer modern path matching. Avoid introducing routes that depend on ambiguous or complex Ant-style wildcard behavior.

```text
AntPathMatcher
      -> PathPatternParser
```

Avoid suffix-based content negotiation:

```text
/users.json
/users.xml
```

Prefer HTTP content negotiation:

```http
GET /users
Accept: application/json
```

When migrating existing routes, verify behavior before changing path patterns.

## Spring MVC 6.0+

Spring Framework 6 introduces a major compatibility boundary.

Verify Java 17+ runtime before upgrading.

Migrate Java EE APIs to Jakarta where required:

```java
import javax.servlet.*;
import javax.validation.*;
```

becomes:

```java
import jakarta.servlet.*;
import jakarta.validation.*;
```

Also inspect other Java EE APIs used by the application.

Do not blindly replace every `javax.*` import. Some `javax` packages remain part of Java SE.

### ProblemDetail

For modern Spring MVC APIs, prefer standardized problem responses:

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

Prefer `ProblemDetail`, `@ControllerAdvice`, `@RestControllerAdvice`, and `@ExceptionHandler` over repeated custom exception handling across controllers.

## Spring MVC 6.1+ And Java 21+

Do not automatically migrate Spring MVC applications to WebFlux for scalability.

For applications using blocking technologies such as Spring MVC, JPA, Hibernate, JDBC, and blocking SDKs, imperative Spring MVC remains appropriate.

When running on suitable Java/Spring stack, consider virtual threads for blocking workloads:

```text
Platform threads
       -> evaluate virtual threads
```

This is an optimization opportunity, not mandatory migration.

Verify thread-local assumptions, concurrency behavior, connection-pool limits, synchronized code, third-party library compatibility, and performance under realistic load before enabling.

## Spring MVC 7.0+

Spring Framework 7 retains a Java 17 baseline, recommends newer LTS Java where appropriate, and moves to Jakarta EE 11 API level including Servlet 6.1.

Evaluate newer MVC capabilities instead of maintaining unnecessary custom infrastructure.

### API Versioning

Prefer Spring MVC built-in API versioning support when appropriate:

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void configureApiVersioning(ApiVersionConfigurer configurer) {
        configurer.useRequestHeader("API-Version");
    }
}
```

Evaluate built-in version resolution through request headers, query parameters, path segments, and media-type parameters.

Before replacing existing versioning, verify behavior and compatibility guarantees can be preserved.

### Jakarta EE 11 / Servlet 6.1

For Spring Framework 7 migrations, verify compatibility across entire web stack:

- Servlet container
- Jakarta Servlet APIs
- Jakarta Validation
- servlet filters
- listeners
- authentication integrations
- third-party MVC libraries
- testing libraries

Do not upgrade Spring MVC independently when surrounding infrastructure is incompatible.

### Jackson 3

Spring Framework 7 supports Jackson 3 while retaining deprecated Jackson 2 support.

Inspect applications using:

```java
ObjectMapper
Jackson2ObjectMapperBuilder
HttpMessageConverter
JsonSerializer
JsonDeserializer
Module
```

Do not blindly rewrite Jackson configuration.

Verify custom serializers, custom deserializers, Jackson modules, annotations, third-party libraries, and API serialization behavior. Preserving existing JSON contract is more important than adopting newer APIs.

### Move Away From MVC XML Configuration

Legacy:

```xml
<mvc:annotation-driven/>

<mvc:interceptors>
    ...
</mvc:interceptors>
```

Modern direction:

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
}
```

Prefer Java configuration for new code. For existing XML-heavy applications, migrate incrementally and verify behavior after each change.
