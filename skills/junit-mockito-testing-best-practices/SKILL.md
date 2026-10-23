---
name: junit-mockito-testing-best-practices
description: Use this skill when creating, reviewing, upgrading, or modernizing Java tests using JUnit 4, JUnit 5/Jupiter, JUnit Platform, JUnit Vintage, JUnit 6, Mockito 1 through 5, mockito-core, mockito-junit-jupiter, MockitoExtension, MockMvc or Spring test slices with Mockito, assertions, test lifecycle methods, parameterized tests, nested tests, dynamic tests, mocks, spies, captors, stubbing, strict stubs, static mocking, final-class mocking, test migration, flaky test repair, or incremental Java test modernization.
metadata:
  mcpmarket-version: 1.0.0
---

# JUnit / Mockito Testing Best Practices

Use this skill for Java test work where behavior preservation, focused tests, reliable migration, and incremental modernization matter.

## Workflow

1. Identify test stack: JUnit generation, Mockito version, build tool, Java version, Spring test stack, and CI runner.
2. Preserve tested behavior before modernizing test style.
3. Pick the smallest useful test level: unit, slice, integration, contract, or end-to-end.
4. Prefer clear assertions and explicit fixtures over broad mocks and hidden setup.
5. Separate required compatibility changes from optional test modernization.
6. Verify with targeted test execution and, for migrations, at least one representative full test run when practical.

## Reference Routing

- Read `references/core-practices.md` before creating, reviewing, or changing Java tests.
- Read `references/junit-version-guidance.md` before JUnit 4, JUnit 5, Jupiter, Vintage, Platform, or JUnit 6 migration work.
- Read `references/mockito-version-guidance.md` before Mockito version upgrades, mockito-junit-jupiter changes, static/final mocking, or strictness changes.
- Read `references/migration-review.md` before non-trivial test migrations or reviews.

## Guardrails

- Do not rewrite passing tests only for style during framework migration.
- Do not make tests weaker to satisfy upgraded APIs.
- Do not over-mock code that is cheaper and clearer to test directly.
- Do not mock infrastructure when test purpose is to verify integration behavior.
- When user asks for latest/current JUnit or Mockito facts, verify official documentation first.
