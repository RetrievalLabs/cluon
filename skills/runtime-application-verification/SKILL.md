---
name: runtime-application-verification
description: Use this skill when verifying that a modernized Java application builds, starts, connects to isolated runtime dependencies, reaches readiness, preserves API/business/security/database/messaging behavior, or matches legacy runtime behavior through deterministic live-application checks.
---

# Runtime Application Verification

Verify deployed behavior, not only compilation. Run the real packaged application with isolated infrastructure, deterministic data, live requests, observable assertions, and cleanup.

Use this skill after Java modernization, framework upgrades, dependency upgrades, configuration migration, persistence migration, or behavioral repair. Prefer evidence from the running application over source inspection alone.

## Workflow

1. Detect build system, application type, runtime profile, packaged artifact, ports, readiness signal, and available tests.
2. Build with the repository wrapper when present: `./mvnw clean verify`, `./gradlew clean build`, then fallback to `mvn` or `gradle`.
3. Discover runtime dependencies from application config, build files, Docker Compose, tests, migrations, and framework metadata.
4. Produce a runtime manifest before starting anything: artifact, command, profiles, ports, dependencies, readiness, tests, and planned scenarios.
5. Provision ephemeral containers or mocks for required infrastructure: databases, caches, brokers, search, SMTP, and external HTTP/SOAP services.
6. Initialize schema and data through application migrations or known project scripts. Keep fixtures deterministic.
7. Start the packaged artifact when practical, then wait for readiness with bounded timeout.
8. Run existing tests first, then live runtime scenarios against the running process.
9. Capture API responses, database state, emitted messages, external calls, security outcomes, logs, commands, exit codes, and artifacts.
10. Compare migrated behavior against expected behavior or legacy observations. Normalize nondeterministic values.
11. Write a structured verification report and always clean up temporary processes, containers, networks, and volumes unless state is needed for debugging.

## Discovery Checklist

Inspect only relevant sources:

- Build files and wrappers: Maven, Gradle, generated artifacts, integration-test tasks.
- Runtime config: `application.properties`, `application.yml`, profile files, Spring config, servlet/JAX-RS/SOAP/gRPC config.
- Infrastructure config: datasource, JPA, Flyway, Liquibase, Redis, Kafka, JMS, RabbitMQ, ActiveMQ, Elasticsearch, SMTP.
- Existing runtime assets: Docker Compose, Testcontainers tests, seed scripts, `schema.sql`, `data.sql`, migration scripts.
- Test evidence: JUnit, TestNG, MockMvc, WebTestClient, RestAssured, Failsafe, Gradle integration tests.
- Readiness candidates: actuator health, app health route, TCP port, startup log signal, lightweight request.

## Infrastructure Rules

- Use containers or mocks instead of production, shared, or developer-local infrastructure when an isolated replacement is possible.
- Use temporary credentials, isolated networks, random host ports, and disposable databases or schemas.
- Inject verification config through environment variables, command-line args, temporary profiles, or container env. Do not permanently change app config just for verification.
- Let Flyway, Liquibase, Hibernate initialization, or project scripts create schema. Record migration versions and failures.
- Mock external services with WireMock, MockServer, fake SMTP, or equivalent. Do not send real payments, emails, notifications, or external mutations.

## Runtime Checks

Verify only protocols and behaviors that the application actually uses:

- Startup: process stays alive, Spring context loads, beans initialize, dependencies connect, migrations finish, port opens, readiness passes.
- API: method, path, query, body, status, content type, headers, redirects, validation, errors, pagination, filtering, sorting.
- Security: anonymous rejection, authenticated success, role rejection/acceptance, CORS, CSRF, session behavior.
- Database: important inserts, updates, deletes, constraints, commits, rollbacks, and behaviorally relevant persisted values.
- Transactions: failed downstream operation leaves state unchanged when rollback is expected.
- External interactions: endpoint, operation, method, important headers, payload, call count, retry, timeout.
- Messaging: topic/queue, payload, headers, emitted/not emitted behavior, consumer handling.
- Scheduled and batch: invoke deterministically when possible; verify job/step status and produced records without waiting for production cron.
- Server-rendered UI: route, view, template rendering, model values, form submission, redirects, validation messages, static assets.
- Protocols: REST, SOAP, gRPC, WebSocket, Servlet, or JAX-RS based on discovered application surface.

## Behavioral Equivalence

When legacy and migrated apps can both run, use the same isolated dependency plan and deterministic scenarios:

```text
start legacy
seed fixture
run scenarios
capture observations
stop legacy
reset state
start migrated
seed fixture
run same scenarios
compare observations
```

Do not reuse mutated state between legacy and migrated runs. Normalize timestamps, UUIDs, generated IDs, trace IDs, request IDs, random ports, and host-specific values unless they carry business meaning.

## Failure Classification

Classify failures by layer so repair targets the right cause:

```text
BUILD_FAILURE
TEST_FAILURE
DEPENDENCY_START_FAILURE
DATABASE_MIGRATION_FAILURE
APPLICATION_START_FAILURE
READINESS_FAILURE
API_FAILURE
BUSINESS_BEHAVIOR_MISMATCH
DATABASE_STATE_MISMATCH
EXTERNAL_INTERACTION_MISMATCH
SECURITY_MISMATCH
CONFIGURATION_FAILURE
EVENT_MISMATCH
BATCH_FAILURE
PROTOCOL_FAILURE
```

Fail fast for build, dependency startup, migration, application startup, and readiness failures. Continue independent behavioral checks when safe so the report contains useful evidence.

## Report Format

Include:

- Runtime manifest: app type, artifact, command, profiles, port, dependencies, images, readiness, scenarios.
- Build evidence: command, exit code, duration, failed module/tests, generated artifact.
- Infrastructure evidence: containers/mocks started, health, injected config, migrations, seed data.
- Application evidence: startup logs, readiness result, process status.
- Scenario results: name, input, expected, actual, status, normalized fields, source evidence.
- Failure details: classification, entrypoint, related business method or rule when known, app logs, dependency logs.
- Summary counts: passed, failed, skipped, blocked.
- Cleanup status: stopped processes, removed containers/networks/volumes, preserved logs/report paths.

## Guardrails

- Never connect to production databases, brokers, or external services.
- Never use production credentials or secrets.
- Never disable security, migrations, transactions, or external interactions only to make verification pass.
- Never hide failing tests or rewrite expected behavior to match migrated output.
- Never assert irrelevant internal columns or byte-for-byte HTML/JSON when semantic assertions are enough.
- Preserve logs and reports needed for debugging, even when cleanup removes runtime resources.
