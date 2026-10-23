# Migration Protocol

Use this workflow for each non-trivial migration unit.

## Migration Unit Protocol

```text
1. Identify migration unit -> verify: source version, target version, affected component, reason for change known.
2. Inspect behavior and dependencies -> verify: implementation, callers, tests, configuration, contracts, and hidden dependencies reviewed.
3. Define invariants -> verify: required behavior, data, security, serialization, transaction, and operational contracts listed when relevant.
4. Understand target differences -> verify: breaking changes and semantic differences known from repository evidence or authoritative docs.
5. Assess modernization -> verify: optional target-version feature has clear benefit, known semantics, acceptable blast radius, and test path.
6. Rewrite smallest coherent unit -> verify: diff only contains requested migration work.
7. Compile and test -> verify: focused checks pass; broader checks match risk.
8. Compare behavior -> verify: each difference is required, intentional, or fixed as regression.
```

## Reasons For Change

Classify why component must change:

```text
REMOVED_API
DEPRECATED_API
RENAMED_API
PACKAGE_RELOCATION
SIGNATURE_CHANGE
SEMANTIC_CHANGE
LANGUAGE_CHANGE
RUNTIME_CHANGE
FRAMEWORK_CHANGE
FRAMEWORK_DEFAULT_CHANGE
CONFIGURATION_CHANGE
DEPENDENCY_CONFLICT
BUILD_CHANGE
SECURITY_CHANGE
SERIALIZATION_CHANGE
PERSISTENCE_CHANGE
```

## Inspection Scope

Inspect relevant callers, callees, interfaces, subclasses, factories, dependency injection, annotations, reflection, generated code, serialization, persistence, transactions, external APIs, events, lifecycle behavior, concurrency, tests, and build configuration.

Prioritize evidence in this order:

```text
existing tests
existing implementation
callers and integrations
configuration
repository documentation
version documentation
inference
```

Classify assumptions as `KNOWN`, `INFERRED`, or `UNKNOWN`. Investigate important `INFERRED` and `UNKNOWN` behavior before rewriting.

## Behavior Contracts

Record only invariants relevant to migration:

- Public contracts: method signatures, endpoints, schemas, status codes, headers, CLI behavior.
- Business behavior: calculations, validation, authorization, state transitions, return values, null handling, ordering, exceptions.
- Persistence: schemas, mappings, stored representations, generated queries, transactions.
- Integration: external API calls, events, message formats, queues, filesystem behavior.
- Operational behavior: startup, shutdown, health checks, logs, metrics, retries, timeouts.

Technical migration must not silently change business rules.

## Semantic Equivalence

Compilation proves type compatibility, not behavior compatibility. When replacing APIs, check defaults, null handling, exceptions, ordering, mutability, thread safety, resource ownership, lifecycle, serialization, encoding, precision, retries, timeouts, security, and performance characteristics.

Treat compiler errors and warnings as migration signals. Identify root cause before patching individual failures.
