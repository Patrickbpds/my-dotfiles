local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
package.path = root .. "/?.lua;" .. package.path

local helpers = require("tests.helpers")
local dependency = require("plugins.java.dependency-management")

helpers.with_project({
  ["pom.xml"] = table.concat({
    "<project>",
    "    <dependencyManagement>",
    "        <dependencies>",
    "            <dependency>",
    "                <groupId>org.springframework.boot</groupId>",
    "                <artifactId>spring-boot-dependencies</artifactId>",
    "                <version>3.2.0</version>",
    "            </dependency>",
    "        </dependencies>",
    "    </dependencyManagement>",
    "    <dependencies>",
    "        <dependency>",
    "            <groupId>com.example</groupId>",
    "            <artifactId>existing</artifactId>",
    "        </dependency>",
    "    </dependencies>",
    "</project>",
  }, "\n"),
}, function(dir)
  local result, err = dependency.insert_maven_dependency("org.apache.commons", "commons-lang3", "3.14.0")
  assert(result, err)

  local text = table.concat(vim.fn.readfile(dir .. "/pom.xml"), "\n")
  local managed_end = text:find("</dependencyManagement>", 1, true)
  local inserted = text:find("<artifactId>commons-lang3</artifactId>", 1, true)
  assert(managed_end, "dependency management closed")
  assert(inserted, "dependency inserted")
  assert(inserted > managed_end, "dependency inserted outside dependencyManagement")

  local duplicate, duplicate_err = dependency.insert_maven_dependency("com.example", "existing", "1.0.0")
  assert(duplicate == nil, "duplicate rejected")
  helpers.assert_equal(duplicate_err, "Dependency already present", "duplicate error")
end)

helpers.with_project({
  ["pom.xml"] = "<project>\n    <dependencies/>\n</project>\n",
}, function(dir)
  local result, err = dependency.insert_maven_dependency("com.example", "lib", "1.0.0")
  assert(result, err)

  local text = table.concat(vim.fn.readfile(dir .. "/pom.xml"), "\n")
  assert(text:find("<dependencies/>", 1, true) == nil, "self closing block replaced")
  assert(text:find("<artifactId>lib</artifactId>", 1, true), "dependency inserted")
end)

helpers.with_project({
  ["pom.xml"] = "<project>\n</project>\n",
}, function(dir)
  local result, err = dependency.insert_maven_dependency("com.example", "lib", "1.0.0")
  assert(result, err)

  local text = table.concat(vim.fn.readfile(dir .. "/pom.xml"), "\n")
  assert(text:find("<dependencies>", 1, true), "dependencies block created")
  assert(text:find("<artifactId>lib</artifactId>", 1, true), "dependency inserted")
end)

helpers.with_project({
  ["build.gradle"] = table.concat({
    "buildscript {",
    "    dependencies {",
    "        classpath 'org.springframework.boot:spring-boot-gradle-plugin:2.7.18'",
    "    }",
    "}",
    "",
    "dependencies {",
    "    implementation 'com.example:existing:1.0.0'",
    "}",
  }, "\n"),
}, function(dir)
  local result, err = dependency.insert_gradle_dependency("org.apache.commons", "commons-lang3", "3.14.0")
  assert(result, err)

  local text = table.concat(vim.fn.readfile(dir .. "/build.gradle"), "\n")
  local buildscript_end = text:find("}\n\ndependencies", 1, true)
  local inserted = text:find("implementation 'org.apache.commons:commons-lang3:3.14.0'", 1, true)
  assert(buildscript_end, "buildscript block closed")
  assert(inserted, "gradle dependency inserted")
  assert(inserted > buildscript_end, "gradle dependency inserted outside buildscript")

  local duplicate, duplicate_err = dependency.insert_gradle_dependency("com.example", "existing", "1.0.0")
  assert(duplicate == nil, "gradle duplicate rejected")
  helpers.assert_equal(duplicate_err, "Dependency already present", "gradle duplicate error")
end)

helpers.with_project({
  ["build.gradle.kts"] = table.concat({
    "dependencies {",
    '    implementation("com.example:existing:1.0.0")',
    "}",
  }, "\n"),
}, function(dir)
  local result, err = dependency.insert_gradle_dependency("com.google.guava", "guava", "33.0.0-jre")
  assert(result, err)

  local text = table.concat(vim.fn.readfile(dir .. "/build.gradle.kts"), "\n")
  assert(text:find('implementation("com.google.guava:guava:33.0.0-jre")', 1, true), "kotlin dependency inserted")
end)

local valid, err = dependency.validate_coordinates("com example", "lib")
assert(not valid, "invalid group rejected")
helpers.assert_equal(err, "Invalid group ID", "invalid group error")

valid, err = dependency.validate_coordinates("com.example", "lib", "1.0/0")
assert(not valid, "invalid version rejected")
helpers.assert_equal(err, "Invalid version", "invalid version error")

print("ok")
vim.cmd("qa!")
