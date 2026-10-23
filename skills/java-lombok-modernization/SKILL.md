---
name: java-lombok-modernization
description: >
  Safely reduce or remove Lombok from Java applications during modernization.
  Use when the repository contains Lombok annotations or dependencies such as
  @Data, @Value, @Getter, @Setter, @Builder, @Slf4j, @SneakyThrows,
  @RequiredArgsConstructor, @AllArgsConstructor, @NoArgsConstructor,
  @EqualsAndHashCode, @ToString, or @With. Prefer Java records and explicit
  Java where behavior and framework compatibility can be preserved.
---

# Java Lombok Modernization

Modernize Lombok usage conservatively.

The objective is not to eliminate Lombok at any cost. Remove it when modern Java or straightforward explicit Java provides an equivalent implementation without changing behavior, APIs, serialization, framework integration, or equality semantics.

## Rules

1. Preserve behavior before reducing Lombok.
2. Do not assume Lombok is incompatible with the target JDK.
3. Prefer records for genuine immutable data carriers.
4. Do not convert classes to records based only on `final` fields.
5. Inspect usages before changing generated methods or constructors.
6. Treat framework-managed classes conservatively.
7. Remove the Lombok dependency only after all required usages are gone.
8. Compile and test after transformations.

## Workflow

```text
Detect Lombok
     │
     ▼
Inventory annotations
     │
     ▼
Determine generated API
     │
     ▼
Inspect class semantics + call sites
     │
     ▼
Choose safe transformation
     │
     ▼
Apply smallest change
     │
     ▼
Compile
     │
     ▼
Run affected tests
     │
     ▼
Remove dependency only if unused
```

## Detect Lombok

Check build files for:

```text
org.projectlombok:lombok
```

Check source and test code for:

```text
import lombok.
```

Inventory usages of at least:

```text
@Data
@Value
@Getter
@Setter
@Builder
@SuperBuilder
@Slf4j
@Log
@Log4j
@Log4j2
@SneakyThrows
@NoArgsConstructor
@AllArgsConstructor
@RequiredArgsConstructor
@EqualsAndHashCode
@ToString
@With
@NonNull
@Cleanup
@Synchronized
```

Do not modify a class until the effective behavior of its Lombok annotations is understood.

## Record Conversion

Consider conversion to a record only when the class is primarily a value/data carrier.

Strong positive signals:

```text
DTO
Request
Response
Payload
Event
Message
Result
Metadata
Key
Value
Options

all logical state supplied during construction
no state mutation
no setters
no subclassing requirement
value-based equality
little or no behavioral logic
```

Example:

```java
@Value
public class UserResponse {
    String name;
    int age;
}
```

May become:

```java
public record UserResponse(
    String name,
    int age
) {}
```

### Record blockers

Do not automatically convert when any of these apply:

```text
@Entity
@Service
@Component
@Controller
@Repository

extends another class
mutable state
setters
state-transition methods
identity-based equality
framework lifecycle requirements
extra instance state
serialization incompatibility
constructor incompatibility
```

Framework-managed annotations are signals for deeper inspection, not proof by themselves.

## Accessor Compatibility

Record accessors differ from JavaBean getters.

Before:

```java
user.getName()
```

Record:

```java
user.name()
```

Before converting to a record:

1. Find all constructor usages.
2. Find all getter usages.
3. Find all setter usages.
4. Find reflection/property access.
5. Check serialization/deserialization.
6. Check framework binding.
7. Update call sites only when safe.

Do not assume record conversion is source-compatible.

## `@Data`

Expand the effective behavior mentally before transforming:

```text
@Data
 ├─ getters
 ├─ setters
 ├─ equals/hashCode
 ├─ toString
 └─ required constructor behavior
```

For immutable data carriers, consider a record.

For mutable/domain/framework classes, preserve the class and replace Lombok functionality explicitly only when beneficial.

### JPA

Treat this as high risk:

```java
@Entity
@Data
class User {
    ...
}
```

Do not mechanically generate Lombok-equivalent `equals`, `hashCode`, or `toString`.

Inspect:

```text
@Id
@EmbeddedId
@OneToOne
@OneToMany
@ManyToOne
@ManyToMany
lazy relationships
proxy behavior
existing identity semantics
```

Prefer explicit domain methods over blindly generated setters where appropriate.

## `@Value`

`@Value` classes are strong record candidates.

Still verify:

```text
inheritance
custom constructors
custom accessors
serialization
framework binding
equals/hashCode expectations
builder usage
```

If semantics match, prefer a record.

## `@Getter` / `@Setter`

Do not blindly replace these annotations with generated methods.

First determine which generated methods are actually used.

For a data carrier, consider a record.

For a domain object, preserve intentional behavior.

Do not replace meaningful operations such as:

```java
account.deposit(amount);
user.rename(name);
```

with generic setters.

Preserve public API compatibility unless affected call sites are intentionally migrated.

## `@RequiredArgsConstructor`

For dependency-injected components, an explicit constructor is a safe modernization when the Lombok dependency is being removed.

Before:

```java
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository repository;
}
```

After:

```java
@Service
public class PaymentService {

    private final PaymentRepository repository;

    public PaymentService(PaymentRepository repository) {
        this.repository = repository;
    }
}
```

Preserve:

```text
parameter order
visibility
annotations
null checks
framework injection semantics
```

## `@AllArgsConstructor` / `@NoArgsConstructor`

Generate explicit constructors only when required.

Preserve:

```text
visibility
parameter order
constructor annotations
forced initialization behavior
framework requirements
```

Be especially careful with:

```text
@NoArgsConstructor(force = true)
```

Do not reproduce behavior without understanding why it exists.

## `@Slf4j`

Replace with an explicit SLF4J logger when Lombok removal is desired.

Before:

```java
@Slf4j
public class UserService {

    void run() {
        log.info("running");
    }
}
```

After:

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UserService {

    private static final Logger log =
        LoggerFactory.getLogger(UserService.class);

    void run() {
        log.info("running");
    }
}
```

Preserve the existing logging framework.

Do not migrate SLF4J to JUL, Log4j, or another logging API as part of Lombok removal.

## `@Builder`

Do not automatically remove `@Builder`.

First search for:

```text
.builder()
.toBuilder()
```

Keep the builder when:

```text
many optional parameters exist
builder usage is widespread
construction readability improves
builder forms part of a public API
framework/tests depend on it
```

Possible transformations:

```text
@Builder
   │
   ├─ simple value object
   │      └─ record / constructor
   │
   ├─ builder API required
   │      └─ keep Lombok
   │
   └─ removing final Lombok dependency
          └─ explicit builder
```

Never replace a readable builder with an error-prone large positional constructor solely to remove Lombok.

Treat `@SuperBuilder` as higher risk because inheritance semantics are involved.

## `@SneakyThrows`

Prefer explicit exception semantics.

Before:

```java
@SneakyThrows
void load() {
    Files.readString(path);
}
```

Possible replacement:

```java
void load() throws IOException {
    Files.readString(path);
}
```

Alternatively handle/wrap the exception when required by the existing API.

Do not change checked exceptions to unchecked exceptions merely to remove Lombok.

Inspect callers before changing a method signature.

## `@EqualsAndHashCode`

Do not regenerate mechanically.

Determine whether equality is:

```text
value based
identity based
custom
inheritance sensitive
```

Preserve:

```text
exclude/include configuration
callSuper
onlyExplicitlyIncluded
custom methods
```

Records are appropriate only when record component equality matches existing semantics.

## `@ToString`

Preserve intentional exclusions and custom formatting.

Be careful with:

```text
JPA relationships
recursive object graphs
lazy-loaded properties
sensitive values
large collections
```

Do not automatically include every field.

## `@With`

A record may support equivalent immutable-update behavior manually:

```java
public record User(String name, int age) {

    public User withName(String name) {
        return new User(name, age);
    }
}
```

Only generate such methods if existing call sites require them.

## Annotation Combinations

Analyze annotations as a group.

For example:

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class User {
    ...
}
```

Do not independently remove `@Data`, then `@Builder`, then constructors without considering the resulting combined API.

Determine the effective generated API first.

## Framework Checks

Before transformation, detect usage with:

```text
JPA / Hibernate
Spring MVC
Spring WebFlux
Jackson
Jakarta Validation
JAXB
JAX-RS
GraphQL
Kafka
Avro
Protobuf
reflection-based libraries
```

Verify compatibility before changing:

```text
constructors
accessors
mutability
annotations
property names
serialization
deserialization
reflection behavior
```

Framework compatibility takes precedence over Lombok removal.

## Dependency Removal

Do not remove the Lombok build dependency until repository-wide Lombok usage is gone for the relevant module.

Check:

```text
src/main
src/test
generated source configuration
annotation processor configuration
all modules
build plugins
```

For Maven, remove Lombok dependency and annotation-processor configuration only when unused.

For Gradle, remove applicable entries such as:

```text
compileOnly
annotationProcessor
testCompileOnly
testAnnotationProcessor
```

only when unused.

## Verification

After each logical transformation:

```text
compile
run affected tests
run static analysis if available
inspect changed public APIs
```

For record conversions additionally verify:

```text
constructor behavior
accessor names
equals/hashCode
toString
serialization
deserialization
validation
reflection
framework binding
call sites
```

Run the project's normal full verification before declaring Lombok removal complete.

## Safety Policy

### Safe / preferred

```text
@Value DTO              → record
@Data immutable DTO     → record after API analysis
@Slf4j                  → explicit logger
@RequiredArgsConstructor→ explicit constructor
```

### Requires analysis

```text
@Getter
@Setter
@Builder
@With
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode
@ToString
```

### High risk

```text
@Data on @Entity
@EqualsAndHashCode on entities
@ToString on entity graphs
@SuperBuilder
@NoArgsConstructor(force = true)
@SneakyThrows on public APIs
```

## Stop Conditions

Do not perform a transformation when:

- generated behavior cannot be determined;
- call sites cannot be safely updated;
- framework compatibility is uncertain;
- equality semantics may change;
- serialization contracts may change unexpectedly;
- public API compatibility would be broken unintentionally;
- tests/build cannot provide sufficient verification.

In these cases, retain Lombok and report the blocker.

## Completion Criteria

Lombok modernization is complete when:

```text
desired safe transformations applied
        +
affected call sites migrated
        +
project compiles
        +
tests pass
        +
framework behavior preserved
        +
no required Lombok usages remain
```

Only then remove the Lombok dependency.

## Guiding Principle

Prefer:

```text
modern Java
+
explicit behavior
+
minimal dependencies
```

but never trade application correctness for the goal of making the repository Lombok-free.