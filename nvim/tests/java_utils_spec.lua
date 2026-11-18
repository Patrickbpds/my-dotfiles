local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
package.path = root .. "/?.lua;" .. package.path

local helpers = require("tests.helpers")
local utils = require("plugins.java.java-utils")

helpers.with_project({
  ["pom.xml"] = "<project><properties><java.version>1.8</java.version></properties></project>",
}, function()
  helpers.assert_equal(utils.get_java_version(), 8, "maven java.version 1.8")
  helpers.assert_equal(utils.get_base_package(), "com.example", "empty project base package")
  helpers.assert_equal(utils.get_resources_dir(), vim.uv.cwd() .. "/src/main/resources", "resources dir")
end)

helpers.with_project({
  ["pom.xml"] = "<project><properties><maven.compiler.release>17</maven.compiler.release></properties></project>",
}, function()
  helpers.assert_equal(utils.get_java_version(), 17, "maven compiler release")
end)

helpers.with_project({
  ["pom.xml"] = "<project><properties><maven.compiler.source>11</maven.compiler.source></properties></project>",
}, function()
  helpers.assert_equal(utils.get_java_version(), 11, "maven compiler source")
end)

helpers.with_project({
  ["build.gradle"] = "java { sourceCompatibility = JavaVersion.VERSION_1_8 }",
}, function()
  helpers.assert_equal(utils.get_java_version(), 8, "gradle JavaVersion 1.8")
end)

helpers.with_project({
  ["build.gradle.kts"] = "java { sourceCompatibility = JavaVersion.VERSION_17 }",
}, function()
  helpers.assert_equal(utils.get_java_version(), 17, "gradle kotlin JavaVersion 17")
end)

helpers.with_project({
  ["build.gradle"] = "java { sourceCompatibility = '21' }",
}, function()
  helpers.assert_equal(utils.get_java_version(), 21, "gradle quoted version")
end)

helpers.with_project({
  ["pom.xml"] = "<project/>",
  ["src/main/java/com/example/Foo.java"] = "package com.example;\n",
}, function(dir)
  vim.cmd("edit " .. vim.fn.fnameescape(dir .. "/src/main/java/com/example/Foo.java"))
  local outside = vim.fn.tempname()
  vim.fn.mkdir(outside, "p")
  vim.cmd("cd " .. vim.fn.fnameescape(outside))
  helpers.assert_equal(utils.get_project_root(), dir, "buffer project root")
  vim.fn.delete(outside, "rf")
end)

helpers.with_project({}, function()
  local fake_home = vim.fn.tempname()
  helpers.write(fake_home .. "/release", 'JAVA_VERSION="1.8.0_402"')
  local previous = vim.env.JAVA_HOME
  vim.env.JAVA_HOME = fake_home
  helpers.assert_equal(utils.get_java_version(), 8, "java 8 release")
  vim.env.JAVA_HOME = previous
  vim.fn.delete(fake_home, "rf")
end)

helpers.with_project({}, function()
  local previous_home = vim.env.JAVA_HOME
  local previous_path = vim.env.PATH
  vim.env.JAVA_HOME = nil
  vim.env.PATH = "/nonexistent"
  helpers.assert_equal(utils.get_java_version(), nil, "missing java version")
  vim.env.JAVA_HOME = previous_home
  vim.env.PATH = previous_path
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
  helpers.assert_equal(utils.get_spring_boot_version(), "3.2.5", "maven spring boot version")
  helpers.assert_equal(utils.uses_jakarta(), true, "maven spring boot 3 jakarta")
  helpers.assert_equal(utils.get_jakarta_namespace(), "jakarta", "maven spring boot namespace")
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
  helpers.assert_equal(utils.get_spring_boot_version(), "2.7.18", "maven spring boot 2 version")
  helpers.assert_equal(utils.uses_jakarta(), false, "maven spring boot 2 javax")
end)

helpers.with_project({
  ["build.gradle"] = "plugins { id 'org.springframework.boot' version '3.3.0' }",
}, function()
  helpers.assert_equal(utils.get_spring_boot_version(), "3.3.0", "gradle spring boot version")
  helpers.assert_equal(utils.uses_jakarta(), true, "gradle spring boot 3 jakarta")
end)

helpers.with_project({
  ["build.gradle.kts"] = 'plugins { id("org.springframework.boot") version "2.7.18" }',
}, function()
  helpers.assert_equal(utils.get_spring_boot_version(), "2.7.18", "gradle kotlin spring boot version")
  helpers.assert_equal(utils.uses_jakarta(), false, "gradle kotlin spring boot 2 javax")
end)

helpers.with_project({
  ["pom.xml"] = "<project><properties><spring-boot.version>3.1.0</spring-boot.version></properties></project>",
}, function()
  helpers.assert_equal(utils.get_spring_boot_version(), "3.1.0", "spring boot property version")
end)

helpers.with_project({
  ["pom.xml"] = "<project><properties><java.version>17</java.version></properties></project>",
  ["src/main/java/com/example/Legacy.java"] = "package com.example;\n\nimport javax.persistence.Entity;\n",
}, function()
  helpers.assert_equal(utils.uses_jakarta(), false, "source javax fallback")
end)

helpers.with_project({
  ["pom.xml"] = "<project><properties><java.version>17</java.version></properties></project>",
  ["src/main/java/com/example/Modern.java"] = "package com.example;\n\nimport jakarta.persistence.Entity;\n",
}, function()
  helpers.assert_equal(utils.uses_jakarta(), true, "source jakarta fallback")
end)

helpers.with_project({
  ["pom.xml"] = "<project><properties><java.version>11</java.version></properties></project>",
}, function()
  helpers.assert_equal(utils.uses_jakarta(), false, "java 11 fallback")
end)

helpers.with_project({}, function()
  local fake_home = vim.fn.tempname()
  helpers.write(fake_home .. "/release", 'JAVA_VERSION="17.0.10"')
  local previous = vim.env.JAVA_HOME
  vim.env.JAVA_HOME = fake_home

  local runtimes = utils.get_jdk_runtimes()
  local detected
  for _, runtime in ipairs(runtimes) do
    if runtime.path == fake_home then
      detected = runtime
      break
    end
  end

  assert(detected, "fake jdk detected")
  helpers.assert_equal(detected.name, "JavaSE-17", "runtime name")

  vim.env.JAVA_HOME = previous
  vim.fn.delete(fake_home, "rf")
end)

print("ok")
vim.cmd("qa!")
