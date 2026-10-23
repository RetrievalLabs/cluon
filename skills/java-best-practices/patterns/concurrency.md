---
name: Concurrency
category: Java
tags: [java, concurrency, http-client, completablefuture, virtual-threads, scoped-values, structured-concurrency, async]
activation:
  keywords: [httpclient, completablefuture, async, virtual, thread, executor, concurrent, scoped, structured]
  file_patterns: ["**/*.java"]
---

# Concurrency Pattern

## AI Quick Reference

**Purpose**: Implement safe, efficient concurrent and asynchronous operations in Java.

**Key Rules**:
1. Use `CompletableFuture` for async operations, not raw threads
2. Handle errors with `exceptionally()` or `handle()`
3. Use Java 11 `HttpClient` for simple HTTP integrations when behavior matches existing clients
4. Use virtual threads (Java 21+) for IO-bound tasks
5. Prefer scoped values (Java 25) over ThreadLocal for lexically scoped immutable context

**Quick Patterns**:

```java
// CompletableFuture with error handling
CompletableFuture<User> userFuture = fetchUserAsync(id)
    .orTimeout(5, TimeUnit.SECONDS)
    .exceptionally(ex -> User.anonymous());

// Java 11 HTTP Client with explicit timeout
HttpClient client = HttpClient.newBuilder()
    .connectTimeout(Duration.ofSeconds(3))
    .build();

// Virtual threads for IO (Java 21+)
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<Future<String>> futures = urls.stream()
        .map(url -> executor.submit(() -> fetch(url)))
        .toList();
}

// Scoped values for immutable request context (Java 25)
ScopedValue.where(REQUEST_CONTEXT, context)
    .run(() -> service.handle(request));

// Parallel execution
CompletableFuture.allOf(userFuture, ordersFuture, prefsFuture)
    .thenApply(v -> new Dashboard(
        userFuture.join(),
        ordersFuture.join(),
        prefsFuture.join()
    ));
```

---

## Human Documentation

### When to Apply

- Making HTTP calls or database queries that shouldn't block
- Processing multiple independent operations in parallel
- Handling high-concurrency workloads (thousands of concurrent tasks)
- Migrating from blocking to non-blocking code

### Implementation Guide

#### 1. CompletableFuture Basics

```java
// Create async operation
CompletableFuture<User> future = CompletableFuture.supplyAsync(() -> {
    return userRepository.findById(id);
});

// Transform result
CompletableFuture<String> emailFuture = future
    .thenApply(User::getEmail)
    .thenApply(String::toLowerCase);

// Consume result
future.thenAccept(user -> log.info("Found: {}", user.getName()));
```

#### 2. Error Handling

```java
// Recover from errors
CompletableFuture<User> userFuture = fetchUserAsync(id)
    .exceptionally(ex -> {
        log.warn("Fetch failed, using default", ex);
        return User.anonymous();
    });

// Handle both success and failure
CompletableFuture<User> userFuture = fetchUserAsync(id)
    .handle((user, ex) -> {
        if (ex != null) {
            metrics.incrementFailure();
            return userCache.get(id);
        }
        metrics.incrementSuccess();
        return user;
    });
```

#### 3. Java 11 HTTP Client

Use `java.net.http.HttpClient` for simple HTTP/2, WebSocket, and JSON-over-HTTP integrations when its timeout, proxy, TLS, pooling, retry, and observability behavior matches the existing client:

```java
HttpRequest request = HttpRequest.newBuilder(uri)
    .timeout(Duration.ofSeconds(5))
    .GET()
    .build();

HttpResponse<String> response = client.send(
    request,
    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
```

Do not replace mature clients such as Apache HttpClient, OkHttp, or framework-managed clients blindly.

#### 4. Virtual Threads (Java 21+)

Use virtual threads for IO-bound operations that would otherwise block:

```java
// Good - scales to thousands of concurrent tasks
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<Future<Response>> responses = requests.stream()
        .map(req -> executor.submit(() -> httpClient.send(req)))
        .toList();

    for (Future<Response> future : responses) {
        processResponse(future.get());
    }
}

// Don't use for CPU-bound work - use ForkJoinPool instead
ForkJoinPool.commonPool().submit(() -> {
    // Heavy computation
});
```

#### 5. Scoped Values (Java 25)

Use scoped values for immutable context that should be available to callees and child threads only within a bounded operation:

```java
private static final ScopedValue<RequestContext> REQUEST_CONTEXT =
    ScopedValue.newInstance();

public Response handle(Request request) throws Exception {
    RequestContext context = RequestContext.from(request);

    return ScopedValue.where(REQUEST_CONTEXT, context)
        .call(() -> service.handle(request));
}
```

Prefer scoped values over `ThreadLocal` for request IDs, tenant IDs, security principals, and other immutable context in virtual-thread-heavy code. Keep `ThreadLocal` for library compatibility or state that intentionally outlives a lexical operation.

#### 6. Structured Concurrency (Java 25 Preview)

Use structured concurrency only when preview features are enabled and the project accepts preview API churn:

```java
try (var scope = StructuredTaskScope.open(
        StructuredTaskScope.Joiner.<Response>allSuccessfulOrThrow())) {
    requests.forEach(request -> scope.fork(() -> client.send(request)));

    return scope.join()
        .map(Subtask::get)
        .toList();
}
```

#### 7. Thread-Safe Collections

```java
// Use concurrent collections
private final ConcurrentHashMap<String, User> cache = new ConcurrentHashMap<>();
private final CopyOnWriteArrayList<Listener> listeners = new CopyOnWriteArrayList<>();

// Atomic operations
private final AtomicInteger counter = new AtomicInteger(0);
counter.incrementAndGet();

// Atomic reference for config updates
private final AtomicReference<Config> config = new AtomicReference<>(defaultConfig);
config.updateAndGet(c -> c.withTimeout(newTimeout));
```

### Anti-Patterns

- Using raw `Thread` instead of `ExecutorService` or `CompletableFuture`
- Replacing a configured HTTP client without matching timeout, retry, TLS, proxy, and monitoring behavior
- Not shutting down ExecutorService (causes resource leaks)
- Using `synchronized` blocks when concurrent collections would suffice
- Blocking virtual threads with CPU-intensive operations
- Pooling virtual threads instead of creating one per task
- Using structured concurrency without preview build and runtime flags
- Ignoring exceptions in async callbacks

### Migration: Virtual Threads

```java
// Before (platform threads - limited scalability)
ExecutorService executor = Executors.newFixedThreadPool(100);

// After (virtual threads - unlimited scalability for IO)
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

// Code using the executor remains unchanged!
executor.submit(() -> fetchData(url));
```

### Examples

See `SKILL.md` for comprehensive examples and the concurrency section.
