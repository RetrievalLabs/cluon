---
name: Modern Features
category: Java
tags: [java, var, text-blocks, records, sealed-classes, pattern-matching, switch-expressions, java-11, java-25]
activation:
  keywords: [var, text, block, record, sealed, permits, instanceof, switch, pattern, constructor, module, compact]
  file_patterns: ["**/*.java"]
---

# Modern Features Pattern

## AI Quick Reference

**Purpose**: Leverage Java 11-25 language and library features for cleaner, safer code.

**Key Rules**:
1. Use `var` only where inferred local type remains obvious
2. Use switch expressions for value-producing branch logic
3. Use text blocks for multi-line literals after whitespace verification
4. Use records for immutable data carriers (DTOs, value objects)
5. Combine sealed types, record patterns, and pattern matching for exhaustive handling
6. Use preview/incubator features only when build and runtime preview flags are explicit

**Quick Patterns**:

```java
// Local variable type inference (Java 10+, in scope for Java 11+ code)
var usersById = new HashMap<String, User>();

// Text block (Java 15+)
String query = """
    SELECT id, name
    FROM users
    WHERE active = true
    """;

// Record with validation
public record User(String id, String name) {
    public User {
        Objects.requireNonNull(id, "id cannot be null");
    }
}

// Sealed type hierarchy
public sealed interface Shape permits Circle, Rectangle {}
public record Circle(double radius) implements Shape {}
public record Rectangle(double w, double h) implements Shape {}

// Exhaustive pattern matching (Java 21+)
double area = switch (shape) {
    case Circle c -> Math.PI * c.radius() * c.radius();
    case Rectangle r -> r.w() * r.h();
};

// Flexible constructor body validation (Java 25)
public class PositiveRange extends Range {
    public PositiveRange(int start, int end) {
        if (start < 0 || end < 0) {
            throw new IllegalArgumentException("Range must be positive");
        }
        super(start, end);
    }
}
```

---

## Human Documentation

### When to Apply

- Creating immutable data transfer objects
- Modeling domain entities with value semantics
- Designing restricted type hierarchies (state machines, result types)
- Replacing instanceof + cast patterns
- Converting switch statements to expressions
- Replacing escaped multi-line strings with text blocks
- Replacing ad hoc first/last collection helpers with sequenced collections
- Validating constructor arguments before explicit constructor invocation
- Writing scripts, examples, or teaching code with compact source files

### Implementation Guide

#### 1. Local Variable Type Inference

Use `var` for local variables when the initializer exposes the type. Do not use it when the type carries domain meaning not visible on the right-hand side:

```java
var users = userRepository.findActiveUsers();
var totalsByCurrency = new EnumMap<Currency, BigDecimal>(Currency.class);

// Avoid - inferred type is not obvious
var result = service.execute(command);
```

#### 2. Switch Expressions

```java
// Expression form returns a value
String dayType = switch (day) {
    case MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY -> "Weekday";
    case SATURDAY, SUNDAY -> "Weekend";
};

// Use yield for complex cases
int score = switch (grade) {
    case "A" -> 4;
    case "B" -> 3;
    case "C" -> 2;
    default -> {
        log.warn("Unknown grade: {}", grade);
        yield 0;
    }
};
```

#### 3. Text Blocks

Text blocks preserve multi-line content without manual newline escapes or string concatenation:

```java
String json = """
    {
      "name": "Ada",
      "active": true
    }
    """;
```

Use text blocks for SQL, JSON, XML, and expected-output tests. Verify indentation and trailing newline behavior before replacing concatenated strings.

#### 4. Records

Records provide immutable data carriers with automatic `equals()`, `hashCode()`, and `toString()`:

```java
// Basic record
public record Point(int x, int y) {}

// Record with compact constructor validation
public record Email(String value) {
    public Email {
        if (value == null || !value.contains("@")) {
            throw new IllegalArgumentException("Invalid email: " + value);
        }
    }
}

// Record with computed properties
public record Rectangle(double width, double height) {
    public double area() {
        return width * height;
    }

    public double perimeter() {
        return 2 * (width + height);
    }
}
```

**Best use cases for records:**
- DTOs (Data Transfer Objects)
- Value objects (Money, Email, Address)
- API responses
- Compound map keys
- Configuration objects

#### 5. Sealed Classes

Sealed classes restrict which classes can extend them:

```java
// Define permitted subtypes
public sealed interface Result<T> permits Success, Failure {}
public record Success<T>(T value) implements Result<T> {}
public record Failure<T>(String error) implements Result<T> {}

// Use with pattern matching for exhaustive handling
public <T> T unwrap(Result<T> result) {
    return switch (result) {
        case Success<T> s -> s.value();
        case Failure<T> f -> throw new RuntimeException(f.error());
    };
}
```

#### 6. Pattern Matching for instanceof

```java
// Before (Java 16-)
if (obj instanceof String) {
    String s = (String) obj;
    return s.length();
}

// After (Java 16+)
if (obj instanceof String s) {
    return s.length();
}

// With guards
if (obj instanceof String s && s.length() > 10) {
    return s.substring(0, 10) + "...";
}
```

#### 7. Pattern Matching in Switch and Record Patterns (Java 21+)

```java
// Type patterns
String describe(Object obj) {
    return switch (obj) {
        case Integer i -> "Integer: " + i;
        case String s -> "String of length " + s.length();
        case List<?> list -> "List with " + list.size() + " elements";
        case null -> "null";
        default -> "Unknown: " + obj.getClass().getName();
    };
}

// Guards with when
String categorize(Shape shape) {
    return switch (shape) {
        case Circle c when c.radius() > 100 -> "Large circle";
        case Circle c -> "Small circle";
        case Rectangle r when r.width() == r.height() -> "Square";
        case Rectangle r -> "Rectangle";
    };
}
```

```java
String describePair(Object obj) {
    return switch (obj) {
        case Point(int x, int y) when x == y -> "diagonal";
        case Point(int x, int y) -> "point " + x + "," + y;
        default -> "unknown";
    };
}
```

#### 8. Sequenced Collections (Java 21+)

Use sequenced collection APIs when encounter order is part of the contract:

```java
SequencedMap<String, User> users = new LinkedHashMap<>();
users.put("first", firstUser);
users.put("last", lastUser);

User first = users.firstEntry().getValue();
User last = users.lastEntry().getValue();
SequencedMap<String, User> newestFirst = users.reversed();
```

Do not use sequenced APIs to imply order for unordered collection implementations.

#### 9. Foreign Function and Memory API (Java 22+)

Use the Foreign Function and Memory API as a replacement path for selected JNI or `Unsafe` memory access only when native boundaries are isolated and tested:

```java
try (Arena arena = Arena.ofConfined()) {
    MemorySegment segment = arena.allocate(ValueLayout.JAVA_INT);
    segment.set(ValueLayout.JAVA_INT, 0, 42);
}
```

Keep application code behind domain-specific native adapters.

#### 10. Java 23-24 Migration Signals

- Use Markdown Javadoc for new or heavily edited docs only when generated output is checked.
- Replace withdrawn string template preview usage with `String.format`, `MessageFormat`, a template engine, or explicit builders.
- Treat native access and `sun.misc.Unsafe` memory-access warnings as dependency upgrade signals before source edits.

#### 11. Java 25 Language Features

Flexible constructor bodies allow validation and other non-instance work before `super(...)` or `this(...)`:

```java
public class PositiveRange extends Range {
    public PositiveRange(int start, int end) {
        if (start < 0 || end < 0) {
            throw new IllegalArgumentException("Range must be positive");
        }
        super(start, end);
    }
}
```

Compact source files and instance `main` methods are permanent in Java 25. Use them for scripts, examples, and teaching code:

```java
void main() {
    IO.println("Hello, Java 25");
}
```

Primitive patterns and module import declarations are preview features in Java 25. Do not use them in production code unless the project explicitly enables preview features:

```java
// Preview - primitive patterns in switch
String describe(int value) {
    return switch (value) {
        case byte b -> "byte-sized: " + b;
        case int i when i > 0 -> "positive int: " + i;
        default -> "other";
    };
}
```

### Anti-Patterns

- Using records when you need mutable state
- Using records when you need inheritance
- Using `var` when the inferred type hides domain meaning
- Replacing concatenated strings with text blocks without checking whitespace
- Not leveraging exhaustive pattern matching with sealed types
- Using `default` in switch when all cases should be explicit
- Forgetting to handle `null` in pattern matching switch
- Enabling Java 25 preview features without explicit project approval
- Replacing conventional application entrypoints with compact source files in established production code

### Examples

See `SKILL.md` for comprehensive examples and the modern features section.
