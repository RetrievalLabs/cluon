# JUnit Version Guidance

Verify current JUnit release status from official JUnit documentation when user asks for latest/current guidance.

## Version Map

```text
JUnit 4
    -> @RunWith
    -> @Rule / @ClassRule
    -> org.junit.Test

JUnit 5
    -> JUnit Platform
    -> JUnit Jupiter
    -> JUnit Vintage for temporary JUnit 4 execution
    -> Java 8+ baseline for early/current 5.x

JUnit 6
    -> current next generation
    -> Java 17+ runtime baseline
    -> Vintage deprecated for removal
```

## JUnit 4

JUnit 4 tests commonly use:

```java
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(MockitoJUnitRunner.class)
public class OrderServiceTest {

    @Test
    public void createsOrder() {
        ...
    }
}
```

Common patterns:

- `@Before`
- `@After`
- `@BeforeClass`
- `@AfterClass`
- `@Rule`
- `@ClassRule`
- `@RunWith`
- `ExpectedException`

When preserving old suites, keep JUnit 4 tests running until behavior is covered by migrated Jupiter tests.

## JUnit 5 / Jupiter

JUnit 5 consists of Platform, Jupiter, and Vintage.

Jupiter tests use:

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Test
    void createsOrder() {
        ...
    }
}
```

Migration mappings:

```text
org.junit.Test -> org.junit.jupiter.api.Test
@Before -> @BeforeEach
@After -> @AfterEach
@BeforeClass -> @BeforeAll
@AfterClass -> @AfterAll
@Ignore -> @Disabled
@RunWith -> @ExtendWith
@Rule -> extension or explicit test code
```

Jupiter test classes and methods can be package-private. Do not make everything public unless project style requires it.

Use:

- `assertThrows` for exception assertions,
- `assertAll` for grouped assertions,
- `@Nested` for related scenarios,
- `@ParameterizedTest` for input matrices,
- `@TempDir` for temporary files,
- `@DisplayName` sparingly when method name is not enough.

## JUnit Vintage

Vintage lets JUnit Platform run JUnit 3/4 tests.

Use Vintage as a bridge during migration, not permanent destination. Migrate actively maintained JUnit 4 tests to Jupiter when touching them or when framework upgrades require it.

Do not remove Vintage until remaining JUnit 4 tests are migrated or intentionally deleted.

## Parameterized Tests

Use parameterized tests when same behavior should hold for multiple inputs:

```java
@ParameterizedTest
@CsvSource({
        "a@example.com,true",
        "not-an-email,false",
        "'',false"
})
void validatesEmail(String input, boolean valid) {
    assertThat(validator.isValid(input)).isEqualTo(valid);
}
```

Avoid parameterized tests when each case needs different setup and assertions.

## Nested Tests

Use `@Nested` to group scenarios around one subject:

```java
@Nested
class CancelOrder {

    @Test
    void rejectsPaidOrder() {
        ...
    }
}
```

Keep nesting shallow.

## Dynamic Tests

Use dynamic tests only when test cases are discovered or generated at runtime. Prefer parameterized tests for static input sets.

## JUnit 6

JUnit 6 is the newer generation and uses Java 17+ at runtime.

Before migrating:

- verify build tool support,
- verify IDE and CI runner support,
- verify Spring Boot/Spring test compatibility,
- verify Mockito and assertion-library compatibility,
- remove or isolate Vintage reliance because Vintage is deprecated for removal.

Do not treat JUnit 6 migration as reason to rewrite all test structure. Make compatibility changes first, then modernize selectively.

## Build Tool Notes

For Maven, ensure Surefire/Failsafe versions support JUnit Platform.

For Gradle, use JUnit Platform:

```groovy
test {
    useJUnitPlatform()
}
```

Keep dependency versions managed by Spring Boot when working in Spring Boot projects unless a specific override is required.
