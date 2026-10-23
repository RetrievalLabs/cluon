---
name: version-rewrite-modernization
description: Use this skill when rewriting an existing codebase for a newer language, runtime, framework, library, SDK, or platform version, including major-version upgrades, removed or deprecated APIs, package relocations, dependency incompatibilities, configuration changes, framework default changes, or deliberate target-version modernization. This skill is for migrations and rewrites of existing systems, not greenfield development.
---

# Version Rewrite Modernization

Use existing implementation as behavioral reference. Reimplement system correctly on target version, preserve required behavior and external contracts, and adopt target-version capabilities only when benefit, semantics, blast radius, and verification are understood.

## Priorities

1. Preserve required business behavior.
2. Reach target-version compatibility.
3. Preserve external contracts unless intentionally changed.
4. Understand dependencies and semantic differences before rewriting.
5. Keep changes small, focused, and independently verifiable.
6. Adopt target-version capabilities when they provide clear verified value.
7. Avoid unrelated redesign.
8. Verify continuously.
9. Remove obsolete compatibility code after new implementation is proven.

## Reference Routing

- Read `references/protocol.md` before non-trivial migration work.
- Read `references/risk-and-safety.md` when classifying changes, adding tests, creating seams, or considering optional modernization.
- Read `references/domain-checks.md` when migration touches persistence, serialization, security, transactions, configuration, generated code, dependencies, or multi-module builds.

## Required Plan Shape

Before editing, state assumptions and success criteria:

```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Stop and investigate when important behavior requires guessing.
