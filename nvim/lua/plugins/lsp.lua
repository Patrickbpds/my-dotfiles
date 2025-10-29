return {
  -- Configure Mason to ensure specific servers are installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Your preferred servers
        "lua-language-server",
        "typescript-language-server",
        "jdtls",
        "java-debug-adapter",
        "java-test",
      },
    },
  },

  -- Configure nvim-lspconfig with custom servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Lua Language Server configuration
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                disable = { "assign-type-mismatch" },
              },
            },
          },
        },
        -- TypeScript/JavaScript configuration
        vtsls = {},
      },
    },
  },
}
