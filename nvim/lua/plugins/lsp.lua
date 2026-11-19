return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "typescript-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
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
        vtsls = {},
      },
    },
  },
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts = opts or {}
      local java_utils = require("java.utils")
      local format_profile = vim.api.nvim_get_runtime_file("lua/lang_servers/eclipse-java-google-style.xml", false)[1]

      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          format = {
            enabled = true,
            settings = {
              url = format_profile and vim.uri_from_fname(format_profile) or nil,
              profile = "GoogleStyle",
            },
          },
          saveActions = {
            organizeImports = true,
          },
          import = {
            gradle = {
              enabled = true,
              wrapper = {
                enabled = true,
              },
            },
            maven = {
              enabled = true,
            },
          },
          configuration = {
            runtimes = java_utils.get_jdk_runtimes(),
          },
        },
      })

      return opts
    end,
  },
}
