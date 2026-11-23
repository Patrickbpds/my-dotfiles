return {
  {
    "tpope/vim-fugitive",
    -- Lazygit (Snacks) is the primary Git UI; Fugitive provides :Git commands
    -- and diff/read/write helpers without loading at startup.
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "Glgrep",
      "Gclog",
    },
  },
}
