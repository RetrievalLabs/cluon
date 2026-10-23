# Spring Security Version Guidance

Verify current version status from official Spring Security docs before giving latest/current guidance.

As of August 27, 2026, official Spring Security docs list stable versions `7.1.1`, `7.0.7`, and `6.5.11`, with `7.2.0-M1` as preview. The Spring Security project page lists the 7.1 generation as current.

## Version Map

```text
Spring Security 4.x
    -> XML or Java config
    -> WebSecurityConfigurerAdapter common
    -> javax-era Servlet/Spring Framework generation

Spring Security 5.x
    -> OAuth2/OIDC support matures
    -> DelegatingPasswordEncoder default direction
    -> component-based SecurityFilterChain available from 5.4
    -> WebSecurityConfigurerAdapter deprecated in 5.7

Spring Security 5.8
    -> bridge release for Spring Security 6
    -> prepare request matchers, authorization, CSRF, and configuration

Spring Security 6.x
    -> Java 17+
    -> Spring Framework 6 / Spring Boot 3
    -> Jakarta namespace
    -> WebSecurityConfigurerAdapter removed
    -> AuthorizationManager direction

Spring Security 6.5
    -> final 6.x minor
    -> preparation release for Spring Security 7

Spring Security 7.x
    -> Spring Framework 7 / Spring Boot 4 generation
    -> lambda DSL required direction
    -> latest stable generation
```

## Spring Security 4.x

Typical older Spring MVC/Spring Boot 1.x or early 2.x applications.

Preserve behavior first. Expect XML configuration, `WebSecurityConfigurerAdapter`, and older password storage patterns.

When modernizing:

- add tests for allowed and denied URLs,
- capture login/logout/session behavior,
- identify custom filters and authentication providers,
- identify plaintext, SHA, or legacy password hashes,
- avoid rewriting full authentication model in same step as framework upgrade.

Prefer moving toward Java configuration and modern password encoding incrementally.

## Spring Security 5.x

Spring Security 5 is common in Spring Boot 2 applications.

Use `DelegatingPasswordEncoder` for password storage. Support legacy password hashes explicitly during migration.

Prefer explicit authorization rules and method security where appropriate.

OAuth2/OIDC client and resource server support are mature enough to prefer over custom token parsing where requirements fit.

## Spring Security 5.4+

`SecurityFilterChain` bean configuration is available. Prefer component-based configuration for new code:

```java
@Bean
SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http
            .authorizeHttpRequests(authorize -> authorize
                    .anyRequest().authenticated())
            .build();
}
```

This prepares code for later migration away from `WebSecurityConfigurerAdapter`.

## Spring Security 5.7

`WebSecurityConfigurerAdapter` was deprecated in favor of component-based security configuration.

Move gradually from:

```java
public class SecurityConfig extends WebSecurityConfigurerAdapter {
}
```

to beans such as:

```java
@Bean
SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http.build();
}
```

Do not mix old adapter-based and new component-based configuration in the same application unless verified; duplicate chains can produce confusing behavior.

## Spring Security 5.8

Spring Security 5.8 is a bridge release for moving to 6.x.

Use it to address deprecations before Spring Boot 3 / Spring Security 6 migration.

Preparation targets:

- replace `WebSecurityConfigurerAdapter`,
- move toward `authorizeHttpRequests`,
- replace old matcher methods with `requestMatchers`,
- review method-security annotations and enabling annotations,
- review CSRF BREACH-related behavior,
- review session management changes,
- prepare for Jakarta namespace through Spring Framework/Spring Boot upgrade path.

## Spring Security 6.x

Spring Security 6 aligns with Spring Framework 6 and Spring Boot 3.

Major boundaries:

- Java 17+ baseline,
- Jakarta namespace through Spring Framework 6,
- `WebSecurityConfigurerAdapter` removed,
- component-based configuration required,
- `AuthorizationManager` model is preferred direction,
- old request authorization APIs removed or superseded.

Use:

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers("/public/**").permitAll()
                        .anyRequest().authenticated())
                .build();
    }
}
```

Do not disable CSRF, sessions, or authorization rules to get past compile failures.

## Spring Security 6.1+

Continue using lambda DSL and component-based configuration.

For method security, prefer `@EnableMethodSecurity` over older global method security configuration in modern code.

Validate both request-level and method-level authorization after migration. URL tests alone are not enough when service methods carry authorization rules.

## Spring Security 6.5

Spring Security 6.5 is the final 6.x minor and intended preparation point for Spring Security 7.

Before moving to 7.x:

- update to latest Spring Boot 3 / Spring Security 6.5 patch where applicable,
- apply 7.0 preparation guidance,
- remove deprecated APIs,
- adopt lambda DSL,
- verify OAuth2, SAML, LDAP, authorization, and session migrations if used.

## Spring Security 7.x

Spring Security 7 aligns with Spring Framework 7 and Spring Boot 4 generation.

Use latest stable 7.1.x patch unless project intentionally stays on 7.0.x or targets a preview.

Expect stricter modern configuration style. Prefer lambda DSL and component-based security configuration.

Before upgrading:

- ensure Spring Boot 4 / Spring Framework 7 compatibility,
- verify Java and Jakarta/Servlet stack compatibility,
- run security tests for every rule,
- verify custom filters and custom authorization managers,
- verify OAuth2/OIDC integrations and token claim mapping,
- verify login, logout, remember-me, and session behavior.

Do not move production apps to `7.2.0-M1` or snapshots unless the project explicitly targets preview features.
