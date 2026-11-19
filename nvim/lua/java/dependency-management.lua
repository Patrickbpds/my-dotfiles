local M = {}

local function utils()
  return require("java.utils")
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
  return result:match('"latestVersion"%s*:%s*"([^"]+)"')
end

local function validate_coordinate(value)
  return type(value) == "string" and value:match("^[%w_%.%-]+$") ~= nil
end

local function validate_version(value)
  return type(value) == "string" and value:match("^[%w_%+%.%-]+$") ~= nil
end

local function validate_coordinates(group_id, artifact_id, version)
  if not validate_coordinate(group_id) then
    return false, "Invalid group ID"
  end
  if not validate_coordinate(artifact_id) then
    return false, "Invalid artifact ID"
  end
  if version ~= nil and version ~= "" and not validate_version(version) then
    return false, "Invalid version"
  end
  return true
end

local function indentation(line)
  return line:match("^(%s*)") or ""
end

local function replace_range(content, first, last, replacement)
  local result = {}
  for i = 1, first - 1 do
    table.insert(result, content[i])
  end
  vim.list_extend(result, replacement)
  for i = last + 1, #content do
    table.insert(result, content[i])
  end
  return result
end

local function scan_tags(line)
  local tags = {}
  for tag in line:gmatch("<([^>]+)>") do
    local first = tag:sub(1, 1)
    if first == "/" then
      local name = tag:sub(2):match("^([%w:%.%-]+)")
      if name then
        table.insert(tags, { close = name })
      end
    elseif first ~= "!" and first ~= "?" then
      local name = tag:match("^([%w:%.%-]+)")
      if name then
        table.insert(tags, { name = name, self_closing = tag:match("/%s*$") ~= nil })
      end
    end
  end
  return tags
end

local function find_project_dependencies(content)
  local stack = {}
  local block
  local self_closing_line

  for i, line in ipairs(content) do
    for _, tag in ipairs(scan_tags(line)) do
      if tag.close then
        local top = stack[#stack]
        if top and top.name == tag.close then
          if tag.close == "dependencies" and top.parent == "project" and not block then
            block = { start = top.start, finish = i }
          end
          table.remove(stack)
        end
      elseif tag.self_closing then
        local parent = stack[#stack]
        if tag.name == "dependencies" and parent and parent.name == "project" and not self_closing_line then
          self_closing_line = i
        end
      else
        local parent = stack[#stack]
        table.insert(stack, { name = tag.name, start = i, parent = parent and parent.name or nil })
      end
    end
  end

  return block, self_closing_line
end

local function maven_dependency_lines(indent, group_id, artifact_id, version)
  local inner = indent .. "    "
  local lines = {
    indent .. "<dependency>",
    inner .. "<groupId>" .. group_id .. "</groupId>",
    inner .. "<artifactId>" .. artifact_id .. "</artifactId>",
  }
  if version and version ~= "" then
    table.insert(lines, inner .. "<version>" .. version .. "</version>")
  end
  table.insert(lines, indent .. "</dependency>")
  return lines
end

local function maven_dependency_exists(content, block, group_id, artifact_id)
  local text = table.concat(vim.list_slice(content, block.start, block.finish), "\n")
  local group = vim.pesc(group_id)
  local artifact = vim.pesc(artifact_id)
  return text:match("<groupId>%s*" .. group .. "%s*</groupId>%s*<artifactId>%s*" .. artifact .. "%s*</artifactId>") ~= nil
end

local function insert_maven_dependency(group_id, artifact_id, version)
  local valid, err = validate_coordinates(group_id, artifact_id, version)
  if not valid then
    return nil, err
  end

  local pom_path = utils().get_project_root() .. "/pom.xml"
  if vim.fn.filereadable(pom_path) == 0 then
    return nil, "pom.xml not found"
  end

  local content = vim.fn.readfile(pom_path)
  local block, self_closing_line = find_project_dependencies(content)
  local new_content
  local line

  if block then
    if maven_dependency_exists(content, block, group_id, artifact_id) then
      return nil, "Dependency already present"
    end

    local indent = indentation(content[block.start])
    local dependencies = maven_dependency_lines(indent .. "    ", group_id, artifact_id, version)

    if block.start == block.finish then
      local replacement = { indent .. "<dependencies>" }
      vim.list_extend(replacement, dependencies)
      table.insert(replacement, indent .. "</dependencies>")
      new_content = replace_range(content, block.start, block.finish, replacement)
      line = block.start + 1
    else
      new_content = replace_range(content, block.finish, block.finish - 1, dependencies)
      line = block.finish
    end
  elseif self_closing_line then
    local indent = indentation(content[self_closing_line])
    local replacement = { indent .. "<dependencies>" }
    vim.list_extend(replacement, maven_dependency_lines(indent .. "    ", group_id, artifact_id, version))
    table.insert(replacement, indent .. "</dependencies>")
    new_content = replace_range(content, self_closing_line, self_closing_line, replacement)
    line = self_closing_line + 1
  else
    local project_end
    for i, current in ipairs(content) do
      if current:match("^%s*</project>%s*$") then
        project_end = i
      end
    end
    if not project_end then
      return nil, "Could not find </project>"
    end

    local replacement = { "    <dependencies>" }
    vim.list_extend(replacement, maven_dependency_lines("        ", group_id, artifact_id, version))
    table.insert(replacement, "    </dependencies>")
    new_content = replace_range(content, project_end, project_end - 1, replacement)
    line = project_end + 1
  end

  if vim.fn.writefile(new_content, pom_path) ~= 0 then
    return nil, "Could not write pom.xml"
  end
  return { path = pom_path, line = line }
end

local function strip_comments_and_strings(line)
  local result = {}
  local quote
  local i = 1

  while i <= #line do
    local char = line:sub(i, i)
    if quote then
      if char == "\\" then
        i = i + 1
      elseif char == quote then
        quote = nil
      end
      table.insert(result, " ")
    elseif char == '"' or char == "'" then
      quote = char
      table.insert(result, " ")
    elseif char == "/" and line:sub(i + 1, i + 1) == "/" then
      break
    elseif char == "/" and line:sub(i + 1, i + 1) == "*" then
      local stop = line:find("*/", i + 2, true)
      if stop then
        i = stop + 1
      else
        break
      end
    else
      table.insert(result, char)
    end
    i = i + 1
  end

  return table.concat(result)
end

local function find_root_dependencies(content)
  local depth = 0
  local start_line
  local finish_line

  for i, line in ipairs(content) do
    local code = strip_comments_and_strings(line)
    if not start_line and depth == 0 and code:match("^%s*dependencies%s*{") then
      start_line = i
    end

    local _, opens = code:gsub("{", "")
    local _, closes = code:gsub("}", "")
    depth = depth + opens - closes

    if start_line and not finish_line and depth == 0 then
      finish_line = i
    end
  end

  if not start_line or not finish_line then
    return nil
  end
  return { start = start_line, finish = finish_line }
end

local function gradle_dependency_line(build_file, group_id, artifact_id, version)
  local coordinate = group_id .. ":" .. artifact_id
  if version and version ~= "" then
    coordinate = coordinate .. ":" .. version
  end
  if build_file:match("%.kts$") then
    return string.format('implementation("%s")', coordinate)
  end
  return string.format("implementation '%s'", coordinate)
end

local function gradle_dependency_exists(content, block, group_id, artifact_id)
  local text = table.concat(vim.list_slice(content, block.start, block.finish), "\n")
  return text:find(group_id .. ":" .. artifact_id, 1, true) ~= nil
end

local function block_indentation(content, block)
  for i = block.start + 1, block.finish - 1 do
    local line = content[i]
    if line and line:match("%S") then
      return indentation(line)
    end
  end
  return indentation(content[block.start]) .. "    "
end

local function insert_gradle_dependency(group_id, artifact_id, version)
  local valid, err = validate_coordinates(group_id, artifact_id, version)
  if not valid then
    return nil, err
  end

  local root = utils().get_project_root()
  local build_file
  for _, candidate in ipairs({ "build.gradle", "build.gradle.kts" }) do
    if vim.fn.filereadable(root .. "/" .. candidate) == 1 then
      build_file = root .. "/" .. candidate
      break
    end
  end
  if not build_file then
    return nil, "Gradle build file not found"
  end

  local content = vim.fn.readfile(build_file)
  local block = find_root_dependencies(content)
  local dependency = gradle_dependency_line(build_file, group_id, artifact_id, version)
  local new_content
  local line

  if block then
    if gradle_dependency_exists(content, block, group_id, artifact_id) then
      return nil, "Dependency already present"
    end

    local indent = block_indentation(content, block)
    new_content = replace_range(content, block.finish, block.finish - 1, { indent .. dependency })
    line = block.finish
  else
    if #content > 0 and content[#content] ~= "" then
      table.insert(content, "")
    end
    new_content = replace_range(content, #content + 1, #content, { "dependencies {", "    " .. dependency, "}" })
    line = #new_content - 1
  end

  if vim.fn.writefile(new_content, build_file) ~= 0 then
    return nil, "Could not write Gradle build file"
  end
  return { path = build_file, line = line }
end

local function add_dependency()
  local build_tool = utils().get_build_tool()
  if not build_tool then
    vim.notify("No build tool detected (pom.xml/build.gradle not found)", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Group ID: " }, function(raw_group_id)
    local group_id = raw_group_id and vim.trim(raw_group_id) or ""
    if group_id == "" then
      return
    end

    vim.ui.input({ prompt = "Artifact ID: " }, function(raw_artifact_id)
      local artifact_id = raw_artifact_id and vim.trim(raw_artifact_id) or ""
      if artifact_id == "" then
        return
      end

      local valid, err = validate_coordinates(group_id, artifact_id)
      if not valid then
        vim.notify(err, vim.log.levels.ERROR)
        return
      end

      local latest = fetch_latest_version(group_id, artifact_id)
      local default_version = latest and (" (latest: " .. latest .. ")") or ""
      vim.ui.input({ prompt = "Version" .. default_version .. ": " }, function(raw_version)
        if raw_version == nil then
          return
        end

        local version = vim.trim(raw_version)
        if version == "" and latest then
          version = latest
        end
        if version == "" then
          vim.notify("No version provided and could not resolve latest", vim.log.levels.WARN)
          return
        end

        valid, err = validate_coordinates(group_id, artifact_id, version)
        if not valid then
          vim.notify(err, vim.log.levels.ERROR)
          return
        end

        local inserted, insert_err
        if build_tool == "maven" then
          inserted, insert_err = insert_maven_dependency(group_id, artifact_id, version)
        elseif build_tool == "gradle" then
          inserted, insert_err = insert_gradle_dependency(group_id, artifact_id, version)
        end

        if inserted then
          vim.notify(
            string.format("Added %s:%s:%s (%s:%d)", group_id, artifact_id, version, inserted.path, inserted.line),
            vim.log.levels.INFO
          )
        else
          vim.notify(
            string.format("Could not add %s:%s:%s: %s", group_id, artifact_id, version, insert_err or "unknown error"),
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
M.validate_coordinates = validate_coordinates
M.insert_maven_dependency = insert_maven_dependency
M.insert_gradle_dependency = insert_gradle_dependency

return M
