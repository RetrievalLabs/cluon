---
name: java-build-tool-best-practices
description: Use this skill when creating, reviewing, upgrading, or rewriting Java Maven or Gradle builds, including pom.xml, Maven Wrapper, Maven 3.6/3.8/3.9/Maven 4 migration, build.gradle, build.gradle.kts, Gradle Wrapper, Gradle 6/7/8/9 migration, Java toolchains, compiler release/source/target settings, repositories, plugin versions, dependencyManagement, BOMs, Gradle platforms, version catalogs, dependency locking, multi-module builds, generated sources, packaging, publishing, CI compatibility, dependency graph preservation, or build-tool modernization during Java upgrades.
---

# Java Build Tool Best Practices

Use this skill for incremental Maven or Gradle modernization. Preserve build behavior, dependency resolution, plugin behavior, packaging, tests, generated sources, CI/CD compatibility, and reproducibility.

## Workflow

1. Detect build system and wrapper before editing files.
2. Inspect root build configuration first for multi-module projects.
3. Capture baseline with project wrapper and existing verification commands.
4. Separate build-tool upgrade, Java upgrade, framework upgrade, dependency overhaul, DSL conversion, and build cleanup.
5. Upgrade one compatibility boundary at a time: wrapper, build tool, required plugins, then required script fixes.
6. Compare dependency graph before and after each migration step.
7. Verify compile, tests, packaging, generated sources, publishing, CI config, and runtime smoke checks when applicable.

## Reference Routing

- Read `references/maven-modernization.md` before Maven build changes, Maven wrapper work, Maven plugin changes, or Maven 3 to 4 migration.
- Read `references/gradle-modernization.md` before Gradle build changes, wrapper upgrades, version catalog work, dependency locking, configuration cache work, or Gradle 6/7/8/9 migration.
- Read `references/migration-review.md` before non-trivial build modernization, dependency graph changes, repository changes, plugin upgrades, or CI-impacting edits.

## Detection

```text
pom.xml                  -> Maven
mvnw / .mvn/             -> Maven Wrapper
build.gradle             -> Gradle Groovy DSL
build.gradle.kts         -> Gradle Kotlin DSL
gradlew / gradle/wrapper -> Gradle Wrapper
```

Use wrapper commands when wrappers exist:

```bash
./mvnw clean verify
./mvnw dependency:tree
./gradlew clean build
./gradlew dependencies
```

## Guardrails

- Do not treat build-tool modernization as cleanup.
- Do not change repository precedence, dependency semantics, packaging, test discovery, generated sources, publishing, or CI behavior silently.
- Do not convert Gradle Groovy DSL to Kotlin DSL during version migration unless explicitly required.
- Do not replace Maven dependency management with Gradle-style catalogs, or Gradle catalogs with Maven-style management.
- Do not blindly exclude transitive dependencies.
- Do not upgrade every plugin to latest unless target build-tool version requires it.
- When user asks for latest/current Maven or Gradle facts, verify official Maven or Gradle documentation first.

## Plugin Contract Notation

- Maven plugins use Maven `groupId` and `artifactId` coordinates.
- Gradle plugins use the plugin ID. Gradle core plugin IDs such as `java` and `war` have no Maven group coordinate; represent them with an empty group and the plugin ID as artifact ID.
- A requirement for a Maven plugin applies only to a Maven build. A Gradle plugin requirement applies only to a Gradle build. When owner choices determine the build tool, express plugin requirements conditionally.
- Spring Boot supports both Maven and Gradle build plugins. Select the corresponding plugin for the chosen build tool; do not declare one build tool's plugin as a universal requirement.
