local M = {}

local function utils()
  return require("plugins.java.java-utils")
end

local function run_in_terminal(cmd)
  utils().run_in_terminal(cmd)
end

local function build_command(tool)
  return utils().get_build_command(tool)
end

local function urlencode(str)
  return (
    str
      :gsub("([^%w _%-%.%~])", function(c)
        return string.format("%%%02X", string.byte(c))
      end)
      :gsub(" ", "+")
  )
end

local function fetch_latest_version(group_id, artifact_id)
  local query = string.format(
    "https://search.maven.org/solrsearch/select?q=g:%s+AND+a:%s&rows=1&wt=json",
    urlencode(group_id),
    urlencode(artifact_id)
  )
  local ok, result = pcall(function()
    return vim.fn.system({ "curl", "-sS", "--max-time", "15", query })
  end)
  if not ok or vim.v.shell_error ~= 0 then
    return nil
  end
  local latest = result:match('"latestVersion"%s*:%s*"([^"]+)"')
  return latest
end

local function insert_maven_dependency(group_id, artifact_id, version)
  local root = utils().get_project_root()
  local pom_path = root .. "/pom.xml"
  if vim.fn.filereadable(pom_path) == 0 then
    return nil
  end

  local content = vim.fn.readfile(pom_path)
  if not content then
    return nil
  end

  local dependency_lines = {
    "        <dependency>",
    "            <groupId>" .. group_id .. "</groupId>",
    "            <artifactId>" .. artifact_id .. "</artifactId>",
  }
  if version and version ~= "" then
    table.insert(dependency_lines, "            <version>" .. version .. "</version>")
  end
  table.insert(dependency_lines, "        </dependency>")

  local insertion_index = nil
  for i, line in ipairs(content) do
    if line:match("^%s*</dependencies>%s*$") then
      insertion_index = i - 1
      break
    end
  end
  if not insertion_index then
    return nil
  end

  local new_content = {}
  for i = 1, insertion_index do
    table.insert(new_content, content[i])
  end
  for _, line in ipairs(dependency_lines) do
    table.insert(new_content, line)
  end
  for i = insertion_index + 1, #content do
    table.insert(new_content, content[i])
  end

  if vim.fn.writefile(new_content, pom_path) == 0 then
    return { path = pom_path, line = insertion_index + 1 }
  end
  return nil
end

local function insert_gradle_dependency(group_id, artifact_id, version)
  local root = utils().get_project_root()
  local candidates = { "build.gradle", "build.gradle.kts" }
  local build_file
  for _, candidate in ipairs(candidates) do
    if vim.fn.filereadable(root .. "/" .. candidate) == 1 then
      build_file = root .. "/" .. candidate
      break
    end
  end
  if not build_file then
    return nil
  end

  local content = vim.fn.readfile(build_file)
  if not content then
    return nil
  end

  local quote = build_file:match("%.kts$") and '"' or "'"
  local has_version = version and version ~= ""
  local version_part = has_version and (":" .. version) or ""
  local dep = string.format("implementation %s%s:%s%s%s", quote, group_id, artifact_id, version_part, quote)

  local dep_start, dep_end = nil, nil
  local in_block = false
  for i, line in ipairs(content) do
    if line:match("^%s*dependencies%s*{") then
      dep_start = i
      in_block = true
    elseif in_block and line:match("^%s*}%s*") then
      dep_end = i
      break
    end
  end
  if not dep_start then
    return nil
  end

  local new_content = {}
  for i = 1, dep_start do
    table.insert(new_content, content[i])
  end
  table.insert(new_content, "    " .. dep)
  local start = dep_end or dep_start + 1
  for i = start, #content do
    table.insert(new_content, content[i])
  end

  if vim.fn.writefile(new_content, build_file) == 0 then
    return { path = build_file, line = dep_start + 1 }
  end
  return nil
end

local function add_dependency()
  local build_tool = utils().get_build_tool()
  if not build_tool then
    vim.notify("No build tool detected (pom.xml/build.gradle not found)", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Group ID: " }, function(group_id)
    if not group_id or group_id == "" then
      return
    end

    vim.ui.input({ prompt = "Artifact ID: " }, function(artifact_id)
      if not artifact_id or artifact_id == "" then
        return
      end

      local latest = fetch_latest_version(group_id, artifact_id)
      local default_version = latest and (" (latest: " .. latest .. ")") or ""
      vim.ui.input({ prompt = "Version" .. default_version .. ": " }, function(version)
        if not version then
          return
        end

        if version == "" and latest then
          version = latest
        end
        if not version or version == "" then
          vim.notify("No version provided and could not resolve latest", vim.log.levels.WARN)
          return
        end

        local inserted
        if build_tool == "maven" then
          inserted = insert_maven_dependency(group_id, artifact_id, version)
        elseif build_tool == "gradle" then
          inserted = insert_gradle_dependency(group_id, artifact_id, version)
        end

        if inserted then
          vim.notify(
            string.format("Added %s:%s:%s (%s:%d)", group_id, artifact_id, version, inserted.path, inserted.line),
            vim.log.levels.INFO
          )
        else
          vim.notify(
            string.format("Could not auto-insert into build file:\n%s:%s:%s", group_id, artifact_id, version),
            vim.log.levels.ERROR
          )
        end
      end)
    end)
  end)
end

local function show_dependency_tree()
  local build_tool = utils().get_build_tool()
  if build_tool == "maven" then
    run_in_terminal(build_command("maven") .. " dependency:tree")
  elseif build_tool == "gradle" then
    run_in_terminal(build_command("gradle") .. " dependencies")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
  end
end

local function check_vulnerabilities()
  local build_tool = utils().get_build_tool()
  if build_tool == "maven" then
    run_in_terminal(build_command("maven") .. " dependency-check:check")
  elseif build_tool == "gradle" then
    run_in_terminal(build_command("gradle") .. " dependencyCheckAnalyze")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
  end
end

local function update_dependencies()
  local build_tool = utils().get_build_tool()
  if build_tool == "maven" then
    run_in_terminal(build_command("maven") .. " versions:display-dependency-updates")
  elseif build_tool == "gradle" then
    run_in_terminal(build_command("gradle") .. " dependencyUpdates")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
  end
end

M.add_dependency = add_dependency
M.show_dependency_tree = show_dependency_tree
M.check_vulnerabilities = check_vulnerabilities
M.update_dependencies = update_dependencies

return M
