# Neovim Engineering Workstation

A LazyVim-based Neovim setup for Java/Spring Boot backend work, with
[OpenCode](https://opencode.ai) as the primary coding agent. The configuration is
modular, lazy-loaded by default, and keeps one primary tool per responsibility.

Validated on Arch Linux on **2026-11-23**. The repository is not auto-updated;
plugin changes are reviewed explicitly with `:Lazy check` / `:Lazy update`.

## Validated baseline

| Component | Version / commit |
| --- | --- |
| Neovim | 0.12.6 |
| LazyVim | `99970099` |
| lazy.nvim | `85c7ff37` |
| JDTLS | 1.60.0 |
| java-debug-adapter | 0.59.0 |
| java-test | 0.47.0 |
| LemMinX | 0.29.3 |
| OpenCode CLI | 2.4.1 |
| opencode.nvim | `3cab89df` |
| rest.nvim | `714d5512` |
| Java runtime | Temurin 21.0.12.1 LTS |
| Maven | 4.0.0-rc-6 (project wrappers preferred) |
| Gradle | not installed system-wide; use `./gradlew` |

## Design

```text
┌────────────────────────────────────────────────────────────┐
│ Neovim 0.12 + LazyVim                                      │
│ editor, pickers, Git, sessions, UI                         │
├───────────────────┬───────────────────┬────────────────────┤
│ Java              │ AI                │ HTTP / API         │
│ jdtls + nvim-dap  │ OpenCode.nvim     │ rest.nvim          │
│ Maven / Gradle    │ Context7 MCP      │ .http files        │
└───────────────────┴───────────────────┴────────────────────┘
```

### One tool per responsibility

| Responsibility | Tool | Notes |
| --- | --- | --- |
| Java LSP | JDTLS + `nvim-jdtls` | LazyVim `lang.java` extra; Lombok agent enabled |
| XML / Maven POM | LemMinX | Root markers include `pom.xml`, Gradle files, `.git` |
| Completion | Blink + Supermaven | Blink handles LSP/completion; Supermaven stays inline-only |
| Java tests | JDTLS test runner | JUnit via DAP; no second Java test adapter |
| Debugging | `nvim-dap` + java-debug-adapter | Breakpoints, stepping, main-class configs |
| Formatting | JDTLS + Google Java Style | Profile at `lua/lang_servers/eclipse-java-google-style.xml` |
| Build/run | Custom `lua/java/` toolbox | Prefers `./mvnw` and `./gradlew` |
| REST / GraphQL | `rest.nvim` | `.http` files; Kulala was removed because it requires a license token |
| Coding agent | OpenCode + `opencode.nvim` | `<leader>o`; protocol auto-detection for V1/V2 |
| Documentation MCP | Context7 | Only default MCP; remote, no OAuth, no stored key |
| Git UI | Snacks Lazygit + gitsigns | Fugitive for `:Git` commands; Octo for GitHub; no extra Git UI |
| SQL | Dadbod UI + sqlfluff | `<leader>D` opens DBUI; `<leader>S` executes a query |

## Requirements

- Neovim **0.11.2+** built with LuaJIT (validated with 0.12.6).
- JDK **21+** for JDTLS. Project JDKs 17/21 are detected automatically.
- Git, `ripgrep`, `fd`, `curl`.
- `luarocks` for `rest.nvim` dependencies.
- OpenCode CLI with a provider already connected (`opencode` → `/connect`).
- Maven or Gradle, preferably through the project wrapper.

The current machine has JDK 8, 11, 17, 21, and 26 under SDKMAN. JDTLS exposes
them as `JavaSE-1.8`, `JavaSE-11`, `JavaSE-17`, `JavaSE-21`, and `JavaSE-26`;
the project’s build file selects the default runtime.

## Installation

Back up an existing Neovim configuration first. For a fresh machine, link the
whole directory:

```bash
mkdir -p ~/.config
ln -s ~/.dotfiles/nvim ~/.config/nvim
```

The current machine uses per-file symlinks instead, which is equivalent:

```text
~/.config/nvim/init.lua       -> ~/.dotfiles/nvim/init.lua
~/.config/nvim/lua           -> ~/.dotfiles/nvim/lua
~/.config/nvim/lazy-lock.json -> ~/.dotfiles/nvim/lazy-lock.json
~/.config/nvim/lazyvim.json  -> ~/.dotfiles/nvim/lazyvim.json
~/.config/nvim/stylua.toml   -> ~/.dotfiles/nvim/stylua.toml
~/.config/nvim/.luarc.json   -> ~/.dotfiles/nvim/.luarc.json
```

Then:

```bash
nvim
```

lazy.nvim bootstraps itself, LazyVim installs the pinned plugins, and Mason
installs the servers listed in `lua/plugins/lsp.lua`. The Java debug and test
extensions are installed by LazyVim’s Java extra.

If Mason was interrupted, install the Java/XML set explicitly:

```vim
:MasonInstall jdtls java-debug-adapter java-test lemminx
```

`jdtls` is provided by Mason; it does not need to be on the shell `PATH`.

## First checks

```vim
:checkhealth
:checkhealth opencode
:checkhealth rest-nvim
:Lazy health
```

Open a Java file and verify:

```vim
:LspInfo
:JdtCompile
:JavaCommands
```

Open `pom.xml` and confirm LemMinX attaches with the project root. If it
attaches with no root, check the `root_markers` in `lua/plugins/lsp.lua`.

## Java workflow

### Build and run

All Java actions live under `<leader>j`; `<leader>j?` lists every command.

| Key | Action |
| --- | --- |
| `<leader>jrs` | Run Spring Boot |
| `<leader>jrp` | Run with a Spring profile |
| `<leader>jrk` | Stop the running app/build (SIGINT) |
| `<leader>jrm` | Maven `clean install -DskipTests` |
| `<leader>jmt` / `<leader>jmv` / `<leader>jmp` | Maven test / verify / package |
| `<leader>jrg` / `<leader>jwt` / `<leader>jwc` | Gradle build / test / clean build |

Commands use `./mvnw` or `./gradlew` when present. Gradle projects without a
wrapper need a system `gradle`; it is intentionally not installed here. The
wrapper workflow was validated with Gradle 8.14.3 in a disposable project.

### Navigation and refactoring

| Key | Action |
| --- | --- |
| `gd` / `gr` / `K` | Definition / references / hover |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol (inc-rename) |
| `<leader>cR` | Rename file |
| `<leader>cf` | Format buffer |
| `<leader>co` | Organize imports |
| `<leader>cxv` / `<leader>cxc` / `<leader>cxm` | Extract variable / constant / method |
| `<leader>cd` | Line diagnostics |
| `]d` / `[d` | Next / previous diagnostic |

### Tests and debugging

| Key | Action |
| --- | --- |
| `<leader>tt` | Run all tests in the current Java class |
| `<leader>tr` | Run the nearest Java test method |
| `<leader>tT` | Pick a Java test |
| `<leader>dc` | Start/continue debugging |
| `<leader>db` / `<leader>dB` | Toggle / conditional breakpoint |
| `<leader>du` | Toggle DAP UI |

In Java buffers these test maps are buffer-local and are set directly in the
JDTLS `on_attach` callback. They intentionally override Neotest’s generic
`<leader>tt` / `<leader>tr` / `<leader>tT` maps. `neotest-java` is not installed,
so there is only one Java test runner.

`java-test` must stay compatible with JDTLS 1.60.0. The old 0.46.x extension
required ASM `[9.9.0,9.10.0)`, while JDTLS 1.60.0 ships ASM 9.10.1. If tests stop
discovering, update the Mason registry and reinstall `java-test`; do not
downgrade JDTLS without pinning a compatible test extension.

### Generators, profiles, migrations, dependencies

| Key | Action |
| --- | --- |
| `<leader>jn` | New Java class/interface/enum/record |
| `<leader>js` | New Spring component (controller/service/repository/entity/DTO/...) |
| `<leader>jg` | Generate a CRUD stack |
| `<leader>jps` / `<leader>jpn` | Switch / create a Spring profile |
| `<leader>jpe` / `<leader>jpp` / `<leader>jpi` | Edit app config / profile config / show profiles |
| `<leader>jbr` / `<leader>jbn` | Run Flyway / create a migration |
| `<leader>jda` | Add a dependency and resolve its latest version |
| `<leader>jdt` / `<leader>jdu` / `<leader>jdv` | Dependency tree / updates / vulnerabilities |

The generators inspect the package layout, Spring Boot version, and
Jakarta/`javax` namespace before writing files. The dependency helper resolves
versions from Maven Central and updates `pom.xml` or the Gradle build file.

## AI workflow

OpenCode is the primary agent. Supermaven remains inline completion; Blink is
the completion engine. The three do not compete for the same role.

| Key | Action |
| --- | --- |
| `<leader>oi` | Open the prompt input |
| `<leader>oI` | New session |
| `<leader>og` | Toggle the OpenCode window |
| `<leader>oo` | Open output |
| `<leader>ot` | Toggle focus |
| `<leader>od` | Review the agent’s diff |
| `<leader>o]` / `<leader>o[` | Next / previous diff |
| `<leader>oc` | Close diff |
| `<leader>os` / `<leader>oh` | Select session / history |
| `<leader>oT` | Session timeline |
| `<leader>oq` | Close the window |
| `<leader>oy` / `<leader>oY` (visual) | Add selection to context / insert inline |

The plugin is lazy-loaded on `VeryLazy`. `default_mode = "build"` and
`preferred_picker = "fzf-lua"` are set in `lua/plugins/opencode.lua`.

Context7 is the only default MCP. It is remote at
`https://mcp.context7.com/mcp`, with OAuth disabled and no stored key. The
global OpenCode policy lives in `../opencode/opencode.json`, the working
agreement in `../opencode/AGENTS.md`, and the Java skill in
`../opencode/skills/java-backend/SKILL.md`.

## HTTP and GraphQL

`rest.nvim` handles `.http` files and is lazy-loaded on the `http` filetype.
Treesitter parsers for `http` and `graphql` are installed.

```http
@base = http://localhost:8080

### Health
GET {{base}}/actuator/health

### Create
POST {{base}}/api/orders
Content-Type: application/json

{"sku": "ABC-1", "quantity": 2}
```

| Key | Action |
| --- | --- |
| `<leader>Rs` | Send request |
| `<leader>Rr` | Replay last request |
| `<leader>Ro` | Open result pane |
| `<leader>Re` | Select environment |
| `<leader>Rc` | Edit cookies |
| `<leader>Rl` | Open logs |

Kulala is not used: its core binary now requires a commercial license token.
`rest.nvim` is the maintained open alternative and was verified against a local
HTTP server.

## SQL

The `lang.sql` extra provides Dadbod, Dadbod UI, SQL completion, and sqlfluff:

```vim
<leader>D    " Toggle the database UI
<leader>S    " Execute the query under the cursor (inside DBUI)
```

Connections are intentionally not committed. Use `vim.g.dbs` in a local
`.lazy.lua` or environment-injected connection URLs, and keep that file out of
Git.

## Keymaps

The complete learning guide is [`../KEYMAPS_LEARNING.md`](../KEYMAPS_LEARNING.md).
The most important groups are:

| Prefix | Group |
| --- | --- |
| `<leader>f` | Files, buffers, recent files, terminal |
| `<leader>s` | Search |
| `<leader>g` | Git |
| `<leader>c` | Code/LSP |
| `<leader>t` | Tests |
| `<leader>j` | Java toolbox |
| `<leader>o` | OpenCode |
| `<leader>R` | REST |
| `<leader>D` | Database UI |
| `<leader>q` | Sessions/quit |
| `<leader>u` | UI toggles |

`which-key` shows the available continuations after each prefix.

## Configuration map

```text
nvim/
├── init.lua                     # boots config.lazy
├── lazyvim.json                 # enabled LazyVim extras
├── lazy-lock.json               # pinned plugin revisions
├── stylua.toml / .luacheckrc    # Lua formatting and lint policy
├── lua/
│   ├── config/
│   │   ├── lazy.lua             # lazy.nvim setup; update checker disabled
│   │   ├── options.lua          # editor options
│   │   ├── keymaps.lua          # general keymaps
│   │   ├── autocmds.lua         # general autocmds
│   │   └── remote_clipboard.lua # OSC52 clipboard support
│   ├── java/                    # build/run, profiles, migrations, dependencies,
│   │   └── templates/           # Java, Spring, and CRUD generators
│   ├── lang_servers/            # Google Java Style profile
│   ├── plugins/
│   │   ├── lsp.lua              # Mason, jdtls, lemminx, JDTLS test maps
│   │   ├── rest.lua             # rest.nvim and .http filetype
│   │   ├── opencode.lua         # OpenCode.nvim and render-markdown
│   │   ├── git.lua              # lazy-loaded Fugitive
│   │   ├── wakatime.lua         # WakaTime on VeryLazy
│   │   ├── which-key.lua        # group labels
│   │   └── ...                  # theme, UI, neo-tree, grapple
│   └── user/heimdall.lua        # generated theme palette
└── tests/                       # headless Lua specs for the Java toolbox
```

Edit the source in `~/.dotfiles/nvim`, not in `~/.config/nvim` (the latter is a
set of symlinks).

## Validation

Run the deterministic checks from `nvim/`:

```bash
stylua --check lua init.lua tests
luacheck lua init.lua tests
./tests/run.sh
```

The test script runs each `tests/*_spec.lua` with `nvim --headless -u NONE -l`.
The CI workflow in `.github/workflows/nvim.yml` currently runs StyLua and
Luacheck.

Local validation performed for this configuration:

| Check | Result |
| --- | --- |
| StyLua 2.5.2 / Luacheck 1.2.0 | 0 warnings, 0 errors |
| `./tests/run.sh` | all specs passed |
| Startup, warm cache | 28–36 ms in quiet runs (34.9 ms typical) |
| Startup, cold cache | 129 ms |
| JDTLS attach, DAP adapter, `:JdtCompile`, `:JavaCommands` | verified headless |
| Full DAP session | breakpoint hit, Step Over, Continue, Locals inspected |
| `<leader>tt` JUnit run | 2 tests succeeded, results in DAP repl |
| Maven `test` and `package` | 2 JUnit tests passed; jar built on Java 21 |
| Gradle wrapper `test` and `build` | passed with Gradle 8.14.3 in a disposable project |
| LemMinX on `pom.xml` | attached with project root |
| JDTLS formatting | 2-space Google-style output verified |
| `rest.nvim` HTTP request | `200 OK`, body, headers, timing rendered |
| `:checkhealth opencode` | passed with OpenCode 2.4.1 |
| `:checkhealth rest-nvim` | passed after opening an `.http` buffer |
| OpenCode config and Context7 | connected, 2 tools |
| Context7 live retrieval | Spring Boot 3.5 and Java SE 21 docs retrieved through MCP |

Not claimed as verified: a real Spring Boot application launch, Kafka/Redis/
PostgreSQL integration tests, Kubernetes or AWS operations, and model-driven
skill invocation. The last was blocked by the configured provider's
insufficient-credit response (HTTP 402), not by a configuration failure.

## Performance

Startup was measured with:

```bash
nvim --headless -u ~/.config/nvim/init.lua --startuptime /tmp/startup.log +qa
```

Warm startup is about 28–36 ms on this machine in quiet runs. A cold first run
is about 129 ms while Lua bytecode caches are populated. Measurements rise
under load (for example, while JDTLS is indexing).

The main performance choices are:

- `checker.enabled = false` in `lua/config/lazy.lua`; updates are explicit.
- WakaTime loads on `VeryLazy`; its CLI setup is network-bound and previously
  added about 88 ms to startup.
- Fugitive loads only when a `:Git` command is used.
- `better-ts-errors` loads only for TypeScript/JavaScript filetypes.
- `rest.nvim` and `opencode.nvim` load on their filetype/event.
- fzf-lua is the picker; Snacks provides the terminal/Lazygit/UI layer.
  Duplicate Git and REST UIs are not installed.

Use `:Lazy profile` if a plugin regresses startup.

## Troubleshooting

### JDTLS does not start

```vim
:MasonInstall jdtls
:JdtShowLogs
```

Check that `java -version` is 21+ and that Mason is on `PATH`. OpenCode and
Neovim must both be started with a normal login environment for SDKMAN JDKs to
be visible.

### Java tests are not discovered

```vim
:MasonUpdate
:MasonInstall java-test
```

The installed `java-test` must be 0.47.0 or newer for JDTLS 1.60.0. The old
0.46.x extension fails with `Unresolved requirement: Require-Bundle:
org.objectweb.asm; bundle-version="[9.9.0,9.10.0)"`.

### LemMinX has no root

Confirm `pom.xml` or a Gradle build file exists in the project root. This
configuration adds those markers explicitly because LemMinX upstream only uses
`.git`.

### `:checkhealth opencode` says no healthcheck

Load the plugin first:

```vim
:Lazy load opencode.nvim
:checkhealth opencode
```

### `opencode mcp list` is empty

The background OpenCode service may still be connecting. Run it again, or check
the resolved configuration:

```bash
opencode debug config
opencode mcp list
```

The config is considered valid when `debug config` shows
`mcp.servers.context7` and a later `mcp list` shows `✓ context7 connected`.

### REST request fails

Open an `.http` buffer first, then run:

```vim
:checkhealth rest-nvim
```

`rest.nvim` is filetype-lazy, so this healthcheck reports no module until an
HTTP file is loaded. Verify `luarocks` is installed and the `http`/`graphql`
Treesitter parsers are present. `rest.nvim` installs its Lua dependencies during
`:Lazy sync`.

### Formatting is not applied

Check that the JDTLS client attached and that
`lua/lang_servers/eclipse-java-google-style.xml` is readable. Format manually
with `<leader>cf`; save-time formatting depends on the LazyVim formatter
configuration for the buffer.

## Maintenance

```vim
:Lazy check      " review available updates
:Lazy update     " apply selected updates
:Lazy profile    " inspect startup cost
:Mason           " inspect/install servers
```

Keep `lazy-lock.json` in version control so updates are reproducible. Do not
enable the automatic checker; a surprise plugin update can break a working
JDTLS/test toolchain.

## Security

- No credentials, tokens, API keys, or connection strings are stored in this
  repository.
- OpenCode’s global policy asks before shell commands, denies reads of private
  keys/certificates, SSH/AWS/gcloud/kube config, `.git-credentials`, `.npmrc`,
  `.pypirc`, Docker auth, and GitHub CLI hosts, and denies edits to `.env*`,
  `.git`, `target`, `build`, `node_modules`, and those credential paths.
- Context7 runs remotely and is the only default MCP. MCP permissions are
  allowlisted to its two tools.
- Permissions are defense in depth, not a sandbox. Shell commands run with the
  user’s authority.
- Keep database URLs and provider keys in environment variables or OpenCode’s
  credential store, never in `opencode.json`.

## Related documentation

- [Root workstation README](../README.md)
- [Keymaps learning guide](../KEYMAPS_LEARNING.md)
- [OpenCode configuration](../opencode/README.md)
- [LazyVim documentation](https://lazyvim.github.io/)
- [JDTLS](https://github.com/eclipse-jdtls/eclipse.jdt.ls)
- [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
- [rest.nvim](https://github.com/rest-nvim/rest.nvim)
- [OpenCode.nvim](https://github.com/sudo-tee/opencode.nvim)
