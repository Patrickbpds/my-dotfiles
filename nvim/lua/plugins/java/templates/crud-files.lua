local M = {}

local function utils()
  return require("plugins.java.java-utils")
end

local function parse_fields(input)
  local fields = {}
  if input and input ~= "" then
    for field_def in input:gmatch("[^,]+") do
      local field_name, field_type = field_def:match("([^:]+):([^:]+)")
      if field_name and field_type then
        table.insert(fields, {
          name = vim.trim(field_name),
          type = vim.trim(field_type),
        })
      end
    end
  end
  return fields
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

  local function getter(type, name)
    return string.format(
      [[
    public %s get%s() {
        return %s;
    }
]],
      type,
      utils().capitalize(name),
      name
    )
  end

  local function setter(type, name)
    return string.format(
      [[
    public void set%s(%s %s) {
        this.%s = %s;
    }
]],
      utils().capitalize(name),
      type,
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

local function field_setter_calls(fields, var)
  local lines = {}
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("        %s.set%s(dto.%s());", var, utils().capitalize(field.name), field.name))
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

local function build_entity(base_package, name, fields, use_lombok)
  local entity_fields = fields_block(fields)
  local table_name = name:lower()

  if use_lombok then
    return string.format(
      [[
package %s.model;

import jakarta.persistence.*;
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

import jakarta.persistence.*;

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

local function build_dto_request(base_package, name, fields)
  local lines = {}
  for i, field in ipairs(fields) do
    lines[i] = string.format("    %s %s", field.type, field.name)
  end
  return string.format(
    [[
package %s.dto;

public record %sRequestDTO(
%s
) {}
]],
    base_package,
    name,
    table.concat(lines, ",\n")
  )
end

local function build_dto_response(base_package, name, fields)
  local lines = { "    Long id" }
  for _, field in ipairs(fields) do
    table.insert(lines, string.format("    %s %s", field.type, field.name))
  end
  return string.format(
    [[
package %s.dto;

public record %sResponseDTO(
%s
) {}
]],
    base_package,
    name,
    table.concat(lines, ",\n")
  )
end

local function build_service(base_package, name, fields)
  local create_setters = field_setter_calls(fields, "entity")
  local update_setters = field_setter_calls(fields, "entity")
  local dto_args = to_dto_args(fields)

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
                .toList();
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

local function build_controller(base_package, name, fields)
  local endpoint = utils().entity_to_endpoint(name)
  return string.format(
    [[
package %s.controller;

import %s.dto.%sRequestDTO;
import %s.dto.%sResponseDTO;
import %s.service.%sService;
import jakarta.validation.Valid;
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
        local base_package = jutils.get_base_package()
        local project_root = jutils.get_project_root()
        local lombok = use_lombok == "Yes"

        local files = {
          { sub = "model", filename = name, content = build_entity(base_package, name, fields, lombok) },
          { sub = "repository", filename = name .. "Repository", content = build_repository(base_package, name) },
          { sub = "dto", filename = name .. "RequestDTO", content = build_dto_request(base_package, name, fields) },
          { sub = "dto", filename = name .. "ResponseDTO", content = build_dto_response(base_package, name, fields) },
          { sub = "service", filename = name .. "Service", content = build_service(base_package, name, fields) },
          {
            sub = "controller",
            filename = name .. "Controller",
            content = build_controller(base_package, name, fields),
          },
        }

        local created = {}
        for _, file in ipairs(files) do
          local dir = project_root .. "/src/main/java/" .. base_package:gsub("%.", "/") .. "/" .. file.sub
          if jutils.write_file(dir .. "/" .. file.filename .. ".java", file.content) then
            table.insert(created, file.filename .. ".java")
          end
        end

        vim.notify(
          string.format(
            "Generated CRUD for %s (%s Lombok)\nFiles: %s",
            name,
            lombok and "with" or "without",
            table.concat(created, ", ")
          ),
          vim.log.levels.INFO
        )
      end)
    end)
  end)
end

return M
