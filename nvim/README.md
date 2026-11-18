# 🚀 Neovim Configuration for Java & Spring Boot Development

A comprehensive Neovim setup optimized for Java and Spring Boot development, built on [LazyVim](https://github.com/LazyVim/LazyVim).

## ✨ Features

### Java & Spring Boot Support
- **Enhanced JDTLS Integration**: Complete Java Language Server via LazyVim's `lang.java` extra (jdtls with Lombok support)
- **Custom Java Toolbox**: Build/run, profiles, migrations, dependency management and generators under `<leader>j`
- **Spring Boot Tools**: Dedicated Spring tooling and profile management with templates
- **Code Completion**: Intelligent completion for Java and Spring annotations
- **Refactoring**: Extract methods, variables, constants with JDTLS
- **Code Actions**: Quick fixes, imports organization, and more
- **Session Management**: LazyVim sessions with persistence.nvim

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
- **Fuzzy Finding**: fzf-lua for fast file and symbol search

## 🚀 Quick Start

### Prerequisites
- Neovim 0.11+ (included with LazyVim)
- Java 21+ (JDTLS runtime; project JDKs are detected automatically)
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

### Java-Specific (Custom `<leader>j` suite)
```vim
<leader>jrs   " Run Spring Boot
<leader>jrp   " Run with profile
<leader>jrk   " Stop app
<leader>jrm   " Maven build
<leader>jrg   " Gradle build
<leader>jmt   " Maven test
<leader>jmv   " Maven verify
<leader>jmp   " Maven package
<leader>jwt   " Gradle test
<leader>jwc   " Gradle clean build
<leader>jn    " New Java file (Class/Interface/Enum/Record)
<leader>js    " New Spring Boot file (Controller/Service/Repository/Entity/DTO)
<leader>jg    " Generate full CRUD
<leader>jbr   " Flyway migrate
<leader>jbn   " New migration
<leader>jps   " Switch Spring profile
<leader>jpn   " New profile
<leader>jpe   " Edit application config
<leader>jpp   " Edit profile config
<leader>jpi   " Profile info
<leader>jda   " Add dependency (auto-insert into pom/build.gradle)
<leader>jdt   " Dependency tree
<leader>jdu   " Update dependencies
<leader>jdv   " Check vulnerabilities
```

### Java LSP (JDTLS via LazyVim)
```vim
<leader>co    " Organize imports
<leader>cxv   " Extract variable
<leader>cxc   " Extract constant
<leader>cxm   " Extract method (visual)
<leader>tt    " Run all tests in class
<leader>tr    " Run nearest test
```

### Session Management
```vim
<leader>qs  " Restore session
<leader>qS  " Select session
<leader>ql  " Restore last session
<leader>qd  " Don't save current session
```

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
<leader>ff  " Find files (fzf-lua)
<leader>fg  " Find git files (fzf-lua)
<leader>fb  " Find buffers (fzf-lua)
<leader>fr  " Recent files (fzf-lua)
<leader>sg  " Live grep (fzf-lua)
```

## 🔧 Configuration Files

### Core Configuration
- `init.lua` - Main entry point
- `lazyvim.json` - LazyVim extras
- `lua/config/lazy.lua` - Plugin management
- `lua/config/options.lua` - Neovim options
- `lua/config/keymaps.lua` - General keybindings

### Java/JDTLS Configuration
- `lua/lang_servers/eclipse-java-google-style.xml` - Google Java formatting
- `lua/plugins/lsp.lua` - JDTLS formatting, imports and JDK runtimes
- `lua/plugins/java/` - Custom Java toolbox (build/run, profiles, migrations, dependencies, templates)
- `lua/plugins/java/templates/` - File, Spring Boot and CRUD generators
- `lua/plugins/java/keymaps-java.lua` - Keymaps under `<leader>j`

### Plugins
- `lua/plugins/` - All plugin configurations
- `lua/plugins/java/` - Custom Java modules (build-run, profiles, migrations, dependencies, templates)
- `lua/plugins/lsp.lua` - LSP server management (jdtls via LazyVim's `lang.java` extra)

### Theme & UI
- `lua/plugins/theme.lua` - Catppuccin + Heimdall colors
- `lua/user/heimdall.lua` - Custom color definitions

## 🆕 Recent Updates

### v3.0 - Custom Java Toolbox
- **Wrapper-aware builds**: prefers `./mvnw` / `./gradlew` when present
- **Expanded build commands**: Maven test/verify/package and Gradle test/clean build under `<leader>jm*` / `<leader>jw*`
- **Stop app**: `<leader>jrk` sends SIGINT to the running app
- **Dependency management**: `add_dependency` resolves the latest version from Maven Central and auto-inserts into `pom.xml` / `build.gradle`
- **CRUD generator**: automatic DTO<->Entity mapping and optional Lombok
- **LSP via LazyVim**: JDTLS + Java debugging/testing provided by LazyVim's `lang.java` extra

### Key Changes
- Removed legacy manual JDTLS setup (now handled by the LazyVim Java extra)
- Reorganized Java keymaps under `<leader>j` with dedicated which-key groups (Run, Maven, Gradle, Database, Profile, Dependencies)
- Updated documentation to match the current modules

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
2. Try `<leader>jrs` to run the application
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
- Check JDTLS settings in `lua/plugins/lsp.lua`

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
