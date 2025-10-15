-- ============================================================================
-- JAVA PLUGIN MAIN MODULE
-- ============================================================================
-- Main entry point for Java plugin functionality
-- Re-exports functions from all submodules for backward compatibility
-- Note: JDTLS setup is handled in after/ftplugin/java.lua

local M = {}

-- Import submodules
local utils = require("plugins.java.java-utils")
local build_run = require("plugins.java.build-run")
local logs = require("plugins.java.logs")
local dependency_mgmt = require("plugins.java.dependency-management")
local profiles_mgmt = require("plugins.java.profiles-management")
local migrations = require("plugins.java.migrations")

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
M.get_build_tool = utils.get_build_tool
M.detect_java_version = utils.detect_java_version

-- ============================================================================
-- BUILD AND RUN FUNCTIONS
-- ============================================================================
M.spring_boot_run = build_run.spring_boot_run
M.spring_boot_run_profile = build_run.spring_boot_run_profile
M.maven_build = build_run.maven_build
M.maven_verify = build_run.maven_verify
M.maven_package = build_run.maven_package
M.gradle_build = build_run.gradle_build
M.gradle_clean = build_run.gradle_clean
M.stop_application = build_run.stop_application

-- Test functions
M.test = {
  run_current_method = build_run.test_current_method,
  run_current_class = build_run.test_current_class,
  run_last = build_run.run_last_test,
  debug_current_method = build_run.debug_current_test,
  run_all = function()
    local build_tool = utils.get_build_tool()
    if build_tool == "maven" then
      build_run.maven_test()
    elseif build_tool == "gradle" then
      build_run.gradle_test()
    end
  end,
}

-- ============================================================================
-- LOGS FUNCTIONS
-- ============================================================================
M.view_logs = logs.view_logs
M.tail_logs = logs.tail_logs

-- ============================================================================
-- DEPENDENCY MANAGEMENT FUNCTIONS
-- ============================================================================
M.add_dependency = function()
  dependency_mgmt.add_dependency(utils)
end
M.show_dependency_tree = function()
  dependency_mgmt.show_dependency_tree(utils)
end
M.check_vulnerabilities = function()
  dependency_mgmt.check_vulnerabilities(utils)
end
M.update_dependencies = function()
  dependency_mgmt.update_dependencies(utils)
end

-- ============================================================================
-- PROFILES MANAGEMENT FUNCTIONS
-- ============================================================================
M.switch_profile = profiles_mgmt.switch_profile
M.edit_properties = profiles_mgmt.edit_properties
M.edit_profile_properties = profiles_mgmt.edit_profile_properties
M.generate_properties = profiles_mgmt.generate_properties

-- ============================================================================
-- DATABASE/MIGRATIONS FUNCTIONS
-- ============================================================================
M.flyway_migrate = migrations.flyway_migrate
M.create_migration = migrations.create_migration

-- ============================================================================
-- REFACTORING FUNCTIONS (LSP-based)
-- ============================================================================
M.refactor = {
  extract_variable = function()
    vim.lsp.buf.code_action({
      context = { diagnostics = {}, only = { "refactor.extract.variable" } },
      apply = true,
    })
  end,
  extract_constant = function()
    vim.lsp.buf.code_action({
      context = { diagnostics = {}, only = { "refactor.extract.constant" } },
      apply = true,
    })
  end,
  extract_method = function()
    vim.lsp.buf.code_action({
      context = { diagnostics = {}, only = { "refactor.extract.method" } },
      apply = false,
    })
  end,
}

-- ============================================================================
-- FILE GENERATION FUNCTIONS
-- ============================================================================
M.file_generator = function()
  local java_files = require("plugins.java.templates.java-files")
  java_files.file_generator(require("plugins.java.java-utils"))
end

M.spring_boot_generator = function()
  local springboot_files = require("plugins.java.templates.springboot-files")
  springboot_files.spring_boot_generator(require("plugins.java.java-utils"))
end

M.generate_crud = function()
  local crud_files = require("plugins.java.templates.crud-files")
  crud_files.generate_crud()
end

return M
