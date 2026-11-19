local M = {}

local function utils()
  return require("java.utils")
end

local function build_command(tool)
  return utils().get_build_command(tool)
end

local function run_in_terminal(cmd)
  utils().run_in_terminal(cmd)
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

local function next_version(migration_dir)
  local files = vim.fn.glob(migration_dir .. "V*.sql", false, true)
  local max_version = 0

  for _, file in ipairs(files) do
    local version = tonumber(vim.fn.fnamemodify(file, ":t"):match("^V(%d+)"))
    if version and version > max_version then
      max_version = version
    end
  end

  return max_version + 1
end

local function create_flyway_migration()
  local build_tool = utils().get_build_tool()
  if not build_tool then
    vim.notify("No build tool detected (pom.xml/build.gradle not found)", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Migration description: " }, function(description)
    if not description or description == "" then
      return
    end

    local migration_dir = utils().get_project_root() .. "/src/main/resources/db/migration/"
    vim.fn.mkdir(migration_dir, "p")

    local version = next_version(migration_dir)
    local sanitized_desc = description:gsub("%s+", "_"):gsub("[^%w_%-]", "")
    local filename = string.format("V%d__%s.sql", version, sanitized_desc)
    local migration_path = migration_dir .. filename

    local content = string.format(
      [[
-- %s
-- Created: %s

]],
      description,
      os.date("%Y-%m-%d %H:%M:%S")
    )

    if utils().write_file(migration_path, content) then
      vim.cmd("edit " .. vim.fn.fnameescape(migration_path))
      vim.notify("Created migration: " .. filename)
    else
      vim.notify("Failed to create migration file!", vim.log.levels.ERROR)
    end
  end)
end

M.flyway_migrate = run_flyway_migrate
M.create_migration = create_flyway_migration

return M
