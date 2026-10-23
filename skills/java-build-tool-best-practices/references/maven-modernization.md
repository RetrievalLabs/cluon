# Maven Modernization

Use this reference for Maven projects, parent POMs, modules, wrappers, plugin changes, dependency management, repository changes, and Maven version upgrades.

## Baseline

Detect:

```text
pom.xml      -> Maven project
mvnw         -> Maven Wrapper
.mvn/        -> Maven Wrapper/configuration
```

For multi-module builds, inspect root `pom.xml` before modules. Preserve:

```text
parent pom
    -> dependencyManagement
    -> pluginManagement
    -> modules
```

Prefer wrapper commands when `mvnw` exists:

```bash
./mvnw clean verify
./mvnw dependency:tree
./mvnw help:effective-pom
```

Capture dependency tree and effective POM before changing versions, repositories, exclusions, or plugin management.

## Version Strategy

Verify current Maven status from official Maven docs before latest/current guidance.

As of August 28, 2026, Apache Maven docs list Maven `3.9.16` as current maintained Maven 3 release, Maven `3.8.9` and earlier as EOL, Maven `3.10.0-rc-1` as release candidate, and Maven 4.0 as not yet GA.

Use small steps:

```text
older Maven 3.x
    -> healthy Maven 3.8/3.9 build
    -> latest supported Maven 3.9.x
    -> Maven 4 test only after warnings and incompatible plugins are handled
```

Treat Maven 4 as a separate migration. Do not combine Maven 3 to 4, Java upgrade, Spring upgrade, dependency overhaul, and POM restructuring into one change.

Before Maven 4:

1. Reach healthy Maven 3.9.x build.
2. Remove Maven warnings.
3. Update incompatible plugins/extensions.
4. Verify custom plugins and extensions.
5. Establish clean test baseline.
6. Test Maven 4 separately.

## Maven 3.6 and 3.8

Treat Maven 3.6.x as legacy baseline. Prioritize lifecycle preservation, deprecated plugin discovery, dependency conflicts, Java version configuration, and wrapper introduction when missing.

For Maven 3.8.x, inspect repository security and resolution behavior. Pay attention to HTTP repositories, mirrors, repository configuration, and plugin repositories. Prefer HTTPS, but do not silently change repository precedence.

## Maven 3.9

Use Maven 3.9.x as preferred Maven 3 modernization target when project constraints permit.

Modernize toward:

- explicit plugin versions,
- reproducible builds,
- centralized dependency management,
- Maven Wrapper,
- current compiler configuration,
- cleaner repository configuration.

Prefer this when project requirements permit:

```xml
<properties>
    <maven.compiler.release>21</maven.compiler.release>
</properties>
```

Do not replace distinct `source` and `target` settings when project intentionally compiles with non-matching settings or uses plugin behavior that requires explicit configuration.

## Dependencies

Prefer `dependencyManagement` for central version management.

For BOM ecosystems such as Spring Boot, prefer supported BOMs:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

Do not manually override individual transitive versions without understanding BOM and dependency-management rules.

Use exclusions narrowly:

```xml
<exclusions>
    <exclusion>
        <groupId>...</groupId>
        <artifactId>...</artifactId>
    </exclusion>
</exclusions>
```

Never remove transitive dependency solely because application code does not directly reference it.

## Plugins and Repositories

Treat Maven plugins as compatibility boundaries: compiler, surefire, failsafe, shade, war, jar, protobuf, OpenAPI, code generation, formatting, static analysis, and custom plugins.

Before upgrading Maven:

1. Identify important plugins and extensions.
2. Check target Maven compatibility.
3. Make minimum plugin changes required by target Maven and JDK.
4. Verify lifecycle, packaging, tests, and generated sources.

Inspect `repositories`, `pluginRepositories`, and `settings.xml` mirrors. Repository changes can alter resolved artifacts even when dependency declarations stay unchanged.
