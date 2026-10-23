# Mockito Version Guidance

Verify current Mockito release status from official Mockito documentation, javadocs, or release pages when user asks for latest/current guidance.

## Version Map

```text
Mockito 1.x
    -> older Java 6/7 era
    -> limited final/static mocking

Mockito 2.x
    -> Java 8 era
    -> optional inline mock maker for final classes/methods

Mockito 3.x
    -> Java 8 era
    -> static mocking supported with inline mock maker

Mockito 4.x
    -> Java 8 baseline
    -> cleanup before Java-baseline changes

Mockito 5.x
    -> Java 11+ baseline
    -> modern default generation
    -> integrate with JUnit Jupiter through mockito-junit-jupiter
```

## Mockito With JUnit 4

Common JUnit 4 style:

```java
@RunWith(MockitoJUnitRunner.class)
public class OrderServiceTest {

    @Mock
    private OrderRepository repository;

    @InjectMocks
    private OrderService service;
}
```

When migrating to Jupiter, replace runner with `MockitoExtension`.

## Mockito With JUnit Jupiter

Prefer:

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository repository;

    @InjectMocks
    private OrderService service;
}
```

Dependency typically comes from `mockito-junit-jupiter`.

Prefer explicit construction over `@InjectMocks` when constructor dependencies are simple:

```java
@BeforeEach
void setUp() {
    service = new OrderService(repository, clock);
}
```

This makes wiring obvious and avoids hidden injection behavior.

## Strictness

Modern Mockito defaults encourage strict stubbing through runner/extension integration.

Unused stubs often indicate test setup drift. Prefer deleting unused stubs over lenient mode.

Use lenient stubs sparingly when shared setup is unavoidable:

```java
lenient().when(repository.findById(1L)).thenReturn(Optional.of(user));
```

If many tests need lenient mode, simplify fixtures or split setup.

## Static Mocking

Use static mocking only for legacy seams or APIs that cannot be injected.

Prefer dependency injection for time, IDs, configuration, external clients, and gateways.

When static mocking is required, keep scope narrow:

```java
try (MockedStatic<ClockProvider> mocked = mockStatic(ClockProvider.class)) {
    mocked.when(ClockProvider::now).thenReturn(fixedInstant);

    ...
}
```

Do not leave static mocks open across tests.

## Final Classes And Methods

Modern Mockito can mock many final classes depending on mock maker and version.

Do not use final mocking to avoid proper design seams when constructor injection or ports would be clearer.

For framework classes, prefer test utilities or slice tests over deep mocking.

## Spies

Use spies sparingly. Spies execute real code and can make tests fragile.

Prefer spies only when preserving legacy behavior while replacing a small collaborator is impractical.

Avoid spying on the class under test unless there is no better short-term migration option.

## Argument Matchers

Use matchers consistently:

```java
when(repository.findByEmail(eq("a@example.com"))).thenReturn(Optional.of(user));
```

Do not mix raw values and matchers in same invocation.

Prefer specific matchers over broad `any()` when argument value matters.

## Void Methods And Exceptions

For void methods:

```java
doThrow(new IOException("failed"))
        .when(client)
        .send(any());
```

For normal return stubs, prefer `when(...).thenReturn(...)`.

## Resetting Mocks

Avoid `reset(mock)` in most tests. It usually signals oversized tests or shared mutable setup.

Create fresh mocks per test through runner/extension lifecycle.

## Mockito 5.x

Mockito 5 requires modern Java baseline compared with Mockito 4 and is the normal current generation for modern Java applications.

Before upgrading:

- verify Java version,
- verify bytecode tooling,
- verify inline/static mocking behavior,
- verify Spring Boot dependency management,
- update `mockito-junit-jupiter` with `mockito-core`,
- run representative tests using final/static mocks.

Do not upgrade Mockito independently of Spring Boot dependency management unless project has reason to override managed versions.
