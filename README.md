# 🏠 Patrick's Neovim Config

A carefully curated collection of Neovim configuration files for a modern development environment, organized with GNU Stow for easy management and deployment.

## 🎯 Philosophy

**Code is Poetry, Editors are Instruments**

This Neovim configuration transforms your text editor into a powerful development orchestra. Every keypress is a note, every plugin a musician, every language server a conductor. We believe in crafting tools that disappear into the background, letting your creativity flow unimpeded while providing the full power of modern development when you need it.

**One Editor, Infinite Possibilities**

From Java enterprise applications to TypeScript web projects, from Python data science to Lua scripting - this configuration adapts to your workflow, not the other way around. It's not just about editing text; it's about crafting software with elegance and efficiency.

**The Art of Invisible Power**

The best tools are those you forget you're using. This setup provides professional-grade development capabilities - LSP integration, debugging, version control, testing - all while maintaining the fluidity and speed that makes Neovim legendary.

**Craftsmanship Over Configuration**

Every line of code in these dotfiles has been carefully considered. Not for the sake of complexity, but for the pursuit of perfection. This is not just a Neovim setup; it's a philosophy of development excellence.

## 📦 What's Inside

### ✏️ Editor (editor/)

Modern Neovim configuration with LSP integration, treesitter, and extensive plugin ecosystem.

- **Neovim**: Modern Vim with LazyVim, LSP servers, DAP debugging, and productivity plugins
- **Plugin Ecosystem**: 50+ plugins for coding, navigation, git integration, and UI enhancements
- **Language Support**: Java, TypeScript, Python, and extensible for more languages
- **Custom Keymaps**: Intuitive keybindings with learning guide

## 🚀 Quick Start

### Prerequisites

#### GNU Stow
```bash
# Ubuntu/Debian
sudo apt install stow

# macOS
brew install stow

# Arch Linux
sudo pacman -S stow

# Fedora
sudo dnf install stow

# Verify
stow --version
```

#### Neovim
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install neovim

# macOS (with Homebrew)
brew install neovim

# Arch Linux
sudo pacman -S neovim

# Fedora
sudo dnf install neovim

# Verify version
nvim --version
```

### Installation

Clone the repository:
```bash
git clone https://github.com/patrickbpds/my-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Backup existing configurations (optional but recommended):
```bash
# Create backup directory
mkdir -p ~/.config-backup

# Backup existing Neovim config
cp -r ~/.config/nvim ~/.config-backup/ 2>/dev/null || true
```

Install with Stow:
```bash
# Install Neovim configuration
stow -v -R -t ~ -d . .config

# Install Neovim plugins
nvim --headless -c 'Lazy sync' +qa
```

## ✏️ Editor Configuration

### Core Features

#### 🚀 LazyVim Integration
- **Plugin Management**: Lazy loading with automatic updates
- **Performance**: Optimized startup times and memory usage
- **Modular**: Easy to enable/disable features

#### 💻 Language Server Protocol (LSP)
- **Multi-language Support**: Java, TypeScript, Python, Lua, and more
- **Auto-completion**: Intelligent code completion with context
- **Diagnostics**: Real-time error checking and warnings
- **Code Actions**: Quick fixes and refactoring suggestions

#### ☕ Java Development Excellence
- **JDTLS Integration**: Full Java language server with Eclipse quality
- **Spring Boot Support**: Dedicated tools for Spring Boot development
- **Maven/Gradle Integration**: Build system support with one-click execution
- **JUnit Testing**: Integrated test runner for unit and integration tests
- **Code Generation**: Automatic CRUD operations and boilerplate generation
- **Database Tools**: Flyway migration support and database integration
- **Microservices Ready**: Optimized for enterprise Java applications

#### 🔍 Treesitter
- **Syntax Highlighting**: Accurate syntax highlighting for all supported languages
- **Code Navigation**: Smart jumping to definitions, references, and symbols
- **Folding**: Intelligent code folding based on syntax

#### 🐛 Debug Adapter Protocol (DAP)
- **Integrated Debugging**: Debug code directly in Neovim
- **Breakpoints**: Set, toggle, and manage breakpoints
- **Variable Inspection**: Watch variables and expressions
- **Step Through**: Step into, over, and out of functions

#### 🎨 UI Enhancements
- **Modern Interface**: Clean, distraction-free editing environment
- **Themes**: Carefully selected color schemes for readability
- **Status Line**: Informative status bar with git status and LSP info
- **File Explorer**: Tree-style file browser with git integration

### Key Features

1. **Git Integration**: `<leader>gg` for Lazygit, inline git blame and diff
2. **Terminal Integration**: `<C-/>` for integrated terminal
3. **Session Management**: Automatic session saving and restoration
4. **Snippet Support**: Code snippets for faster coding
5. **Formatter Integration**: Automatic code formatting on save

### Java Development Workflow

#### Build & Run
- `<leader>JRr` - Run Spring Boot application
- `<leader>JRm` - Maven build
- `<leader>JRg` - Gradle build

#### Testing
- `<leader>Jtm` - Test current method
- `<leader>Jtc` - Test current class
- `<leader>Jta` - Test all classes

#### Code Generation
- `<leader>Jn` - New Java class
- `<leader>JS` - New Spring Boot component
- `<leader>JG` - Generate CRUD operations

#### Refactoring
- `<leader>Jrv` - Extract variable
- `<leader>Jrc` - Extract constant
- `<leader>Jrr` - Rename symbol

### Learning Keymaps

📖 [Complete Keymaps Learning Guide](KEYMAPS_LEARNING.md)

## 🔧 Customization

### Modifying Configurations
Edit files directly in the stow directories:
```bash
# Edit Neovim config
vim .config/nvim/lua/config/options.lua

# Restow to apply changes
stow -R .config
```

### Adding New Configurations
```bash
# Create new package directory
mkdir -p mypackage/.config/myapp

# Add your config files
cp ~/.config/myapp/config mypackage/.config/myapp/

# Stow the new package
stow mypackage
```

## 🗂️ Directory Structure

```
my-dotfiles/
├── .config/
│   └── nvim/                    # Complete Neovim configuration
│       ├── lua/
│       │   ├── config/          # Core configurations
│       │   │   ├── autocmds.lua # Auto commands
│       │   │   ├── keymaps.lua  # Key mappings
│       │   │   ├── lazy.lua     # Plugin manager config
│       │   │   ├── options.lua  # Neovim options
│       │   │   └── lazyvim.json # LazyVim config
│       │   ├── lang_servers/    # Language server configs
│       │   │   └── intellij-java-google-style.xml
│       │   └── plugins/         # Plugin configurations
│       │       ├── java/        # Java-specific plugins
│       │       ├── autopairs.lua
│       │       ├── cmp.lua      # Completion
│       │       ├── comment.lua  # Commenting
│       │       ├── dap.lua      # Debug adapter
│       │       ├── git.lua      # Git integration
│       │       ├── grapple.lua  # Fast navigation
│       │       ├── harpoon.lua  # File marking
│       │       ├── lint.lua     # Linting
│       │       ├── lsp.lua      # Language server
│       │       ├── lualine.lua  # Status line
│       │       ├── neo-tree.lua # File explorer
│       │       ├── session.lua  # Session management
│       │       ├── snippets.lua # Code snippets
│       │       ├── theme.lua    # Color scheme
│       │       ├── ui.lua       # UI enhancements
│       │       ├── wakatime.lua # Time tracking
│       │       └── which-key.lua # Key hinting
│       ├── .gitignore
│       ├── .neoconf.json
│       ├── init.lua             # Main init file
│       ├── lazy-lock.json       # Plugin lockfile
│       └── stylua.toml          # Lua formatter config
├── KEYMAPS_LEARNING.md          # Keymaps learning guide
└── README.md                    # This documentation
```

## 🔄 Management Commands

### Useful Stow Commands

```bash
# Install/link configurations
stow .config

# Remove/unlink configurations
stow -D .config

# Reinstall (useful after editing)
stow -R .config

# Simulate actions (dry run)
stow -n .config

# Verbose output
stow -v .config
```

### Maintenance

```bash
# Check for broken symlinks
find ~ -xtype l -print

# Update from git
git pull origin main

# Restow after updates
stow -R .config

# Clean broken symlinks
find ~ -maxdepth 1 -name ".*" -type l ! -exec test -e {} \; -delete 2>/dev/null || true
```

## 🔧 Troubleshooting

### LSP not working
```bash
# Check if Mason is installed
:Mason

# Install LSP servers
:MasonInstall lua-language-server typescript-language-server
```

### Plugins not loading
```bash
# Sync plugins
:Lazy sync

# Clear cache
:Lazy clean
```

### Stow Issues
```bash
# Check stow status
stow -n .config

# Restow configuration
stow -v -R -t ~ -d . .config

# Clean broken symlinks
find ~ -maxdepth 1 -name ".*" -type l ! -exec test -e {} \; -delete 2>/dev/null || true
```

### Slow performance
```bash
# Disable unnecessary plugins
:LazyExtras

# Check performance settings
:checkhealth
```

### Version Issues
```bash
# Check Neovim version
nvim --version

# Ensure version 0.9 or higher
# Upgrade if necessary
```

## 🤝 Contributing

Feel free to open issues and pull requests!

## 📄 License

This project is under the MIT license.

## 🙏 Acknowledgments

- The GNU Stow maintainers for this excellent tool
- The LazyVim community for the amazing base configuration
- Everyone who shares their dotfiles and inspires others

"The best dotfiles are the ones that make you forget they exist while making everything work perfectly."
