local M = {}

local build_run = require("java.build-run")
local dependency = require("java.dependency-management")
local profiles = require("java.profiles-management")
local migrations = require("java.migrations")

M.spring_boot_run = build_run.spring_boot_run
M.spring_boot_run_profile = build_run.spring_boot_run_profile
M.maven_build = build_run.maven_build
M.maven_test = build_run.maven_test
M.maven_verify = build_run.maven_verify
M.maven_package = build_run.maven_package
M.gradle_build = build_run.gradle_build
M.gradle_test = build_run.gradle_test
M.gradle_clean = build_run.gradle_clean
M.stop_app = build_run.stop_app

M.add_dependency = dependency.add_dependency
M.show_dependency_tree = dependency.show_dependency_tree
M.check_vulnerabilities = dependency.check_vulnerabilities
M.update_dependencies = dependency.update_dependencies

M.switch_profile = profiles.switch_profile
M.edit_properties = profiles.edit_properties
M.edit_profile_properties = profiles.edit_profile_properties
M.create_new_profile = profiles.create_new_profile
M.show_profile_info = profiles.show_profile_info
M.get_active_profile = profiles.get_active_profile

M.flyway_migrate = migrations.flyway_migrate
M.create_migration = migrations.create_migration

M.file_generator = function()
  require("java.templates.java-files").file_generator()
end

M.spring_boot_generator = function()
  require("java.templates.springboot-files").spring_boot_generator()
end

M.generate_crud = function()
  require("java.templates.crud-files").generate_crud()
end

return M
