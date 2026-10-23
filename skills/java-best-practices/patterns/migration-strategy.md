---
name: Java 8 to 25 Migration Strategy
category: Java
tags: [java, migration, java-8, java-11, java-17, java-21, java-25, modernization, jdeps, jdeprscan]
activation:
  keywords: [migration, upgrade, java 8, java 11, java 17, java 21, java 25, jdeps, jdeprscan, removed api]
  file_patterns: ["**/*.java", "**/pom.xml", "**/build.gradle", "**/build.gradle.kts"]
---

# Java 8 to 25 Migration Strategy

## AI Quick Reference

**Purpose**: Plan safe Java 8 through Java 25 migrations.
**Key Rules**:
1. Prefer staged LTS jumps: Java 11, 17, 21, then 25
2. Fix build, dependency, runtime, and removed-API issues before optional source modernization
3. Use `jdeps --jdk-internals` and `jdeprscan --release 25`
4. Use Maven/Gradle toolchains and `--release` to make source and bytecode targets explicit
5. Treat preview/incubator features as opt-in modernization only
6. Preserve behavior first; modernize only when tests cover semantics

**Quick Commands**:

```bash
Harness generates the build report before migration agents start; read the supplied report for dependency and plugin context.
jdeps --jdk-internals <jar-or-classes>
jdeprscan --release 25 --class-path <classpath> <classes-or-jar>
```

---

## Human Documentation

### When to Apply

- Migrating Java 8/11/17/21 applications toward Java 25
- Reviewing source edits suggested by migration tooling
- Deciding whether new Java syntax is safe for maintained application code
- Handling removed modules, internal APIs, preview features, native access, or runtime warnings

### Migration Strategy

1. **Inventory first**: parse build files, resolve dependency and plugin graph, run source/API scanners, and identify runtime flags.
2. **Compile on an intermediate LTS**: make code compile and tests run on Java 11, 17, or 21 before using Java 25-only syntax.
3. **Upgrade dependencies before source rewrites**: bytecode, mocking, ORM, application-server, native-access, serialization, and observability libraries often own migration failures.
4. **Apply source modernization last**: use records, switch expressions, virtual threads, and scoped values only after behavior-preserving migration passes.
5. **Keep preview features explicit**: require `--enable-preview` and project approval for preview/incubator APIs.

### Version-by-Version Guidance

#### Java 9

- Java Platform Module System introduced modules, strong module boundaries, modular runtime images, and new command-line flags.
- Split packages and duplicate classes can break module-path builds.
- Reflection into JDK internals starts producing illegal-access warnings.
- Code assuming application class loader is `URLClassLoader` can fail.
- Keep legacy apps on classpath first; move to `module-info.java` only when dependencies are module-ready.
- Use `--add-exports` and `--add-opens` only as temporary migration flags.
- Remove `JAVA_HOME/jre`, `rt.jar`, `tools.jar`, and extension-directory assumptions.
- CLDR locale data became default. Use explicit `Locale` and explicit date/time/number patterns for persisted or asserted output.
- `List.of`, `Set.of`, `Map.of`, and `copyOf` factories reject nulls and return immutable collections. Use only when those semantics match.

#### Java 10

- `var` can be used for local variables with an initializer.
- Use `var` only where inferred type remains obvious. Do not change public API signatures.
- Version strings use a time-based scheme. Replace custom parsing with `Runtime.version()` or build-tool version helpers.

#### Java 11 LTS

- Java EE and CORBA modules were removed. `javax.xml.bind`, `javax.xml.ws`, `javax.activation`, `javax.annotation`, `javax.jws`, and `org.omg` references can fail.
- Add explicit standalone dependencies or migrate to Jakarta packages when framework version requires it.
- Do not mix `javax` source imports with Jakarta dependencies.
- `java.net.http.HttpClient` is standard. Use it for simple HTTP integrations only after matching timeout, proxy, TLS, pooling, retry, and observability behavior.
- Single-file source launch is useful for scripts and small utilities. Keep production builds under Maven or Gradle.

#### Java 12-13

- Switch expressions and text blocks were preview.
- Do not introduce Java 12/13 preview syntax in maintained code.
- Use final Java 14 switch expressions and final Java 15 text blocks instead.

#### Java 14

- Switch expressions became final.
- Convert only branch logic already shaped as value production.
- Preserve intentional switch fall-through. Arrow labels do not fall through.
- Helpful NullPointerException diagnostics can change exact exception messages. Avoid exact NPE message assertions unless they are public contract.

#### Java 15

- Text blocks became final.
- Use text blocks for SQL, JSON, XML, and expected-output tests.
- Verify indentation, trailing newline behavior, and `stripIndent`/`stripTrailing` effects before replacing string concatenation.
- Upgrade bytecode-generation libraries such as Byte Buddy, ASM, CGLIB, Mockito, Hibernate enhancer, and similar tools before Java 25 testing.

#### Java 16

- Records became final.
- Convert DTOs and value classes only when constructor validation, serialization, ORM mapping, and framework reflection behavior are compatible.
- Pattern matching for `instanceof` became final.
- Replace local `instanceof` plus cast idioms only when variable scope and null behavior stay unchanged.

#### Java 17 LTS

- Strong JDK encapsulation is default.
- Reflection into `java.*` internals can throw `InaccessibleObjectException`.
- `--illegal-access` no longer restores Java 8-era access.
- Replace internal API and reflection usage. Use `--add-opens` and `--add-exports` only as tracked temporary flags.
- Sealed classes and interfaces became final. Use them only when extension boundaries are intentional.

#### Java 18

- UTF-8 became default charset for Java SE APIs.
- Add explicit `StandardCharsets.UTF_8` or required legacy charset at file, stream, resource, and test-output boundaries.
- Run comparison tests with explicit encoding settings when persisted output or fixtures are charset-sensitive.

#### Java 19-20

- Virtual threads were preview.
- Do not migrate production thread pools based on Java 19/20 preview APIs.
- Wait for Java 21 final virtual thread APIs.

#### Java 21 LTS

- Virtual threads became final. Prefer them at request/task boundaries for blocking IO after measuring JDBC drivers, HTTP clients, locks, thread-local context propagation, and monitoring.
- Do not automatically replace all executors or pool virtual threads.
- Sequenced collections became final. Use `SequencedCollection`, `SequencedSet`, and `SequencedMap` only when encounter order is part of the contract.
- Pattern matching for `switch` and record patterns became final. Preserve null/default behavior and exhaustiveness.
- Dynamic Java agent loading emits warnings. Configure required agents at JVM startup and upgrade test/observability tools.

#### Java 22

- Foreign Function and Memory API became final.
- Migrate JNI or `Unsafe` only when native boundaries are isolated and covered by tests.
- Keep application code behind native adapters.
- Unnamed variables and patterns became final. Use `_` only for truly unused lambda, catch, and pattern variables.
- Multi-file source launch is useful for scripts and examples, not application packaging.

#### Java 23

- Markdown Javadoc is available. Do not bulk-convert existing Javadocs unless generated documentation is compared.
- String Templates preview was withdrawn. Replace `STR` and `StringTemplate` usage with `String.format`, `MessageFormat`, a template engine, or explicit builders.
- Implicitly declared classes and instance `main` methods were preview. Avoid preview entrypoint forms in production migration.

#### Java 24

- Native access warnings identify JNI, FFM, and native libraries needing explicit handling.
- Make native access explicit only for known modules.
- `sun.misc.Unsafe` memory-access methods emit warnings. Upgrade owning libraries instead of editing transitive callers directly.

#### Java 25 LTS

- Compact source files and instance `main` methods are final. Use them for small programs, scripts, and teaching examples; do not rewrite application entrypoints.
- Flexible constructor bodies are final. Use statements before `super(...)` or `this(...)` only where they remove awkward helper code and preserve initialization order.
- Scoped values are final. Use them for immutable request-scoped context, especially with virtual threads. Do not mechanically replace all `ThreadLocal` usage.
- Primitive patterns, module import declarations, structured concurrency, stable values, Vector API, and PEM encodings remain preview/incubator in Java 25. Use only with explicit project approval and build/runtime flags.
- Key Derivation Function API is available. Use after validating provider, algorithm, and compliance requirements.
- Compact object headers are a product feature. Benchmark memory-sensitive services under representative load.
- Experimental Graal JIT was removed. Remove `-XX:+UseGraalJIT` or use a GraalVM distribution intentionally.
- Selected obsolete APIs were removed. Use the generated `changes/removed_apis.yaml` for exact symbol detection.

### Anti-Patterns

- Mixing compile fixes, dependency upgrades, and optional syntax modernization in one untestable change
- Adding `--add-opens` or `--add-exports` without tracking owner and removal plan
- Replacing mature HTTP clients without matching behavior
- Converting DTOs to records before checking serializers, frameworks, and reflection
- Enabling preview features to make migration compile
- Treating runtime warnings from agents, native access, or `Unsafe` as harmless noise

### Examples

Use `java-best-practices` for feature-specific code examples after migration blockers are resolved.
