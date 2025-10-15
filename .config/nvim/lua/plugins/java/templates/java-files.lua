local M = {}
-- ============================================================================
-- Java File Templates
-- ============================================================================
local java_templates = {}

java_templates.class = [[
package %s;

public class %s {
    // TODO: Implement class
}
]]

java_templates.abstract = [[
package %s;

public abstract class %s {
    // TODO: Implement abstract class
}
]]

java_templates.enum = [[
package %s;

public enum %s {
    // TODO: Add enum values
}
]]

java_templates.interface = [[
package %s;

public interface %s {
    // TODO: Add interface methods
}
]]

java_templates.record = [[
package %s;

public record %s() {
    // TODO: Add record components
}
]]

-- ============================================================================
-- Generate Java File
-- ============================================================================
local function generate_java_file(file_type, name, utils)
  local package_name = utils.detect_package()
  local project_root = vim.fn.getcwd()
  local package_path = package_name:gsub("%.", "/")
  local current_dir = vim.fn.expand("%:p:h")
  local is_test = current_dir:find(project_root .. "/src/test/java", 1, true) == 1

  local base_dir = is_test and "/src/test/java/" or "/src/main/java/"
  local dir = project_root .. base_dir .. package_path

  vim.notify("Debug: name=" .. name .. ", package=" .. package_name, vim.log.levels.INFO)

  local template = java_templates[file_type]
  local content = string.format(template, package_name, name)

  utils.write_java_file(dir, name, content)
end

-- ============================================================================
-- Java File Generator Menu
-- ============================================================================
function M.file_generator(utils)
  local options = {
    "Class",
    "Abstract Class",
    "Interface",
    "Enum",
    "Record",
  }

  vim.ui.select(options, { prompt = "Generate Java file:" }, function(choice)
    if not choice then
      return
    end

    vim.ui.input({ prompt = "Class name: " }, function(name)
      if not name or name == "" then
        return
      end

      local file_type_map = {
        ["Class"] = "class",
        ["Abstract Class"] = "abstract",
        ["Interface"] = "interface",
        ["Enum"] = "enum",
        ["Record"] = "record",
      }

      generate_java_file(file_type_map[choice], name, utils)
    end)
  end)
end

return M
