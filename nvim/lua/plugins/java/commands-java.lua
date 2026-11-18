local M = {}

local function java()
  return require("plugins.java.java")
end

local commands = {
  { "JavaRun", function()
    java().spring_boot_run()
  end, "Run Spring Boot" },
  { "JavaRunProfile", function()
    java().spring_boot_run_profile()
  end, "Run Spring Boot with a profile" },
  { "JavaStop", function()
    java().stop_app()
  end, "Stop the running app or build" },
  { "JavaMavenBuild", function()
    java().maven_build()
  end, "Maven clean install" },
  { "JavaMavenTest", function()
    java().maven_test()
  end, "Maven test" },
  { "JavaMavenVerify", function()
    java().maven_verify()
  end, "Maven clean verify" },
  { "JavaMavenPackage", function()
    java().maven_package()
  end, "Maven clean package" },
  { "JavaGradleBuild", function()
    java().gradle_build()
  end, "Gradle build" },
  { "JavaGradleTest", function()
    java().gradle_test()
  end, "Gradle test" },
  { "JavaGradleClean", function()
    java().gradle_clean()
  end, "Gradle clean build" },

  { "JavaNewFile", function()
    java().file_generator()
  end, "Generate a Java file" },
  { "JavaNewSpringFile", function()
    java().spring_boot_generator()
  end, "Generate a Spring Boot file" },
  { "JavaNewCrud", function()
    java().generate_crud()
  end, "Generate a CRUD stack" },

  { "JavaFlywayMigrate", function()
    java().flyway_migrate()
  end, "Run Flyway migrations" },
  { "JavaNewMigration", function()
    java().create_migration()
  end, "Create a Flyway migration" },

  { "JavaSwitchProfile", function()
    java().switch_profile()
  end, "Switch the active Spring profile" },
  { "JavaNewProfile", function()
    java().create_new_profile()
  end, "Create a Spring profile" },
  { "JavaEditProperties", function()
    java().edit_properties()
  end, "Edit application configuration" },
  { "JavaEditProfile", function()
    java().edit_profile_properties()
  end, "Edit a profile configuration" },
  { "JavaProfileInfo", function()
    java().show_profile_info()
  end, "Show profile information" },

  { "JavaAddDependency", function()
    java().add_dependency()
  end, "Add a dependency to the build file" },
  { "JavaDependencyTree", function()
    java().show_dependency_tree()
  end, "Show the dependency tree" },
  { "JavaUpdateDependencies", function()
    java().update_dependencies()
  end, "Check for dependency updates" },
  { "JavaCheckVulnerabilities", function()
    java().check_vulnerabilities()
  end, "Check dependencies for vulnerabilities" },
}

function M.setup()
  if vim.g.java_commands_registered then
    return
  end
  vim.g.java_commands_registered = true

  for _, command in ipairs(commands) do
    vim.api.nvim_create_user_command(command[1], command[2], { desc = command[3] })
  end
end

function M.list()
  local names = vim.tbl_map(function(command)
    return command[1]
  end, commands)
  table.sort(names)
  vim.notify("Java commands:\n" .. table.concat(names, "\n"), vim.log.levels.INFO)
end

return M
