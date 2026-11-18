local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)

local utils = require("plugins.java.java-utils")

local function write(path, content)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

local function with_project(files, fn)
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")

  for path, content in pairs(files) do
    write(dir .. "/" .. path, content)
  end

  local previous = vim.uv.cwd()
  vim.cmd("silent! enew!")
  vim.cmd("cd " .. vim.fn.fnameescape(dir))

  local ok, err = pcall(fn, dir)

  vim.cmd("cd " .. vim.fn.fnameescape(previous))
  vim.fn.delete(dir, "rf")
  assert(ok, err)
end

local function assert_equal(actual, expected, label)
  assert(actual == expected, string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)))
end

with_project({
  ["pom.xml"] = "<project><properties><java.version>1.8</java.version></properties></project>",
}, function()
  assert_equal(utils.get_java_version(), 8, "maven java.version 1.8")
  assert_equal(utils.get_base_package(), "com.example", "empty project base package")
  assert_equal(utils.get_resources_dir(), vim.uv.cwd() .. "/src/main/resources", "resources dir")
end)

with_project({
  ["pom.xml"] = "<project><properties><maven.compiler.release>17</maven.compiler.release></properties></project>",
}, function()
  assert_equal(utils.get_java_version(), 17, "maven compiler release")
end)

with_project({
  ["pom.xml"] = "<project><properties><maven.compiler.source>11</maven.compiler.source></properties></project>",
}, function()
  assert_equal(utils.get_java_version(), 11, "maven compiler source")
end)

with_project({
  ["build.gradle"] = "java { sourceCompatibility = JavaVersion.VERSION_1_8 }",
}, function()
  assert_equal(utils.get_java_version(), 8, "gradle JavaVersion 1.8")
end)

with_project({
  ["build.gradle.kts"] = "java { sourceCompatibility = JavaVersion.VERSION_17 }",
}, function()
  assert_equal(utils.get_java_version(), 17, "gradle kotlin JavaVersion 17")
end)

with_project({
  ["build.gradle"] = "java { sourceCompatibility = '21' }",
}, function()
  assert_equal(utils.get_java_version(), 21, "gradle quoted version")
end)

with_project({
  ["pom.xml"] = "<project/>",
  ["src/main/java/com/example/Foo.java"] = "package com.example;\n",
}, function(dir)
  vim.cmd("edit " .. vim.fn.fnameescape(dir .. "/src/main/java/com/example/Foo.java"))
  local outside = vim.fn.tempname()
  vim.fn.mkdir(outside, "p")
  vim.cmd("cd " .. vim.fn.fnameescape(outside))
  assert_equal(utils.get_project_root(), dir, "buffer project root")
  vim.fn.delete(outside, "rf")
end)

with_project({}, function()
  local fake_home = vim.fn.tempname()
  write(fake_home .. "/release", 'JAVA_VERSION="1.8.0_402"')
  local previous = vim.env.JAVA_HOME
  vim.env.JAVA_HOME = fake_home
  assert_equal(utils.get_java_version(), 8, "java 8 release")
  vim.env.JAVA_HOME = previous
  vim.fn.delete(fake_home, "rf")
end)

with_project({}, function()
  local previous_home = vim.env.JAVA_HOME
  local previous_path = vim.env.PATH
  vim.env.JAVA_HOME = nil
  vim.env.PATH = "/nonexistent"
  assert_equal(utils.get_java_version(), nil, "missing java version")
  vim.env.JAVA_HOME = previous_home
  vim.env.PATH = previous_path
end)

print("ok")
vim.cmd("qa!")
