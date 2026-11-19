local M = {}

local actions = require("java.actions")

local function java()
  return require("java")
end

function M.setup()
  if vim.g.java_commands_registered then
    return
  end
  vim.g.java_commands_registered = true

  for _, action in ipairs(actions) do
    vim.api.nvim_create_user_command(action[1], function()
      java()[action[3]]()
    end, { desc = action[4] })
  end

  vim.api.nvim_create_user_command("JavaCommands", M.list, { desc = "List Java commands" })
end

function M.list()
  local names = {}
  for _, action in ipairs(actions) do
    table.insert(names, action[1])
  end
  table.insert(names, "JavaCommands")
  table.sort(names)
  vim.notify("Java commands:\n" .. table.concat(names, "\n"), vim.log.levels.INFO)
end

return M
