local M = {}

-- ============================================================================
-- 📋 LOGGING FUNCTIONS
-- ============================================================================

local function view_logs()
  local log_files = {
    vim.fn.getcwd() .. "/logs/application.log",
    vim.fn.getcwd() .. "/target/spring-boot.log",
    vim.fn.getcwd() .. "/build/spring-boot.log",
  }

  for _, log_file in ipairs(log_files) do
    if vim.fn.filereadable(log_file) == 1 then
      vim.cmd("botright split | edit " .. log_file)
      vim.cmd("normal! G")
      return
    end
  end

  vim.notify("No log files found", vim.log.levels.WARN)
end

local function tail_logs()
  local log_files = {
    vim.fn.getcwd() .. "/logs/application.log",
    vim.fn.getcwd() .. "/target/spring-boot.log",
  }

  for _, log_file in ipairs(log_files) do
    if vim.fn.filereadable(log_file) == 1 then
      vim.cmd("botright split | terminal tail -f " .. log_file)
      vim.cmd("startinsert")
      return
    end
  end

  vim.notify("No log files found", vim.log.levels.WARN)
end

M.view_logs = view_logs
M.tail_logs = tail_logs

return M

