# Spring MVC Migration Safety

Use this reference before non-trivial Spring MVC upgrades, rewrites, or reviews that affect public HTTP behavior.

## Required Versus Optional Modernization

Always distinguish compatibility changes from modernization opportunities.

### Required Compatibility Changes

Examples:

```text
javax.servlet -> jakarta.servlet
javax.validation -> jakarta.validation
removed/deprecated Spring APIs
incompatible path matching behavior
Servlet API compatibility
framework signature changes
```

These may be necessary for target Spring version.

### Optional Modernization

Examples:

```text
class DTO -> record
platform threads -> virtual threads
custom errors -> ProblemDetail
XML configuration -> Java configuration
custom API versioning -> Spring API versioning
MVC -> WebFlux
```

Do not automatically perform optional modernization merely because target version supports it.

Apply optional modernization only when:

1. It provides concrete benefit.
2. Existing behavior can be preserved.
3. Dependencies support it.
4. Tests can verify change.
5. It does not unnecessarily expand migration scope.

## Migration Flow

```text
Understand existing behavior
        -> identify version incompatibilities
        -> make smallest compatible change
        -> compile
        -> run tests
        -> verify HTTP contracts
        -> continue
```

Preserve unless intentionally changing public contract:

- endpoint paths
- HTTP methods
- request formats
- response formats
- status codes
- headers
- validation behavior
- authentication/authorization behavior
- exception semantics
- transaction boundaries

Version migration and architectural modernization are related but separate concerns. Never rewrite working MVC architecture solely because newer Spring version provides newer feature.

## HTTP Contract Review

Check controller changes for:

- path and path variable compatibility,
- query parameter defaults and required flags,
- request body shape,
- media type negotiation,
- response status codes,
- response body JSON fields and null handling,
- response headers,
- validation failure shape,
- exception mapping,
- security behavior,
- CORS behavior where relevant.

Run serialization-focused tests when DTOs, Jackson configuration, message converters, records, validation, or error bodies change.

## Path Matching And Content Negotiation

Modern Spring MVC uses parsed `PathPattern` matching. Avoid ambiguous routes and complex wildcard behavior.

Do not migrate path matching rules without tests for important routes.

Avoid suffix-based content negotiation such as `/users.json` for new APIs. Prefer `Accept` header content negotiation.

When preserving old clients requires suffix paths, treat them as explicit compatibility behavior and test them.

## WebFlux Decision Rule

Do not migrate Spring MVC to WebFlux solely because WebFlux is newer or reactive.

Keep Spring MVC when application is mostly imperative/blocking, uses JPA/Hibernate/JDBC, or relies on Servlet ecosystem integrations.

Consider WebFlux only when there is real need for reactive non-blocking I/O and dependent libraries support non-blocking behavior end to end.

## Review Checklist

Check:

- Are controllers thin?
- Are service and repository responsibilities separated?
- Are constructor-injected dependencies explicit?
- Are DTOs used for public API contracts?
- Is Bean Validation applied at HTTP boundary?
- Are business validations in service/domain layer?
- Is exception handling centralized?
- Are errors free of sensitive implementation details?
- Are HTTP methods and status codes semantically correct?
- Are transactions outside controllers?
- Is Spring Boot MVC configuration extended without accidental `@EnableWebMvc` takeover?
- Are `javax.*` to `jakarta.*` changes limited to moved Java EE APIs?
- Are path matching/content negotiation changes covered by tests?
- Are serialization contracts preserved?
- Is optional modernization justified and verified?
