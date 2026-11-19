local M = {}

local actions = require("java.actions")

local function java()
  return require("java")
end

function M.setup()
  if vim.g.java_keymaps_registered then
    return
  end
  vim.g.java_keymaps_registered = true

  for _, action in ipairs(actions) do
    vim.keymap.set("n", action[2], function()
      java()[action[3]]()
    end, { desc = action[4] })
  end

  vim.keymap.set("n", "<leader>j?", "<cmd>JavaCommands<cr>", { desc = "List Java Commands" })
end

return M
