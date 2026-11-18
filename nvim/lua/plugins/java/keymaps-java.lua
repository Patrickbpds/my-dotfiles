local M = {}

local function java()
  return require("plugins.java.java")
end

local keymaps = {
  { "<leader>jrs", function()
    java().spring_boot_run()
  end, "Run Spring Boot" },
  { "<leader>jrp", function()
    java().spring_boot_run_profile()
  end, "Run with Profile" },
  { "<leader>jrk", function()
    java().stop_app()
  end, "Stop App" },
  { "<leader>jrm", function()
    java().maven_build()
  end, "Maven Build" },
  { "<leader>jrg", function()
    java().gradle_build()
  end, "Gradle Build" },

  { "<leader>jmt", function()
    java().maven_test()
  end, "Maven Test" },
  { "<leader>jmv", function()
    java().maven_verify()
  end, "Maven Verify" },
  { "<leader>jmp", function()
    java().maven_package()
  end, "Maven Package" },

  { "<leader>jwt", function()
    java().gradle_test()
  end, "Gradle Test" },
  { "<leader>jwc", function()
    java().gradle_clean()
  end, "Gradle Clean Build" },

  { "<leader>jn", function()
    java().file_generator()
  end, "New Java File" },
  { "<leader>js", function()
    java().spring_boot_generator()
  end, "New Spring File" },
  { "<leader>jg", function()
    java().generate_crud()
  end, "Generate CRUD" },

  { "<leader>jbr", function()
    java().flyway_migrate()
  end, "Run Flyway Migrate" },
  { "<leader>jbn", function()
    java().create_migration()
  end, "New Migration" },

  { "<leader>jps", function()
    java().switch_profile()
  end, "Switch Profile" },
  { "<leader>jpn", function()
    java().create_new_profile()
  end, "New Profile" },
  { "<leader>jpe", function()
    java().edit_properties()
  end, "Edit Properties Config" },
  { "<leader>jpp", function()
    java().edit_profile_properties()
  end, "Edit Profile Config" },
  { "<leader>jpi", function()
    java().show_profile_info()
  end, "Profile Info" },

  { "<leader>jda", function()
    java().add_dependency()
  end, "Add Dependency" },
  { "<leader>jdt", function()
    java().show_dependency_tree()
  end, "Dependency Tree" },
  { "<leader>jdu", function()
    java().update_dependencies()
  end, "Update Dependencies" },
  { "<leader>jdv", function()
    java().check_vulnerabilities()
  end, "Check Vulnerabilities" },
}

function M.setup()
  if vim.g.java_keymaps_registered then
    return
  end
  vim.g.java_keymaps_registered = true

  for _, map in ipairs(keymaps) do
    vim.keymap.set("n", map[1], map[2], { desc = map[3] })
  end
end

return M
