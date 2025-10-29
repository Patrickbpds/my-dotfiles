local M = {}

local utils = require("plugins.java.java-utils")
local build_run = require("plugins.java.build-run")
local dependency = require("plugins.java.dependency-management")
local profiles = require("plugins.java.profiles-management")
local migrations = require("plugins.java.migrations")

-- Build/Run
M.spring_boot_run = function()
  build_run.spring_boot_run(utils)
end
M.spring_boot_run_profile = build_run.spring_boot_run_profile
M.maven_build = build_run.maven_build
M.gradle_build = build_run.gradle_build

-- Dependencies
M.add_dependency = function()
  dependency.add_dependency(utils)
end
M.show_dependency_tree = function()
  dependency.show_dependency_tree(utils)
end
M.check_vulnerabilities = function()
  dependency.check_vulnerabilities(utils)
end
M.update_dependencies = function()
  dependency.update_dependencies(utils)
end

-- Profiles
M.switch_profile = profiles.switch_profile
M.edit_properties = profiles.edit_properties
M.edit_profile_properties = profiles.edit_profile_properties
M.generate_properties = profiles.generate_properties

-- Migrations
M.flyway_migrate = function()
  migrations.flyway_migrate(utils)
end
M.create_migration = migrations.create_migration

-- Generators
M.file_generator = function()
  require("plugins.java.templates.java-files").file_generator(utils)
end

M.spring_boot_generator = function()
  require("plugins.java.templates.springboot-files").spring_boot_generator(utils)
end

M.generate_crud = function()
  require("plugins.java.templates.crud-files").generate_crud()
end

return M
