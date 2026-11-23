---
name: Java Backend
description: Java 17/21+, Spring Boot, Maven/Gradle, JUnit/Mockito, JPA, REST/GraphQL/gRPC, Kafka, PostgreSQL, Redis, Docker/Kubernetes, AWS, CI/CD, and observability.
---

# Java Backend Workflow

Use this skill for Java and Spring Boot changes, reviews, and build failures.

## First inspect

1. Find the project root and build tool: `pom.xml`, `build.gradle`, or `build.gradle.kts`.
2. Prefer the wrapper: `./mvnw` or `./gradlew`. Fall back to `mvn` or `gradle` only when no wrapper exists.
3. Read the Java version, Spring Boot version, modules, and packaging from the build file.
4. Read the nearest `AGENTS.md`, `CONTRIBUTING.md`, and the tests that cover the area.

## Commands

Use the narrowest command that proves the change:

| Goal | Maven | Gradle |
| --- | --- | --- |
| Compile | `./mvnw -q -DskipTests compile` | `./gradlew compileJava` |
| One test | `./mvnw -q -Dtest=ClassName#method test` | `./gradlew test --tests 'ClassName.method'` |
| Module tests | `./mvnw -q -pl module -am test` | `./gradlew :module:test` |
| Full verify | `./mvnw -q verify` | `./gradlew check` |
| Run app | `./mvnw spring-boot:run -Dspring-boot.run.profiles=local` | `./gradlew bootRun --args='--spring.profiles.active=local'` |

If the repository documents different commands, follow the repository.

## Spring Boot conventions

- Keep controllers thin: validation, mapping, and HTTP concerns at the boundary; business rules in services/domain objects.
- Use constructor injection. Avoid field injection and hidden service locators.
- Do not expose JPA entities directly from REST/GraphQL APIs; map to DTOs or records.
- Use `@Transactional` at the service boundary with a clear propagation and rollback policy.
- Validate input at the boundary (`jakarta.validation`) and return consistent error payloads.
- Make write endpoints idempotent where retries are expected; document idempotency keys.
- Keep configuration in typed `@ConfigurationProperties`; never hard-code credentials or environment-specific URLs.
- Use profiles for environment differences, not for business logic.

## Persistence

- Use migrations (Flyway/Liquibase); never change a shared schema by hand.
- Watch for N+1 queries, unbounded collections, and missing indexes on query predicates.
- Use pessimistic or optimistic locking deliberately for concurrent writes.
- Test repositories against the real database engine with Testcontainers when the project supports it.

## Tests

- Prefer behavior tests through public interfaces. Use JUnit 5 and Mockito for unit seams; use Spring Boot tests only when wiring matters.
- Add a regression test for every bug fix.
- Keep test names specific: `rejectsDuplicateEmail`, not `testCreate`.
- For Kafka/Redis/HTTP integrations, verify serialization, retries, timeouts, and failure paths, not only the happy path.

## Messaging and distributed systems

- Assume at-least-once delivery. Make consumers idempotent and handle duplicates.
- Define retry, backoff, dead-letter, and poison-message behavior explicitly.
- Include correlation IDs and structured logs across HTTP, messaging, and scheduled work.
- Expose health, metrics, and traces for new dependencies; avoid logging secrets or full payloads.

## Review checklist

- Build and the narrowest relevant tests pass.
- No secrets, credentials, or local paths added to versioned files.
- API, database, and configuration changes are backward compatible or have a migration plan.
- Error handling, timeouts, retries, and observability cover the new failure modes.
- Commands actually executed are reported; credential-dependent/manual checks are labeled as not verified.
