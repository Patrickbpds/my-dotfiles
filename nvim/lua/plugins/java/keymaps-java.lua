local function setup_custom_java_keymaps()
  local java = require("plugins.java.java")

  -- ========== BUILD E RUN ==========
  vim.keymap.set("n", "<leader>JRr", java.spring_boot_run, { desc = "Run Spring Boot" })
  vim.keymap.set("n", "<leader>JRp", java.spring_boot_run_profile, { desc = "Run with Profile" })
  vim.keymap.set("n", "<leader>JRm", java.maven_build, { desc = "Maven Build" })
  vim.keymap.set("n", "<leader>JRg", java.gradle_build, { desc = "Gradle Build" })

  -- ========== LOGS ==========
  vim.keymap.set("n", "<leader>JLv", java.view_logs, { desc = "View Logs" })
  vim.keymap.set("n", "<leader>JLt", java.tail_logs, { desc = "Tail Logs" })

  -- ========== GERADORES ==========
  vim.keymap.set("n", "<leader>Jn", java.file_generator, { desc = "New Java File" })
  vim.keymap.set("n", "<leader>JS", java.spring_boot_generator, { desc = "New Spring File" })
  vim.keymap.set("n", "<leader>JG", java.generate_crud, { desc = "Generate CRUD" })

  -- ========== DATABASE ==========
  vim.keymap.set("n", "<leader>JBm", java.flyway_migrate, { desc = "Flyway Migrate" })
  vim.keymap.set("n", "<leader>JBn", java.create_migration, { desc = "New Migration" })

  -- ========== PROFILES ==========
  vim.keymap.set("n", "<leader>JCp", java.switch_profile, { desc = "Switch Profile" })
  vim.keymap.set("n", "<leader>JCe", java.edit_properties, { desc = "Edit Properties" })
  vim.keymap.set("n", "<leader>JCP", java.edit_profile_properties, { desc = "Edit Profile Properties" })
  vim.keymap.set("n", "<leader>JCg", java.generate_properties, { desc = "Generate Properties Template" })

  -- ========== DEPENDENCIES ==========
  vim.keymap.set("n", "<leader>JDa", java.add_dependency, { desc = "Add Dependency" })
  vim.keymap.set("n", "<leader>JDd", java.show_dependency_tree, { desc = "Dependency Tree" })
  vim.keymap.set("n", "<leader>JDu", java.update_dependencies, { desc = "Update Dependencies" })
  vim.keymap.set("n", "<leader>JDv", java.check_vulnerabilities, { desc = "Check Vulnerabilities" })

  -- Setup which-key
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>J", group = "Java" },
      { "<leader>JR", group = "Run/Build" },
      { "<leader>JL", group = "Logs" },
      { "<leader>JB", group = "Database" },
      { "<leader>JC", group = "Config" },
      { "<leader>JD", group = "Dependencies" },
    })
  end
end

-- Load keymaps when opening Java file
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = setup_custom_java_keymaps,
})

return { setup = setup_custom_java_keymaps }
