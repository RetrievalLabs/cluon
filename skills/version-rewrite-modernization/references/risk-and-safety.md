# Risk And Safety

Use this reference when selecting verification depth, adding tests, creating seams, or considering optional modernization.

## Change Classes

Tag significant changes as one of:

```text
REQUIRED_MIGRATION
BEHAVIOR_PRESERVING_REFACTOR
OPTIONAL_MODERNIZATION
INTENTIONAL_BEHAVIOR_CHANGE
COMPATIBILITY_LAYER
DEPENDENCY_CHANGE
BUILD_CHANGE
DATA_CHANGE
CONFIGURATION_CHANGE
```

Do not let optional modernization hide behavior changes. Do not preserve obsolete implementation styles when target-version features clearly improve code and can be verified.

## Modernization Decision Rule

Use target-version features when they provide clear value and are verifiable:

```text
CLEAR BENEFIT?
  NO  -> DON'T DO IT
  YES -> SEMANTICS KNOWN?
           NO  -> INVESTIGATE
           YES -> VERIFIABLE?
                    NO  -> DEFER
                    YES -> ADOPT
```

Useful modernization may include supported replacement APIs, immutable data carriers, modern control flow, improved concurrency, better framework abstractions, stronger type safety, removal of obsolete workarounds, or reduced boilerplate.

Before converting data-carrying types, inspect mutability, setters, inheritance, constructors, equality, serialization, reflection, binding, proxy requirements, ORM requirements, and no-argument constructor assumptions.

Before changing concurrency models, inspect downstream capacity, connection pools, rate limits, thread-local state, synchronization, ordering guarantees, observability assumptions, and backpressure.

## Risk Levels

`LOW`: isolated rename, package relocation, simple compatibility fix, obvious syntax equivalence. Verify with compile and focused tests.

`MEDIUM`: dependency replacement, DTO shape change, framework API migration, serialization-sensitive change, moderate call graph. Verify with compile, unit tests, characterization tests where useful, and relevant integration tests.

`HIGH`: persistence, security, transaction, concurrency, shared foundational components, cross-service contracts, or poorly tested business logic. Verify with stronger behavioral and integration checks.

## Safety Techniques

Use existing tests first. Add characterization tests when behavior is poorly understood. Characterization tests record what code does today, including branches, boundaries, nulls, exceptions, ordering, state transitions, serialization, emitted events, and authorization decisions.

Use seams, adapters, dependency injection, feature flags, or parallel implementations only when they reduce migration risk. Do not add abstractions without clear migration purpose.

Use differential testing when old and new implementations can run safely against same inputs. Do not double-execute destructive side effects unless shadow execution is explicitly safe.

## Completion Criteria

Migration is complete when applicable criteria are satisfied:

- Target version builds and application starts.
- Existing, characterization, migration-specific, and critical integration tests pass as appropriate.
- Required business behavior and public contracts are preserved.
- Intentional behavior changes and modernizations are understood and verified.
- Persistence, serialization, security, transaction, concurrency, operational behavior, and configuration remain compatible where relevant.
- Dependencies are target-version compatible.
- Important warnings are understood.
- Obsolete dependencies and temporary compatibility mechanisms are removed or explicitly tracked.
- Rollback implications are understood for risky changes.
