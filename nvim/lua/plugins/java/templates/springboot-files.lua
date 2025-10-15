local M = {}
-- ============================================================================
-- Spring Boot Templates
-- ============================================================================
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

import org.springframework.stereotype.Service;

@Service
public class %s {

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

-- ============================================================================
-- Generate Spring Boot File
-- ============================================================================
local function generate_spring_template(kind, name, utils)
  local package_name = utils.detect_package()
  local endpoint = name:lower()
  local entity = name
  local class_name
  local content

  if kind == "Controller" then
    class_name = name .. "Controller"
    content = string.format(spring_templates.controller, package_name, endpoint, class_name)
  elseif kind == "Service" then
    class_name = name .. "Service"
    content = string.format(spring_templates.service, package_name, class_name)
  elseif kind == "Repository" then
    class_name = name .. "Repository"
    content = string.format(spring_templates.repository, package_name, package_name, entity, class_name, entity)
  elseif kind == "Entity" then
    class_name = name
    content = string.format(spring_templates.entity, package_name, class_name)
  elseif kind == "DTO Request" then
    class_name = name .. "RequestDTO"
    content = string.format(spring_templates.dto_request, package_name, class_name)
  elseif kind == "DTO Response" then
    class_name = name .. "ResponseDTO"
    content = string.format(spring_templates.dto_response, package_name, class_name)
  elseif kind == "Mapper" then
    class_name = name .. "Mapper"
    content = string.format(spring_templates.mapper, package_name, class_name)
  elseif kind == "Config" then
    class_name = name .. "Config"
    content = string.format(spring_templates.config, package_name, class_name)
  elseif kind == "Exception" then
    class_name = name .. "Exception"
    content = string.format(spring_templates.exception, package_name, class_name, class_name)
  elseif kind == "Exception Handler" then
    class_name = name .. "ExceptionHandler"
    content = string.format(spring_templates.exception_handler, package_name, class_name)
  else
    vim.notify("Template não definido: " .. kind, vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.expand("%:p:h")
  utils.write_java_file(dir, class_name, content)
end

-- ============================================================================
-- Spring Boot Generator Menu
-- ============================================================================
function M.spring_boot_generator(utils)
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
      generate_spring_template(choice, name, utils)
    end)
  end)
end

return M
