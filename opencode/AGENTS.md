# Engineering workstation

## Working agreement

- Read the nearest `AGENTS.md`, `CONTRIBUTING.md`, build files, and the relevant tests before editing.
- Prefer the project's existing build tool and wrapper: `./mvnw` / `./gradlew` before system `mvn` / `gradle`.
- Keep changes scoped. Do not commit, push, rewrite history, or upgrade dependencies unless explicitly asked.
- Ask before destructive Git operations, database migrations, or changes outside the active project.
- Never print, commit, or copy secrets. Treat `.env*`, `*.pem`, `*.key`, cloud credentials, and kubeconfig as sensitive.
- Verify with the narrowest useful command first, then the module build or test suite.

## Verification

- Report the commands that actually ran and separate verified results from credential-dependent or manual checks.
- Do not claim a build, test, deployment, or integration passed unless it was executed in this session.
- Prefer deterministic, headless commands in CI and automation.

## Skills

- Use `java-backend` for Java 17/21+, Spring Boot, Maven/Gradle, JUnit/Mockito, JPA, and backend architecture work.
- Use `tdd` for behavior changes and bug fixes when a test can be written first.
- Use `code-review` before proposing a pull request.
- Use `diagnosing-bugs` for failures that are not explained by a quick inspection.
