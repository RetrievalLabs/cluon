---
name: soap-modernization
description: Use this skill when discovering, reviewing, or modernizing Java SOAP services or clients for modern Spring Boot and Java, including WSDL/XSD contracts, JAX-WS, Spring-WS, Apache CXF, Axis/Axis2, JAXB, javax-to-jakarta SOAP APIs, generated sources, SOAP faults, SOAP headers, and WS-Security.
metadata:
  mcpmarket-version: 1.0.0
---

# SOAP Modernization

Modernize SOAP implementations without accidentally changing external contracts. Default to preserving SOAP unless contract replacement is explicit and all affected consumers are known, controlled, and inside the migration boundary.

## Workflow

1. Discover SOAP artifacts: WSDL, XSD, endpoints, clients, generated SOAP/JAXB sources, framework configuration, security configuration, and SOAP dependencies.
2. Identify technologies in use: JAX-WS, Spring-WS, Apache CXF, Axis/Axis2, JAXB, `javax.jws.*`, `javax.xml.ws.*`, `jakarta.jws.*`, and `jakarta.xml.ws.*`.
3. For each SOAP contract, identify producer, consumers, whether consumers are internal or external, whether consumers are known, and whether producer and consumers are inside the migration boundary.
4. Choose migration strategy before editing code.
5. Prefer supported Spring Boot-compatible SOAP stacks: Spring Web Services for schema or contract-first services; Apache CXF for existing JAX-WS/CXF applications where preserving programming model and WSDL matters.
6. Regenerate large generated SOAP/JAXB source trees from WSDL/XSD with modern tooling instead of manually rewriting them.
7. Keep SOAP endpoints thin. Put business behavior in application services or domain code when restructuring transport classes.
8. Verify contract, security, fault, parsing, response, and side-effect compatibility after migration.

## Decision Rule

Preserve SOAP when any of these are true:

- External consumers exist.
- Consumers are unknown.
- Consumers cannot be migrated together.
- Backward compatibility is required.
- API redesign is not explicitly authorized.

SOAP to REST is eligible only when all of these are true:

- Contract replacement is intentional.
- All relevant consumers are known and controlled.
- Producer and consumers are inside migration boundary.
- Migration updates every affected producer and consumer.
- Equivalent behavior can be verified.

Do not infer that a SOAP contract is internal because its implementation exists in the same repository. Do not convert SOAP to REST only because SOAP is legacy.

## Preserve Contract

Treat existing WSDL and XSD files as compatibility artifacts unless contract redesign is requested. Preserve namespaces, service names, ports, bindings, operation names, SOAPAction values, message structures, fault structures, required headers, and security semantics.

Prefer this path:

```text
Existing WSDL/XSD
  -> modern SOAP tooling
  -> generated Jakarta-compatible classes
  -> handwritten adapters/endpoints
```

Do not rename contract identifiers to make them look modern.

## Dependencies

Replace obsolete SOAP runtime dependencies with versions compatible with target Java and Spring Boot versions. Verify SOAP runtime, JAXB runtime, WSDL tooling, generated sources, and framework dependencies together.

Handle Java EE to Jakarta migration deliberately:

```text
javax.jws.*       -> jakarta.jws.*
javax.xml.bind.*  -> jakarta.xml.bind.*
javax.xml.ws.*    -> jakarta.xml.ws.*
```

Do not replace packages blindly. Some `javax.*` packages remain valid JDK APIs.

## Faults And Security

Discover existing SOAP faults and triggering conditions. Preserve fault names, structures, codes where contractually significant, and business failure semantics. Do not turn known SOAP faults into generic server errors.

Detect WS-Security, UsernameToken, X.509 certificates, XML signatures, XML encryption, timestamps, WS-Addressing, and custom SOAP headers. Migrate security behavior to supported modern equivalents without weakening required semantics. HTTPS alone is not a replacement for SOAP security.

## REST Migration

When SOAP to REST is explicitly allowed, migrate business semantics rather than mechanically converting XML operations to JSON endpoints. Use HTTP semantics based on behavior and side effects, not operation names alone. Map WSDL operations to resources or actions, XSD messages to REST DTOs, SOAP faults to HTTP status and error contracts, and SOAP security to appropriate API security. Generate or update OpenAPI. Remove SOAP endpoints only after every affected client is migrated and verified.

## Verification

For preserved SOAP contracts, compare the same SOAP requests against legacy and modern implementations. Verify WSDL compatibility, XSD compatibility, namespaces, operations, SOAPAction, request parsing, response structure, SOAP faults, required headers, authentication, authorization, WS-Security behavior, and business side effects.

Exact byte-for-byte XML equality is not required unless the contract requires it. Semantic and contract compatibility are required.

Run relevant unit, integration, SOAP contract, end-to-end, security, startup, and build/package tests. Add characterization tests when required to prove compatibility. Successful compilation alone is not successful SOAP migration.

