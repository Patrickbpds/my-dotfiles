return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "jdtls",
        "lemminx",
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
        -- XML language server: pom.xml, Spring XML, Maven settings.
        -- Upstream only uses .git; add build markers so non-Git Maven/Gradle
        -- projects still get a workspace root.
        lemminx = {
          root_markers = {
            ".git",
            "pom.xml",
            "build.gradle",
            "build.gradle.kts",
            "settings.gradle",
            "settings.gradle.kts",
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts = opts or {}
      local java_utils = require("java.utils")
      local format_profile = vim.api.nvim_get_runtime_file("lua/lang_servers/eclipse-java-google-style.xml", false)[1]

      -- LazyVim adds these through which-key, which only creates the maps once
      -- its setup runs. Set them directly so the JDTLS test runner also works
      -- when which-key is lazy, disabled, or running headless.
      local user_on_attach = opts.on_attach
      opts.on_attach = function(args)
        if user_on_attach then
          user_on_attach(args)
        end
        if vim.bo[args.buf].filetype ~= "java" then
          return
        end
        local map = function(lhs, fn, desc)
          vim.keymap.set("n", lhs, fn, { buffer = args.buf, desc = desc })
        end
        map("<leader>tt", function()
          require("jdtls.dap").test_class()
        end, "Run All Tests (JDTLS)")
        map("<leader>tr", function()
          require("jdtls.dap").test_nearest_method()
        end, "Run Nearest Test (JDTLS)")
        map("<leader>tT", function()
          require("jdtls.dap").pick_test()
        end, "Pick Test (JDTLS)")
      end

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
