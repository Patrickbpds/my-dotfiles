-- REST/GraphQL requests from .http files. rest.nvim is used instead of the
-- LazyVim util.rest extra because Kulala now requires a commercial license
-- token for its core binary.
vim.filetype.add({
  extension = {
    http = "http",
  },
})

return {
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "http", "graphql" })
        end,
      },
    },
    keys = {
      { "<leader>R", "", desc = "+Rest" },
      { "<leader>Rs", "<cmd>Rest run<cr>", desc = "Send request", ft = "http" },
      { "<leader>Rr", "<cmd>Rest last<cr>", desc = "Replay last request", ft = "http" },
      { "<leader>Ro", "<cmd>Rest open<cr>", desc = "Open result pane", ft = "http" },
      { "<leader>Re", "<cmd>Rest env select<cr>", desc = "Select environment", ft = "http" },
      { "<leader>Rc", "<cmd>Rest cookies<cr>", desc = "Edit cookies", ft = "http" },
      { "<leader>Rl", "<cmd>Rest logs<cr>", desc = "Open logs", ft = "http" },
    },
  },
}
