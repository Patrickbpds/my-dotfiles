local M = {}

local function utils()
  return require("plugins.java.java-utils")
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

import jakarta.persistence.*;

@Entity
public class %s {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
}
]]

spring_templates.dto_request = [[
package %s;

public record %s(
    String name,
    String email
) {}
]]

spring_templates.dto_response = [[
package %s;

public record %s(
    Long id,
    String name,
    String email
) {}
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

local function generate_spring_template(kind, name)
  local jutils = utils()
  local base_package = jutils.get_base_package()
  local target_package = base_package .. "." .. SPRING_PACKAGES[kind]
  local endpoint = jutils.entity_to_endpoint(name)
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
    content = string.format(spring_templates.entity, target_package, class_name)
  elseif kind == "DTO Request" then
    class_name = name .. "RequestDTO"
    content = string.format(spring_templates.dto_request, target_package, class_name)
  elseif kind == "DTO Response" then
    class_name = name .. "ResponseDTO"
    content = string.format(spring_templates.dto_response, target_package, class_name)
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
    vim.notify("Unknown template: " .. kind, vim.log.levels.ERROR)
    return
  end

  local root = jutils.get_project_root()
  local dir = root .. "/src/main/java/" .. target_package:gsub("%.", "/")
  jutils.write_java_file(dir, class_name, content)
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

  vim.ui.select(options, { prompt = "Generate Spring Boot file:" }, function(choice)
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
