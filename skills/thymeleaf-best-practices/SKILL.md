---
name: thymeleaf-best-practices
description: Use this skill when creating, reviewing, or migrating Thymeleaf server-rendered views, especially full JSP, JSPX, JSTL, Spring form tag, JSP tag file, custom JSP tag, or InternalResourceViewResolver migrations to Thymeleaf 3.1.5.RELEASE in Spring MVC applications.
metadata:
  mcpmarket-version: 1.0.0
---

# Thymeleaf Best Practices

Use this skill for Spring MVC server-rendered view work where JSP behavior must
be understood, migrated, verified, and removed rather than coexisting with
Thymeleaf.

## Workflow

1. Discover every active JSP, JSPX, JSP tag file, taglib, JSP include, JSP
   resolver, servlet mapping, error page, forward, and dependency before editing.
2. Map controller/view relationships and preserve routes, HTTP methods, request
   parameters, path variables, redirects, session behavior, validation, security,
   CSRF, localization, forms, JavaScript contracts, and rendered behavior.
3. Classify JSP logic as presentation, formatting, validation, authorization,
   business logic, workflow logic, data access, side effect, or infrastructure.
4. Extract non-presentation behavior into controllers, services, policies, view
   models, or security configuration before converting templates.
5. Detect existing view technology and configured template/static locations
   before moving files. If Thymeleaf is already active, preserve its templates
   and modernize configuration/dependencies instead of doing a JSP-style
   migration.
6. Convert JSP views to Thymeleaf `3.1.5.RELEASE`, normally under
   `src/main/resources/templates/`, unless `spring.thymeleaf.prefix` or custom
   template resolvers define another location. Move browser assets to
   `src/main/resources/static/` unless custom static resource locations are
   configured.
7. Remove JSP views, tag files, custom JSP infrastructure, JSP view resolvers,
   JSP servlet configuration, and unused JSP dependencies only after equivalent
   Thymeleaf behavior is verified.
8. Run a final zero-JSP search and application verification before declaring the
   migration complete.

## Reference Routing

- Read `references/jsp-to-thymeleaf-migration.md` before any JSP-to-Thymeleaf
  migration, review, or cleanup.
- Read `references/template-conversion-rules.md` before converting JSP EL, JSTL,
  Spring form tags, includes, tag files, custom tags, localization, URLs, forms,
  JavaScript, or security-sensitive rendering.

## Guardrails

- Do not do blind JSP syntax conversion.
- Do not leave JSP as a fallback or permanent coexistence path.
- Do not copy JSP scriptlets or Java code into Thymeleaf templates.
- Do not call services, repositories, external APIs, or mutating workflows from
  templates.
- Do not encode complex business rules in large Thymeleaf expressions.
- Do not disable CSRF, validation, authorization, localization, or JavaScript
  contracts for convenience.
- Do not use `th:utext` unless trusted HTML rendering is intentional and
  verified.
- Do not remove JSP dependencies or infrastructure until all active usages are
  gone.

## Packaging Compatibility

- Thymeleaf works with Spring MVC in Spring Boot and non-Boot Spring MVC applications.
- Thymeleaf does not by itself require executable JAR packaging; a WAR deployment can also serve Thymeleaf templates.
- An executable JAR cannot serve JSP. Treat that limitation as a JSP/executable-JAR conflict only when JSP remains selected; do not infer a conflict between Thymeleaf and WAR or between Spring MVC and Spring Boot.
