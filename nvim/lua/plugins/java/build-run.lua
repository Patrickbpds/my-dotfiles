local M = {}

-- ============================================================================
-- 🏗️ BUILD AND RUN FUNCTIONS
-- ============================================================================

-- ============================================================================
-- Maven Build Commands
-- ============================================================================
local function maven_build()
  vim.cmd("botright split | terminal mvn clean install -DskipTests")
  vim.cmd("startinsert")
end

local function maven_test()
  vim.cmd("botright split | terminal mvn test")
  vim.cmd("startinsert")
end

local function maven_verify()
  vim.cmd("botright split | terminal mvn clean verify")
  vim.cmd("startinsert")
end

local function maven_package()
  vim.cmd("botright split | terminal mvn clean package")
  vim.cmd("startinsert")
end

-- ============================================================================
-- Gradle Build Commands
-- ============================================================================
local function gradle_build()
  vim.cmd("botright split | terminal ./gradlew build")
  vim.cmd("startinsert")
end

local function gradle_test()
  vim.cmd("botright split | terminal ./gradlew test")
  vim.cmd("startinsert")
end

local function gradle_clean()
  vim.cmd("botright split | terminal ./gradlew clean build")
  vim.cmd("startinsert")
end

-- ============================================================================
-- Spring Boot Run Commands
-- ============================================================================
local function spring_boot_run(utils)
  local build_tool = utils.get_build_tool()
  if build_tool == "maven" then
    vim.cmd("botright split | terminal mvn spring-boot:run")
  elseif build_tool == "gradle" then
    vim.cmd("botright split | terminal ./gradlew bootRun")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

local function spring_boot_run_with_profile()
  vim.ui.select({ "dev", "test", "prod", "local" }, { prompt = "Select profile:" }, function(profile)
    if not profile then
      return
    end

    local utils = require("plugins.java.java-utils")
    local build_tool = utils.get_build_tool()
    if build_tool == "maven" then
      vim.cmd(string.format("botright split | terminal mvn spring-boot:run -Dspring-boot.run.profiles=%s", profile))
    elseif build_tool == "gradle" then
      vim.cmd(
        string.format("botright split | terminal ./gradlew bootRun --args='--spring.profiles.active=%s'", profile)
      )
    end
    vim.cmd("startinsert")
  end)
end

M.maven_build = maven_build
M.maven_test = maven_test
M.maven_verify = maven_verify
M.maven_package = maven_package
M.gradle_build = gradle_build
M.gradle_test = gradle_test
M.gradle_clean = gradle_clean

M.spring_boot_run = spring_boot_run
M.spring_boot_run_profile = spring_boot_run_with_profile

return M
