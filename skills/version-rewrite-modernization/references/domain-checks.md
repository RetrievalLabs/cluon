# Domain Checks

Use this reference when migration touches high-risk domains, dependency graphs, or multi-module builds.

## High-Risk Domains

For persistence, check schema compatibility, column types, defaults, constraints, enums, generated SQL, timestamps, precision, transaction behavior, and rollback path.

For serialization, verify property names, null handling, date/time formats, enum and numeric representation, polymorphism, unknown fields, and custom serializers.

For security, verify authentication, authorization, filter order, CSRF, CORS, password handling, sessions, tokens, tenant isolation, and validation.

For transactions, verify boundaries, propagation, isolation, rollback conditions, proxy behavior, exception handling, async boundaries, and nested transactions.

For configuration, inspect renamed or removed properties, changed defaults, environment variables, profiles, secrets, deployment configuration, and silently ignored settings.

For generated code, inspect annotation processors, schemas, generators, metamodels, generated clients, and build-time code generation.

## Dependency Analysis

Analyze direct dependencies, transitive dependencies, BOMs, dependency management, version conflicts, removed or renamed artifacts, scopes, runtime dependencies, test dependencies, annotation processors, and build plugins.

For large version jumps, account for breaking changes across intermediate releases, not only final target version.

## Multi-Module Analysis

For multi-module repositories, inspect parent build files, shared configuration, internal libraries, module dependency order, shared data types, generated code, test fixtures, and integration modules. Migrate foundational modules conservatively.
