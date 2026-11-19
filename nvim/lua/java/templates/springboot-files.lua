local M = {}

local RECORD_MIN_VERSION = 16

local function utils()
  return require("java.utils")
end

local spring_templates = {}

spring_templates.controller = [[
package %s;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/%s")
public class %s {

}
]]

spring_templates.service = [[
package %s;

import %s.model.%s;
import %s.repository.%sRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class %s {

    private final %sRepository repository;

    public %s(%sRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public List<%s> findAll() {
        return repository.findAll();
    }

    @Transactional(readOnly = true)
    public %s findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("%s not found with id: " + id));
    }

    @Transactional
    public %s save(%s entity) {
        return repository.save(entity);
    }

    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new RuntimeException("%s not found with id: " + id);
        }
        repository.deleteById(id);
    }
}
]]

spring_templates.repository = [[
package %s;

import %s.model.%s;
import org.springframework.data.jpa.repository.JpaRepository;

public interface %s extends JpaRepository<%s, Long> {

}
]]

spring_templates.entity = [[
package %s;

import %s.persistence.*;

@Entity
public class %s {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
}
]]

spring_templates.mapper = [[
package %s;

public interface %s {

}
]]

spring_templates.config = [[
package %s;

import org.springframework.context.annotation.Configuration;

@Configuration
public class %s {

}
]]

spring_templates.exception = [[
package %s;

public class %s extends RuntimeException {

    public %s(String message) {
        super(message);
    }
}
]]

spring_templates.exception_handler = [[
package %s;

import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class %s {

}
]]

local SPRING_PACKAGES = {
  ["Controller"] = "controller",
  ["Service"] = "service",
  ["Repository"] = "repository",
  ["Entity"] = "model",
  ["DTO Request"] = "dto",
  ["DTO Response"] = "dto",
  ["Mapper"] = "mapper",
  ["Config"] = "config",
  ["Exception"] = "exception",
  ["Exception Handler"] = "exception",
}

local function dto_fields(fields)
  local lines = {}
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("    private %s %s;", field.type, field.name))
  end
  return table.concat(lines, "\n")
end

local function dto_default_constructor(class_name)
  return string.format("    public %s() {\n    }", class_name)
end

local function dto_constructor(class_name, fields)
  local params = {}
  local assignments = {}
  for _, field in ipairs(fields) do
    table.insert(params, string.format("%s %s", field.type, field.name))
    table.insert(assignments, string.format("        this.%s = %s;", field.name, field.name))
  end
  return string.format("    public %s(%s) {\n%s\n    }", class_name, table.concat(params, ", "), table.concat(assignments, "\n"))
end

local function dto_accessors(fields)
  local blocks = {}
  for _, field in ipairs(fields) do
    local capitalized = utils().capitalize(field.name)
    table.insert(
      blocks,
      string.format("    public %s get%s() {\n        return %s;\n    }", field.type, capitalized, field.name)
    )
    table.insert(
      blocks,
      string.format(
        "    public void set%s(%s %s) {\n        this.%s = %s;\n    }",
        capitalized,
        field.type,
        field.name,
        field.name,
        field.name
      )
    )
  end
  return table.concat(blocks, "\n\n")
end

local function dto_class(package, class_name, fields)
  return string.format(
    [[
package %s;

public class %s {

%s

%s

%s

%s
}
]],
    package,
    class_name,
    dto_fields(fields),
    dto_default_constructor(class_name),
    dto_constructor(class_name, fields),
    dto_accessors(fields)
  )
end

local function dto_record(package, class_name, fields)
  local lines = {}
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("    %s %s", field.type, field.name))
  end
  return string.format(
    [[
package %s;

public record %s(
%s
) {}
]],
    package,
    class_name,
    table.concat(lines, ",\n")
  )
end

local function render_spring_template(kind, name, options)
  options = options or {}
  local jutils = utils()
  local base_package = options.base_package or jutils.get_base_package()
  local target_package = base_package .. "." .. SPRING_PACKAGES[kind]
  local endpoint = jutils.entity_to_endpoint(name)
  local java_version = options.java_version
  if java_version == nil then
    java_version = jutils.get_java_version()
  end
  local use_record = (java_version or 0) >= RECORD_MIN_VERSION
  local class_name
  local content

  if kind == "Controller" then
    class_name = name .. "Controller"
    content = string.format(spring_templates.controller, target_package, endpoint, class_name)
  elseif kind == "Service" then
    class_name = name .. "Service"
    content = string.format(
      spring_templates.service,
      target_package,
      base_package,
      name,
      base_package,
      name,
      class_name,
      name,
      class_name,
      name,
      name,
      name,
      name,
      name,
      name,
      name
    )
  elseif kind == "Repository" then
    class_name = name .. "Repository"
    content = string.format(spring_templates.repository, target_package, base_package, name, class_name, name)
  elseif kind == "Entity" then
    class_name = name
    local namespace = options.namespace or jutils.get_jakarta_namespace(java_version)
    content = string.format(spring_templates.entity, target_package, namespace, class_name)
  elseif kind == "DTO Request" then
    class_name = name .. "RequestDTO"
    local fields = {
      { name = "name", type = "String" },
      { name = "email", type = "String" },
    }
    content = use_record and dto_record(target_package, class_name, fields) or dto_class(target_package, class_name, fields)
  elseif kind == "DTO Response" then
    class_name = name .. "ResponseDTO"
    local fields = {
      { name = "id", type = "Long" },
      { name = "name", type = "String" },
      { name = "email", type = "String" },
    }
    content = use_record and dto_record(target_package, class_name, fields) or dto_class(target_package, class_name, fields)
  elseif kind == "Mapper" then
    class_name = name .. "Mapper"
    content = string.format(spring_templates.mapper, target_package, class_name)
  elseif kind == "Config" then
    class_name = name .. "Config"
    content = string.format(spring_templates.config, target_package, class_name)
  elseif kind == "Exception" then
    class_name = name .. "Exception"
    content = string.format(spring_templates.exception, target_package, class_name, class_name)
  elseif kind == "Exception Handler" then
    class_name = name .. "ExceptionHandler"
    content = string.format(spring_templates.exception_handler, target_package, class_name)
  else
    return nil
  end

  return {
    class_name = class_name,
    content = content,
    package = target_package,
    java_version = java_version,
  }
end

function M.render(kind, name, options)
  if not SPRING_PACKAGES[kind] then
    return nil
  end
  return render_spring_template(kind, name, options)
end

local function generate_spring_template(kind, name)
  local rendered = M.render(kind, name)
  if not rendered then
    vim.notify("Unknown template: " .. kind, vim.log.levels.ERROR)
    return
  end

  local jutils = utils()
  local dir = jutils.get_project_root() .. "/src/main/java/" .. rendered.package:gsub("%.", "/")
  jutils.write_java_file(dir, rendered.class_name, rendered.content, rendered.java_version)
end

function M.spring_boot_generator()
  local options = {
    "Controller",
    "Service",
    "Repository",
    "Entity",
    "DTO Request",
    "DTO Response",
    "Mapper",
    "Config",
    "Exception",
    "Exception Handler",
  }

  local version = utils().get_java_version()
  local prompt = string.format("Generate Spring Boot file (Java %s):", version or "?")

  vim.ui.select(options, { prompt = prompt }, function(choice)
    if not choice then
      return
    end

    vim.ui.input({ prompt = "Class name (e.g., User): " }, function(name)
      if not name or name == "" then
        return
      end
      generate_spring_template(choice, name)
    end)
  end)
end

return M
