local M = {}

local function utils()
  return require("plugins.java.java-utils")
end

local java_templates = {
  class = [[
package %s;

public class %s {
    // TODO: Implement class
}
]],
  abstract = [[
package %s;

public abstract class %s {
    // TODO: Implement abstract class
}
]],
  enum = [[
package %s;

public enum %s {
    // TODO: Add enum values
}
]],
  interface = [[
package %s;

public interface %s {
    // TODO: Add interface methods
}
]],
  record = [[
package %s;

public record %s() {
    // TODO: Add record components
}
]],
}

local RECORD_MIN_VERSION = 16

local function generate_java_file(file_type, name)
  local jutils = utils()
  local version = jutils.get_java_version()

  if file_type == "record" and version and version < RECORD_MIN_VERSION then
    vim.notify(
      string.format("Records require Java %d+ but the active version is %d", RECORD_MIN_VERSION, version),
      vim.log.levels.WARN
    )
    return
  end

  local package_name = jutils.detect_package()
  local project_root = jutils.get_project_root()
  local package_path = package_name:gsub("%.", "/")
  local current_dir = vim.fn.expand("%:p:h")
  local is_test = current_dir:find(project_root .. "/src/test/java", 1, true) == 1

  local base_dir = is_test and "/src/test/java/" or "/src/main/java/"
  local dir = project_root .. base_dir .. package_path

  local content = string.format(java_templates[file_type], package_name, name)
  jutils.write_java_file(dir, name, content, version)
end

function M.file_generator()
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

      generate_java_file(file_type_map[choice], name)
    end)
  end)
end

return M
