# Neovim Keymaps Learning Guide

A progressive guide to the keymaps in this workstation. `<leader>` is **Space**.
LazyVim provides most defaults; this repository adds the Java toolbox, OpenCode,
REST, and a few editor conveniences.

Use `<leader>?` or wait after pressing `<leader>` to let which-key show the
available continuations. Use `:verbose map <key>` when a mapping is unclear.

## 1. Basics

### Movement and editing

```vim
h j k l          " Character movement
w b              " Word forward/back
0 $              " Start/end of line
gg G             " Top/bottom of file
i a              " Insert/append
o O              " New line below/above
x dd             " Delete character/line
u <C-r>          " Undo/redo
```

### Search

```vim
/pattern         " Search forward
?pattern         " Search backward
n N              " Next/previous match
* #              " Search word under cursor
<Esc>            " Clear search highlights
```

### Windows

```vim
<C-h> <C-j> <C-k> <C-l>   " Move focus between windows
<leader>wv                 " Vertical split
<leader>wh                 " Horizontal split
<leader>wd                 " Delete window
```

### Terminal and indentation

```vim
<C-/>            " Toggle/focus the root terminal
<leader>ft       " Terminal in project root
<leader>fT       " Terminal in cwd
<Esc><Esc>       " Leave terminal mode
< >              " Indent left/right, keep selection (visual mode)
```

## 2. Files, buffers, and search

### Pickers (fzf-lua)

```vim
<leader><space>  " Find files (root)
<leader>ff       " Find files (root)
<leader>fF       " Find files (cwd)
<leader>fg       " Find git files
<leader>fb       " Buffers
<leader>fr       " Recent files
<leader>fc       " Find config file
```

### Grep and symbols

```vim
<leader>/        " Live grep (root)
<leader>sg       " Live grep (root)
<leader>sG       " Live grep (cwd)
<leader>sw       " Word under cursor (root)
<leader>sW       " Word under cursor (cwd)
<leader>sd       " Workspace diagnostics
<leader>sD       " Buffer diagnostics
<leader>sk       " Search keymaps
<leader>sh       " Help pages
```

### Buffers

```vim
<leader>bb       " Switch to other buffer
<leader>bd       " Delete buffer
<leader>bo       " Delete other buffers
<leader>bi       " Delete invisible buffers
```

### File explorer (Neo-tree)

```vim
<leader>e        " Toggle explorer (root)
<leader>E        " Toggle explorer (cwd)
<leader>fe       " Toggle explorer (root)
<leader>fE       " Toggle explorer (cwd)
<leader>ge       " Git status explorer
<leader>be       " Buffer explorer
```

Inside Neo-tree, use `a` to add, `d` to delete, `r` to rename, `y` to copy, and
`p` to paste.

## 3. Code and LSP

### Navigation

```vim
gd               " Go to definition
gr               " References
gI               " Implementation
K                " Hover documentation
gh               " Hover (this config remaps gh to K)
```

### Actions

```vim
<leader>ca       " Code action
<leader>cA       " Source action
<leader>cr       " Rename symbol (inc-rename)
<leader>cR       " Rename file
<leader>cf       " Format buffer
<leader>co       " Organize imports (Java)
<leader>cxv      " Extract variable
<leader>cxc      " Extract constant
<leader>cxm      " Extract method (visual mode)
```

### Diagnostics and trouble

```vim
]d / [d          " Next/previous diagnostic
<leader>cd       " Line diagnostics
<leader>xx       " Workspace diagnostics (Trouble)
<leader>xX       " Buffer diagnostics (Trouble)
<leader>cs       " Symbols (Trouble)
<leader>cS       " LSP references/definitions (Trouble)
]q / [q          " Next/previous quickfix item
```

## 4. Git

### Lazygit and pickers

```vim
<leader>gg       " Lazygit (repository root)
<leader>gG       " Lazygit (cwd)
<leader>gd       " Git diff (files)
<leader>gs       " Git status
<leader>gl       " Git log
<leader>gb       " Blame line
<leader>gf       " Current file history
<leader>gc       " Commits
```

### Hunk workflow (gitsigns)

```vim
]h / [h          " Next/previous hunk
]H / [H          " Last/first hunk
<leader>ghs      " Stage hunk
<leader>ghr      " Reset hunk
<leader>ghS      " Stage buffer
<leader>ghu      " Undo stage hunk
<leader>ghp      " Preview hunk inline
<leader>ghb      " Blame line
<leader>ghB      " Blame buffer
<leader>ghd      " Diff this
<leader>ghD      " Diff this against HEAD~1
```

### Fugitive

Fugitive is lazy-loaded. These commands open it on demand:

```vim
:Git             " Status
:Git diff        " Diff
:Gdiffsplit      " Diff in a split
:Gread           " Revert the current file from Git
:Gwrite          " Stage/write the current file
:Ggrep pattern   " Git grep
```

Octo adds GitHub issue/PR browsing; it is not a second general Git UI.

## 5. Tests

### Generic (Neotest)

```vim
<leader>tt       " Run current test file
<leader>tT       " Run all test files
<leader>tr       " Run nearest test
<leader>ts       " Toggle summary
<leader>to       " Show output
<leader>tO       " Toggle output panel
<leader>tS       " Stop
<leader>tw       " Toggle watch
<leader>td       " Debug nearest test
```

### Java (JDTLS)

In a Java buffer, these buffer-local maps replace the generic ones:

```vim
<leader>tt       " Run all tests in the current class (JDTLS)
<leader>tr       " Run the nearest test method (JDTLS)
<leader>tT       " Pick a test (JDTLS)
```

The Java test runner is the JDTLS DAP integration. `neotest-java` is deliberately
not installed, so there is only one Java test path. Test output goes to the DAP
repl; `Tests finished. Results printed to dap-repl.` means it completed.

## 6. Debugging (DAP)

```vim
<leader>dc       " Run/continue
<leader>da       " Run with arguments
<leader>db       " Toggle breakpoint
<leader>dB       " Conditional breakpoint
<leader>dC       " Run to cursor
<leader>di       " Step into
<leader>dO       " Step over
<leader>do       " Step out
<leader>dP       " Pause
<leader>dr       " Toggle REPL
<leader>du       " Toggle DAP UI
<leader>de       " Evaluate expression
<leader>dt       " Terminate
<leader>dl       " Run last
```

Java main-class configurations are registered automatically. Set a breakpoint,
then use `<leader>dc`.

## 7. Java toolbox

Every action is under `<leader>j`. `<leader>j?` opens `:JavaCommands`.

### Run and build

```vim
<leader>jrs      " Run Spring Boot
<leader>jrp      " Run with a profile
<leader>jrk      " Stop the app/build
<leader>jrm      " Maven clean install
<leader>jrg      " Gradle build
```

### Maven and Gradle

```vim
<leader>jmt      " Maven test
<leader>jmv      " Maven clean verify
<leader>jmp      " Maven clean package
<leader>jwt      " Gradle test
<leader>jwc      " Gradle clean build
```

### Generators

```vim
<leader>jn       " New Java class/interface/enum/record
<leader>js       " New Spring component
<leader>jg       " Generate a CRUD stack
```

### Database and Spring profiles

```vim
<leader>jbr      " Flyway migrate
<leader>jbn      " New Flyway migration
<leader>jps      " Switch Spring profile
<leader>jpn      " Create a Spring profile
<leader>jpe      " Edit application config
<leader>jpp      " Edit profile config
<leader>jpi      " Show profile info
```

### Dependencies

```vim
<leader>jda      " Add dependency (latest version from Maven Central)
<leader>jdt      " Dependency tree
<leader>jdu      " Check dependency updates
<leader>jdv      " Check vulnerabilities
```

**Mnemonic:** `r` run, `m` Maven, `w` Gradle wrapper, `b` database,
`p` profile, `d` dependencies, `n`/`s`/`g` generators.

## 8. OpenCode

OpenCode is the coding agent. Supermaven is only inline completion; Blink handles
completion. These maps are provided by `opencode.nvim` under `<leader>o`.

### Core

```vim
<leader>oi       " Open prompt input
<leader>oI       " New session
<leader>og       " Toggle OpenCode window
<leader>oo       " Open output
<leader>ot       " Toggle focus
<leader>oq       " Close window
```

### Review and context

```vim
<leader>od       " Open the diff view
<leader>o]       " Next diff
<leader>o[       " Previous diff
<leader>oc       " Close diff
<leader>oy       " Add visual selection to context (visual mode)
<leader>oY       " Insert visual selection inline (visual mode)
```

### Sessions

```vim
<leader>oh       " History
<leader>os       " Select session
<leader>oT       " Timeline
<leader>oN       " New session tab
<leader>o< / >   " Previous/next session tab
```

### Model and provider

```vim
<leader>op       " Configure provider
<leader>oV       " Configure model variant
```

Outside Neovim, use `opencode` for the TUI and `opencode debug config` to inspect
the resolved configuration. Context7 is the only default MCP.

## 9. REST and GraphQL

Open an `.http` file, place the cursor in a request, then:

```vim
<leader>Rs       " Send request
<leader>Rr       " Replay last request
<leader>Ro       " Open result pane
<leader>Re       " Select environment
<leader>Rc       " Edit cookies
<leader>Rl       " Open logs
```

Example:

```http
@base = http://localhost:8080

### Health
GET {{base}}/actuator/health

### Create order
POST {{base}}/api/orders
Content-Type: application/json

{"sku": "ABC-1", "quantity": 2}
```

## 10. SQL

```vim
<leader>D        " Toggle Dadbod UI
<leader>S        " Execute query under cursor (inside DBUI, normal/visual)
```

Keep database URLs in a local `.lazy.lua`, environment variables, or Dadbod’s
connection store; never commit them.

## 11. Sessions and quitting

```vim
<leader>qs       " Restore session
<leader>qS       " Select session
<leader>ql       " Restore last session
<leader>qd       " Don't save current session
<leader>qq       " Quit all
```

## 12. Learning path

1. **Week 1:** `h j k l`, `w b`, `gg G`, `i a o`, `dd u <C-r>`, `/ n`.
2. **Week 2:** window navigation, `<leader>ff`, `<leader>sg`, `<leader>fb`,
   `<leader>e`.
3. **Week 3:** `gd`, `gr`, `K`, `<leader>ca`, `<leader>cr`, diagnostics.
4. **Week 4:** Git hunks, Lazygit, sessions, Java tests and debugging.
5. **Ongoing:** OpenCode (`<leader>oi`, `<leader>od`) and REST (`<leader>Rs`).

### Practice exercises

1. Open a project, jump to a class with `<leader>ff`, then `gd` into a method.
2. Use `<leader>ca` to fix an import, then `<leader>cf` to format.
3. Make two edits, stage one hunk with `<leader>ghs`, and inspect the diff with
   `<leader>gd`.
4. Open a Java test, run `<leader>tr` on one method, then `<leader>tt` for the
   class.
5. Set a breakpoint with `<leader>db`, start with `<leader>dc`, and step with
   `<leader>dO`, `<leader>di`, and `<leader>do`.
6. Open an `.http` file and send a request with `<leader>Rs`.
7. Ask OpenCode for a change with `<leader>oi`, review it with `<leader>od`, and
   accept or revert it.

## Troubleshooting

### A keymap does not work

1. Check the mode: normal, visual, insert, or terminal.
2. Confirm the plugin is loaded with `:Lazy`.
3. Inspect the mapping:

   ```vim
   :verbose map <leader>tt
   :verbose map <leader>oi
   ```

4. In Java buffers, `<leader>tt` is buffer-local and intentionally different
   from Neotest.

### Which-key does not show a group

Run `:Lazy load which-key`, then press `<leader>` again. In headless runs,
which-key may not initialize; the Java test maps are still set directly in
JDTLS `on_attach`.

### Startup feels slow

Use `:Lazy profile` and compare against the warm baseline in
[`nvim/README.md`](nvim/README.md). WakaTime, OpenCode, REST, and Fugitive are
lazy-loaded; an accidental eager plugin is the usual cause.

---

**Tip:** Learn 3–5 maps per day and use them until they are automatic. The goal
is not to memorize every mapping; it is to keep the common Java, Git, test, and
agent workflows within reach.
