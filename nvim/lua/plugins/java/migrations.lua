local M = {}

-- ============================================================================
-- 🗄️ DATABASE FUNCTIONS
-- ============================================================================

local function utils()
  return require("plugins.java.java-utils")
end

local function build_command(tool)
  return utils().get_build_command(tool)
end

local function run_in_terminal(cmd)
  local root = utils().get_project_root()
  local old_cwd = vim.fn.getcwd()
  vim.fn.chdir(root)
  vim.cmd("botright split | terminal " .. cmd)
  vim.fn.chdir(old_cwd)
  vim.cmd("startinsert")
end

local function run_flyway_migrate()
  local build_tool = utils().get_build_tool()
  if build_tool == "maven" then
    run_in_terminal(build_command("maven") .. " flyway:migrate")
  elseif build_tool == "gradle" then
    run_in_terminal(build_command("gradle") .. " flywayMigrate")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
  end
end

local function create_flyway_migration()
  vim.ui.input({ prompt = "Migration description: " }, function(description)
    if not description or description == "" then
      return
    end

    local root = utils().get_project_root()
    local migration_dir = root .. "/src/main/resources/db/migration/"

    vim.fn.mkdir(migration_dir, "p")

    local files = vim.fn.glob(migration_dir .. "V*.sql", false, true)

    local max_version = 0
    for _, file in ipairs(files) do
      local version = tonumber(file:match("V(%d+)"))
      if version and version > max_version then
        max_version = version
      end
    end

    local new_version = max_version + 1

    local sanitized_desc = description:gsub("%s+", "")
    local filename = string.format("V%d__%s.sql", new_version, sanitized_desc)
    local migration_path = migration_dir .. filename

    local content = string.format(
      [[
-- Migration: %s
-- Created: %s

-- Add your SQL here
]],
      description,
      os.date("%Y-%m-%d %H:%M:%S")
    )

    local file = io.open(migration_path, "w")
    if file then
      file:write(content)
      file:close()
      vim.cmd("edit " .. migration_path)
      vim.notify("Created migration: " .. filename)
    else
      vim.notify("Failed to create migration file!", vim.log.levels.ERROR)
    end
  end)
end

M.flyway_migrate = run_flyway_migrate
M.create_migration = create_flyway_migration

return M
