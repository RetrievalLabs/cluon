---
name: spring-boot-config-modernization
description: Modernize legacy Spring configuration into idiomatic Spring Boot by classifying legacy config, preferring auto-configuration and properties, and preserving behavior without 1:1 translation.
---

# Spring Boot Configuration Modernization

Modernize behavior, not syntax. Legacy XML, `web.xml`, Java config, and environment-specific Spring files should usually become less configuration in Spring Boot.

Use this skill when migrating legacy Spring configuration to Spring Boot or reviewing such a migration. Do not use it for unrelated Spring feature work.

## Operating Principle

For each legacy configuration element, answer:

1. What runtime behavior does this provide?
2. Does Spring Boot already provide it?
3. If not, is it an external property, application-owned bean, annotation, or truly necessary Java config?

Prefer this path:

```text
legacy configuration
understood behavior
Spring Boot auto-configuration
application properties
annotations
explicit Java config only when necessary
```

## Classification

Classify every legacy configuration element before changing it:

- `AUTO`: Spring Boot already provides behavior. Remove legacy config.
- `PROPERTY`: Move runtime/environment values to `application.yml` or profile files. Never commit secrets.
- `ANNOTATION`: Convert application-owned beans to stereotypes such as `@Service`, `@Component`, `@Repository`, or `@Controller`; prefer constructor injection.
- `JAVA_CONFIG`: Keep explicit config only when Boot defaults are insufficient.
- `REMOVE`: Delete obsolete, duplicated, external-container-only, or no-longer-needed config.
- `REVIEW`: Stop and understand semantics before migrating.

Use `REVIEW` for JNDI, XA/JTA, multiple transaction managers, multiple persistence units, custom `BeanPostProcessor`, `FactoryBean`, custom filters, parent/child contexts, application-server integrations, custom `SessionFactory`, and anything security-sensitive or deployment-specific.

## Hard Rules

- Prefer Boot starters and auto-configuration over recreating legacy infrastructure.
- Do not create Java config just because equivalent XML existed.
- Do not add `@EnableWebMvc` for standard Spring Boot MVC. Use `WebMvcConfigurer` only for real MVC customization.
- Keep explicit configuration small and behavior-specific.
- Externalize environment-specific values and secrets.
- Collapse duplicate configuration to one source of truth.
- Preserve runtime behavior, but do not preserve insecure or obsolete settings blindly.
- Do not blindly replace `javax.*` with `jakarta.*`; inspect API ownership and target dependency versions.

## Common Decisions

### Web and MVC

- `web.xml` servlet infrastructure such as `ContextLoaderListener`, `DispatcherServlet`, encoding filters, multipart setup, and standard error pages is usually `AUTO` or `PROPERTY`.
- Remove `<mvc:annotation-driven>`, duplicate component scans, default servlet handlers, standard resource mappings, and default Jackson converter beans for normal Boot MVC.
- Move static assets to `src/main/resources/static/`, `public/`, or another Boot-supported resource location. Avoid custom resource handlers unless behavior differs from Boot defaults.
- Keep custom interceptors, formatters, argument resolvers, CORS behavior, and non-standard view resolution as `JAVA_CONFIG`, normally through focused `WebMvcConfigurer` methods.

### Datasource, JPA, and Transactions

- Replace hand-built `DriverManagerDataSource`, `BasicDataSource`, Tomcat pool, or DBCP pool beans with `spring.datasource.*` and Boot's pool selection unless the app requires a specific pool.
- Put pool tuning under the matching property namespace, usually `spring.datasource.hikari.*` when Hikari is used.
- Prefer Boot-managed JPA with `spring.jpa.*`; remove duplicated JDBC settings from `hibernate.cfg.xml` or `persistence.xml` where Boot manages them.
- Prefer `EntityManager`, Spring Data repositories, and Boot-managed transaction infrastructure over legacy `HibernateTemplate`, manual `SessionFactory`, and explicit transaction-manager beans.
- Remove `<tx:annotation-driven/>` when Boot provides transaction infrastructure; keep `@Transactional` behavior in application code.
- Treat multiple datasources, persistence units, and transaction managers as `REVIEW` first, then `JAVA_CONFIG` only after semantics are clear.

### Security

- Migrate Spring Security XML to focused `SecurityFilterChain` beans when custom rules exist.
- Preserve URL authorization, roles, login/logout behavior, session rules, remember-me behavior, access-denied behavior, and actuator/static-resource rules.
- Do not preserve MD5, plaintext passwords, hardcoded secrets, or disabled CSRF without justification.
- Use modern password hashing and externalized credentials.

### Application Beans

- Convert application-owned service, repository, controller, listener, and scheduled-task beans to annotations when component scanning from `@SpringBootApplication` covers their package.
- Keep third-party SDK clients, custom factories, custom Jackson modules, custom JMS listener factories, and complex Spring Batch jobs as small `JAVA_CONFIG` only when required.

### Properties and Profiles

- Prefer `application.yml` plus `application-dev.yml`, `application-test.yml`, and `application-prod.yml` for environment differences.
- Use profiles for different behavior, not merely different values.
- Move session timeout, server port, multipart limits, logging levels, Hibernate properties, broker URLs, and datasource credentials to properties.

### Messaging, Batch, Scheduling, Logging

- Prefer `@JmsListener` and injected `JmsTemplate`; move broker settings to properties. Do not change messaging technology unless requested.
- Convert Spring Batch XML jobs to modern `Job` and `Step` definitions while preserving job names, step order, chunk sizes, readers, processors, writers, listeners, retry/skip behavior, restartability, parameters, and metadata persistence.
- Find the actual scheduler before converting to `@Scheduled`; comments are not evidence. Account for multiple application replicas before enabling local scheduling.
- Remove Log4j 1.x. Use `logging.level.*` for simple logging and `logback-spring.xml` only for advanced behavior.

## Migration Workflow

1. Inspect dependencies, Java version, Spring version, Boot target, packaging, and deployment model.
2. Inventory all config files: XML, `web.xml`, Java config, properties, profiles, logging, Hibernate/JPA, security, messaging, batch, and container descriptors.
3. Detect duplicate concerns, especially datasource plus Hibernate, repeated component scans, repeated MVC setup, repeated transaction managers, and security split across XML and filters.
4. Add or verify a root-package `@SpringBootApplication` entry point.
5. Migrate external values into Boot properties with environment placeholders for secrets.
6. Migrate datasource, JPA, and transactions to Boot defaults unless review proves explicit config is needed.
7. Convert application-owned beans to annotations.
8. Remove legacy MVC and servlet infrastructure that Boot provides.
9. Migrate security, messaging, batch, scheduling, and logging based on behavior.
10. Remove obsolete config, then build, test, and verify runtime behavior.

## Validation

Verify the migrated application:

- starts successfully and resolves beans;
- maps controllers and serves static assets correctly;
- preserves security rules and authentication behavior;
- connects to the database and preserves transaction behavior;
- loads repositories, JMS listeners, batch jobs, templates, multipart handling, JSON output, profiles, and logging as applicable;
- commits no secrets;
- has less configuration unless explicit behavior requires otherwise.

## Migration Summary Format

When reporting a migration decision, use this format:

```text
Legacy:
spring-datasource.xml

Target:
application.yml + Boot DataSource auto-configuration

Classification:
PROPERTY + AUTO

Action:
remove XML

Behavior:
connection settings preserved
pool implementation moved to Boot default
credentials externalized
```
