require("plugins.java.commands-java").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  once = true,
  callback = function()
    require("plugins.java.keymaps-java").setup()
  end,
})
