# 📚 Neovim Keymaps Learning Guide

This guide is a complete tutorial to learn and master the keymaps configured in my Neovim setup. Each section includes explanations, practical examples, and memorization tips.

## 🏠 General Keymaps (Always Available)

### Basic Navigation
```vim
<C-h>    " Move focus to left window
<C-j>    " Move focus to lower window
<C-k>    " Move focus to upper window
<C-l>    " Move focus to right window
```

**Memorization Tip:** Think of HJKL as an inverted arrow:
- H: Left (←)
- J: Down (↓)
- K: Up (↑)
- L: Right (→)

**Exercise:** Open two vertical splits (`:vsplit`) and practice navigating between them.

### Window Management
```vim
<leader>wv    " Split window vertically
<leader>wh    " Split window horizontally
```

**Tip:** `<leader>w` + `v` (vertical) or `h` (horizontal).

### Clear Highlights
```vim
<Esc>         " Remove search highlights
```

**When to use:** After searching with `/` or `?`.

### Terminal Mode
```vim
<Esc><Esc>    " Exit terminal mode
```

**Tip:** In integrated terminal, press Esc twice to return to normal mode.

### Visual Indentation
```vim
<          " Indent left (keeps selection)
>          " Indent right (keeps selection)
```

**Tip:** Use in visual mode to indent multiple lines without losing selection.

## 🔍 Navigation and Search (Telescope)

### File Search
```vim
<leader>ff    " Find files (Telescope)
<leader>fg    " Search text (grep) in all files
<leader>fb    " List open buffers
<leader>fr    " Recent files
```

**Mnemonic Sequence:** "Find Files", "Find Grep", "Find Buffers", "Find Recent"

**Exercise:** Use `<leader>ff` to open a file, then `<leader>fb` to return to buffers.

### Advanced Search
```vim
<leader>sg    " Search text with grep
<leader>sw    " Search word under cursor
<leader>sG    " Search text in git files
```

## 💻 Code Development (LSP)

### Code Navigation
```vim
gd         " Go to definition
gr         " Go to references
K          " Show documentation (hover)
```

**Sequence:** g + d (definition), g + r (references), K (know/Knowledge)

### Code Actions
```vim
<leader>ca    " Available code actions
<leader>rn    " Rename symbol
<leader>cR    " Refactor structure
```

### Diagnostics
```vim
]d         " Next error/diagnostic
[d         " Previous error
<leader>cd " Current line diagnostic
<leader>cD " Workspace diagnostics
```

**Tip:** Use `]d` and `[d` to quickly navigate between errors.

## 📝 Git Integration

### Git Commands
```vim
<leader>gg    " Open Lazygit
<leader>gb    " Current line blame
<leader>gd    " File diff
<leader>gD    " File diff (split)
```

### Hunk Navigation
```vim
]c         " Next git hunk
[c         " Previous hunk
```

**Tip:** Use to navigate between changes in the file.

## 🖥️ Terminal and Sessions

### Integrated Terminal
```vim
<C-/>      " Toggle terminal
<leader>ft " Terminal in project root directory
<leader>fT " Terminal in current directory
```

### Sessions
```vim
<leader>qs    " Save session
<leader>ql    " Load session
<leader>qd    " Delete session
```

## 📁 File Explorer (Neo-tree)

### Basic Navigation
```vim
<leader>e     " Toggle explorer
<leader>E     " Focus on explorer
```

### Explorer Actions
```vim
a          " Create file/directory
d          " Delete file/directory
r          " Rename
y          " Copy
p          " Paste
```

## 🔧 Java Development (Specialized)

### Build and Execution
```vim
<leader>JRr    " Run Spring Boot
<leader>JRm    " Maven build
<leader>JRg    " Gradle build
<leader>JRp    " Run with profile
<leader>JRs    " Stop application
```

**Sequence:** `<leader>J` + `R` (Run) + command initial

**Note:** Testing, refactoring, and code generation features are now handled by LazyVim's built-in LSP and testing integrations. Use `<leader>c` for code actions and `<leader>ft` for testing.

### Logs and Monitoring
```vim
<leader>JLv    " View logs
<leader>JLt    " Tail logs
```

### Database
```vim
<leader>JBm    " Flyway migrate
<leader>JBn    " New migration
```

### Configurations
```vim
<leader>JCp    " Switch profile
<leader>JCe    " Edit properties
<leader>JCP    " Edit profile properties
<leader>JCg    " Generate properties template
<leader>JCu    " Update JDTLS config
```

### Dependencies
```vim
<leader>JDa    " Add dependency
<leader>JDu    " Update dependencies
<leader>JDv    " Check vulnerabilities
<leader>JDd    " Show dependency tree
```

## 🎯 Keymap Groups by Prefix

### `<leader>` (Space) - Main
- **f**: Find/File operations
- **s**: Search operations
- **g**: Git operations
- **c**: Code operations
- **q**: Session/quit operations
- **w**: Window operations
- **b**: Buffer operations
- **h**: Help/documentation

### `<leader>J` - Java (Specialized)
- **JR**: Run/Build operations
- **JL**: Logs
- **JB**: Database
- **JC**: Configuration
- **JD**: Dependencies

**Note:** Testing and refactoring are handled by LazyVim's built-in LSP features (`<leader>c` for code actions).

## 🚀 Learning Tips

### 1. Learn Progressively
- Start with basic navigation (HJKL, windows)
- Then searches (ff, fg, fb)
- Then LSP (gd, gr, K)
- Finally specializations (Java, Git)

### 2. Use Which-Key
The which-key plugin automatically shows available options when you press `<leader>`.

### 3. Practice Daily
- Open Neovim and practice 5-10 minutes per day
- Use `:Tutor` for basic lessons
- Experiment with new combinations

### 4. Memorization by Associations
- **gd**: "go definition" (go to definition)
- **gr**: "go references" (go to references)
- **K**: "Know" (knowledge/documentation)
- **<leader>ff**: "find files" (find files)

### 5. Essential Shortcuts for Beginners
```vim
# Navigation
h j k l          # Basic movement
w b              # Word forward/back
0 $              # Start/end of line
gg G             # Top/bottom of file

# Editing
i a              # Insert/Append
o O              # New line below/above
x dd             # Delete char/line
u Ctrl+r         # Undo/Redo

# Search
/ ?              # Search forward/backward
n N              # Next/previous occurrence
* #              # Search word under cursor
```

### 6. Important Commands
```vim
:w :q :wq         # Save/Quit/Save and quit
:e <file>         # Open file
:sp :vsp          # Split horizontal/vertical
:buffers          # List buffers
:help <topic>     # Help
```

## 🎮 Practical Exercises

### Exercise 1: Basic Navigation
1. Open a large file
2. Use `gg` to go to top
3. Use `G` to go to bottom
4. Use `50G` to go to line 50
5. Use `/word` to search
6. Use `n` for next occurrence

### Exercise 2: Multi-window Editing
1. `:vsplit` to split vertically
2. `<C-l>` and `<C-h>` to navigate
3. Open different files in each window
4. `:sp` to split horizontally
5. Practice navigation with `<C-j>` and `<C-k>`

### Exercise 3: Java Development
1. Open a `.java` file
2. Use `<leader>JRr` to run Spring Boot
3. Use `<leader>ft` to run tests (LazyVim built-in)
4. Use `gd` to go to definition
5. Use `<leader>ca` for code actions (LazyVim built-in)

### Exercise 4: Git Workflow
1. Make changes to a file
2. Use `<leader>gd` to see diff
3. Use `<leader>gg` to open Lazygit
4. Navigate hunks with `]c` and `[c`

## 🔍 Troubleshooting

### Keymap not working?
1. Check if you're in the correct mode (normal/visual/insert)
2. Confirm plugin is loaded (`:Lazy`)
3. Use `:verbose map <key>` to see mappings
4. Check conflicts with `:map`

### Forgot a keymap?
- Press `<leader>` and wait (which-key)
- Consult this guide
- Use `:help` for official documentation

### Slow performance?
- Use local keymaps when possible
- Avoid recursive mappings
- Configure appropriate timeouts

---

**💡 Final Tip:** Practice makes perfect. Start slow, focus on 3-5 keymaps per day, and gradually build your command vocabulary. Neovim is a powerful tool - master the keymaps and you'll be much more productive!</content>
</xai:function_call">Write file KEYMAPS_LEARNING.md