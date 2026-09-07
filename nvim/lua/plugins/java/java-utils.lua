local M = {}

-- ============================================================================
--  Only utilities that LazyVim does NOT provide
-- ============================================================================

-- Safe File Reader
local function read_file_lines(filepath, max_lines)
  max_lines = max_lines or 1000

  local success, content = pcall(vim.fn.readfile, filepath, "", max_lines)

  return success and content or {}
end

-- Detect package from current file
function M.detect_package()
  local current_file = vim.fn.expand("%:p")
  local project_root = M.get_project_root()

  if not current_file or current_file == "" then
    return "com.example"
  end

  -- Attempt to read file package
  if current_file:match("%.java$") then
    local file_content = read_file_lines(current_file, 100)
    for _, line in ipairs(file_content) do
      local package_match = line:match("^package%s+([%w%.]+)%s*;")
      if package_match then
        return package_match
      end
    end
  end

  -- Inferring from the directory structure
  local current_dir = vim.fn.expand("%:p:h")
  local main_java = project_root .. "/src/main/java"
  local test_java = project_root .. "/src/test/java"

  local function get_package_from_path(base_path)
    if not base_path or not current_dir:find(base_path, 1, true) then
      return nil
    end
    local relative_path = current_dir:sub(#base_path + 2)
    if relative_path and relative_path ~= "" then
      return relative_path:gsub("/", ".")
    end
    return nil
  end

  return get_package_from_path(main_java) or get_package_from_path(test_java) or "com.example"
end

-- Detect project root from common build markers
function M.get_project_root()
  local markers =
    { "pom.xml", "mvnw", "build.gradle", "build.gradle.kts", "gradlew", "settings.gradle", "settings.gradle.kts" }
  local root = vim.fs.root(vim.fn.getcwd(), markers)
  return root or vim.fn.getcwd()
end

-- Detect build tool
function M.get_build_tool()
  local root = M.get_project_root()
  if vim.fn.filereadable(root .. "/pom.xml") == 1 then
    return "maven"
  elseif vim.fn.filereadable(root .. "/build.gradle") == 1 or vim.fn.filereadable(root .. "/build.gradle.kts") == 1 then
    return "gradle"
  end
  return nil
end

-- Prefer the project's Maven/Gradle wrapper when available
function M.get_build_command(build_tool)
  local root = M.get_project_root()
  if build_tool == "maven" then
    if vim.fn.filereadable(root .. "/mvnw") == 1 then
      return root .. "/mvnw"
    end
    return "mvn"
  elseif build_tool == "gradle" then
    if vim.fn.filereadable(root .. "/gradlew") == 1 then
      return root .. "/gradlew"
    end
    return "gradle"
  end
  return nil
end

-- Write Java file
function M.write_java_file(dir, class_name, content)
  vim.fn.mkdir(dir, "p")
  local full_path = dir .. "/" .. class_name .. ".java"

  local file = io.open(full_path, "w")
  if file then
    file:write(content)
    file:close()
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    vim.notify("Created: " .. class_name)
  else
    vim.notify("Failed to write file: " .. full_path, vim.log.levels.ERROR)
  end
end

return M
