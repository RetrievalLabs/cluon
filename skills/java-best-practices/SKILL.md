---
name: java-best-practices
description: Use this skill when migrating Java 8, 11, 17, or 21 applications to Java 25, handling removed APIs, JDK internals, dependency upgrades, runtime flags, staged Java LTS upgrades, Optional handling, HTTP Client, CompletableFuture, records, sealed classes, virtual threads, scoped values, or Java modernization.
metadata:
  mcpmarket-version: 1.0.0
---
# Java Best Practices

Guidance for migrating Java 8/11/17/21 applications to Java 25 and writing type-safe, concurrent, modern Java code. Covers staged upgrades, removed APIs, dependency readiness, null safety, concurrency patterns, and modern language features.

Use `patterns/migration-strategy.md` for Java 8 through Java 25 migration guidance before optional source modernization.

## Core Principles

1. **Null safety first**: Use Optional for return values, @Nullable/@NonNull for parameters
2. **Immutability preferred**: Use records for data carriers, final fields where possible
3. **Explicit error handling**: Use checked exceptions sparingly, prefer Result patterns
4. **Modern features**: Leverage Java 11-25 features when they reduce code without changing behavior
5. **Virtual threads for IO**: Use virtual threads (Java 21+) for IO-bound operations
6. **Preview caution**: Use Java 25 preview/incubator features only when build flags, runtime flags, and upgrade risk are acceptable
7. **Migration before modernization**: Fix build, dependency, runtime, and removed-API blockers before optional syntax upgrades

## Type Safety

### Use Optional for Return Values

```java
// Good - explicit absence representation
public Optional<User> findById(String id) {
    User user = userRepository.findById(id);
    return Optional.ofNullable(user);
}

// Bad - null return
public User findById(String id) {
    return userRepository.findById(id); // May return null
}
```

### Never Use Optional as Parameter or Field

```java
// Bad - Optional as parameter
public void processUser(Optional<User> user) { ... }

// Good - use @Nullable annotation or overloading
public void processUser(@Nullable User user) { ... }
public void processUser(User user) { ... } // Overload for non-null

// Bad - Optional as field
private Optional<String> middleName;

// Good - nullable field with annotation
@Nullable
private String middleName;
```

### Use Null Safety Annotations

```java
import org.jspecify.annotations.Nullable;
import org.jspecify.annotations.NonNull;

// Good - explicit null contract
public @NonNull User createUser(@NonNull String name, @Nullable String email) {
    Objects.requireNonNull(name, "name cannot be null");
    return new User(name, email);
}
```

### Defensive Coding with Objects.requireNonNull

```java
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;

    // Good - fail-fast validation in constructor
    public UserService(UserRepository repository, EmailService emailService) {
        this.repository = Objects.requireNonNull(repository, "repository cannot be null");
        this.emailService = Objects.requireNonNull(emailService, "emailService cannot be null");
    }
}
```

## Null Handling

### Optional Transformation with map/flatMap

```java
// Good - chained transformations
String city = findUserById(id)
    .map(User::getAddress)
    .map(Address::getCity)
    .orElse("Unknown");

// Good - flatMap for Optional-returning methods
Optional<Order> latestOrder = findUserById(id)
    .flatMap(User::getLatestOrder);
```

### Prefer orElseGet for Expensive Defaults

```java
// Good - lazy evaluation for expensive default
User user = findUserById(id)
    .orElseGet(() -> userService.createDefaultUser());

// Bad - always evaluates default
User user = findUserById(id)
    .orElse(userService.createDefaultUser()); // Always creates default user!
```

### Use orElseThrow for Required Values

```java
// Good - explicit exception for missing required value
User user = findUserById(id)
    .orElseThrow(() -> new UserNotFoundException("User not found: " + id));

// Good - Java 10+ simplified version
User user = findUserById(id)
    .orElseThrow(); // Throws NoSuchElementException
```

### Avoid Optional.get() Without Check

```java
// Bad - may throw NoSuchElementException
User user = findUserById(id).get();

// Good - use orElseThrow with meaningful exception
User user = findUserById(id)
    .orElseThrow(() -> new IllegalStateException("Expected user to exist"));

// Good - check presence first if needed
Optional<User> userOpt = findUserById(id);
if (userOpt.isPresent()) {
    User user = userOpt.get();
    // ...
}

// Better - use ifPresent or map
findUserById(id).ifPresent(user -> {
    // Process user
});
```

### Filter with Optional

```java
// Good - combine filter with map
Optional<String> activeUserEmail = findUserById(id)
    .filter(User::isActive)
    .map(User::getEmail);

// Equivalent to
Optional<String> activeUserEmail = findUserById(id)
    .flatMap(user -> user.isActive()
        ? Optional.of(user.getEmail())
        : Optional.empty());
```

### Optional in Streams

```java
// Good - filter out empty Optionals (Java 9+)
List<User> users = userIds.stream()
    .map(this::findUserById)
    .flatMap(Optional::stream)
    .toList();

// Pre-Java 9
List<User> users = userIds.stream()
    .map(this::findUserById)
    .filter(Optional::isPresent)
    .map(Optional::get)
    .collect(Collectors.toList());
```

### Java 11 String and Optional Helpers

```java
// Good - explicit blank validation
public User createUser(String name) {
    Objects.requireNonNull(name, "name");
    if (name.isBlank()) {
        throw new IllegalArgumentException("name is required");
    }
    return new User(name.strip());
}

// Good - clearer absence branch
Optional<User> user = findByEmail(email);
if (user.isEmpty()) {
    audit.missingUser(email);
}
```

Do not replace `trim()` with `strip()` unless Unicode whitespace handling is intended.

## Concurrency

### CompletableFuture Basics

```java
// Good - create async operations
CompletableFuture<User> future = CompletableFuture.supplyAsync(() -> {
    return userRepository.findById(id);
});

// Good - chain transformations
CompletableFuture<String> emailFuture = future
    .thenApply(User::getEmail)
    .thenApply(String::toLowerCase);

// Good - combine multiple futures
CompletableFuture<UserProfile> profile = CompletableFuture
    .allOf(userFuture, ordersFuture, preferencesFuture)
    .thenApply(v -> new UserProfile(
        userFuture.join(),
        ordersFuture.join(),
        preferencesFuture.join()
    ));
```

### Java 11 HTTP Client

Use `java.net.http.HttpClient` for simple HTTP/2, WebSocket, and JSON-over-HTTP integrations when behavior matches existing clients.

```java
HttpClient client = HttpClient.newBuilder()
    .connectTimeout(Duration.ofSeconds(3))
    .build();

HttpRequest request = HttpRequest.newBuilder(uri)
    .timeout(Duration.ofSeconds(5))
    .GET()
    .build();

HttpResponse<String> response = client.send(
    request,
    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
```

Do not replace mature clients blindly. Match timeout, proxy, TLS, pooling, retry, and observability behavior first.

### CompletableFuture Error Handling

```java
// Good - handle errors with exceptionally
CompletableFuture<User> userFuture = fetchUserAsync(id)
    .exceptionally(ex -> {
        log.error("Failed to fetch user: {}", id, ex);
        return User.anonymous();
    });

// Good - handle with recovery
CompletableFuture<User> userFuture = fetchUserAsync(id)
    .handle((user, ex) -> {
        if (ex != null) {
            log.warn("Fetch failed, using cache", ex);
            return userCache.get(id);
        }
        return user;
    });

// Good - chain error handling with whenComplete
fetchUserAsync(id)
    .whenComplete((user, ex) -> {
        if (ex != null) {
            metrics.incrementFailure();
        } else {
            metrics.incrementSuccess();
        }
    });
```

### Parallel Execution with CompletableFuture

```java
// Good - execute multiple operations in parallel
public CompletableFuture<DashboardData> loadDashboard(String userId) {
    CompletableFuture<User> userFuture = fetchUserAsync(userId);
    CompletableFuture<List<Order>> ordersFuture = fetchOrdersAsync(userId);
    CompletableFuture<List<Notification>> notificationsFuture = fetchNotificationsAsync(userId);

    return CompletableFuture.allOf(userFuture, ordersFuture, notificationsFuture)
        .thenApply(v -> new DashboardData(
            userFuture.join(),
            ordersFuture.join(),
            notificationsFuture.join()
        ));
}

// Good - first to complete wins
CompletableFuture<String> fastest = CompletableFuture.anyOf(
    fetchFromPrimary(),
    fetchFromSecondary(),
    fetchFromCache()
).thenApply(result -> (String) result);
```

### Virtual Threads (Java 21+)

```java
// Good - virtual threads for IO-bound tasks
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<Future<String>> futures = urls.stream()
        .map(url -> executor.submit(() -> fetchUrl(url)))
        .toList();

    List<String> results = new ArrayList<>();
    for (Future<String> future : futures) {
        results.add(future.get());
    }
}

// Good - structured concurrency with Joiner (Java 25 preview)
try (var scope = StructuredTaskScope.open(
        StructuredTaskScope.Joiner.<Response>allSuccessfulOrThrow())) {
    requests.forEach(request -> scope.fork(() -> client.send(request)));

    return scope.join()
        .map(Subtask::get)
        .toList();
}
```

### Scoped Values (Java 25)

Use scoped values for immutable request context shared with callees and child threads. Prefer them over `ThreadLocal` for virtual-thread-heavy code when data has lexical scope.

```java
private static final ScopedValue<RequestContext> REQUEST_CONTEXT =
    ScopedValue.newInstance();

public Response handle(Request request) throws Exception {
    RequestContext context = RequestContext.from(request);

    return ScopedValue.where(REQUEST_CONTEXT, context)
        .call(() -> service.handle(request));
}

public User currentUser() {
    return REQUEST_CONTEXT.get().user();
}
```

Use `ThreadLocal` only when existing libraries require it or data must outlive a lexical operation boundary.

### When to Use Virtual Threads

```java
// Good use case - many concurrent IO operations
// Each virtual thread blocks on IO without consuming OS thread
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    // Can handle thousands of concurrent requests efficiently
    List<Future<Response>> responses = requests.stream()
        .map(req -> executor.submit(() -> httpClient.send(req)))
        .toList();
}

// Bad use case - CPU-bound computation
// Use platform threads or ForkJoinPool for CPU-intensive work
ForkJoinPool.commonPool().submit(() -> {
    // Heavy computation here
});
```

### ExecutorService Patterns

```java
// Good - bounded thread pool with rejection handling
ExecutorService executor = new ThreadPoolExecutor(
    4,                      // core pool size
    8,                      // max pool size
    60, TimeUnit.SECONDS,   // keep-alive time
    new ArrayBlockingQueue<>(100),  // bounded queue
    new ThreadPoolExecutor.CallerRunsPolicy()  // rejection policy
);

// Good - always shutdown executors
try {
    // Submit tasks
} finally {
    executor.shutdown();
    if (!executor.awaitTermination(30, TimeUnit.SECONDS)) {
        executor.shutdownNow();
    }
}

// Better - use try-with-resources (Java 19+)
try (var executor = Executors.newFixedThreadPool(4)) {
    // Submit tasks
} // Auto-shutdown
```

### Thread Safety Patterns

```java
// Good - immutable objects are thread-safe
public record User(String id, String name, String email) {}

// Good - use concurrent collections
private final ConcurrentHashMap<String, User> userCache = new ConcurrentHashMap<>();
private final CopyOnWriteArrayList<EventListener> listeners = new CopyOnWriteArrayList<>();

// Good - atomic operations
private final AtomicInteger counter = new AtomicInteger(0);
private final AtomicReference<Config> config = new AtomicReference<>(defaultConfig);

// Good - use locks for complex operations
private final ReentrantReadWriteLock lock = new ReentrantReadWriteLock();

public User getUser(String id) {
    lock.readLock().lock();
    try {
        return userCache.get(id);
    } finally {
        lock.readLock().unlock();
    }
}

public void updateUser(User user) {
    lock.writeLock().lock();
    try {
        userCache.put(user.id(), user);
    } finally {
        lock.writeLock().unlock();
    }
}
```

### Async Error Handling Patterns

```java
// Good - Result type for async operations
public sealed interface AsyncResult<T> {
    record Success<T>(T value) implements AsyncResult<T> {}
    record Failure<T>(Throwable error) implements AsyncResult<T> {}
}

public CompletableFuture<AsyncResult<User>> fetchUserSafe(String id) {
    return fetchUserAsync(id)
        .<AsyncResult<User>>thenApply(AsyncResult.Success::new)
        .exceptionally(AsyncResult.Failure::new);
}

// Good - timeout handling
CompletableFuture<User> userFuture = fetchUserAsync(id)
    .orTimeout(5, TimeUnit.SECONDS)
    .exceptionally(ex -> {
        if (ex instanceof TimeoutException) {
            return User.anonymous();
        }
        throw new CompletionException(ex);
    });

// Good - retry with exponential backoff
public <T> CompletableFuture<T> withRetry(
        Supplier<CompletableFuture<T>> operation,
        int maxRetries,
        Duration initialDelay) {

    return operation.get().exceptionallyCompose(ex -> {
        if (maxRetries <= 0) {
            return CompletableFuture.failedFuture(ex);
        }
        return CompletableFuture
            .delayedExecutor(initialDelay.toMillis(), TimeUnit.MILLISECONDS)
            .execute(() -> {});
        // Continue with recursive retry...
    });
}
```

## Modern Java Features

### Local Variable Type Inference (Java 10+, in scope for Java 11+)

```java
// Good - inferred type is clear
var usersById = new HashMap<String, User>();
var activeUsers = userRepository.findActiveUsers();

// Bad - inferred type hides domain meaning
var result = service.execute(command);
```

Use `var` for local variables only. Never change public API signatures to hide types.

### Switch Expressions (Java 14+)

```java
// Good - switch as expression
public String getDayType(DayOfWeek day) {
    return switch (day) {
        case MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY -> "Weekday";
        case SATURDAY, SUNDAY -> "Weekend";
    };
}

// Good - with yield for complex cases
public int calculate(Operation op, int a, int b) {
    return switch (op) {
        case ADD -> a + b;
        case SUBTRACT -> a - b;
        case MULTIPLY -> a * b;
        case DIVIDE -> {
            if (b == 0) {
                throw new ArithmeticException("Division by zero");
            }
            yield a / b;
        }
    };
}
```

Convert only value-producing switch logic. Preserve intentional fall-through behavior.

### Text Blocks (Java 15+)

```java
String query = """
    SELECT id, name
    FROM users
    WHERE active = true
    """;
```

Use text blocks for SQL, JSON, XML, and expected-output tests. Verify indentation and trailing newline behavior before replacing concatenated strings.

### Records (Java 16+)

```java
// Good - immutable data carrier with automatic equals, hashCode, toString
public record User(String id, String name, String email) {}

// Good - compact constructor for validation
public record User(String id, String name, String email) {
    public User {
        Objects.requireNonNull(id, "id cannot be null");
        Objects.requireNonNull(name, "name cannot be null");
        if (email != null && !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email format");
        }
    }
}

// Good - add computed properties
public record Rectangle(double width, double height) {
    public double area() {
        return width * height;
    }

    public double perimeter() {
        return 2 * (width + height);
    }
}

// Good - static factory methods
public record Point(int x, int y) {
    public static Point origin() {
        return new Point(0, 0);
    }

    public static Point of(int x, int y) {
        return new Point(x, y);
    }
}
```

### When to Use Records

```java
// Good use cases for records:
// 1. DTOs (Data Transfer Objects)
public record UserDTO(String id, String name, String email) {}

// 2. Value objects
public record Money(BigDecimal amount, Currency currency) {}

// 3. API responses
public record ApiResponse<T>(T data, int status, String message) {}

// 4. Configuration objects
public record DatabaseConfig(String host, int port, String database) {}

// 5. Compound map keys
public record CacheKey(String userId, String resourceType) {}

// Bad use cases - don't use records when:
// - You need mutable state
// - You need inheritance
// - You need custom equals/hashCode that differs from all fields
```

### Sealed Classes (Java 17+)

```java
// Good - restrict inheritance hierarchy
public sealed interface Shape
    permits Circle, Rectangle, Triangle {

    double area();
}

public record Circle(double radius) implements Shape {
    @Override
    public double area() {
        return Math.PI * radius * radius;
    }
}

public record Rectangle(double width, double height) implements Shape {
    @Override
    public double area() {
        return width * height;
    }
}

public record Triangle(double base, double height) implements Shape {
    @Override
    public double area() {
        return 0.5 * base * height;
    }
}
```

### Sealed Classes for Result Types

```java
// Good - algebraic data type pattern
public sealed interface Result<T>
    permits Result.Success, Result.Failure {

    record Success<T>(T value) implements Result<T> {}
    record Failure<T>(String error, Throwable cause) implements Result<T> {
        public Failure(String error) {
            this(error, null);
        }
    }

    default T getOrThrow() {
        return switch (this) {
            case Success<T> s -> s.value();
            case Failure<T> f -> throw new RuntimeException(f.error(), f.cause());
        };
    }

    default T getOrElse(T defaultValue) {
        return switch (this) {
            case Success<T> s -> s.value();
            case Failure<T> f -> defaultValue;
        };
    }
}
```

### Pattern Matching for instanceof (Java 16+)

```java
// Good - pattern matching eliminates cast
public String describe(Object obj) {
    if (obj instanceof String s) {
        return "String of length " + s.length();
    }
    if (obj instanceof Integer i) {
        return "Integer: " + i;
    }
    if (obj instanceof List<?> list && !list.isEmpty()) {
        return "Non-empty list with " + list.size() + " elements";
    }
    return "Unknown: " + obj;
}

// Bad - old style with explicit cast
public String describeOld(Object obj) {
    if (obj instanceof String) {
        String s = (String) obj;  // Redundant cast
        return "String of length " + s.length();
    }
    // ...
}
```

### Pattern Matching in Switch (Java 21+)

```java
// Good - exhaustive pattern matching
public double calculateArea(Shape shape) {
    return switch (shape) {
        case Circle c -> Math.PI * c.radius() * c.radius();
        case Rectangle r -> r.width() * r.height();
        case Triangle t -> 0.5 * t.base() * t.height();
    };
}

// Good - with guards
public String categorize(Shape shape) {
    return switch (shape) {
        case Circle c when c.radius() > 100 -> "Large circle";
        case Circle c -> "Small circle";
        case Rectangle r when r.width() == r.height() -> "Square";
        case Rectangle r -> "Rectangle";
        case Triangle t -> "Triangle";
    };
}

// Good - null handling in switch (Java 21+)
public String process(String input) {
    return switch (input) {
        case null -> "Input is null";
        case String s when s.isBlank() -> "Input is blank";
        case String s -> "Input: " + s;
    };
}
```

### Sequenced Collections (Java 21+)

Use sequenced collection APIs when encounter order is part of the contract:

```java
SequencedMap<String, User> users = new LinkedHashMap<>();
users.put("first", firstUser);
users.put("last", lastUser);

User first = users.firstEntry().getValue();
User last = users.lastEntry().getValue();
SequencedMap<String, User> newestFirst = users.reversed();
```

Do not use sequenced APIs to imply order for unordered collection implementations.

### Foreign Function and Memory API (Java 22+)

Use the Foreign Function and Memory API as a replacement path for selected JNI or `Unsafe` memory access only when native boundaries are isolated and tested:

```java
try (Arena arena = Arena.ofConfined()) {
    MemorySegment segment = arena.allocate(ValueLayout.JAVA_INT);
    segment.set(ValueLayout.JAVA_INT, 0, 42);
}
```

Keep application code behind domain-specific native adapters.

### Java 23-24 Migration Signals

- Use Markdown Javadoc for new or heavily edited docs only when generated output is checked.
- Replace withdrawn string template preview usage with `String.format`, `MessageFormat`, a template engine, or explicit builders.
- Treat native access and `sun.misc.Unsafe` memory-access warnings as dependency upgrade signals before source edits.

### Java 25 Language Updates

Use permanent Java 25 language features when they make existing code clearer without changing behavior:

```java
// Good - validate constructor arguments before delegating (Java 25)
public class PositiveRange extends Range {
    public PositiveRange(int start, int end) {
        if (start < 0 || end < 0) {
            throw new IllegalArgumentException("Range must be positive");
        }
        super(start, end);
    }
}
```

Compact source files and instance `main` methods are useful for scripts, examples, and teaching code. Keep normal class structure for production application entrypoints unless project style explicitly permits compact source files.

```java
void main() {
    IO.println("Hello, Java 25");
}
```

Use Java 25 preview features only behind explicit preview build and runtime flags:

```java
// Preview - primitive patterns in switch
String describe(int value) {
    return switch (value) {
        case byte b -> "byte-sized: " + b;
        case int i when i > 0 -> "positive int: " + i;
        default -> "other";
    };
}
```

Avoid converting ordinary imports to module import declarations in application code unless the project has adopted that preview feature.

## Quick Reference: Modern Features Checklist

- [ ] Keep compile/runtime migration separate from optional modernization
- [ ] Use records for immutable data carriers (DTOs, value objects)
- [ ] Use `var` only when inferred local type remains obvious
- [ ] Use text blocks only after verifying whitespace and trailing newline behavior
- [ ] Add validation in compact constructors
- [ ] Use sealed classes to restrict type hierarchies
- [ ] Combine sealed interfaces with records for algebraic data types
- [ ] Use pattern matching with instanceof to avoid explicit casts
- [ ] Use switch expressions instead of switch statements
- [ ] Use sequenced collection APIs only when encounter order is part of the contract
- [ ] Keep FFM usage behind tested native adapters
- [ ] Replace withdrawn string template preview usage before targeting Java 23+
- [ ] Treat native access and Unsafe warnings as dependency upgrade signals
- [ ] Leverage exhaustive pattern matching with sealed types
- [ ] Use guards in switch patterns for conditional matching
- [ ] Use Java 25 flexible constructor bodies for validation before `super(...)` when it removes fragile constructor workarounds
- [ ] Keep compact source files and instance `main` methods to scripts, examples, or explicitly approved project style
- [ ] Gate Java 25 preview/incubator features behind explicit `--enable-preview` or module requirements

## Quick Reference: Concurrency Checklist

- [ ] Use Java 11 `HttpClient` only when behavior matches existing HTTP clients
- [ ] Use `CompletableFuture` for async operations, not raw threads
- [ ] Handle errors with `exceptionally()` or `handle()`
- [ ] Use `allOf()` for parallel operations that all must complete
- [ ] Use virtual threads (Java 21+) for IO-bound tasks
- [ ] Prefer scoped values (Java 25) over `ThreadLocal` for lexically scoped immutable context
- [ ] Use structured concurrency only when preview features are enabled
- [ ] Use platform threads/ForkJoinPool for CPU-bound tasks
- [ ] Always shutdown ExecutorService in finally block or try-with-resources
- [ ] Prefer immutable objects and records for thread safety
- [ ] Use concurrent collections instead of synchronized wrappers
- [ ] Add timeouts to async operations with `orTimeout()`
- [ ] Implement retry logic for transient failures

## Quick Reference: Type Safety Checklist

- [ ] Return `Optional<T>` for potentially absent values
- [ ] Never use `Optional` as method parameter or field
- [ ] Use `@Nullable`/`@NonNull` annotations consistently
- [ ] Validate non-null parameters with `Objects.requireNonNull()`
- [ ] Prefer `orElseGet()` over `orElse()` for expensive defaults
- [ ] Use `orElseThrow()` for required values
- [ ] Never call `Optional.get()` without checking presence
- [ ] Use `map()`/`flatMap()` for Optional transformations
