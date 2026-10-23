# JUnit / Mockito Core Testing Practices

Use these practices for Java test code across JUnit and Mockito generations.

## Test Behavior, Not Implementation Detail

Write tests around observable behavior, public contracts, and important edge cases.

Prefer:

```java
@Test
void rejectsBlankEmail() {
    assertThatThrownBy(() -> service.createUser(""))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("email");
}
```

Avoid tests that only verify private helper structure, incidental call order, or framework wiring unrelated to behavior.

## Use Correct Test Level

Prefer plain unit tests for pure business logic.

Use slice tests for narrow framework behavior:

```text
@WebMvcTest      controller/web behavior
@DataJpaTest     persistence behavior
@JsonTest        JSON serialization behavior
```

Use integration tests when behavior depends on real infrastructure, transactions, container lifecycle, security filters, persistence provider behavior, messaging, or serialization across boundaries.

Do not start a full Spring context for every test when a plain unit or slice test is enough.

## Keep Tests Focused

Follow arrange, act, assert shape:

```java
@Test
void calculatesDiscountForPremiumCustomer() {
    Customer customer = premiumCustomer();

    Money discount = pricingService.discountFor(customer);

    assertThat(discount).isEqualTo(Money.of("10.00"));
}
```

Use descriptive test names. Prefer one behavior per test. Avoid large scenario tests that fail for many unrelated reasons.

## Prefer Clear Assertions

Use assertion libraries already present in the project, such as AssertJ, Hamcrest, Truth, or JUnit assertions.

Prefer assertions that explain expected behavior:

```java
assertThat(result)
        .extracting(UserResponse::id, UserResponse::email)
        .containsExactly(42L, "a@example.com");
```

Avoid assertions that only check non-null values when the actual contract is stronger.

## Fixtures

Keep test fixtures explicit and local unless shared setup is genuinely stable.

Avoid hidden global setup that makes each test hard to read. Use test data builders or factory methods only when they reduce meaningful duplication.

Good helper:

```java
private CreateUserRequest validRequest() {
    return new CreateUserRequest("Ada", "ada@example.com");
}
```

Avoid helper layers that obscure required fields and defaults.

## Mockito Usage

Use Mockito to isolate collaborators when those collaborators are slow, external, stateful, nondeterministic, or hard to construct.

Prefer real objects for simple value objects and pure domain code.

Use `@ExtendWith(MockitoExtension.class)` with JUnit Jupiter:

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository repository;

    @InjectMocks
    private OrderService service;

    @Test
    void createsOrder() {
        when(repository.save(any())).thenReturn(savedOrder());

        OrderResponse response = service.create(validRequest());

        assertThat(response.id()).isEqualTo(1L);
        verify(repository).save(any());
    }
}
```

Prefer constructor injection in production code so tests can instantiate objects directly.

## Stubbing And Verification

Stub only interactions required for behavior under test. Avoid broad default stubs.

Prefer:

```java
when(repository.findById(1L)).thenReturn(Optional.of(user));
```

Avoid:

```java
when(repository.findById(any())).thenReturn(Optional.of(user));
```

unless any value is part of intended behavior.

Verify important side effects. Do not verify every interaction by default.

## Argument Captors

Use captors when output is passed to a collaborator and cannot be observed otherwise:

```java
ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);

verify(repository).save(captor.capture());

assertThat(captor.getValue().getEmail()).isEqualTo("ada@example.com");
```

Prefer asserting returned values or persisted observable behavior when possible.

## Avoid Over-Mocking

Over-mocking makes tests fragile. Warning signs:

- test mirrors implementation line by line,
- every method call is verified,
- mocks return mocks,
- simple domain objects are mocked,
- test fails after harmless refactor.

Use real collaborators when cheap and deterministic.

## Time, Randomness, And Concurrency

Inject `Clock`, ID generators, random sources, and executors when code depends on time, randomness, or concurrency.

Avoid sleeps in tests. Use controllable clocks, latches, await utilities, or deterministic executors.

## Test Data And Isolation

Tests should not depend on execution order. Avoid shared mutable state.

Clean up external state or use isolated resources. For database integration tests, prefer transactions, disposable containers, or test-specific schemas depending on project pattern.

## Do Not Hide Broken Behavior

Do not loosen assertions, swallow exceptions, or mark tests disabled to pass a migration unless issue is tracked and deliberately deferred.

If a test was wrong, update it to express intended behavior and state why through test name or nearby code.
