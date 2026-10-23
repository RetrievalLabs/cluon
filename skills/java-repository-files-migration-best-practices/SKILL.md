---
name: java-repository-files-migration-best-practices
description: Use this skill when migrating non-source repository files for a Java application migration, including build scripts, containers, CI/CD, deployment manifests, environment templates, developer tooling, metadata, and documentation that must match the final migrated application.
---

# Java Repository Files Migration Best Practices

Use this skill after or alongside Java application migration when repository-level files must reflect the final application architecture. This skill is for non-source operational and support files, not Java code, application logic, framework APIs, or test implementation.

## Operating Principle

Repository files follow the migrated application. Do not modernize them independently because of filename, extension, or age.

For each candidate file:

1. Read the file before editing.
2. Extract assumptions about Java version, build system, modules, packaging, runtime, configuration, ports, artifact paths, deployment, and verification commands.
3. Compare those assumptions with the migrated application.
4. Change only assumptions that are no longer valid.
5. Preserve unrelated repository behavior.
6. Verify the resulting file where practical.

## Files to Inspect

Inspect only files relevant to the migration task and repository shape:

- Build tooling: `Makefile`, `scripts/`, shell build or release scripts.
- Containers: `Dockerfile`, compose files, `.dockerignore`, entrypoint scripts.
- CI/CD and automation: GitHub Actions, GitLab CI, Jenkins, Azure Pipelines, CircleCI, Dependabot, Renovate, Sonar, custom actions.
- Deployment: `k8s/`, `helm/`, `deploy/`, ECS task definitions, runtime Terraform, systemd units, deployment scripts.
- Environment templates: `.env.example`, committed sample env files, example properties or YAML, shell env files, secret templates.
- Developer tooling: `.devcontainer/`, `.vscode/`, shared IDE config, `.sdkmanrc`, `.java-version`, `.tool-versions`.
- Metadata and docs: `.gitignore`, `.gitattributes`, hooks, license/check scripts, `README.md`, `CONTRIBUTING.md`, `docs/`, setup and deployment guides.

## Assumption Classes

Classify discovered references before editing:

- Runtime: `java`, `JAVA_HOME`, JVM flags, `catalina.sh`, application-server commands.
- Build: Maven or Gradle wrapper, build goals, test goals, generated-source commands, packaging.
- Modules: old module names, removed directories, new module layout.
- Configuration: env vars, profiles, property names, config file locations.
- Deployment: image names, commands, ports, probes, volumes, startup arguments.
- Paths: WAR/EAR/JAR locations, `WEB-INF/`, webapp paths, target or build output paths.

## Guardrails

- Do not rewrite every YAML, shell, or documentation file mechanically.
- Do not replace WAR/EAR with JAR unless the migrated build actually produces and runs that artifact.
- Do not invent ports, health endpoints, artifact names, module names, image names, or deployment topology.
- Do not rename environment variables without checking application configuration and external compatibility.
- Do not remove JVM options without understanding their purpose.
- Do not upgrade unrelated infrastructure or CI actions unless required for the migrated Java/tooling target.
- Do not modify secrets.
- Keep documentation updates near the end so they describe the final repository, not an intermediate migration state.

## Validation

Run validations that match files changed:

```bash
./mvnw clean verify
./gradlew clean build
make build
docker build .
docker compose config
```

Also validate syntax and references where applicable: YAML, shell scripts, GitHub Actions structure, Kubernetes manifests, Helm templates, referenced modules, artifact paths, and expected build outputs.

Finish only when repository files behave as if the migrated architecture had always been the intended architecture.
