local registered = false

local function setup_custom_java_keymaps()
  if registered then
    return
  end
  registered = true

  local java = require("plugins.java.java")

  -- ========== BUILD E RUN ==========
  vim.keymap.set("n", "<leader>jrs", java.spring_boot_run, { desc = "Run Spring Boot" })
  vim.keymap.set("n", "<leader>jrp", java.spring_boot_run_profile, { desc = "Run with Profile" })
  vim.keymap.set("n", "<leader>jrk", java.stop_app, { desc = "Stop App" })
  vim.keymap.set("n", "<leader>jrm", java.maven_build, { desc = "Maven Build" })
  vim.keymap.set("n", "<leader>jrg", java.gradle_build, { desc = "Gradle Build" })

  -- ========== MAVEN ==========
  vim.keymap.set("n", "<leader>jmt", java.maven_test, { desc = "Maven Test" })
  vim.keymap.set("n", "<leader>jmv", java.maven_verify, { desc = "Maven Verify" })
  vim.keymap.set("n", "<leader>jmp", java.maven_package, { desc = "Maven Package" })

  -- ========== GRADLE ==========
  vim.keymap.set("n", "<leader>jwt", java.gradle_test, { desc = "Gradle Test" })
  vim.keymap.set("n", "<leader>jwc", java.gradle_clean, { desc = "Gradle Clean Build" })

  -- ========== GERADORES ==========
  vim.keymap.set("n", "<leader>jn", java.file_generator, { desc = "New Java File" })
  vim.keymap.set("n", "<leader>js", java.spring_boot_generator, { desc = "New Spring File" })
  vim.keymap.set("n", "<leader>jg", java.generate_crud, { desc = "Generate CRUD" })

  -- ========== DATABASE ==========
  vim.keymap.set("n", "<leader>jbr", java.flyway_migrate, { desc = "Run Flyway Migrate" })
  vim.keymap.set("n", "<leader>jbn", java.create_migration, { desc = "New Migration" })

  -- ========== PROFILES ==========
  vim.keymap.set("n", "<leader>jps", java.switch_profile, { desc = "Switch Profile" })
  vim.keymap.set("n", "<leader>jpn", java.create_new_profile, { desc = "New Profile" })
  vim.keymap.set("n", "<leader>jpe", java.edit_properties, { desc = "Edit Properties Config" })
  vim.keymap.set("n", "<leader>jpp", java.edit_profile_properties, { desc = "Edit Profile Config" })
  vim.keymap.set("n", "<leader>jpi", java.show_profile_info, { desc = "Profile Info" })

  -- ========== DEPENDÊNCIAS ==========
  vim.keymap.set("n", "<leader>jda", java.add_dependency, { desc = "Add Dependency" })
  vim.keymap.set("n", "<leader>jdt", java.show_dependency_tree, { desc = "Dependency Tree" })
  vim.keymap.set("n", "<leader>jdu", java.update_dependencies, { desc = "Update Dependencies" })
  vim.keymap.set("n", "<leader>jdv", java.check_vulnerabilities, { desc = "Check Vulnerabilities" })
end

-- Load keymaps when opening a Java file
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = setup_custom_java_keymaps,
})

return { setup = setup_custom_java_keymaps }
