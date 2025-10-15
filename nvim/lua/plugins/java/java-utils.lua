-- ============================================================================
-- JAVA UTILITIES
-- ============================================================================
-- Utility functions for Java development in Neovim

local M = {}

-- ============================================================================
-- JDK Configuration
-- ============================================================================
M.JDK_PATHS = {
  [8] = "/usr/lib/jvm/java-8-openjdk",
  [11] = "/usr/lib/jvm/java-11-openjdk",
  [17] = "/usr/lib/jvm/java-17-openjdk",
  [21] = "/usr/lib/jvm/java-21-openjdk",
  [24] = "/usr/lib/jvm/java-24-jdk",
  [25] = "/usr/lib/jvm/java-25-openjdk",
}

-- ============================================================================
-- Safe File Reader
-- ============================================================================
local function read_file_lines(filepath, max_lines)
  max_lines = max_lines or 1000
  local success, content = pcall(vim.fn.readfile, filepath, "", max_lines)
  return success and content or {}
end

-- ============================================================================
-- Parse Maven Version
-- ============================================================================
local function parse_maven_version(pom_content)
  for _, line in ipairs(pom_content) do
    local java_version = line:match("<java%.version>([%d]+)</java%.version>")
    if java_version then
      return tonumber(java_version)
    end
    local compiler_source = line:match("<maven%.compiler%.source>([%d]+)</maven%.compiler%.source>")
    if compiler_source then
      return tonumber(compiler_source)
    end
    local compiler_release = line:match("<maven%.compiler%.release>([%d]+)</maven%.compiler%.release>")
    if compiler_release then
      return tonumber(compiler_release)
    end
  end
  return nil
end

-- ============================================================================
-- Parse Gradle Version
-- ============================================================================
local function parse_gradle_version(gradle_content)
  for _, line in ipairs(gradle_content) do
    local source_compat = line:match("sourceCompatibility%s*=%s*['\"]?([%d]+)['\"]?")
      or line:match("sourceCompatibility%s*=%s*JavaVersion%.VERSION_([%d]+)")
    if source_compat then
      return tonumber(source_compat)
    end
    local toolchain_version = line:match("languageVersion%s*=%s*JavaLanguageVersion%.of%(([%d]+)%)")
    if toolchain_version then
      return tonumber(toolchain_version)
    end
  end
  return nil
end

-- ============================================================================
-- Detect Java Version
-- ============================================================================
function M.detect_java_version()
  local cwd = vim.fn.getcwd()

  -- Check for Maven pom.xml
  local pom_xml = cwd .. "/pom.xml"
  if vim.fn.filereadable(pom_xml) == 1 then
    local pom_content = read_file_lines(pom_xml, 500)
    local version = parse_maven_version(pom_content)
    if version then
      return version
    end
  end

  -- Check for Gradle
  local build_gradle = cwd .. "/build.gradle"
  local build_gradle_kts = cwd .. "/build.gradle.kts"
  local gradle_file = vim.fn.filereadable(build_gradle) == 1 and build_gradle
    or (vim.fn.filereadable(build_gradle_kts) == 1 and build_gradle_kts or nil)

  if gradle_file then
    local gradle_content = read_file_lines(gradle_file, 500)
    local version = parse_gradle_version(gradle_content)
    if version then
      return version
    end
  end

  return 17
end

-- ============================================================================
-- Validate JDK Path
-- ============================================================================
local function validate_jdk_path(path)
  if not path or vim.fn.isdirectory(path) ~= 1 then
    return false
  end
  local java_binary = path .. "/bin/java"
  return vim.fn.executable(java_binary) == 1
end

-- ============================================================================
-- Get JDK Path
-- ============================================================================
-- Retorna o caminho do JDK baseado na versão solicitada.
-- Faz fallback para Java 17 ou qualquer versão disponível se não encontrar.
function M.get_jdk_path(version)
  if not version or type(version) ~= "number" then
    vim.notify("Invalid Java version provided", vim.log.levels.ERROR)
    return nil
  end

  -- Try requested version first
  local path = M.JDK_PATHS[version]
  if validate_jdk_path(path) then
    return path
  end

  -- Fallback to Java 17 if not already tried
  if version ~= 17 then
    local fallback_path = M.JDK_PATHS[17]
    if validate_jdk_path(fallback_path) then
      vim.notify(string.format("Java %d not available, falling back to Java 17", version), vim.log.levels.WARN)
      return fallback_path
    end
  end

  -- Try any available JDK
  for ver, jdk_path in pairs(M.JDK_PATHS) do
    if validate_jdk_path(jdk_path) then
      vim.notify(string.format("Using fallback Java %d (requested: %d)", ver, version), vim.log.levels.WARN)
      return jdk_path
    end
  end

  vim.notify("No JDK installations found!", vim.log.levels.ERROR)
  return nil
end

-- ============================================================================
-- Detect Package
-- ============================================================================
function M.detect_package()
  local current_file = vim.fn.expand("%:p")
  local project_root = vim.fn.getcwd()

  if not current_file or current_file == "" then
    return "com.example"
  end

  -- Try to read package from file
  if current_file:match("%.java$") then
    local file_content = read_file_lines(current_file, 100)
    for _, line in ipairs(file_content) do
      local package_match = line:match("^package%s+([%w%.]+)%s*;")
      if package_match then
        return package_match
      end
    end
  end

  -- Infer from directory structure
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

  local package = get_package_from_path(main_java) or get_package_from_path(test_java)
  return package or "com.example"
end

-- ============================================================================
-- Get Build Tool
-- ============================================================================
function M.get_build_tool()
  local cwd = vim.fn.getcwd()
  if vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
    return "maven"
  elseif vim.fn.filereadable(cwd .. "/build.gradle") == 1 or vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1 then
    return "gradle"
  end
  return nil
end

-- ============================================================================
-- Write Java File
-- ============================================================================
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
