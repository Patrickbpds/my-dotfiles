local M = {}

local function utils()
  return require("java.utils")
end

function M.stop_app()
  local buf = M._terminals and table.remove(M._terminals)
  if buf and vim.api.nvim_buf_is_valid(buf) then
    local ok, job_id = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
    if ok and job_id and job_id > 0 then
      vim.fn.chansend(job_id, "\x03")
    end
    vim.notify("Stopped application", vim.log.levels.INFO)
    return
  end

  local current = vim.api.nvim_get_current_buf()
  if vim.bo[current].buftype == "terminal" then
    local ok, job_id = pcall(vim.api.nvim_buf_get_var, current, "terminal_job_id")
    if ok and job_id and job_id > 0 then
      vim.fn.chansend(job_id, "\x03")
    end
    vim.notify("Stopped application", vim.log.levels.INFO)
  else
    vim.notify("No running app/build to stop", vim.log.levels.WARN)
  end
end

M._terminals = {}

local function tracked_terminal(cmd)
  local buf = utils().run_in_terminal(cmd)
  table.insert(M._terminals, buf)
  return buf
end

local function mvn()
  return utils().get_build_command("maven")
end

local function gradle()
  return utils().get_build_command("gradle")
end

local function maven_build()
  tracked_terminal(mvn() .. " clean install -DskipTests")
end

local function maven_test()
  tracked_terminal(mvn() .. " test")
end

local function maven_verify()
  tracked_terminal(mvn() .. " clean verify")
end

local function maven_package()
  tracked_terminal(mvn() .. " clean package")
end

local function gradle_build()
  tracked_terminal(gradle() .. " build")
end

local function gradle_test()
  tracked_terminal(gradle() .. " test")
end

local function gradle_clean()
  tracked_terminal(gradle() .. " clean build")
end

local function spring_boot_run()
  local build_tool = utils().get_build_tool()
  if build_tool == "maven" then
    tracked_terminal(mvn() .. " spring-boot:run")
  elseif build_tool == "gradle" then
    tracked_terminal(gradle() .. " bootRun")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
  end
end

local function spring_boot_run_profile(profile)
  local run = function(selected)
    local build_tool = utils().get_build_tool()
    if build_tool == "maven" then
      tracked_terminal(mvn() .. string.format(" spring-boot:run -Dspring-boot.run.profiles=%s", selected))
    elseif build_tool == "gradle" then
      tracked_terminal(gradle() .. string.format(" bootRun --args='--spring.profiles.active=%s'", selected))
    else
      vim.notify("No build tool detected", vim.log.levels.ERROR)
    end
  end

  if profile and profile ~= "" then
    run(profile)
    return
  end

  vim.ui.select({ "dev", "test", "prod", "local" }, { prompt = "Select profile:" }, function(selected)
    if selected then
      run(selected)
    end
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
M.spring_boot_run_profile = spring_boot_run_profile

return M
