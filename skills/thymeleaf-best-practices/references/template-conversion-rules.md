# Thymeleaf Template Conversion Rules

Use these rules when converting JSP, JSPX, JSTL, Spring tags, JSP tag files, or
custom JSP tags to Thymeleaf `3.1.5.RELEASE`.

## Output

Prefer escaped output:

```html
<span th:text="${user.name}"></span>
```

Use `th:utext` only for trusted HTML after explicit trust analysis.

## Conditions

JSTL:

```jsp
<c:if test="${user.active}">
    Active
</c:if>
```

Thymeleaf:

```html
<span th:if="${user.active}">Active</span>
```

Use `th:unless` for inverse conditions when it improves clarity.

## Switches

JSTL:

```jsp
<c:choose>
    <c:when test="${status == 'OPEN'}">Open</c:when>
    <c:when test="${status == 'CLOSED'}">Closed</c:when>
    <c:otherwise>Unknown</c:otherwise>
</c:choose>
```

Thymeleaf:

```html
<div th:switch="${status}">
    <span th:case="'OPEN'">Open</span>
    <span th:case="'CLOSED'">Closed</span>
    <span th:case="*">Unknown</span>
</div>
```

## Iteration

JSTL:

```jsp
<c:forEach var="order" items="${orders}">
    <div>${order.id}</div>
</c:forEach>
```

Thymeleaf:

```html
<div th:each="order : ${orders}" th:text="${order.id}"></div>
```

With status:

```html
<tr th:each="order, stat : ${orders}">
    <td th:text="${stat.count}"></td>
    <td th:text="${order.id}"></td>
</tr>
```

## URLs

Do not manually concatenate servlet context paths.

Use path variables:

```html
<a th:href="@{/users/{id}(id=${user.id})}">
```

Use query parameters:

```html
<a th:href="@{/orders(page=${page},size=${size})}">
```

Use form actions:

```html
<form th:action="@{/orders}" method="post">
```

## Spring Forms

Prefer Spring-backed Thymeleaf form support:

```html
<form th:action="@{/users}" th:object="${user}" method="post">
    <input type="text" th:field="*{name}">
    <span th:if="${#fields.hasErrors('name')}" th:errors="*{name}"></span>
</form>
```

Preserve action URL, HTTP method, field names, hidden fields, checkbox values,
radio values, select values, multipart configuration, validation semantics,
`BindingResult`, redirect behavior, and CSRF behavior.

## Includes and Fragments

Identify both static and dynamic JSP includes:

```jsp
<%@ include file="..." %>
<jsp:include page="..." />
```

Do not assume they are equivalent. Determine whether included JSPs only render
HTML, expect request attributes, mutate request state, or perform side effects.

Presentation-only includes usually become fragments:

```html
<header th:fragment="header">
    ...
</header>
```

Use:

```html
<header th:replace="~{fragments/header :: header}"></header>
```

## Tag Files and Custom Tags

Migrate `WEB-INF/tags/` based on behavior.

Presentation-oriented tags usually become `templates/fragments/`.

Custom tags may need one of these targets:

```text
Thymeleaf fragment
Custom Thymeleaf dialect
View-model field
Controller helper
Spring Security integration
Application service
```

Extract authorization logic, service calls, data loading, mutation, and business
behavior before replacing tag infrastructure.

## Localization

Spring JSP:

```jsp
<spring:message code="customer.name"/>
```

Thymeleaf:

```html
<span th:text="#{customer.name}"></span>
```

Preserve existing message keys unless localization is intentionally migrated.

## Request and Session State

Avoid exposing servlet objects merely to emulate JSP behavior:

```text
request
response
session
application
pageContext
```

Expose required values explicitly:

```java
model.addAttribute("currentUser", currentUser);
```

Then render:

```html
<span th:text="${currentUser.name}"></span>
```

## Security

Preserve backend authorization. View-level hiding is not access control.

Use prepared view-model decisions or Spring Security integration for rendering.
Do not convert security rules into arbitrary complex template expressions.

Verify endpoint authorization, role-based rendering, ownership restrictions,
CSRF, and unauthorized redirects or errors.

## JavaScript

Preserve JavaScript-sensitive DOM contracts during initial migration:

```text
id
class
name
data-*
element structure
AJAX endpoints
```

Use Thymeleaf JavaScript inlining only where server data must enter JavaScript:

```html
<script th:inline="javascript">
    const userId = [[${user.id}]];
</script>
```

## Static Resources

Move applicable browser assets to Spring Boot static locations unless custom
resource locations are configured:

```text
src/main/resources/static/
```

Common mapping:

```text
src/main/webapp/css/     -> src/main/resources/static/css/
src/main/webapp/js/      -> src/main/resources/static/js/
src/main/webapp/images/  -> src/main/resources/static/images/
src/main/webapp/fonts/   -> src/main/resources/static/fonts/
```

Use Thymeleaf URLs:

```html
<link rel="stylesheet" th:href="@{/css/app.css}">
<script th:src="@{/js/app.js}"></script>
<img th:src="@{/images/logo.png}" alt="">
```

Do not rewrite CSS, JavaScript, images, or fonts only because JSP became
Thymeleaf. Preserve files and update URLs only where resource paths changed.

## Error Pages

Migrate JSP error pages, including `isErrorPage="true"` pages, to Thymeleaf
templates where appropriate:

```text
templates/error/404.html
templates/error/500.html
```

Preserve custom error data and status behavior.
