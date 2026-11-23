---
name: Java Backend
description: Use for Java 17/21+ and Spring Boot implementation, reviews, build failures, REST APIs, persistence and transactions, Kafka messaging, tests, and production readiness.
---

# Java Backend Workflow

Use this skill for Java and Spring Boot changes, reviews, and build failures.
Apply it proportionally: follow the repository's conventions and existing
architecture, and prefer the smallest change that solves the problem. The
topics below define scope, not a mandatory stack.

## First inspect

1. Find the project root and build tool: `pom.xml`, `build.gradle`, or
   `build.gradle.kts`.
2. Prefer the wrapper: `./mvnw` or `./gradlew`. Fall back to `mvn` or `gradle`
   only when no wrapper exists.
3. Read the Java version, Spring Boot version, modules, and packaging from the
   build file. Use only language features supported by that source level.
4. Read the nearest `AGENTS.md`, `CONTRIBUTING.md`, and the tests that cover the
   area.

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

## Engineering judgment

- Put framework and transport concerns at the edges; keep business rules in
  domain/application code. Clean and hexagonal layering is useful when it
  isolates real variation; do not add ports, adapters, or modules for
  hypothetical flexibility (KISS, YAGNI).
- Prefer cohesive classes with small, honest interfaces (SOLID). Remove
  duplication when it represents the same rule (DRY), not merely similar-looking
  code.
- Keep invariants next to the state they protect. Use domain objects with
  behavior rather than anemic entities passed through every layer.
- Use records for immutable carriers, sealed types for closed domain variants,
  and pattern matching where it removes casts or boilerplate, provided the Java
  source level supports them.
- On Java 21+, virtual threads can help I/O-bound concurrency. Their per-task
  executor is unbounded, so bound incoming work and protect shared mutable
  state; do not assume they speed up CPU-bound code.
- Introduce Kafka, caches, queues, or multiple datastores only when a concrete
  requirement justifies the operational cost.

## Spring Boot and REST

- Keep controllers thin: validation, mapping, authorization checks, and HTTP
  concerns belong at the boundary; business rules belong in services or domain
  objects.
- Use constructor injection. Avoid field injection and hidden service locators.
- Do not expose JPA entities directly from REST APIs; map to DTOs or records.
- Validate input with `jakarta.validation` and return a consistent error shape;
  use Spring's `ProblemDetail` when the project already follows that convention.
- Use accurate status codes: `200` for successful reads/updates, `201` plus a
  `Location` header for creations, `202` for accepted asynchronous work, `204`
  for successful responses with no body, `400` for malformed input, `401`/`403`
  for authentication/authorization, `404` for missing resources, `409` for
  state conflicts, and `5xx` only for server-side failures.
- Treat `GET`/`HEAD` as safe and `PUT`/`DELETE` as idempotent. For retried POSTs,
  define an idempotency key or equivalent deduplication strategy.
- Keep configuration in typed, validated `@ConfigurationProperties`. Use profiles
  for environment differences, never for business logic. Load secrets from the
  environment or a secret manager; never hard-code credentials or environment
  URLs.
- Enforce authorization at the boundary and do not trust client-supplied
  identity or ownership. Use parameterized queries, avoid leaking stack traces
  or personal data, and redact secrets from logs.

## Persistence and transactions

- Use Flyway or Liquibase migrations; never change a shared schema by hand.
  Prefer backward-compatible expand/contract changes for deployed systems.
- Keep repositories as persistence seams rather than homes for business rules.
- Place `@Transactional` on the service/application operation that owns the
  unit of work. Keep transactions short, choose propagation and rollback rules
  deliberately, and remember that proxied self-invocation does not start a new
  transaction.
- Avoid remote calls inside database transactions where practical. If they are
  unavoidable, state the failure and timeout semantics explicitly.
- Watch for N+1 queries, unbounded collections, missing indexes on query
  predicates, and unpaginated reads. Use unique constraints and optimistic or
  pessimistic locking deliberately for concurrent writes.
- Test repositories against the real database engine with Testcontainers when
  the project supports it.

## Messaging and distributed systems

- Use Kafka only when asynchronous decoupling or event integration is actually
  needed. A local, synchronous workflow does not need a broker.
- Define event contracts with a stable ID, type, version, timestamp, and
  correlation ID. Evolve schemas compatibly; consumers must tolerate unknown
  fields.
- Assume at-least-once delivery at consumer boundaries. Deduplicate by event ID
  or another stable business key, and make handlers idempotent.
- Configure bounded retries with backoff and jitter, a dead-letter or poison
  path, and explicit failure metrics. Preserve ordering where required by using
  a deliberate partition key.
- Use an idempotent producer and, when DB state and publication must be atomic,
  a transactional outbox. Kafka can provide exactly-once behavior for
  Kafka-to-Kafka flows with transactional producers and read-committed consumers;
  external systems still require idempotency or cooperation.
- Use a Saga only for multi-service or multi-database workflows that need
  compensating actions. Document eventual consistency, reconciliation, and
  recovery steps.
- Propagate correlation IDs and emit structured logs, health checks, metrics,
  and traces for new dependencies. Never log secrets or full payloads.

## Tests

- Prefer behavior tests through public interfaces. Use JUnit 5 and Mockito for
  unit seams; use Spring Boot tests when wiring matters and MockMvc or
  WebTestClient for HTTP behavior.
- Add a regression test for every bug fix. Name tests for the behavior they
  prove, such as `rejectsDuplicateEmail`, not `testCreate`.
- Cover validation, authorization, boundary mapping, transaction outcomes,
  serialization, retries, timeouts, duplicates, and failure paths—not only the
  happy path.
- Avoid asserting on private implementation details; tests should survive
  safe refactors.

## Review checklist

- Build and the narrowest relevant tests pass.
- No secrets, credentials, local paths, or personal configuration were added.
- Architecture keeps business rules independent of framework and transport
  concerns; unnecessary layers or dependencies are absent.
- API status codes, DTO boundaries, validation, and authorization are correct.
- Transaction boundaries, error handling, timeouts, retries, and observability
  cover the new failure modes.
- Concurrency, idempotency, and ordering risks are addressed where relevant.
- Database, event, and configuration changes are backward compatible or have a
  migration/recovery plan.
- Commands actually executed are reported; manual and credential-dependent
  checks are labeled as not verified.
