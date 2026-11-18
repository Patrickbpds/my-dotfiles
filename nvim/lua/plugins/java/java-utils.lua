local M = {}

local BUILD_MARKERS = {
  "pom.xml",
  "mvnw",
  "build.gradle",
  "build.gradle.kts",
  "gradlew",
  "settings.gradle",
  "settings.gradle.kts",
}

local function read_file_lines(filepath, max_lines)
  max_lines = max_lines or 1000

  local success, content = pcall(vim.fn.readfile, filepath, "", max_lines)

  return success and content or {}
end

function M.detect_package()
  local current_file = vim.fn.expand("%:p")
  local project_root = M.get_project_root()

  if not current_file or current_file == "" then
    return "com.example"
  end

  if current_file:match("%.java$") then
    local file_content = read_file_lines(current_file, 100)
    for _, line in ipairs(file_content) do
      local package_match = line:match("^package%s+([%w%.]+)%s*;")
      if package_match then
        return package_match
      end
    end
  end

  local current_dir = vim.fn.expand("%:p:h")
  local main_java = project_root .. "/src/main/java"
  local test_java = project_root .. "/src/test/java"

  local function get_package_from_path(base_path)
    if not base_path or current_dir:find(base_path, 1, true) ~= 1 then
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

function M.get_base_package()
  local root = M.get_project_root()
  local source_roots = { root .. "/src/main/java", root .. "/src/test/java" }

  local function is_java_identifier(dir)
    return dir:match("^[%a_][%w_]*$") ~= nil
  end

  for _, base in ipairs(source_roots) do
    if vim.fn.isdirectory(base) == 1 then
      local segment = base .. "/"
      local parts = {}
      while true do
        local dirs = {}
        for _, child in ipairs(vim.fn.glob(segment .. "*", false, true)) do
          if vim.fn.isdirectory(child) == 1 and is_java_identifier(vim.fn.fnamemodify(child, ":t")) then
            table.insert(dirs, child)
          end
        end
        if #dirs == 1 then
          local name = vim.fn.fnamemodify(dirs[1], ":t")
          table.insert(parts, name)
          segment = dirs[1] .. "/"
        else
          break
        end
      end
      if #parts > 0 then
        return table.concat(parts, ".")
      end
    end
  end

  return M.detect_package()
end

function M.get_project_root()
  local cwd = vim.fn.getcwd()
  return vim.fs.root(0, BUILD_MARKERS) or vim.fs.root(cwd, BUILD_MARKERS) or cwd
end

local function normalize_java_version(value)
  if not value then
    return nil
  end

  value = tostring(value):gsub("_", ".")
  local legacy = tonumber(value:match("^1%.(%d+)"))
  if legacy then
    return legacy
  end

  return tonumber(value:match("^(%d+)"))
end

local function parse_java_version(text)
  if not text then
    return nil
  end

  local version = text:match("JAVA_VERSION%s*=%s*\"([%d_.]+)\"")
  if version then
    return normalize_java_version(version)
  end

  return normalize_java_version(text)
end

local function java_version_from_release()
  local home = vim.fn.getenv("JAVA_HOME")
  if not home or home == vim.NIL or home == "" then
    return nil
  end
  local release = home .. "/release"
  if vim.fn.filereadable(release) == 0 then
    return nil
  end
  return parse_java_version(M.read_file(release))
end

local function java_version_from_command()
  local ok, output = pcall(function()
    return vim.fn.system({ "java", "-version" })
  end)
  if not ok or vim.v.shell_error ~= 0 then
    return nil
  end
  return normalize_java_version(output:match('version%s*"([%d_.]+)"'))
end

local function java_version_from_build_file(build_tool)
  local root = M.get_project_root()
  if build_tool == "maven" then
    local pom = M.read_file(root .. "/pom.xml")
    if pom then
      local version = pom:match("<java%.version>%s*([%d%.]+)%s*<")
        or pom:match("<maven%.compiler%.release>%s*([%d%.]+)%s*<")
        or pom:match("<maven%.compiler%.source>%s*([%d%.]+)%s*<")
        or pom:match("<maven%.compiler%.target>%s*([%d%.]+)%s*<")
      if version then
        return normalize_java_version(version)
      end
    end
  elseif build_tool == "gradle" then
    for _, file in ipairs({ "build.gradle", "build.gradle.kts" }) do
      local content = M.read_file(root .. "/" .. file)
      if content then
        local version = content:match("JavaLanguageVersion%.of%s*%(%s*(%d+)%s*%)")
          or content:match("sourceCompatibility%s*=%s*['\"]?([%d%.]+)")
          or content:match("targetCompatibility%s*=%s*['\"]?([%d%.]+)")
          or content:match("sourceCompatibility%s*=%s*JavaVersion%.VERSION_([%d_]+)")
          or content:match("targetCompatibility%s*=%s*JavaVersion%.VERSION_([%d_]+)")
        if version then
          return normalize_java_version(version)
        end
      end
    end
  end
  return nil
end

function M.get_java_version()
  local build_tool = M.get_build_tool()
  return java_version_from_build_file(build_tool)
    or java_version_from_release()
    or java_version_from_command()
end

function M.has_java_version(minimum)
  local version = M.get_java_version()
  return version ~= nil and version >= minimum
end

local function version_major(version)
  if not version then
    return nil
  end
  return tonumber(tostring(version):match("^(%d+)"))
end

function M.get_spring_boot_version()
  local root = M.get_project_root()
  local build_tool = M.get_build_tool()

  if build_tool == "maven" then
    local pom = M.read_file(root .. "/pom.xml")
    if not pom then
      return nil
    end
    return pom:match("<artifactId>%s*spring%-boot%-starter%-parent%s*</artifactId>%s*<version>%s*([%d%.]+)%s*</version>")
      or pom:match("<artifactId>%s*spring%-boot%-dependencies%s*</artifactId>%s*<version>%s*([%d%.]+)%s*</version>")
      or pom:match("<spring%-boot%.version>%s*([%d%.]+)%s*</spring%-boot%.version>")
  elseif build_tool == "gradle" then
    for _, file in ipairs({ "build.gradle", "build.gradle.kts" }) do
      local content = M.read_file(root .. "/" .. file)
      if content then
        local version = content:match(
          "id%s*%(?%s*['\"]org%.springframework%.boot['\"]%s*%)?%s*version%s*['\"]([%d%.]+)['\"]"
        )
          or content:match("spring%-boot%-gradle%-plugin[^\n]-version%s*['\"]([%d%.]+)['\"]")
          or content:match("spring%-boot%-gradle%-plugin:([%d%.]+)")
        if version then
          return version
        end
      end
    end
  end

  return nil
end

local function project_uses_import(import)
  local root = M.get_project_root() .. "/src/main/java"
  for _, file in ipairs(vim.fn.glob(root .. "/**/*.java", false, true)) do
    local content = M.read_file(file)
    if content and content:find(import, 1, true) then
      return true
    end
  end
  return false
end

function M.uses_jakarta(java_version)
  local spring_major = version_major(M.get_spring_boot_version())
  if spring_major then
    return spring_major >= 3
  end

  local jakarta = project_uses_import("import jakarta.")
  local javax = project_uses_import("import javax.")
  if jakarta ~= javax then
    return jakarta
  end

  return (java_version or M.get_java_version() or 0) >= 17
end

function M.get_jakarta_namespace(java_version)
  return M.uses_jakarta(java_version) and "jakarta" or "javax"
end

local function java_home_version(path)
  return parse_java_version(M.read_file(path .. "/release"))
end

function M.detect_jdks()
  local jdks = {}
  local seen = {}

  local function add(path)
    if not path or path == "" or path == vim.NIL then
      return
    end
    path = vim.fn.fnamemodify(path, ":p"):gsub("/+$", "")
    if vim.fn.isdirectory(path) == 0 then
      return
    end
    local real = vim.uv.fs_realpath(path) or path
    if seen[real] then
      return
    end
    local version = java_home_version(path)
    if version then
      seen[real] = true
      table.insert(jdks, { path = path, version = version })
    end
  end

  add(vim.fn.getenv("JAVA_HOME"))

  local patterns = {
    vim.fn.expand("~/.sdkman/candidates/java") .. "/*",
    vim.fn.expand("~/.jdks") .. "/*",
    vim.fn.expand("~/.gradle/jdks") .. "/*",
    vim.fn.expand("~/.local/share/mise/installs/java") .. "/*",
    vim.fn.expand("~/.asdf/installs/java") .. "/*",
    "/usr/lib/jvm/*",
    "/usr/java/*",
    "/opt/java/*",
    "/Library/Java/JavaVirtualMachines/*/Contents/Home",
  }

  for _, pattern in ipairs(patterns) do
    for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
      add(path)
    end
  end

  table.sort(jdks, function(a, b)
    if a.version == b.version then
      return a.path < b.path
    end
    return a.version < b.version
  end)

  return jdks
end

local function runtime_name(major)
  if major == 8 then
    return "JavaSE-1.8"
  end
  return "JavaSE-" .. major
end

function M.get_jdk_runtimes()
  local paths_by_major = {}
  local java_home = vim.fn.getenv("JAVA_HOME")
  if java_home == vim.NIL or java_home == "" then
    java_home = nil
  end
  local home_real = java_home and (vim.uv.fs_realpath(java_home) or java_home)

  for _, jdk in ipairs(M.detect_jdks()) do
    local jdk_real = vim.uv.fs_realpath(jdk.path) or jdk.path
    if (home_real and jdk_real == home_real) or not paths_by_major[jdk.version] then
      paths_by_major[jdk.version] = jdk.path
    end
  end

  local majors = {}
  for major in pairs(paths_by_major) do
    table.insert(majors, major)
  end
  table.sort(majors)

  local project_major = M.get_java_version()
  local default_major = paths_by_major[project_major] and project_major or majors[#majors]
  local runtimes = {}

  for _, major in ipairs(majors) do
    local runtime = { name = runtime_name(major), path = paths_by_major[major] }
    if major == default_major then
      runtime.default = true
    end
    table.insert(runtimes, runtime)
  end

  return runtimes
end

function M.get_build_tool()
  local root = M.get_project_root()
  if vim.fn.filereadable(root .. "/pom.xml") == 1 then
    return "maven"
  elseif vim.fn.filereadable(root .. "/build.gradle") == 1 or vim.fn.filereadable(root .. "/build.gradle.kts") == 1 then
    return "gradle"
  end
  return nil
end

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

function M.get_resources_dir()
  return M.get_project_root() .. "/src/main/resources"
end

function M.run_in_terminal(cmd)
  local root = M.get_project_root()
  vim.cmd("botright split")
  vim.cmd("terminal")
  vim.fn.chansend(vim.b.terminal_job_id, "cd " .. vim.fn.shellescape(root) .. "\n")
  vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\n")
  vim.cmd("startinsert")
  return vim.api.nvim_get_current_buf()
end

function M.absolute_path(path)
  if path:sub(1, 1) == "/" then
    return path
  end
  return M.get_project_root() .. "/" .. path
end

function M.read_file(path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

function M.write_file(path, content)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local file = io.open(path, "w")
  if not file then
    return false
  end
  file:write(content)
  file:close()
  return true
end

function M.write_java_file(dir, class_name, content, version)
  vim.fn.mkdir(dir, "p")
  local full_path = dir .. "/" .. class_name .. ".java"

  local java_version = version or M.get_java_version()
  if java_version then
    content = string.format("// Generated for Java %d\n%s", java_version, content)
  end

  if not M.write_file(full_path, content) then
    vim.notify("Failed to write file: " .. full_path, vim.log.levels.ERROR)
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(full_path))
  vim.notify(string.format("Created: %s (Java %s)", class_name, java_version or "?"))
end

function M.capitalize(str)
  return (str:gsub("^%l", string.upper))
end

function M.to_pascal_case(str)
  local pascal = str:gsub("[%s_%-]+", " "):gsub("(%a)([%w']*)", function(first, rest)
    return first:upper() .. rest
  end)
  return (pascal:gsub("%s", ""))
end

function M.entity_to_endpoint(name)
  return (name:gsub("(%l)(%u)", "%1-%2"):gsub("(%u)(%u%l)", "%1-%2"):lower())
end

function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

return M
