# JUnit / Mockito Migration And Review

Use this reference before non-trivial test migrations or reviews.

## Migration Workflow

1. Identify current JUnit, Mockito, assertion library, build plugins, Java version, Spring Boot/Spring Test version, and CI runner.
2. Inventory test types: unit, Spring slice, full integration, database, security, contract, end-to-end.
3. Preserve behavior and failure signal before style modernization.
4. Upgrade build plugin/runtime support for JUnit Platform when moving to Jupiter.
5. Use Vintage temporarily when needed to keep JUnit 4 tests running.
6. Migrate touched or failing tests first.
7. Replace runners/rules with Jupiter extensions and explicit code.
8. Replace Mockito runner/rule with `MockitoExtension`.
9. Run targeted tests after small batches.
10. Run representative full suite before finishing migration.

## Required Compatibility Changes

Examples:

```text
org.junit.Test -> org.junit.jupiter.api.Test
@Before -> @BeforeEach
@After -> @AfterEach
@BeforeClass -> @BeforeAll
@AfterClass -> @AfterAll
@Ignore -> @Disabled
@RunWith(MockitoJUnitRunner.class) -> @ExtendWith(MockitoExtension.class)
ExpectedException rule -> assertThrows
JUnit 4 rules -> Jupiter extensions or explicit lifecycle code
Surefire/Failsafe old versions -> JUnit Platform-compatible versions
Gradle test task -> useJUnitPlatform()
Mockito old Java baseline -> compatible Mockito major
```

## Optional Modernization

Examples:

```text
repeated tests -> @ParameterizedTest
scenario classes -> @Nested
manual temp files -> @TempDir
legacy assertions -> project-standard fluent assertions
static utility calls -> injected collaborators
custom runners -> extensions
over-broad integration tests -> unit or slice tests
```

Apply optional modernization only when it improves clarity, reliability, speed, or coverage and does not hide behavior changes.

## Review Checklist

Check:

- Does each test assert meaningful behavior?
- Is test level appropriate for behavior under test?
- Are mocks limited to true collaborators?
- Are simple values and domain objects real objects?
- Are stubs specific and necessary?
- Are important side effects verified?
- Are exception tests precise?
- Are parameterized tests readable?
- Are fixtures explicit enough to understand failures?
- Are tests independent of execution order?
- Is time/randomness/concurrency controlled?
- Are sleeps avoided?
- Are disabled tests justified?
- Are migrations preserving failure signal?
- Are JUnit 4 and Jupiter imports not mixed accidentally in same test?
- Is Vintage present only when still needed?
- Is Mockito strictness not weakened globally without reason?
- Are static/final mocks scoped and justified?
- Are Spring tests using the smallest useful context?
- Are integration tests using real infrastructure when integration behavior is the point?

## Common Migration Bugs

Watch for:

- `org.junit.Test` accidentally left in Jupiter test class,
- lifecycle annotations imported from wrong JUnit generation,
- `@BeforeAll` non-static methods without proper test instance lifecycle,
- parameterized tests missing `junit-jupiter-params`,
- Mockito extension missing so `@Mock` fields remain null,
- Spring extension replaced accidentally,
- JUnit 4 rules silently ignored after migration,
- exception tests only checking exception type but not message or state,
- static mocks leaking between tests,
- lenient mode hiding unused or wrong stubs.

## Testing Preservation Rule

If a migration breaks tests, determine whether production behavior, test assumptions, or test framework wiring changed.

Do not weaken assertions merely to pass upgraded test APIs. Update tests to express intended behavior and keep equivalent coverage.
