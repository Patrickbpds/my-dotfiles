return {
  -- Session management per Git repository (inspired by brianrbrenner/nvim)
  {
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup({
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
        auto_session_use_git_branch = true, -- Use git branch to differentiate sessions
        auto_session_enable_last_session = false,
        auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
        auto_session_create_enabled = true,
        auto_session_restore_enabled = true,
        auto_session_save_enabled = true,
      })

      -- Auto-save session on exit
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if vim.g.savesession then
            if vim.g.sessionfile ~= "" then
              vim.api.nvim_command(string.format("mks! %s", vim.g.sessionfile))
            end
          end
        end,
      })

      -- Key mappings for session management
      vim.keymap.set("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "Save Session" })
      vim.keymap.set("n", "<leader>sl", "<cmd>SessionLoad<CR>", { desc = "Load Session" })
      vim.keymap.set("n", "<leader>sd", "<cmd>SessionDelete<CR>", { desc = "Delete Session" })
    end,
  },
}