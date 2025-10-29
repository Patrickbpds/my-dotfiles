local M = {}

-- ============================================================================
-- ⚙️ PROFILES & CONFIGURATION MANAGEMENT
-- ============================================================================

-- Utility: Check if file exists
local function file_exists(filepath)
  return vim.fn.filereadable(filepath) == 1
end

-- Utility: Read file content safely
local function read_file(filepath)
  if not file_exists(filepath) then
    return nil
  end
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

-- Utility: Write file content safely
local function write_file(filepath, content)
  local dir = vim.fn.fnamemodify(filepath, ":h")
  vim.fn.mkdir(dir, "p")

  local file = io.open(filepath, "w")
  if not file then
    vim.notify("Failed to write file: " .. filepath, vim.log.levels.ERROR)
    return false
  end
  file:write(content)
  file:close()
  return true
end

-- Utility: Get project root
local function get_project_root()
  return vim.fn.getcwd()
end

-- Utility: Get resources directory
local function get_resources_dir()
  return get_project_root() .. "/src/main/resources"
end

-- ============================================================================
-- Profile Detection & Management
-- ============================================================================

-- Detect available profiles from existing files
local function detect_available_profiles()
  local resources_dir = get_resources_dir()
  local profiles = {}

  -- Common profile names to check
  local common_profiles = { "dev", "test", "prod", "local", "staging", "qa" }

  -- Check for application-{profile}.properties/yml files
  for _, profile in ipairs(common_profiles) do
    local props_file = resources_dir .. "/application-" .. profile .. ".properties"
    local yml_file = resources_dir .. "/application-" .. profile .. ".yml"
    local yaml_file = resources_dir .. "/application-" .. profile .. ".yaml"

    if file_exists(props_file) or file_exists(yml_file) or file_exists(yaml_file) then
      table.insert(profiles, profile)
    end
  end

  -- Also scan directory for any other profile files
  local glob_pattern = resources_dir .. "/application-*.{properties,yml,yaml}"
  local files = vim.fn.glob(glob_pattern, false, true)

  for _, file in ipairs(files) do
    local profile = file:match("application%-([^%.]+)%.")
    if profile and not vim.tbl_contains(profiles, profile) then
      table.insert(profiles, profile)
    end
  end

  -- Add custom option for creating new profile
  table.insert(profiles, "[ + Create New Profile ]")

  return profiles
end

-- Get current active profile from application.properties/yml
local function get_active_profile()
  local resources_dir = get_resources_dir()

  -- Check application.properties
  local props_file = resources_dir .. "/application.properties"
  if file_exists(props_file) then
    local content = read_file(props_file)
    if content then
      local profile = content:match("spring%.profiles%.active%s*=%s*([%w_%-]+)")
      if profile then
        return profile
      end
    end
  end

  -- Check application.yml
  local yml_file = resources_dir .. "/application.yml"
  if file_exists(yml_file) then
    local content = read_file(yml_file)
    if content then
      local profile = content:match("active:%s*([%w_%-]+)")
      if profile then
        return profile
      end
    end
  end

  -- Check environment variable
  local env_profile = vim.fn.getenv("SPRING_PROFILES_ACTIVE")
  if env_profile and env_profile ~= vim.NIL then
    return env_profile
  end

  return nil
end

-- Set active profile in application.properties/yml
local function set_active_profile(profile)
  local resources_dir = get_resources_dir()

  -- Try to update application.properties first
  local props_file = resources_dir .. "/application.properties"
  if file_exists(props_file) then
    local content = read_file(props_file)
    if content then
      -- Check if profile setting exists
      if content:match("spring%.profiles%.active") then
        -- Update existing profile
        content = content:gsub("spring%.profiles%.active%s*=%s*[%w_%-]+", "spring.profiles.active=" .. profile)
      else
        -- Add profile setting
        content = content .. "\n# Active Profile\nspring.profiles.active=" .. profile .. "\n"
      end

      if write_file(props_file, content) then
        vim.notify("✓ Active profile set to: " .. profile, vim.log.levels.INFO)
        return true
      end
    end
  end

  -- Try application.yml
  local yml_file = resources_dir .. "/application.yml"
  if file_exists(yml_file) then
    local content = read_file(yml_file)
    if content then
      if content:match("spring:%s*\n%s*profiles:") then
        -- Update existing profile
        content = content:gsub("(spring:%s*\n%s*profiles:%s*\n%s*active:)%s*[%w_%-]+", "%1 " .. profile)
      else
        -- Add profile setting
        content = content .. "\nspring:\n  profiles:\n    active: " .. profile .. "\n"
      end

      if write_file(yml_file, content) then
        vim.notify("✓ Active profile set to: " .. profile, vim.log.levels.INFO)
        return true
      end
    end
  end

  -- If no file exists, create application.properties
  local new_content = string.format(
    [[
# Spring Boot Application Configuration
# Active Profile
spring.profiles.active=%s
]],
    profile
  )

  if write_file(props_file, new_content) then
    vim.notify("✓ Created application.properties with profile: " .. profile, vim.log.levels.INFO)
    return true
  end

  return false
end

-- ============================================================================
-- Profile Operations
-- ============================================================================

-- Switch active profile
local function switch_profile()
  local profiles = detect_available_profiles()

  if #profiles == 0 then
    vim.notify("No profiles found. Create one first!", vim.log.levels.WARN)
    return
  end

  local current_profile = get_active_profile()
  local prompt = "Select profile:"
  if current_profile then
    prompt = "Select profile (current: " .. current_profile .. "):"
  end

  vim.ui.select(profiles, { prompt = prompt }, function(choice)
    if not choice then
      return
    end

    if choice == "[ + Create New Profile ]" then
      M.create_new_profile()
      return
    end

    -- Set environment variable
    vim.fn.setenv("SPRING_PROFILES_ACTIVE", choice)

    -- Update configuration file
    set_active_profile(choice)
  end)
end

-- Create new profile
local function create_new_profile()
  vim.ui.input({ prompt = "Profile name (e.g., staging, qa): " }, function(profile_name)
    if not profile_name or profile_name == "" then
      return
    end

    -- Sanitize profile name
    profile_name = profile_name:lower():gsub("[^%w_%-]", "")

    -- Ask for format
    vim.ui.select({ "properties", "yml", "yaml" }, { prompt = "Select format:" }, function(format)
      if not format then
        return
      end

      local resources_dir = get_resources_dir()
      local filename = string.format("application-%s.%s", profile_name, format)
      local filepath = resources_dir .. "/" .. filename

      if file_exists(filepath) then
        vim.notify("Profile already exists: " .. profile_name, vim.log.levels.WARN)
        vim.cmd("edit " .. filepath)
        return
      end

      -- Generate content based on format
      local content
      if format == "properties" then
        content = M.generate_properties_template(profile_name)
      else
        content = M.generate_yml_template(profile_name)
      end

      if write_file(filepath, content) then
        vim.notify("✓ Created profile: " .. profile_name, vim.log.levels.INFO)
        vim.cmd("edit " .. filepath)
      end
    end)
  end)
end

-- Edit main properties/yml file
local function edit_properties()
  local resources_dir = get_resources_dir()

  local property_files = {
    { path = resources_dir .. "/application.properties", name = "application.properties" },
    { path = resources_dir .. "/application.yml", name = "application.yml" },
    { path = resources_dir .. "/application.yaml", name = "application.yaml" },
  }

  -- Find existing files
  local existing_files = {}
  for _, file_info in ipairs(property_files) do
    if file_exists(file_info.path) then
      table.insert(existing_files, file_info)
    end
  end

  if #existing_files == 0 then
    -- No file exists, ask to create one
    vim.ui.select(
      { "application.properties", "application.yml" },
      { prompt = "No config file found. Create:" },
      function(choice)
        if not choice then
          return
        end

        local filepath = resources_dir .. "/" .. choice
        local content

        if choice:match("%.properties$") then
          content = M.generate_properties_template()
        else
          content = M.generate_yml_template()
        end

        if write_file(filepath, content) then
          vim.cmd("edit " .. filepath)
        end
      end
    )
    return
  end

  if #existing_files == 1 then
    -- Only one file exists, open it directly
    vim.cmd("edit " .. existing_files[1].path)
    return
  end

  -- Multiple files exist, let user choose
  local file_names = vim.tbl_map(function(f)
    return f.name
  end, existing_files)
  vim.ui.select(file_names, { prompt = "Select file to edit:" }, function(choice)
    if not choice then
      return
    end

    for _, file_info in ipairs(existing_files) do
      if file_info.name == choice then
        vim.cmd("edit " .. file_info.path)
        return
      end
    end
  end)
end

-- Edit profile-specific properties
local function edit_profile_properties()
  local profiles = detect_available_profiles()

  -- Remove the "create new" option
  profiles = vim.tbl_filter(function(p)
    return p ~= "[ + Create New Profile ]"
  end, profiles)

  if #profiles == 0 then
    vim.notify("No profiles found. Create one first!", vim.log.levels.WARN)
    return
  end

  vim.ui.select(profiles, { prompt = "Select profile to edit:" }, function(profile)
    if not profile then
      return
    end

    local resources_dir = get_resources_dir()

    -- Find the profile file
    local property_files = {
      resources_dir .. "/application-" .. profile .. ".properties",
      resources_dir .. "/application-" .. profile .. ".yml",
      resources_dir .. "/application-" .. profile .. ".yaml",
    }

    for _, prop_file in ipairs(property_files) do
      if file_exists(prop_file) then
        vim.cmd("edit " .. prop_file)
        return
      end
    end

    vim.notify("Profile file not found for: " .. profile, vim.log.levels.ERROR)
  end)
end

-- ============================================================================
-- Template Generation
-- ============================================================================

function M.generate_properties_template(profile_name)
  profile_name = profile_name or "default"

  return string.format(
    [[
# ============================================================================
# Spring Boot Configuration - %s Profile
# ============================================================================

# ============================================================================
# Server Configuration
# ============================================================================
server.port=8080
server.servlet.context-path=/
server.error.include-message=always
server.error.include-binding-errors=always

# ============================================================================
# Database Configuration
# ============================================================================
spring.datasource.url=jdbc:postgresql://localhost:5432/mydb
spring.datasource.username=user
spring.datasource.password=password
spring.datasource.driver-class-name=org.postgresql.Driver

# Connection Pool Configuration
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000

# ============================================================================
# JPA/Hibernate Configuration
# ============================================================================
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.jdbc.batch_size=20
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true

# ============================================================================
# Logging Configuration
# ============================================================================
logging.level.root=INFO
logging.level.com.example=DEBUG
logging.level.org.springframework.web=DEBUG
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
logging.pattern.console=%%d{yyyy-MM-dd HH:mm:ss} - %%msg%%n
logging.file.name=logs/application.log

# ============================================================================
# Actuator Configuration
# ============================================================================
management.endpoints.web.exposure.include=health,info,metrics,prometheus
management.endpoint.health.show-details=when-authorized
management.metrics.export.prometheus.enabled=true

# ============================================================================
# Security Configuration (if using Spring Security)
# ============================================================================
# spring.security.user.name=admin
# spring.security.user.password=admin

# ============================================================================
# Jackson Configuration
# ============================================================================
spring.jackson.serialization.indent_output=true
spring.jackson.default-property-inclusion=non_null

# ============================================================================
# Profile Specific Settings
# ============================================================================
app.profile=%s
]],
    profile_name,
    profile_name
  )
end

function M.generate_yml_template(profile_name)
  profile_name = profile_name or "default"

  return string.format(
    [[
# ============================================================================
# Spring Boot Configuration - %s Profile
# ============================================================================

# ============================================================================
# Server Configuration
# ============================================================================
server:
  port: 8080
  servlet:
    context-path: /
  error:
    include-message: always
    include-binding-errors: always

# ============================================================================
# Database Configuration
# ============================================================================
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: user
    password: password
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000

  # ============================================================================
  # JPA/Hibernate Configuration
  # ============================================================================
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        dialect: org.hibernate.dialect.PostgreSQLDialect
        jdbc:
          batch_size: 20
        order_inserts: true
        order_updates: true

  # ============================================================================
  # Jackson Configuration
  # ============================================================================
  jackson:
    serialization:
      indent_output: true
    default-property-inclusion: non_null

# ============================================================================
# Logging Configuration
# ============================================================================
logging:
  level:
    root: INFO
    com.example: DEBUG
    org.springframework.web: DEBUG
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
  pattern:
    console: "%%d{yyyy-MM-dd HH:mm:ss} - %%msg%%n"
  file:
    name: logs/application.log

# ============================================================================
# Actuator Configuration
# ============================================================================
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when-authorized
  metrics:
    export:
      prometheus:
        enabled: true

# ============================================================================
# Profile Specific Settings
# ============================================================================
app:
  profile: %s
]],
    profile_name,
    profile_name
  )
end

-- ============================================================================
-- Profile Information Display
-- ============================================================================

local function show_profile_info()
  local current_profile = get_active_profile()
  local available_profiles = detect_available_profiles()

  -- Remove "create new" option
  available_profiles = vim.tbl_filter(function(p)
    return p ~= "[ + Create New Profile ]"
  end, available_profiles)

  local info = {
    "╔═══════════════════════════════════════════╗",
    "║     Spring Boot Profile Information      ║",
    "╚═══════════════════════════════════════════╝",
    "",
    "📍 Current Active Profile:",
  }

  if current_profile then
    table.insert(info, "   → " .. current_profile)
  else
    table.insert(info, "   → (none)")
  end

  table.insert(info, "")
  table.insert(info, "📋 Available Profiles:")

  if #available_profiles > 0 then
    for _, profile in ipairs(available_profiles) do
      local marker = profile == current_profile and "✓ " or "  "
      table.insert(info, "   " .. marker .. profile)
    end
  else
    table.insert(info, "   (no profiles found)")
  end

  -- Show in a floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, info)

  local width = 50
  local height = #info
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
  })

  -- Close on any key
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
end

-- ============================================================================
-- Exported Functions
-- ============================================================================

M.switch_profile = switch_profile
M.create_new_profile = create_new_profile
M.edit_properties = edit_properties
M.edit_profile_properties = edit_profile_properties
M.show_profile_info = show_profile_info
M.get_active_profile = get_active_profile

return M
