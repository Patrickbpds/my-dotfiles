local M = {}

local RECORD_MIN_VERSION = 16

local function utils()
  return require("java.utils")
end

local function split_fields(input)
  local parts = {}
  local depth = 0
  local start = 1

  for i = 1, #input do
    local char = input:sub(i, i)
    if char == "<" then
      depth = depth + 1
    elseif char == ">" then
      depth = depth - 1
    elseif char == "," and depth == 0 then
      table.insert(parts, input:sub(start, i - 1))
      start = i + 1
    end
  end

  table.insert(parts, input:sub(start))
  return parts
end

local function parse_fields(input)
  local fields = {}
  local errors = {}

  if input and input ~= "" then
    for _, field_def in ipairs(split_fields(input)) do
      local field_name, field_type = field_def:match("^%s*([^:]+):([^:]+)%s*$")
      if not field_name or not field_type then
        table.insert(errors, "invalid field: " .. vim.trim(field_def))
      else
        field_name = vim.trim(field_name)
        field_type = vim.trim(field_type)
        if not utils().is_valid_java_identifier(field_name) then
          table.insert(errors, "invalid field name: " .. field_name)
        elseif not utils().is_valid_java_type(field_type) then
          table.insert(errors, "invalid field type: " .. field_type)
        else
          table.insert(fields, { name = field_name, type = field_type })
        end
      end
    end
  end

  return fields, errors
end

local function fields_block(fields)
  local lines = {}
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("    private %s %s;", field.type, field.name))
  end
  return table.concat(lines, "\n")
end

local function accessors_block(fields)
  local lines = {}

  local function getter(field_type, name)
    return string.format(
      [[
    public %s get%s() {
        return %s;
    }
]],
      field_type,
      utils().capitalize(name),
      name
    )
  end

  local function setter(field_type, name)
    return string.format(
      [[
    public void set%s(%s %s) {
        this.%s = %s;
    }
]],
      utils().capitalize(name),
      field_type,
      name,
      name,
      name
    )
  end

  table.insert(lines, getter("Long", "id"))
  table.insert(lines, setter("Long", "id"))
  for _, field in ipairs(fields) do
    table.insert(lines, getter(field.type, field.name))
    table.insert(lines, setter(field.type, field.name))
  end
  return table.concat(lines, "\n")
end

local function dto_accessor(field, use_record)
  if use_record then
    return field.name .. "()"
  end
  return "get" .. utils().capitalize(field.name) .. "()"
end

local function field_setter_calls(fields, var, use_record)
  local lines = {}
  for _, field in ipairs(fields) do
    table.insert(
      lines,
      string.format("        %s.set%s(dto.%s);", var, utils().capitalize(field.name), dto_accessor(field, use_record))
    )
  end
  return table.concat(lines, "\n")
end

local function to_dto_args(fields)
  local lines = { "            entity.getId()" }
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("            entity.get%s()", utils().capitalize(field.name)))
  end
  return table.concat(lines, ",\n")
end

local function build_entity(base_package, name, fields, use_lombok, namespace)
  local entity_fields = fields_block(fields)
  local table_name = name:lower()

  if use_lombok then
    return string.format(
      [[
package %s.model;

import %s.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "%s")
public class %s {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

%s
}
]],
      base_package,
      namespace,
      table_name,
      name,
      entity_fields
    )
  end

  local ctor_params = { "Long id" }
  local ctor_assignments = { "        this.id = id;" }
  for _, field in ipairs(fields) do
    table.insert(ctor_params, string.format("%s %s", field.type, field.name))
    table.insert(ctor_assignments, string.format("        this.%s = %s;", field.name, field.name))
  end

  return string.format(
    [[
package %s.model;

import %s.persistence.*;

@Entity
@Table(name = "%s")
public class %s {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

%s

    public %s() {
    }

    public %s(%s) {
%s
    }

%s}
]],
    base_package,
    namespace,
    table_name,
    name,
    entity_fields,
    name,
    name,
    table.concat(ctor_params, ", "),
    table.concat(ctor_assignments, "\n"),
    accessors_block(fields)
  )
end

local function build_repository(base_package, name)
  return string.format(
    [[
package %s.repository;

import %s.model.%s;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface %sRepository extends JpaRepository<%s, Long> {

}
]],
    base_package,
    base_package,
    name,
    name,
    name
  )
end

local function dto_fields(fields)
  local lines = {}
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("    private %s %s;", field.type, field.name))
  end
  return table.concat(lines, "\n")
end

local function dto_constructor_params(fields)
  local params = {}
  for _, field in ipairs(fields) do
    table.insert(params, string.format("%s %s", field.type, field.name))
  end
  return table.concat(params, ", ")
end

local function dto_constructor_body(fields)
  local lines = {}
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("        this.%s = %s;", field.name, field.name))
  end
  return table.concat(lines, "\n")
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

local function build_dto_class(base_package, class_name, fields)
  return string.format(
    [[
package %s.dto;

public class %s {

%s

    public %s() {
    }

    public %s(%s) {
%s
    }

%s
}
]],
    base_package,
    class_name,
    dto_fields(fields),
    class_name,
    class_name,
    dto_constructor_params(fields),
    dto_constructor_body(fields),
    dto_accessors(fields)
  )
end

local function build_dto_request(base_package, name, fields, use_record)
  local class_name = name .. "RequestDTO"
  if not use_record then
    return build_dto_class(base_package, class_name, fields)
  end

  local lines = {}
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("    %s %s", field.type, field.name))
  end
  return string.format(
    [[
package %s.dto;

public record %s(
%s
) {}
]],
    base_package,
    class_name,
    table.concat(lines, ",\n")
  )
end

local function build_dto_response(base_package, name, fields, use_record)
  local class_name = name .. "ResponseDTO"
  local response_fields = { { name = "id", type = "Long" } }
  vim.list_extend(response_fields, fields)

  if not use_record then
    return build_dto_class(base_package, class_name, response_fields)
  end

  local lines = {}
  for _, field in ipairs(response_fields) do
    table.insert(lines, string.format("    %s %s", field.type, field.name))
  end
  return string.format(
    [[
package %s.dto;

public record %s(
%s
) {}
]],
    base_package,
    class_name,
    table.concat(lines, ",\n")
  )
end

local function build_service(base_package, name, fields, use_record)
  local create_setters = field_setter_calls(fields, "entity", use_record)
  local update_setters = field_setter_calls(fields, "entity", use_record)
  local dto_args = to_dto_args(fields)
  local collect_import = use_record and "" or "import java.util.stream.Collectors;\n"
  local collect_suffix = use_record and ".toList()" or ".collect(Collectors.toList())"

  return string.format(
    [[
package %s.service;

import %s.dto.%sRequestDTO;
import %s.dto.%sResponseDTO;
import %s.model.%s;
import %s.repository.%sRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
%s
@Service
public class %sService {

    private final %sRepository repository;

    public %sService(%sRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public %sResponseDTO create(%sRequestDTO dto) {
        %s entity = new %s();
%s
        entity = repository.save(entity);
        return toDTO(entity);
    }

    @Transactional(readOnly = true)
    public List<%sResponseDTO> findAll() {
        return repository.findAll().stream()
                .map(this::toDTO)
                %s;
    }

    @Transactional(readOnly = true)
    public %sResponseDTO findById(Long id) {
        return repository.findById(id)
                .map(this::toDTO)
                .orElseThrow(() -> new RuntimeException("%s not found with id: " + id));
    }

    @Transactional
    public %sResponseDTO update(Long id, %sRequestDTO dto) {
        %s entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("%s not found with id: " + id));
%s
        entity = repository.save(entity);
        return toDTO(entity);
    }

    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new RuntimeException("%s not found with id: " + id);
        }
        repository.deleteById(id);
    }

    private %sResponseDTO toDTO(%s entity) {
        return new %sResponseDTO(
%s
        );
    }
}
]],
    base_package,
    base_package,
    name,
    base_package,
    name,
    base_package,
    name,
    base_package,
    name,
    collect_import,
    name,
    name,
    name,
    name,
    name,
    name,
    name,
    name,
    create_setters,
    name,
    collect_suffix,
    name,
    name,
    name,
    name,
    name,
    name,
    update_setters,
    name,
    name,
    name,
    name,
    dto_args
  )
end

local function build_controller(base_package, name, namespace)
  local endpoint = utils().entity_to_endpoint(name)
  return string.format(
    [[
package %s.controller;

import %s.dto.%sRequestDTO;
import %s.dto.%sResponseDTO;
import %s.service.%sService;
import %s.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/%s")
public class %sController {

    private final %sService service;

    public %sController(%sService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<%sResponseDTO> create(@Valid @RequestBody %sRequestDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(dto));
    }

    @GetMapping
    public ResponseEntity<List<%sResponseDTO>> findAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<%sResponseDTO> findById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<%sResponseDTO> update(@PathVariable Long id, @Valid @RequestBody %sRequestDTO dto) {
        return ResponseEntity.ok(service.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
]],
    base_package,
    base_package,
    name,
    base_package,
    name,
    base_package,
    name,
    namespace,
    endpoint,
    name,
    name,
    name,
    name,
    name,
    name,
    name,
    name,
    name,
    name
  )
end

function M.build_files(name, fields, options)
  options = options or {}
  local jutils = utils()
  local base_package = options.base_package or jutils.get_base_package()
  local java_version = options.java_version
  if java_version == nil then
    java_version = jutils.get_java_version()
  end
  local use_record = options.record
  if use_record == nil then
    use_record = (java_version or 0) >= RECORD_MIN_VERSION
  end
  local namespace = options.namespace or jutils.get_jakarta_namespace(java_version)
  local lombok = options.lombok == true

  return {
    base_package = base_package,
    files = {
      { sub = "model", filename = name, content = build_entity(base_package, name, fields, lombok, namespace) },
      { sub = "repository", filename = name .. "Repository", content = build_repository(base_package, name) },
      {
        sub = "dto",
        filename = name .. "RequestDTO",
        content = build_dto_request(base_package, name, fields, use_record),
      },
      {
        sub = "dto",
        filename = name .. "ResponseDTO",
        content = build_dto_response(base_package, name, fields, use_record),
      },
      { sub = "service", filename = name .. "Service", content = build_service(base_package, name, fields, use_record) },
      { sub = "controller", filename = name .. "Controller", content = build_controller(base_package, name, namespace) },
    },
  }
end

function M.generate_crud()
  vim.ui.input({ prompt = "Entity name (e.g., Product): " }, function(raw_name)
    if not raw_name or raw_name == "" then
      return
    end

    local name = utils().to_pascal_case(raw_name)
    if name == "" then
      vim.notify("Invalid entity name", vim.log.levels.ERROR)
      return
    end

    vim.ui.input({ prompt = "Fields (e.g., name:String,price:Double,active:Boolean): " }, function(fields_input)
      local fields = parse_fields(fields_input)

      vim.ui.select({ "Yes", "No" }, { prompt = "Use Lombok (@Data)?" }, function(use_lombok)
        if not use_lombok then
          return
        end

        local jutils = utils()
        local version = jutils.get_java_version()
        local use_record = (version or 0) >= RECORD_MIN_VERSION
        local built = M.build_files(name, fields, {
          record = use_record,
          namespace = jutils.get_jakarta_namespace(),
          lombok = use_lombok == "Yes",
        })

        local created = {}
        for _, file in ipairs(built.files) do
          local dir = jutils.get_project_root() .. "/src/main/java/" .. built.base_package:gsub("%.", "/") .. "/" .. file.sub
          local content = file.content
          if version then
            content = string.format("// Generated for Java %d\n%s", version, content)
          end
          if jutils.write_file(dir .. "/" .. file.filename .. ".java", content) then
            table.insert(created, file.filename .. ".java")
          end
        end

        vim.notify(
          string.format(
            "Generated CRUD for %s (Java %s, %s, %s Lombok)\nFiles: %s",
            name,
            version or "?",
            use_record and "records" or "classes",
            use_lombok == "Yes" and "with" or "without",
            table.concat(created, ", ")
          ),
          vim.log.levels.INFO
        )
      end)
    end)
  end)
end

return M
