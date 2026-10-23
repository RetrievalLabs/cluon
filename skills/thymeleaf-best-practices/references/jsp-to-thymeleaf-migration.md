# JSP to Thymeleaf Migration

Use this reference to migrate a JSP-based Spring MVC application fully to
Thymeleaf `3.1.5.RELEASE`.

Target runtime:

```text
Spring MVC
Thymeleaf 3.1.5.RELEASE
No active JSP rendering path
```

## Discovery

Before changing templates, find the complete JSP surface:

```text
*.jsp
*.jspx
WEB-INF/jsp/
WEB-INF/views/
WEB-INF/tags/
web.xml
Spring XML configuration
Java MVC configuration
ViewResolver configuration
Servlet configuration
error page configuration
taglib descriptors
existing Thymeleaf templates
spring.thymeleaf.* properties
TemplateResolver beans
spring.web.resources.static-locations
spring.mvc.static-path-pattern
```

Search Java and configuration files for:

```text
.jsp
.jspx
/WEB-INF/views
InternalResourceViewResolver
JstlView
RequestDispatcher
forward:
jsp:
javax.servlet.jsp
jakarta.servlet.jsp
taglib
```

Do not mark discovery complete until every active JSP entry point is identified.

## View Technology and Locations

Detect view technology before moving files.

- JSP views normally migrate from `src/main/webapp/WEB-INF/...` to Thymeleaf
  `.html` templates.
- Spring Boot normally resolves Thymeleaf templates from
  `src/main/resources/templates/` with logical view names such as
  `return "users/profile";`.
- If `spring.thymeleaf.prefix`, `spring.thymeleaf.suffix`, custom
  `TemplateResolver` beans, or non-default view resolver configuration exist,
  preserve or migrate to that configured location deliberately.
- If Thymeleaf is already in use, preserve existing templates and modernize
  dependencies, syntax, and unnecessary manual configuration. Do not perform a
  JSP-style relocation.
- Browser assets normally belong under `src/main/resources/static/`; preserve
  custom `spring.web.resources.static-locations` and
  `spring.mvc.static-path-pattern` behavior when present.

## Classification

For each JSP, identify:

- JSP directives, declarations, expressions, and scriptlets.
- JSP EL, JSTL, Spring tags, Spring form tags, and custom tags.
- Static includes, dynamic includes, forwards, tag files, and taglib descriptors.
- Message bundle access, request attributes, session attributes, servlet objects,
  forms, validation, security conditions, JavaScript, AJAX endpoints, dynamic
  URLs, dynamic HTML, side effects, service calls, and database access.

Classify embedded behavior as:

```text
Presentation
Formatting
Validation
Authorization
Business Logic
Workflow Logic
Data Access
Side Effect
Infrastructure
```

Only presentation-oriented behavior should remain in Thymeleaf templates.

## Behavior Preservation

Preserve observable behavior:

- Routes, HTTP methods, path variables, query parameters, redirects, and status
  codes.
- Request attributes, session behavior, form field names, hidden values,
  checkbox/radio/select values, multipart behavior, validation errors, and
  `BindingResult` semantics.
- Backend authorization, role-sensitive rendering, ownership restrictions, CSRF,
  unauthorized redirects/errors, and localized messages.
- JavaScript-sensitive `id`, `class`, `name`, `data-*`, element structure, AJAX
  endpoints, and form serialization contracts.

Keep controller logical view names when practical:

```java
return "customers/detail";
```

maps from:

```text
/WEB-INF/views/customers/detail.jsp
```

to:

```text
src/main/resources/templates/customers/detail.html
```

Move related static resources without converting them unless URLs or packaging
require it:

```text
src/main/webapp/css/     -> src/main/resources/static/css/
src/main/webapp/js/      -> src/main/resources/static/js/
src/main/webapp/images/  -> src/main/resources/static/images/
```

## Extraction

Scriptlets and JSP-hosted Java code must move out of templates.

Move business rules, workflow decisions, service calls, data access, side
effects, and complex authorization checks into controllers, services, policies,
view-model fields, or security configuration.

Prefer prepared decisions:

```java
model.addAttribute("orderActionAllowed", orderPolicy.canPerformAction(order));
```

over complex template rules:

```html
<div th:if="${orderActionAllowed}">
```

Prepare data needed by the view before rendering. Do not depend on uncontrolled
lazy loading from template rendering.

## Migration Order

Use this order unless project constraints require a different sequence:

1. Discover all JSP artifacts and active entry points.
2. Analyze JSP dependencies and controller/view relationships.
3. Classify JSP logic and extract non-presentation behavior.
4. Prepare controller/view-model contracts.
5. Convert JSP templates, forms, includes, tag files, localization, security
   rendering, JavaScript inlining, and static resources.
6. Verify pages with characterization, controller, integration, or browser tests
   according to risk.
7. Remove JSP files, JSPX files, `WEB-INF/tags`, JSP-only includes, obsolete
   taglib descriptors, JSP view resolver configuration, JSP servlet mappings,
   JSP error page references, and unused JSP dependencies.
8. Run final zero-JSP verification.

## Verification

Every migrated view should verify:

- URL, HTTP method, path variable, query parameter, redirect, and status behavior.
- Important rendered content, loops, conditional rendering, and escaping.
- Form action, method, input names, field binding, validation errors, multipart
  behavior, and CSRF.
- Protected endpoint behavior and authorization-sensitive rendering.
- JavaScript selectors, AJAX calls, and form serialization.
- Message resolution and locale behavior.

Capture existing JSP behavior before replacement when practical. Behavioral
equivalence is required; byte-for-byte HTML equality is not.

## Zero-JSP Search

At the end, search the complete application for:

```text
.jsp
.jspx
WEB-INF/tags
JstlView
InternalResourceViewResolver
Jasper
javax.servlet.jsp
jakarta.servlet.jsp
JSP taglib URIs
```

Review every remaining match. Expected final state:

```text
Active *.jsp files = 0
Active *.jspx files = 0
JSP tag files = 0
JSP view resolvers = 0
JSP rendering routes = 0
JSP includes = 0
JSP-only taglibs = 0
JSP compiler requirement = 0
```

Application must build, start, and pass behavioral tests before migration is
complete.
