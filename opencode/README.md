# OpenCode Engineering Workstation

Versioned OpenCode configuration for the Neovim/LazyVim Java workstation.
Validated against OpenCode CLI **2.4.1** on 2026-11-23.

## Files

| File | Purpose |
| --- | --- |
| `opencode.json` | Global permissions, Context7 MCP, watcher ignores, update policy |
| `AGENTS.md` | Global working agreement for every project |
| `skills/java-backend/SKILL.md` | Java/Spring Boot workflow, build/test commands, review checklist |
| `README.md` | This document |

The intended global links are:

```text
~/.config/opencode/opencode.json -> ~/.dotfiles/opencode/opencode.json
~/.config/opencode/AGENTS.md     -> ~/.dotfiles/opencode/AGENTS.md
~/.config/opencode/skills        -> ~/.dotfiles/opencode/skills
```

Existing general skills under `~/.agents/skills` remain available to OpenCode
through its compatibility discovery path. They are not copied into this
repository.

## Design

- **One primary agent:** OpenCode is the coding agent. Supermaven remains
  inline completion in Neovim; Blink remains the LSP/completion engine.
- **Docs first:** Context7 is the only MCP enabled by default. It is remote,
  read-only, and useful for current framework/API documentation.
- **Least privilege:** shell commands ask by default; read-only Git and search
  commands are allowlisted; secrets and generated directories are protected.
- **No secrets in Git:** no API keys, tokens, connection strings, or local
  credentials are stored here. Use environment variables or OpenCode's
  credential store.
- **Portable skills:** the Java skill is repository-owned and has no external
  runtime dependency.

## Context7 MCP

Context7 is configured as a remote MCP server:

```json
{
  "mcp": {
    "servers": {
      "context7": {
        "type": "remote",
        "url": "https://mcp.context7.com/mcp",
        "oauth": false
      }
    }
  }
}
```

It works without an account at lower rate limits. If you need higher limits,
use your own API key through an environment variable and add an authorization
header locally; never commit the key. The permission rules allow only the two
Context7 tools (`resolve-library-id` and `query-docs`); everything else follows
the global ask/allow policy.

Verify it with:

```bash
opencode mcp list
opencode debug config
```

`mcp list` may print `No MCP servers configured` while the background service is
still starting. Run it again; a healthy connection prints
`✓ context7 connected`. `debug config` should show `mcp.servers.context7`.

## Skills

OpenCode discovers:

- `~/.config/opencode/skills` (this repository through the link above)
- `~/.agents/skills` and `~/.claude/skills` (global compatibility)
- `.opencode/skills`, `.agents/skills`, and `.claude/skills` in projects

The custom `java-backend` skill covers build-tool detection, Maven/Gradle
commands, Spring Boot conventions, JPA/migrations, JUnit/Mockito,
Kafka/Redis failure modes, and a review checklist. It is loaded on demand by
the agent rather than injected into every prompt.

The existing general skills were reviewed individually. The most useful for
this workstation are:

| Skill | Use |
| --- | --- |
| `tdd` | Red/green behavior changes and bug fixes |
| `code-review` | Review changes against standards and the originating spec |
| `diagnosing-bugs` | Investigation loop for hard failures and regressions |
| `domain-modeling` | Domain vocabulary, `CONTEXT.md`, and ADRs |
| `research` | Primary-source research captured as Markdown |
| `resolving-merge-conflicts` | In-progress merge/rebase conflicts |
| `writing-for-agents` | Editing skills, `AGENTS.md`, and agent-facing docs |

Specialized workflow skills such as `teach`, `ask-matt`, `wayfinder`, and
`to-questionnaire` remain available but are not part of the default Java
workflow.

## Permissions

The policy is intentionally conservative:

- `shell *` asks. Read-only Git (`status`, `diff`, `log`, `show`, `branch`) and
  `rg`/`fd` are allowed.
- `git commit`, `git push`, `git reset --hard`, and `rm -rf` always ask.
- Reads are allowed except `.env` files (ask), private keys/certificates, SSH
  material, AWS credentials, gcloud config, kubeconfig, `.git-credentials`,
  `.npmrc`, `.pypirc`, Docker auth, and GitHub CLI hosts (deny).
- Edits are allowed except `.env*`, `.git`, `target`, `build`, `node_modules`,
  and the credential paths above. `.env.example` is editable.
- Paths outside the active project ask before access.
- MCP tools ask unless explicitly allowlisted; Context7 is the only allowlisted
  server.

Treat permissions as defense in depth, not as a sandbox. Shell commands run
with your user's authority.

## Optional additions

Add these only when the workload requires them, and give them minimal
permissions:

| Candidate | Decision |
| --- | --- |
| GitHub MCP | Not added; `gh` CLI and Octo already cover issues/PRs |
| Playwright MCP | Not added; frontend/E2E work is outside the Java backend focus |
| PostgreSQL MCP | Not added; credentials and schema exposure outweigh the benefit for routine work |
| Sentry MCP | Not added; requires a project token and is better scoped per repository |
| Filesystem MCP | Not added; OpenCode already has project read/edit tools |

## Validation

```bash
opencode debug config
opencode debug agents
opencode mcp list
opencode mcp auth context7   # only if you later enable OAuth
```

`debug config` should show 49 permission rules, `update: disable`, the watcher
ignores, and `mcp.servers.context7`. `debug agents` should show the secret
read/edit denials and the `.env.example` allowances. `mcp list` should print
`✓ context7 connected` once the background service has started.

Live Context7 calls were verified through the MCP protocol: `resolve-library-id`
selected official Spring Boot and Java SE libraries, and `query-docs` returned
Spring Boot 3.5 configuration-property guidance and Java SE 21 virtual-thread
documentation. No API key was used.

Model-driven skill invocation remains unverified: a live `opencode run` task
was blocked by the configured provider's HTTP 402 insufficient-credit response.
This is a provider account limitation, not a configuration error.

Inside Neovim:

```vim
:checkhealth opencode
```
