# Gradle Modernization

Use this reference for Gradle projects, wrappers, build scripts, convention plugins, version catalogs, dependency locking, Java toolchains, repository changes, and Gradle version upgrades.

## Baseline

Detect:

```text
build.gradle             -> Gradle Groovy DSL
build.gradle.kts         -> Gradle Kotlin DSL
settings.gradle          -> Gradle settings, Groovy DSL
settings.gradle.kts      -> Gradle settings, Kotlin DSL
gradlew / gradle/wrapper -> Gradle Wrapper
```

For multi-project builds, inspect settings and root build logic before subprojects:

```text
settings.gradle(.kts)
    -> root build logic
    -> convention plugins
    -> modules
```

Prefer wrapper commands when `gradlew` exists:

```bash
./gradlew build
./gradlew build --warning-mode all
./gradlew dependencies
```

Capture dependencies and warnings before changing wrapper, plugins, repositories, dependency configurations, generated sources, or publishing.

## Version Strategy

Verify current Gradle compatibility from official Gradle docs before latest/current guidance.

As of August 28, 2026, Gradle current docs list version `9.7.1`; Gradle requires JVM 17 through 26 to run; Java 25 support starts at Gradle `9.1.0` for both toolchains and running Gradle.

Use small steps:

```text
Gradle 6
    -> Gradle 7
    -> Gradle 8
    -> Gradle 9
```

Intermediate steps may be skipped only when official compatibility guidance and project plugin compatibility make jump low risk. Never skip validation.

Upgrade wrapper with wrapper task:

```bash
./gradlew wrapper --gradle-version <target-version>
./gradlew clean build
./gradlew dependencies
```

## Gradle 6 to 7

Treat Gradle 6 as legacy source. First run:

```bash
./gradlew build
./gradlew build --warning-mode all
```

Capture deprecations, custom tasks, plugins, dependency configurations, generated sources, and publishing configuration.

Resolve old dependency configurations:

```text
compile        -> implementation or api
runtime        -> runtimeOnly
testCompile    -> testImplementation
testRuntime    -> testRuntimeOnly
```

For libraries, prefer `java-library` and choose `api` only for dependencies exposed in public API.

Do not convert Groovy DSL to Kotlin DSL during version migration.

## Gradle 7 to 8

Resolve Gradle 7 deprecations before moving to Gradle 8. Pay attention to custom tasks, plugin APIs, convention plugins, and eager task configuration.

Prefer lazy task configuration:

```kotlin
tasks.register("generateCode") {
}
```

Prefer named task configuration:

```kotlin
tasks.named<Test>("test") {
    useJUnitPlatform()
}
```

Adopt build cache only when project behavior and CI setup make it appropriate:

```properties
org.gradle.caching=true
```

Test configuration cache compatibility separately. Do not enable it as part of a version migration unless requested or already expected by project policy.

## Gradle 8 to 9

Before Gradle 9:

1. Establish clean Gradle 8 build.
2. Run with all warnings enabled.
3. Update incompatible plugins.
4. Remove deprecated Gradle APIs.
5. Verify custom build logic.
6. Verify Java compatibility.
7. Update wrapper.

Gradle 9 removes many APIs deprecated in earlier releases. Treat script, plugin, and convention-plugin warnings as blockers before wrapper upgrade.

## Dependencies

Prefer version catalogs for centralized dependency declarations when project already uses catalogs or user asks for catalog adoption:

```toml
[versions]
guava = "..."

[libraries]
guava = { module = "com.google.guava:guava", version.ref = "guava" }
```

Use:

```kotlin
implementation(libs.guava)
```

Do not introduce version catalogs during compatibility migration unless it directly reduces migration risk or is isolated and independently verifiable.

Keep distinct roles clear:

```text
Version catalog   -> declares requested versions
Platform / BOM    -> aligns and constrains versions
Dependency lock   -> records resolved versions
```

For reproducible resolution, consider dependency locking only as an isolated change:

```kotlin
dependencyLocking {
    lockAllConfigurations()
}
```

Investigate dependency behavior with:

```bash
./gradlew dependencies
./gradlew dependencyInsight --dependency <dependency> --configuration runtimeClasspath
```

Do not blindly exclude transitive dependencies.

## Java Compatibility

Build-tool runtime JDK and Java compilation target are separate. Verify:

```text
Gradle version
    -> JDK running Gradle
    -> Java toolchain / compilation target
    -> plugins
    -> framework generation
```

Prefer Java toolchains for Gradle:

```kotlin
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}
```

Do not assume old Gradle or plugin versions can run on a new JDK because application code targets that Java version.

## Repositories and Plugins

Centralize repositories where practical:

```kotlin
dependencyResolutionManagement {
    repositories {
        mavenCentral()
    }
}
```

Do not silently change repository precedence.

Treat Gradle plugins as compatibility boundaries: Java, Spring Boot, Kotlin, Android Gradle Plugin, SpotBugs, Checkstyle, JaCoCo, Protobuf, publishing, code generation, and custom plugins.

Upgrade build tool first, then make minimum required plugin changes, verify, and only then do optional build modernization.
