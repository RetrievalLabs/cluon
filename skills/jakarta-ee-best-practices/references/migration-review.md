# Jakarta EE Migration And Review

Use this reference before non-trivial upgrades, rewrites, or code reviews.

## Migration Workflow

### 1. Identify Current State

Determine:

- current Jakarta/Java EE version,
- Java version,
- application server,
- deployment format,
- Jakarta APIs used,
- third-party dependencies,
- database/persistence provider,
- messaging integrations,
- security model.

### 2. Identify Target State

Determine:

- target Jakarta EE version,
- target Java version,
- target runtime/application server,
- required specification versions.

### 3. Check Runtime Compatibility

Before modifying source code, verify that the application server supports target Jakarta EE version, target Java version, and required Jakarta specifications.

### 4. Upgrade Dependencies

Upgrade Jakarta-compatible persistence providers, REST implementations, CDI integrations, validation libraries, security integrations, testing libraries, build plugins, and annotation processors.

Do not assume old `javax.*` libraries are compatible with Jakarta EE 9+.

### 5. Make Smallest Required Source Changes

Perform compatibility changes first:

```text
javax.* -> jakarta.*
removed APIs -> supported replacements
obsolete runtime configuration -> supported configuration
Managed Beans -> CDI
```

Avoid unrelated refactors.

### 6. Compile Early

Compile after small migration steps. Do not accumulate hundreds of mechanical changes before verifying compilation.

### 7. Test Behavior

Run relevant unit, integration, persistence, REST, security, transaction, and deployment/startup tests.

For container-dependent behavior, test against actual target Jakarta runtime where possible.

### 8. Modernize Selectively

After compatibility is established, consider target-platform improvements:

```text
DTO -> record
legacy repository boilerplate -> Jakarta Data
legacy Date APIs -> java.time
unmanaged async work -> Jakarta Concurrency
appropriate blocking workloads -> managed virtual threads
vendor-specific feature -> standard Jakarta API
```

Each modernization needs a clear reason.

## Do Not Modernize Unrelated Syntax

During a Jakarta version migration, avoid unnecessary transformations such as:

```text
loops -> streams
classes -> records
switch -> new switch syntax
threads -> virtual threads
manual constructors -> generated constructors
POJOs -> Lombok
```

Allow such changes only when required by migration, removing deprecated or removed API usage, improving correctness, substantially reducing boilerplate, or providing demonstrated architectural or performance benefit.

Version migration and style modernization should remain separate concerns where practical.

## Testing Practices

Prefer unit tests for pure business logic.

Prefer integration tests for behavior involving CDI, JPA, Jakarta Transactions, Jakarta Security, Jakarta REST integration, interceptors, container lifecycle, and managed concurrency.

Do not mock Jakarta container behavior so heavily that tests no longer represent runtime behavior.

Critical migrations should include tests that establish behavior before migration and verify same behavior afterward.

## Review Checklist

Check:

- Is code compatible with declared Jakarta EE version?
- Is Java version compatible with target runtime?
- Are Jakarta APIs used instead of unnecessary vendor-specific APIs?
- Are CDI scopes and dependency lifecycles clear?
- Is business logic outside REST/Servlet transport classes?
- Are transaction boundaries explicit and sensible?
- Are persistence entities kept separate from public API contracts where appropriate?
- Are N+1 and lazy-loading risks controlled?
- Is Jakarta Validation used appropriately?
- Are container-managed resources preferred?
- Is concurrency managed by Jakarta runtime?
- Are removed/deprecated APIs avoided for target version?
- Are migrations limited to necessary or clearly beneficial changes?
- Is runtime-dependent behavior covered by integration tests?
- Has observable application behavior been preserved?

## Decision Rule

When deciding whether to use a newer Jakarta EE feature:

```text
Is it required for compatibility?
    yes -> migrate
    no  -> ask next question

Does it fix correctness, remove deprecated behavior,
reduce substantial boilerplate, or provide clear
performance/architectural benefit?
    yes -> consider adopting with tests
    no  -> keep existing implementation
```

Presence of a newer feature is not by itself a reason to rewrite working code.

## Target Outcome

Successful Jakarta EE migration leaves application:

- behaviorally equivalent unless intentional changes were requested,
- compatible with target Jakarta EE runtime,
- portable where practical,
- easier to maintain,
- free from removed APIs,
- tested at important integration boundaries,
- modernized only where change provides clear value.
