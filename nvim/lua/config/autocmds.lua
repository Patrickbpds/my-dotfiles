require("java.commands").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  once = true,
  callback = function()
    require("java.keymaps").setup()
  end,
})
