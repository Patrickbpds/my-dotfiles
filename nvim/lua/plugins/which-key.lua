return {
  {
    "folke/which-key.nvim",
    opts = {
      preset = "classic",
      spec = {
        { "<leader>a", group = "ai", icon = { icon = "", color = "yellow" } },
        { "<leader>o", group = "opencode", icon = { icon = "󰚩", color = "green" } },
        { "<leader>R", group = "rest", icon = { icon = "", color = "blue" } },
        { "<leader>z", group = "scripts", icon = { icon = "", color = "cyan" } },
        { "<leader>m", group = "grapple" },
        { "<leader>j", group = "java", icon = { icon = "☕", color = "orange" } },
        { "<leader>jr", group = "Run/Build" },
        { "<leader>jm", group = "Maven" },
        { "<leader>jw", group = "Gradle" },
        { "<leader>jb", group = "Database" },
        { "<leader>jp", group = "Profile" },
        { "<leader>jd", group = "Dependencies" },
      },
    },
  },
}
