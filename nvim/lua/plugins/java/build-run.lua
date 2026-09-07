local M = {}

-- ============================================================================
-- 🏗️ BUILD AND RUN FUNCTIONS
-- ============================================================================

local function utils()
  return require("plugins.java.java-utils")
end

-- Registry of terminal buffers opened by this module (most recent last)
M._terminals = {}

-- Run a command in a bottom split terminal and keep track of it
local function run_in_terminal(cmd)
  local root = utils().get_project_root()
  local old_cwd = vim.fn.getcwd()
  vim.fn.chdir(root)
  vim.cmd("botright split | terminal " .. cmd)
  vim.fn.chdir(old_cwd)
  local buf = vim.api.nvim_get_current_buf()
  table.insert(M._terminals, buf)
  vim.cmd("startinsert")
end

-- Send SIGINT to the most recently launched app/build, then close its buffer
function M.stop_app()
  local function signal_buffer(buf)
    local ok, job_id = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
    if ok and job_id and job_id > 0 then
      vim.fn.chansend(job_id, "\x03")
    end
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end

  -- Prefer the tracked terminals
  while #M._terminals > 0 do
    local buf = table.remove(M._terminals)
    if vim.api.nvim_buf_is_valid(buf) then
      signal_buffer(buf)
      vim.notify("⏹ Stopped application", vim.log.levels.INFO)
      return
    end
  end

  -- Fallback: signal the current buffer if it is a terminal
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype == "terminal" then
    signal_buffer(buf)
    vim.notify("⏹ Stopped application", vim.log.levels.INFO)
  else
    vim.notify("No running app/build to stop", vim.log.levels.WARN)
  end
end

-- Maven/Gradle executable (wrapper-aware)
local function mvn()
  return utils().get_build_command("maven")
end

local function gradle()
  return utils().get_build_command("gradle")
end

-- ============================================================================
-- Maven Build Commands
-- ============================================================================
local function maven_build()
  run_in_terminal(mvn() .. " clean install -DskipTests")
end

local function maven_test()
  run_in_terminal(mvn() .. " test")
end

local function maven_verify()
  run_in_terminal(mvn() .. " clean verify")
end

local function maven_package()
  run_in_terminal(mvn() .. " clean package")
end

-- ============================================================================
-- Gradle Build Commands
-- ============================================================================
local function gradle_build()
  run_in_terminal(gradle() .. " build")
end

local function gradle_test()
  run_in_terminal(gradle() .. " test")
end

local function gradle_clean()
  run_in_terminal(gradle() .. " clean build")
end

-- ============================================================================
-- Spring Boot Run Commands
-- ============================================================================
local function spring_boot_run()
  local build_tool = utils().get_build_tool()
  if build_tool == "maven" then
    run_in_terminal(mvn() .. " spring-boot:run")
  elseif build_tool == "gradle" then
    run_in_terminal(gradle() .. " bootRun")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
  end
end

local function spring_boot_run_with_profile()
  vim.ui.select({ "dev", "test", "prod", "local" }, { prompt = "Select profile:" }, function(profile)
    if not profile then
      return
    end

    local build_tool = utils().get_build_tool()
    local args
    if build_tool == "maven" then
      args = mvn() .. string.format(" spring-boot:run -Dspring-boot.run.profiles=%s", profile)
    elseif build_tool == "gradle" then
      args = gradle() .. string.format(" bootRun --args='--spring.profiles.active=%s'", profile)
    else
      vim.notify("No build tool detected", vim.log.levels.ERROR)
      return
    end
    run_in_terminal(args)
  end)
end

-- ============================================================================
-- Exports
-- ============================================================================
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
