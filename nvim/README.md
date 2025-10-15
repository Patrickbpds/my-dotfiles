# 🚀 Neovim Configuration for Java & Spring Boot Development

A comprehensive Neovim setup optimized for Java and Spring Boot development, built on [LazyVim](https://github.com/LazyVim/LazyVim).

## ✨ Features

### Java & Spring Boot Support
- **Enhanced JDTLS Integration**: Complete Java Language Server with nvim-java for automatic plugin management
- **Spring Boot Tools**: Integrated Spring Boot development with nvim-java's spring-boot-tools
- **Code Completion**: Intelligent completion for Java, Spring annotations, and dependencies
- **Refactoring**: Extract methods, variables, constants with JDTLS
- **Code Actions**: Quick fixes, imports organization, and more
- **Session Management**: Automatic session saving per Git repository (inspired by brianrbrenner)

### Debugging & Testing
- **DAP Integration**: Debug Java applications with breakpoints and stepping
- **Test Execution**: Run JUnit/TestNG tests directly from Neovim
- **Debug Adapters**: Java Debug Adapter and Java Test adapters via Mason

### Code Quality
- **Google Java Style**: Automatic code formatting following Google standards
- **Import Organization**: Automatic import sorting and optimization
- **Diagnostics**: Real-time error detection and warnings
- **Code Lens**: Reference counts and implementation hints

### UI/UX Enhancements
- **Custom Theme**: Catppuccin with Heimdall color scheme
- **Advanced Status Line**: Lualine with LSP, diagnostics, and git integration
- **File Explorer**: Neo-tree for project navigation
- **Fuzzy Finding**: Telescope for fast file and symbol search

## 🚀 Quick Start

### Prerequisites
- Neovim 0.11+ (included with LazyVim)
- Java 17+ (for JDTLS and Spring Boot)
- Git (for plugin management)

### Installation
This configuration is already set up. To start using it:

1. **Open a Java/Spring Boot project**:
   ```bash
   cd /path/to/your/spring-boot-project
   nvim
   ```

2. **JDTLS will automatically start** when you open a `.java` file

3. **Install required LSP servers** (first time only):
   ```vim
   :MasonInstall jdtls java-debug-adapter java-test
   ```

## 📋 Key Mappings

### LSP (Language Server Protocol)
```vim
<leader>ch  " Show hover documentation
<leader>cd  " Go to definition
<leader>cD  " Go to declaration
<leader>cr  " Show references
<leader>ci  " Show implementations
<leader>ca  " Code actions
<leader>cR  " Rename symbol
```

### Java-Specific (JDTLS + nvim-java)
```vim
<leader>Jo  " Organize imports
<leader>Jv  " Extract variable
<leader>JC  " Extract constant
<leader>Jt  " Test nearest method
<leader>JT  " Test class
<leader>Ju  " Update project config
<leader>Jr  " Run Spring Boot (via nvim-java)
<leader>Jc  " Create class (via nvim-java)
<leader>Ji  " Create interface (via nvim-java)
<leader>Je  " Create enum (via nvim-java)
```

### Session Management
```vim
<leader>ss  " Save current session
<leader>sl  " Load session
<leader>sd  " Delete session
```
*Sessions are automatically saved per Git repository on exit*

### Debugging (DAP)
```vim
<leader>dc  " Start/Continue debugging
<leader>dd  " Step over
<leader>de  " Step into
<leader>df  " Step out
<leader>db  " Toggle breakpoint
<leader>dB  " Conditional breakpoint
```

### General
```vim
<leader>ff  " Find files (Telescope)
<leader>fg  " Live grep (Telescope)
<leader>fb  " Find buffers (Telescope)
<leader>fh  " Help tags (Telescope)
```

## 🔧 Configuration Files

### Core Configuration
- `init.lua` - Main entry point
- `lua/config/lazy.lua` - Plugin management
- `lua/config/options.lua` - Neovim options
- `lua/config/keymaps.lua` - General keybindings
- `lua/config/autocmds.lua` - Auto commands

### Java/JDTLS Configuration
- `lua/config/jdtls.lua` - Complete JDTLS setup
- `lua/lang_servers/intellij-java-google-style.xml` - Google Java formatting

### Plugins
- `lua/plugins/` - All plugin configurations
- `lua/plugins/java.lua` - nvim-java integration (replaces manual JDTLS)
- `lua/plugins/session.lua` - Auto-session management
- `lua/plugins/dap.lua` - Debug adapter configuration
- `lua/plugins/lsp.lua` - LSP server management

### Theme & UI
- `lua/plugins/theme.lua` - Catppuccin + Heimdall colors
- `lua/user/heimdall.lua` - Custom color definitions

## 🆕 Recent Updates

### v2.0 - Enhanced Java/Spring Boot Integration
- **Migrated to nvim-java**: Replaced manual JDTLS setup with nvim-java for automatic plugin management
- **Enhanced Spring Boot Support**: Integrated nvim-java's spring-boot-tools for better Spring development
- **Session Management**: Added auto-session plugin for per-repository session persistence
- **Improved Configuration**: Streamlined plugin loading and reduced conflicts

### Key Changes
- Disabled manual JDTLS autocmd (now handled by nvim-java)
- Disabled separate springboot-nvim plugin (functionality in nvim-java)
- Added session management with Git branch awareness
- Enhanced key mappings for Spring Boot operations

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   LazyVim Core  │    │   Custom Config │    │ External Tools  │
│   (Base distro) │◄──►│   (Java/Spring) │◄──►│   (Java, JDTLS) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   LSP Client    │    │   DAP Client    │    │   Build Tools   │
│ (nvim-lspconfig)│    │  (nvim-dap)     │    │  (Gradle/Maven) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧪 Testing Your Setup

### Basic LSP Test
1. Open a `.java` file
2. Check status line shows "jdtls"
3. Try `<leader>ch` on a class/method - should show documentation

### Code Completion Test
1. Type `System.out.p` and press `<Tab>`
2. Should complete to `System.out.println()`

### Debugging Test
1. Set breakpoint with `<leader>db`
2. Start debug with `<leader>dc`
3. Should show debug UI

### Spring Boot Test
1. Open a Spring Boot project
2. Try `<leader>Jr` to run the application
3. Should start Spring Boot server

## 🔍 Troubleshooting

### JDTLS Not Starting
```vim
:MasonInstall jdtls
:MasonInstall java-debug-adapter
:MasonInstall java-test
```
Then restart Neovim and reopen Java file.

### No Code Completion
- Ensure JDTLS is running (check status line)
- Try `:LspInfo` to see LSP status
- Check `:Mason` for installed servers

### Formatting Not Working
- Verify Google style XML file exists
- Check JDTLS settings in `lua/config/jdtls.lua`

### Debug Not Working
- Ensure Java debug adapter is installed
- Check DAP UI is loaded
- Try `:DapShowLog` for debug logs

## 📚 Resources

- [LazyVim Documentation](https://lazyvim.github.io/)
- [JDTLS Documentation](https://github.com/eclipse-jdtls/eclipse.jdt.ls)
- [Spring Boot Plugin](https://github.com/elmcgill/springboot-nvim)
- [Neovim LSP](https://neovim.io/doc/user/lsp.html)

## 🤝 Contributing

This configuration is maintained for Java/Spring Boot development. For improvements:

1. Test changes with real Spring Boot projects
2. Ensure backward compatibility
3. Update documentation
4. Follow existing code style

## 📄 License

This Neovim configuration is provided as-is for development use.
