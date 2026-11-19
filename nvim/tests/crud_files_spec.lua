local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
package.path = root .. "/?.lua;" .. package.path

local helpers = require("tests.helpers")
local crud = require("java.templates.crud-files")

local fields = {
  { name = "name", type = "String" },
  { name = "price", type = "Double" },
}

local function file(files, filename)
  for _, item in ipairs(files) do
    if item.filename == filename then
      return item
    end
  end
end

local legacy = crud.build_files("Product", fields, {
  base_package = "com.example",
  record = false,
  namespace = "javax",
  lombok = false,
})

assert(legacy.files, "legacy files generated")
helpers.assert_equal(legacy.base_package, "com.example", "legacy base package")

local legacy_entity = file(legacy.files, "Product")
assert(legacy_entity.content:find("import javax.persistence.*", 1, true), "legacy entity uses javax")

local legacy_request = file(legacy.files, "ProductRequestDTO")
assert(legacy_request.content:find("public class ProductRequestDTO", 1, true), "legacy request dto is a class")
assert(legacy_request.content:find("public String getName()", 1, true), "legacy request dto has getters")

local legacy_service = file(legacy.files, "ProductService")
assert(legacy_service.content:find("import java.util.stream.Collectors;", 1, true), "legacy service imports Collectors")
assert(legacy_service.content:find(".collect(Collectors.toList())", 1, true), "legacy service collects a list")
assert(legacy_service.content:find("dto.getName()", 1, true), "legacy service uses getters")

local legacy_controller = file(legacy.files, "ProductController")
assert(legacy_controller.content:find("import javax.validation.Valid;", 1, true), "legacy controller uses javax")

local modern = crud.build_files("Product", fields, {
  base_package = "com.example",
  record = true,
  namespace = "jakarta",
  lombok = true,
})

local modern_entity = file(modern.files, "Product")
assert(modern_entity.content:find("import jakarta.persistence.*", 1, true), "modern entity uses jakarta")
assert(modern_entity.content:find("import lombok.Data;", 1, true), "modern entity uses lombok")

local modern_request = file(modern.files, "ProductRequestDTO")
assert(modern_request.content:find("public record ProductRequestDTO", 1, true), "modern request dto is a record")

local modern_service = file(modern.files, "ProductService")
assert(modern_service.content:find(".toList()", 1, true), "modern service uses Stream.toList")
assert(not modern_service.content:find("Collectors", 1, true), "modern service skips Collectors")
assert(modern_service.content:find("dto.name()", 1, true), "modern service uses record accessors")

local modern_controller = file(modern.files, "ProductController")
assert(modern_controller.content:find("import jakarta.validation.Valid;", 1, true), "modern controller uses jakarta")

local invalid_name = crud.build_files("123", fields, {
  base_package = "com.example",
  record = false,
  namespace = "javax",
  lombok = false,
})
assert(invalid_name == nil, "invalid entity name rejected")

local duplicate, duplicate_error = crud.build_files("Product", {
  { name = "name", type = "String" },
  { name = "name", type = "String" },
}, {
  base_package = "com.example",
  record = false,
  namespace = "javax",
  lombok = false,
})
assert(duplicate == nil and duplicate_error, "duplicate field rejected")

local invalid_field, field_error = crud.build_files("Product", {
  { name = "class", type = "String" },
}, {
  base_package = "com.example",
  record = false,
  namespace = "javax",
  lombok = false,
})
assert(invalid_field == nil and field_error, "invalid field name rejected")

local invalid_type, type_error = crud.build_files("Product", {
  { name = "price", type = "String;" },
}, {
  base_package = "com.example",
  record = false,
  namespace = "javax",
  lombok = false,
})
assert(invalid_type == nil and type_error, "invalid field type rejected")

local normalized = crud.build_files("user_profile", fields, {
  base_package = "com.example",
  record = false,
  namespace = "javax",
  lombok = false,
})
assert(normalized and normalized.files[1].filename == "UserProfile", "entity name normalized")

print("ok")
vim.cmd("qa!")
