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

  local package_name = M.detect_package()
  return package_name:match("(.+)%.[^.]+$") or package_name
end

function M.get_project_root()
  local root = vim.fs.root(vim.fn.getcwd(), BUILD_MARKERS)
  return root or vim.fn.getcwd()
end

local function parse_java_version(text)
  if not text then
    return nil
  end
  local version = text:match("JAVA_VERSION%s*=%s*\"([%d_.]+)\"")
  if version then
    version = version:gsub("_", ".")
    local major = tonumber(version:match("^(%d+)"))
    if major and major >= 9 then
      return major
    end
    local minor = tonumber(version:match("^1%.(%d+)"))
    if minor then
      return minor
    end
  end
  return tonumber(text:match("^(%d+)"))
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
  return tonumber(output:match('version%s*"(%d+)'))
end

local function java_version_from_build_file(build_tool)
  local root = M.get_project_root()
  if build_tool == "maven" then
    local pom = M.read_file(root .. "/pom.xml")
    if pom then
      local version = pom:match("<java%.version>%s*([%d]+)%s*<") or pom:match("<maven%.compiler%.release>%s*([%d]+)%s*<")
      if version then
        return tonumber(version)
      end
    end
  elseif build_tool == "gradle" then
    for _, file in ipairs({ "build.gradle", "build.gradle.kts" }) do
      local content = M.read_file(root .. "/" .. file)
      if content then
        local version = content:match("JavaLanguageVersion%.of%s*%(%s*(%d+)%s*%)")
          or content:match("sourceCompatibility%s*=%s*['\"]?(%d+)")
          or content:match("targetCompatibility%s*=%s*['\"]?(%d+)")
        if version then
          return tonumber(version)
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
    or tonumber(string.match(_VERSION, "(%d+)"))
end

function M.has_java_version(minimum)
  local version = M.get_java_version()
  return version ~= nil and version >= minimum
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
  local root = M.get_project_root()
  if vim.fn.isdirectory(root .. "/src/main/resources") == 1 then
    return root .. "/src/main/resources"
  end
  return vim.fn.getcwd() .. "/src/main/resources"
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
