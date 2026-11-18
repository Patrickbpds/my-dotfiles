local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
package.path = root .. "/?.lua;" .. package.path

local helpers = require("tests.helpers")
local spring = require("plugins.java.templates.springboot-files")

helpers.with_project({
  ["pom.xml"] = "<project><properties><java.version>1.8</java.version></properties></project>",
}, function()
  local entity = spring.render("Entity", "User", { base_package = "com.example" })
  assert(entity.content:find("import javax.persistence.*", 1, true), "java 8 entity uses javax")

  local request = spring.render("DTO Request", "User", { base_package = "com.example", java_version = 8 })
  assert(request.content:find("public class UserRequestDTO", 1, true), "java 8 request dto is a class")
  assert(request.content:find("public String getName()", 1, true), "java 8 request dto has getters")
  assert(not request.content:find("public record", 1, true), "java 8 request dto is not a record")
end)

helpers.with_project({
  ["pom.xml"] = table.concat({
    "<project>",
    "  <parent>",
    "    <groupId>org.springframework.boot</groupId>",
    "    <artifactId>spring-boot-starter-parent</artifactId>",
    "    <version>3.2.5</version>",
    "  </parent>",
    "  <properties>",
    "    <java.version>17</java.version>",
    "  </properties>",
    "</project>",
  }, "\n"),
}, function()
  local entity = spring.render("Entity", "User", { base_package = "com.example" })
  assert(entity.content:find("import jakarta.persistence.*", 1, true), "spring boot 3 entity uses jakarta")

  local response = spring.render("DTO Response", "User", { base_package = "com.example" })
  assert(response.content:find("public record UserResponseDTO", 1, true), "java 17 response dto is a record")
  assert(response.content:find("Long id", 1, true), "response dto has id")
end)

helpers.with_project({
  ["pom.xml"] = table.concat({
    "<project>",
    "  <parent>",
    "    <groupId>org.springframework.boot</groupId>",
    "    <artifactId>spring-boot-starter-parent</artifactId>",
    "    <version>2.7.18</version>",
    "  </parent>",
    "  <properties>",
    "    <java.version>17</java.version>",
    "  </properties>",
    "</project>",
  }, "\n"),
}, function()
  local entity = spring.render("Entity", "User", { base_package = "com.example" })
  assert(entity.content:find("import javax.persistence.*", 1, true), "spring boot 2 entity uses javax")

  local request = spring.render("DTO Request", "User", { base_package = "com.example" })
  assert(request.content:find("public record UserRequestDTO", 1, true), "java 17 request dto is a record")
end)

assert(spring.render("Unknown", "User", {}) == nil, "unknown template rejected")

helpers.with_project({}, function()
  local entity = spring.render("Entity", "User", { base_package = "com.example", java_version = 8 })
  assert(entity.content:find("import javax.persistence.*", 1, true), "explicit java 8 uses javax")

  local modern_entity = spring.render("Entity", "User", { base_package = "com.example", java_version = 17 })
  assert(modern_entity.content:find("import jakarta.persistence.*", 1, true), "explicit java 17 uses jakarta")
end)

for _, kind in ipairs({
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
}) do
  local rendered = spring.render(kind, "User", { base_package = "com.example", java_version = 17, namespace = "jakarta" })
  assert(rendered and rendered.content and #rendered.content > 0, kind .. " rendered")
  assert(rendered.package:find("^com%.example%."), kind .. " package")
end

print("ok")
vim.cmd("qa!")
