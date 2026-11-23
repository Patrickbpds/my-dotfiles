-- OpenCode is the primary coding agent. Supermaven remains the inline
-- completion engine; the two responsibilities do not overlap.
return {
  {
    "sudo-tee/opencode.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
        ft = { "markdown", "opencode_output" },
      },
    },
    opts = {
      -- fzf-lua is already the workstation picker.
      preferred_picker = "fzf-lua",
      default_mode = "build",
    },
  },
}
