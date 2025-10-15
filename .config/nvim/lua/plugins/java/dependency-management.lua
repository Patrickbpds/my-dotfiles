local M = {}

-- ============================================================================
-- 📦 DEPENDENCY MANAGEMENT
-- ============================================================================

local function add_dependency(utils)
  local build_tool = utils.get_build_tool()

  vim.ui.input({ prompt = "Group ID: " }, function(group_id)
    if not group_id or group_id == "" then
      return
    end

    vim.ui.input({ prompt = "Artifact ID: " }, function(artifact_id)
      if not artifact_id or artifact_id == "" then
        return
      end

      vim.ui.input({ prompt = "Version: " }, function(version)
        if not version or version == "" then
          return
        end

        if build_tool == "maven" then
          local dependency = string.format(
            [[
        <dependency>
            <groupId>%s</groupId>
            <artifactId>%s</artifactId>
            <version>%s</version>
        </dependency>]],
            group_id,
            artifact_id,
            version
          )
          vim.notify("Add this to pom.xml:\n" .. dependency)
        elseif build_tool == "gradle" then
          local dependency = string.format("implementation '%s:%s:%s'", group_id, artifact_id, version)
          vim.notify("Add this to build.gradle:\n" .. dependency)
        end
      end)
    end)
  end)
end

local function show_dependency_tree(utils)
  local build_tool = utils.get_build_tool()
  if build_tool == "maven" then
    vim.cmd("botright split | terminal mvn dependency:tree")
  elseif build_tool == "gradle" then
    vim.cmd("botright split | terminal ./gradlew dependencies")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

local function check_vulnerabilities(utils)
  local build_tool = utils.get_build_tool()
  if build_tool == "maven" then
    vim.cmd("botright split | terminal mvn dependency-check:check")
  elseif build_tool == "gradle" then
    vim.cmd("botright split | terminal ./gradlew dependencyCheckAnalyze")
  else
    vim.notify("No build tool detected", vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

local function update_dependencies(utils)
  local build_tool = utils.get_build_tool()
  if build_tool == "maven" then
    vim.cmd("botright split | terminal mvn versions:display-dependency-updates")
  elseif build_tool == "gradle" then
    vim.cmd("botright split | terminal ./gradlew dependencyUpdates")
  end
  vim.cmd("startinsert")
end

M.add_dependency = add_dependency
M.show_dependency_tree = show_dependency_tree
M.check_vulnerabilities = check_vulnerabilities
M.update_dependencies = update_dependencies

return M

