local M = {}

-- ============================================================================
-- ⚙️ CONFIGURATION MANAGEMENT
-- ============================================================================

local function switch_profile()
  vim.ui.select({ "dev", "test", "prod", "local" }, { prompt = "Select profile:" }, function(choice)
    if choice then
      vim.notify("Switching to profile: " .. choice)
      vim.fn.setenv("SPRING_PROFILES_ACTIVE", choice)
    end
  end)
end

local function edit_properties()
  local property_files = {
    vim.fn.getcwd() .. "/src/main/resources/application.properties",
    vim.fn.getcwd() .. "/src/main/resources/application.yml",
    vim.fn.getcwd() .. "/src/main/resources/application.yaml",
  }

  for _, prop_file in ipairs(property_files) do
    if vim.fn.filereadable(prop_file) == 1 then
      vim.cmd("edit " .. prop_file)
      return
    end
  end

  vim.notify("No application properties file found", vim.log.levels.WARN)
end

local function edit_profile_properties()
  vim.ui.select({ "dev", "test", "prod", "local" }, { prompt = "Select profile:" }, function(profile)
    if not profile then
      return
    end

    local property_files = {
      vim.fn.getcwd() .. "/src/main/resources/application-" .. profile .. ".properties",
      vim.fn.getcwd() .. "/src/main/resources/application-" .. profile .. ".yml",
    }

    for _, prop_file in ipairs(property_files) do
      if vim.fn.filereadable(prop_file) == 1 then
        vim.cmd("edit " .. prop_file)
        return
      end
    end

    vim.notify("Profile properties not found for: " .. profile, vim.log.levels.WARN)
  end)
end

local function generate_properties_template()
  local properties_file = vim.fn.getcwd() .. "/src/main/resources/application.properties"

  if vim.fn.filereadable(properties_file) == 1 then
    vim.notify("application.properties already exists", vim.log.levels.WARN)
    return
  end

  local content = [[
# Server Configuration
server.port=8080
server.servlet.context-path=/

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/mydb
spring.datasource.username=user
spring.datasource.password=password
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Logging
logging.level.root=INFO
logging.level.com.example=DEBUG
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Actuator
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=when-authorized
]]

  local dir_path = vim.fn.fnamemodify(properties_file, ":h")
  vim.fn.mkdir(dir_path, "p")

  local file = io.open(properties_file, "w")
  if file then
    file:write(content)
    file:close()
    vim.cmd("edit " .. properties_file)
    vim.notify("Created application.properties template")
  end
end

M.switch_profile = switch_profile
M.edit_properties = edit_properties
M.edit_profile_properties = edit_profile_properties
M.generate_properties = generate_properties_template

return M

