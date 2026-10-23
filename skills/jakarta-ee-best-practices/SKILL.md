---
name: jakarta-ee-best-practices
description: Use this skill when creating, reviewing, upgrading, or rewriting Jakarta EE and Java EE applications, including CDI, Jakarta REST, Jakarta Persistence, Jakarta Transactions, Jakarta Validation, Jakarta Security, Jakarta Concurrency, Jakarta Messaging, Jakarta Data, javax-to-jakarta namespace migration, managed resources, application-server portability, Jakarta EE 8 through 11 upgrades, or Jakarta EE 12 readiness checks.
metadata:
  mcpmarket-version: 1.0.0
---

# Jakarta EE Best Practices

Use this skill for Jakarta EE application work where behavior preservation, standard APIs, runtime portability, and controlled modernization matter.

## Workflow

1. Identify current Jakarta/Java EE version, Java version, runtime, deployment format, and Jakarta APIs in use.
2. Identify target Jakarta EE version, Java version, runtime, and required specifications.
3. Preserve observable behavior unless user explicitly requests behavior change.
4. Fix compatibility issues before optional modernization.
5. Prefer standard Jakarta APIs over vendor internals where practical.
6. Verify with focused unit tests and target-runtime integration or deployment checks when container behavior matters.

## Reference Routing

- Read `references/core-practices.md` before creating, reviewing, or changing Jakarta EE application code.
- Read `references/version-guidance.md` before Jakarta EE 8, 9, 9.1, 10, 11, or 12 planning and migration work.
- Read `references/migration-review.md` before non-trivial upgrades, rewrites, or code reviews.

## Guardrails

- Do not combine platform migration with unrelated architectural or stylistic rewrites.
- Do not blindly replace every `javax.*`; only Jakarta-owned APIs moved to `jakarta.*`.
- Do not weaken security, transaction semantics, persistence mappings, ID strategies, or API contracts to satisfy an upgrade.
- Do not use newer Jakarta EE features only because they exist.
- When user asks for latest/current Jakarta EE status, verify official Jakarta EE pages first.
