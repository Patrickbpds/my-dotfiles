-- ============================================================================
-- ⌨️ KEY MAPPINGS FOR JAVA
-- ============================================================================
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

-- Setup global Java keymaps when this module is loaded
setup_global_java_keymaps()

-- Export functions for manual setup if needed (may be unused)
return {
  setup_global_java_keymaps = setup_global_java_keymaps,
  is_java_project = is_java_project,
}
