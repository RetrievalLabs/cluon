# Build Migration Review

Use this reference before non-trivial Maven or Gradle modernization, dependency graph changes, repository changes, plugin upgrades, and CI-impacting edits.

## Success Criteria

Define success criteria before edits:

```text
1. Detect build system and wrapper -> verify: root build files and wrapper files inspected.
2. Capture baseline -> verify: clean build/test command, dependency graph, and warnings captured or blocker recorded.
3. Make one scoped migration step -> verify: diff touches only required build files.
4. Compare behavior -> verify: dependency graph, packaging, generated sources, test execution, publishing, and CI behavior checked where applicable.
```

## Separation Rules

Keep migrations separate unless compatibility requires coupling:

```text
build-tool upgrade
Java upgrade
framework upgrade
dependency overhaul
Groovy DSL to Kotlin DSL conversion
repository restructuring
module restructuring
optional cleanup
```

Decision rule:

```text
Is change required for target Maven/Gradle version?
    Yes -> make change.
    No  -> does it directly reduce migration risk?
        Yes -> consider isolated change.
        No  -> defer.
```

## Dependency Graph Preservation

Before modernization:

```bash
./mvnw dependency:tree
./gradlew dependencies
```

After modernization, compare:

- version changes,
- removed dependencies,
- new dependencies,
- conflict-resolution changes,
- BOM/platform changes,
- exclusions,
- runtime dependencies.

Compilation alone does not prove dependency behavior was preserved.

## Plugin Checks

Identify plugins before upgrading build tool:

```text
Maven Compiler Plugin
Maven Surefire
Maven Failsafe
Maven Shade Plugin
Gradle Java Plugin
Spring Boot Plugin
Kotlin Plugin
SpotBugs
Checkstyle
JaCoCo
Protobuf plugins
custom plugins
```

For each important plugin, check target build-tool and JDK compatibility. Upgrade only plugins needed for compatibility, unless user asks for broader plugin modernization.

## Repository Checks

Inspect:

```text
Maven repositories
Maven pluginRepositories
Maven settings.xml mirrors
Gradle repositories
Gradle pluginManagement repositories
Gradle dependencyResolutionManagement repositories
CI-provided repository credentials and mirrors
```

Prefer trusted HTTPS repositories. Do not silently change repository precedence.

## Verification

Run project pipeline after each migration step:

```bash
./mvnw clean verify
./mvnw dependency:tree
./gradlew clean build
./gradlew dependencies
```

Also verify when applicable:

- unit tests,
- integration tests,
- packaging,
- generated code,
- annotation processors,
- Docker image creation,
- publishing,
- CI pipelines,
- application startup,
- runtime smoke tests.

Record blockers explicitly when commands cannot run due to missing credentials, network restrictions, unsupported local JDK, unavailable services, or broken pre-existing baseline.

## Official Sources

Use official docs for latest/current guidance:

- Maven release history: `https://maven.apache.org/docs/history.html`
- Maven Wrapper: `https://maven.apache.org/tools/wrapper/`
- Maven Compiler Plugin release setting: `https://maven.apache.org/plugins/maven-compiler-plugin/examples/set-compiler-release.html`
- Maven Dependency Plugin tree goal: `https://maven.apache.org/plugins/maven-dependency-plugin/tree-mojo.html`
- Gradle compatibility matrix: `https://docs.gradle.org/current/userguide/compatibility.html`
- Gradle upgrade guides: `https://docs.gradle.org/current/userguide/upgrading_version_8.html` and `https://docs.gradle.org/current/userguide/upgrading_major_version_9.html`
- Gradle Wrapper: `https://docs.gradle.org/current/userguide/gradle_wrapper.html`
- Gradle Java toolchains: `https://docs.gradle.org/current/userguide/toolchains.html`
- Gradle version catalogs: `https://docs.gradle.org/current/userguide/version_catalogs.html`
- Gradle platforms/BOMs: `https://docs.gradle.org/current/userguide/platforms.html`
