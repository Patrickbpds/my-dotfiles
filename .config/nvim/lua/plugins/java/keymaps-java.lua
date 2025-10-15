-- ============================================================================
-- ⌨️ KEY MAPPINGS FOR JAVA
-- ============================================================================

-- Setup basic Java keymaps (always available for .java files)
local function setup_basic_java_keymaps()
  -- ========== LOGS ==========
  vim.keymap.set("n", "<leader>JLv", function()
    require("plugins.java.java").view_logs()
  end, { desc = "View Logs" })

  vim.keymap.set("n", "<leader>JLt", function()
    require("plugins.java.java").tail_logs()
  end, { desc = "Tail Logs" })
end

-- Setup LSP-specific keymaps (only with JDTLS)
local function setup_lsp_java_keymaps(buf)
  -- ========== FORMAT AND IMPORTS ==========
  vim.keymap.set(
    "n",
    "<leader>JrF",
    "<Cmd>lua vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })<CR>",
    { buffer = buf, desc = "Organize Imports" }
  )

  vim.keymap.set("n", "<leader>Jrf", function()
    vim.lsp.buf.format({ async = true })
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" }, diagnostics = {} },
      apply = true,
    })
  end, { buffer = buf, desc = "Format + Organize Imports" })

  -- ========== REFACTORING ==========
  vim.keymap.set(
    "n",
    "<leader>Jrv",
    "<Cmd>lua require('plugins.java.java').refactor.extract_variable()<CR>",
    { buffer = buf, desc = "Extract Variable" }
  )

  vim.keymap.set(
    "v",
    "<leader>Jrv",
    "<Esc><Cmd>lua require('plugins.java.java').refactor.extract_variable()<CR>",
    { buffer = buf, desc = "Extract Variable" }
  )

  vim.keymap.set(
    "n",
    "<leader>Jrc",
    "<Cmd>lua require('plugins.java.java').refactor.extract_constant()<CR>",
    { buffer = buf, desc = "Extract Constant" }
  )

  vim.keymap.set(
    "v",
    "<leader>Jrc",
    "<Esc><Cmd>lua require('plugins.java.java').refactor.extract_constant()<CR>",
    { buffer = buf, desc = "Extract Constant" }
  )

  vim.keymap.set("n", "<leader>Jrm", function()
    vim.lsp.buf.code_action({
      context = {
        diagnostics = {},
        only = { "refactor.extract.method" },
      },
      apply = false,
    })
  end, { buffer = buf, desc = "Extract Method" })

  vim.keymap.set("n", "<leader>Jrr", "<Cmd>lua vim.lsp.buf.rename()<CR>", { buffer = buf, desc = "Rename Symbol" })

  -- ========== TESTING ==========
  vim.keymap.set(
    "n",
    "<leader>Jtm",
    "<Cmd>lua require('plugins.java.java').test.run_current_method()<CR>",
    { buffer = buf, desc = "Test Method" }
  )

  vim.keymap.set(
    "n",
    "<leader>Jtc",
    "<Cmd>lua require('plugins.java.java').test.run_current_class()<CR>",
    { buffer = buf, desc = "Test Class" }
  )

  vim.keymap.set("n", "<leader>Jtl", function()
    require("plugins.java.java").test.run_last()
  end, { buffer = buf, desc = "Run Last Test" })

  vim.keymap.set("n", "<leader>Jtd", function()
    require("plugins.java.java").test.debug_current_method()
  end, { buffer = buf, desc = "Debug Test Method" })

  vim.keymap.set("n", "<leader>Jta", function()
    local utils = require("plugins.java.java-utils")
    local build_tool = utils.get_build_tool()
    if build_tool == "maven" then
      require("plugins.java.build-run").maven_test()
    elseif build_tool == "gradle" then
      require("plugins.java.build-run").gradle_test()
    end
  end, { buffer = buf, desc = "Test All" })

  -- ========== CODE GENERATION ==========
  vim.keymap.set("n", "<leader>Jcg", function()
    vim.lsp.buf.code_action({
      context = {
        diagnostics = {},
        only = { "source.generate.toString", "source.generate.hashCodeEquals", "source.generate.constructor" },
      },
    })
  end, { buffer = buf, desc = "Generate Code" })

  vim.keymap.set("n", "<leader>Jcd", function()
    vim.notify("Generating JavaDoc... (Use IDE code actions)", vim.log.levels.INFO)
    vim.lsp.buf.code_action()
  end, { buffer = buf, desc = "Generate JavaDoc" })
end

-- Setup which-key labels for Java
local function setup_which_key()
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>J", group = "Java", buffer = true },

      { "<leader>Jr", group = "Refactor", buffer = true },
      { "<leader>Jrv", desc = "Extract Variable", buffer = true },
      { "<leader>Jrc", desc = "Extract Constant", buffer = true },
      { "<leader>Jrm", desc = "Extract Method", buffer = true },
      { "<leader>Jrr", desc = "Rename Symbol", buffer = true },
      { "<leader>JrF", desc = "Organize Imports", buffer = true },
      { "<leader>Jrf", desc = "Format + Organize Imports", buffer = true },

      { "<leader>Jt", group = "Tests", buffer = true },
      { "<leader>Jtm", desc = "Test Method", buffer = true },
      { "<leader>Jtc", desc = "Test Class", buffer = true },
      { "<leader>Jtl", desc = "Run Last Test", buffer = true },
      { "<leader>Jtd", desc = "Debug Test", buffer = true },
      { "<leader>Jta", desc = "Test All", buffer = true },

      { "<leader>Jc", group = "Code Generation", buffer = true },
      { "<leader>Jcg", desc = "Generate Code", buffer = true },
      { "<leader>Jcd", desc = "Generate JavaDoc", buffer = true },
    })
  end
end

-- Detect if current directory is a Java project
local function is_java_project()
  local cwd = vim.fn.getcwd()
  -- Check for common Java project files
  local java_indicators = {
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".project", -- Eclipse
    ".classpath", -- Eclipse
  }

  for _, file in ipairs(java_indicators) do
    if vim.fn.filereadable(cwd .. "/" .. file) == 1 then
      return true
    end
  end

  -- Check for src/main/java directory (Maven/Gradle standard)
  if vim.fn.isdirectory(cwd .. "/src/main/java") == 1 then
    return true
  end

  -- Check for any .java files in the project
  local java_files = vim.fn.glob(cwd .. "/**/*.java", false, true)
  if #java_files > 0 then
    return true
  end

  return false
end

-- Setup global Java keymaps (always available - basic operations)
local function setup_global_java_keymaps()
  -- Load java module once
  local java_module = require("plugins.java.java")

  -- Setup ONLY basic keymaps globally (build, run, docker, logs)
  -- All other keymaps (refactoring, testing, etc.) are LSP-specific and only available in .java files

  -- ========== BUILD AND RUN (Global) ==========
  vim.keymap.set("n", "<leader>JRr", function()
    java_module.spring_boot_run()
  end, { desc = "Run Spring Boot" })

  vim.keymap.set("n", "<leader>JRm", function()
    java_module.maven_build()
  end, { desc = "Maven Build" })

  vim.keymap.set("n", "<leader>JRg", function()
    java_module.gradle_build()
  end, { desc = "Gradle Build" })

  vim.keymap.set("n", "<leader>JRp", function()
    java_module.spring_boot_run_profile()
  end, { desc = "Run with Profile" })

  vim.keymap.set("n", "<leader>JRv", function()
    java_module.maven_verify()
  end, { desc = "Maven Verify" })

  vim.keymap.set("n", "<leader>JRP", function()
    java_module.maven_package()
  end, { desc = "Maven Package" })

  vim.keymap.set("n", "<leader>JRc", function()
    java_module.gradle_clean()
  end, { desc = "Gradle Clean Build" })

  vim.keymap.set("n", "<leader>JRs", "<Cmd>JavaRunnerStopMain<CR>", { desc = "Stop Application" })

  -- ========== LOGS (Global) ==========
  vim.keymap.set("n", "<leader>JLv", function()
    java_module.view_logs()
  end, { desc = "View Logs" })

  vim.keymap.set("n", "<leader>JLt", function()
    java_module.tail_logs()
  end, { desc = "Tail Logs" })

  -- ========== FILE GENERATION (Global) ==========
  vim.keymap.set("n", "<leader>Jn", function()
    java_module.file_generator()
  end, { desc = "New Java File" })

  vim.keymap.set("n", "<leader>JS", function()
    java_module.spring_boot_generator()
  end, { desc = "New Spring Boot File" })

  vim.keymap.set("n", "<leader>JG", function()
    java_module.generate_crud()
  end, { desc = "Generate CRUD" })

  -- ========== DATABASE (Global) ==========
  vim.keymap.set("n", "<leader>JBm", function()
    java_module.flyway_migrate()
  end, { desc = "Flyway Migrate" })

  vim.keymap.set("n", "<leader>JBn", function()
    java_module.create_migration()
  end, { desc = "New Migration" })

  -- ========== PROFILE CONFIGURATION ==========
  vim.keymap.set("n", "<leader>JCp", function()
    require("plugins.java.java").switch_profile()
  end, { desc = "Switch Profile" })

  vim.keymap.set("n", "<leader>JCe", function()
    require("plugins.java.java").edit_properties()
  end, { desc = "Edit Properties" })

  vim.keymap.set("n", "<leader>JCP", function()
    require("plugins.java.java").edit_profile_properties()
  end, { desc = "Edit Profile Properties" })

  vim.keymap.set("n", "<leader>JCg", function()
    require("plugins.java.java").generate_properties()
  end, { desc = "Generate Properties Template" })

  vim.keymap.set("n", "<leader>JCu", "<Cmd>JdtUpdateConfig<CR>", { desc = "Update JDTLS Config" })

  -- ========== DEPENDENCIES ==========
  vim.keymap.set("n", "<leader>JDa", function()
    require("plugins.java.java").add_dependency()
  end, { desc = "Add Dependency" })

  vim.keymap.set("n", "<leader>JDu", function()
    require("plugins.java.java").update_dependencies()
  end, { desc = "Update Dependencies" })

  vim.keymap.set("n", "<leader>JDv", function()
    require("plugins.java.java").check_vulnerabilities()
  end, { desc = "Check Vulnerabilities" })

  vim.keymap.set("n", "<leader>JDd", function()
    require("plugins.java.java").show_dependency_tree()
  end, { desc = "Show Dependency Tree" })

  -- Setup which-key for global Java keymaps
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>J", group = "Java" },
      { "<leader>JR", group = "Run/Build" },
      { "<leader>JRr", desc = "Run Spring Boot" },
      { "<leader>JRm", desc = "Maven Build" },
      { "<leader>JRg", desc = "Gradle Build" },
      { "<leader>JRp", desc = "Run with Profile" },
      { "<leader>JRv", desc = "Maven Verify" },
      { "<leader>JRP", desc = "Maven Package" },
      { "<leader>JRc", desc = "Gradle Clean Build" },
      { "<leader>JRs", desc = "Stop Application" },
      { "<leader>JL", group = "Logs" },
      { "<leader>JLv", desc = "View Logs" },
      { "<leader>JLt", desc = "Tail Logs" },
      { "<leader>Jn", desc = "New Java File" },
      { "<leader>JS", desc = "New Spring Boot File" },
      { "<leader>JG", desc = "Generate CRUD" },
      { "<leader>JB", group = "Database" },
      { "<leader>JBm", desc = "Flyway Migrate" },
      { "<leader>JBn", desc = "New Migration" },
      { "<leader>JC", group = "Profile Config" },
      { "<leader>JCp", desc = "Switch Profile" },
      { "<leader>JCe", desc = "Edit Properties" },
      { "<leader>JCP", desc = "Edit Profile Properties" },
      { "<leader>JCg", desc = "Generate Properties" },
      { "<leader>JCu", desc = "Update Config" },
      { "<leader>JD", group = "Dependencies" },
      { "<leader>JDa", desc = "Add Dependency" },
      { "<leader>JDu", desc = "Update Dependencies" },
      { "<leader>JDv", desc = "Check Vulnerabilities" },
      { "<leader>JDd", desc = "Show Dependency Tree" },
    })
  end

  print("Java keymaps loaded globally (basic operations only)")
end

-- Setup keymaps for all Java files (basic functionality)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(_)
    setup_basic_java_keymaps()
    setup_which_key()
  end,
})

-- Setup LSP-specific keymaps when JDTLS attaches
vim.api.nvim_create_autocmd("LspAttach", {
  pattern = "*.java",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "jdtls" then
      setup_lsp_java_keymaps(args.buf)
    end
  end,
})

-- Setup global Java keymaps when this module is loaded
setup_global_java_keymaps()

-- Export functions for manual setup if needed (may be unused)
return {
  setup_basic_java_keymaps = setup_basic_java_keymaps,
  setup_lsp_java_keymaps = setup_lsp_java_keymaps,
  setup_which_key = setup_which_key,
  setup_global_java_keymaps = setup_global_java_keymaps,
  is_java_project = is_java_project,
}
