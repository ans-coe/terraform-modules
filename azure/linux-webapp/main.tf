##########
# Insights
##########

resource "azurerm_log_analytics_workspace" "main" {
  count = var.create_application_insights ? 1 : 0

  name                = "log-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_application_insights" "main" {
  count = var.create_application_insights ? 1 : 0

  name                = "appi-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  application_type = "web"
  workspace_id     = one(azurerm_log_analytics_workspace.main[*].id)
}

###############
# Service Plan
###############

resource "azurerm_service_plan" "main" {
  count = var.plan["create"] ? 1 : 0

  name                = var.plan["name"] == null ? "asp-${var.name}" : var.plan["name"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku_name = var.plan["sku_name"]

  os_type                = "Linux"
  zone_balancing_enabled = var.plan["zone_balancing"]
}

locals {
  plan_id = coalesce(one(azurerm_service_plan.main[*].id), var.plan["id"])
}

#########
# Webapp
#########

resource "azurerm_linux_web_app" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  service_plan_id           = local.plan_id
  virtual_network_subnet_id = var.subnet_id

  https_only                      = true
  key_vault_reference_identity_id = var.key_vault_identity_id

  zip_deploy_file = var.zip_deploy_file

  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      application_stack {
        docker_image        = lookup(var.application_stack, "docker_image", null)
        docker_image_tag    = lookup(var.application_stack, "docker_image_tag", null)
        dotnet_version      = lookup(var.application_stack, "dotnet_version", null)
        java_server         = lookup(var.application_stack, "java_server", null)
        java_server_version = lookup(var.application_stack, "java_server_version", null)
        java_version        = lookup(var.application_stack, "java_version", null)
        node_version        = lookup(var.application_stack, "node_version", null)
        php_version         = lookup(var.application_stack, "php_version", null)
        python_version      = lookup(var.application_stack, "python_version", null)
        ruby_version        = lookup(var.application_stack, "ruby_version", null)
        go_version          = lookup(var.application_stack, "go_version", null)
      }
      app_command_line = lookup(site_config.value, "app_command_line", null)

      worker_count           = lookup(site_config.value, "worker_count", 1)
      use_32_bit_worker      = lookup(site_config.value, "use_32_bit_worker", null)
      local_mysql_enabled    = lookup(site_config.value, "local_mysql_enabled", null)
      always_on              = lookup(site_config.value, "always_on", false)
      vnet_route_all_enabled = lookup(site_config.value, "vnet_route_all_enabled", null)
      load_balancing_mode    = lookup(site_config.value, "load_balancing_mode", null)

      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
      http2_enabled           = lookup(site_config.value, "http2_enabled", false)
      websockets_enabled      = lookup(site_config.value, "websockets_enabled", false)
      default_documents       = var.default_documents

      api_definition_url    = lookup(site_config.value, "api_definition_url", null)
      api_management_api_id = lookup(site_config.value, "api_management_api_id", null)

      health_check_path                 = lookup(site_config.value, "health_check_path", null)
      health_check_eviction_time_in_min = lookup(site_config.value, "health_check_eviction_time_in_min", null)

      container_registry_use_managed_identity       = lookup(site_config.value, "container_registry_use_managed_identity", true)
      container_registry_managed_identity_client_id = lookup(site_config.value, "container_registry_managed_identity_client_id", null)
      remote_debugging_enabled                      = lookup(site_config.value, "remote_debugging_enabled", false)
      remote_debugging_version                      = lookup(site_config.value, "remote_debugging_version", null)

      dynamic "cors" {
        for_each = var.cors == null ? [] : [1]
        content {
          allowed_origins     = lookup(var.cors, "allowed_origins", null)
          support_credentials = lookup(var.cors, "support_credentials", null)
        }
      }

      dynamic "ip_restriction" {
        for_each = local.access_rules
        content {
          name     = ip_restriction.name
          priority = ip_restriction.priority
          action   = ip_restriction.action

          ip_address                = ip_restriction.ip_address
          service_tag               = ip_restriction.service_tag
          virtual_network_subnet_id = ip_restriction.virtual_network_subnet_id
          headers                   = ip_restriction.headers
        }
      }
      dynamic "scm_ip_restriction" {
        for_each = local.scm_access_rules
        content {
          name     = scm_ip_restriction.name
          priority = scm_ip_restriction.priority
          action   = scm_ip_restriction.action

          ip_address                = scm_ip_restriction.ip_address
          service_tag               = scm_ip_restriction.service_tag
          virtual_network_subnet_id = scm_ip_restriction.virtual_network_subnet_id
          headers                   = scm_ip_restriction.headers
        }
      }
    }
  }

  app_settings = local.app_settings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value["name"]
      type  = connection_string.value["type"]
      value = connection_string.value["value"]
    }
  }
  dynamic "sticky_settings" {
    for_each = length(concat(local.sticky_app_settings, var.sticky_connection_strings)) == 0 ? [] : [1]
    content {
      app_setting_names       = length(local.sticky_app_settings) == 0 ? null : local.sticky_app_settings
      connection_string_names = length(var.sticky_connection_strings) == 0 ? null : var.sticky_connection_strings
    }
  }

  logs {
    detailed_error_messages = var.logs["detailed_error_messages"]
    failed_request_tracing  = var.logs["failed_request_tracing"]

    application_logs {
      file_system_level = var.logs["level"]
    }

    http_logs {
      file_system {
        retention_in_days = var.logs["retention_in_days"]
        retention_in_mb   = var.logs["retention_in_mb"]
      }
    }
  }

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to image tag, as this would be managed elsewhere.
      site_config[0].application_stack[0].docker_image_tag,
      # Ignore blob log configuration - ideally configure through diagnostic setting
      logs[0].application_logs[0].azure_blob_storage,
      logs[0].http_logs[0].azure_blob_storage,
      # Ignore hidden links that when deleted may break functionality
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      # Configure authentication outside of Terraform
      auth_settings_v2,
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}

resource "azurerm_linux_web_app_slot" "main" {
  for_each = var.slots

  name           = each.value
  app_service_id = azurerm_linux_web_app.main.id
  tags           = var.tags

  virtual_network_subnet_id = var.subnet_id

  https_only                      = true
  key_vault_reference_identity_id = var.key_vault_identity_id

  zip_deploy_file = var.zip_deploy_file

  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      worker_count           = lookup(site_config.value, "worker_count", 1)
      use_32_bit_worker      = lookup(site_config.value, "use_32_bit_worker", null)
      local_mysql_enabled    = lookup(site_config.value, "local_mysql_enabled", null)
      always_on              = lookup(site_config.value, "always_on", false)
      vnet_route_all_enabled = lookup(site_config.value, "vnet_route_all_enabled", null)
      load_balancing_mode    = lookup(site_config.value, "load_balancing_mode", null)

      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
      http2_enabled           = lookup(site_config.value, "http2_enabled", false)
      websockets_enabled      = lookup(site_config.value, "websockets_enabled", false)
      default_documents       = var.default_documents

      api_definition_url    = lookup(site_config.value, "api_definition_url", null)
      api_management_api_id = lookup(site_config.value, "api_management_api_id", null)

      health_check_path                 = lookup(site_config.value, "health_check_path", null)
      health_check_eviction_time_in_min = lookup(site_config.value, "health_check_eviction_time_in_min", null)

      container_registry_use_managed_identity       = lookup(site_config.value, "container_registry_use_managed_identity", true)
      container_registry_managed_identity_client_id = lookup(site_config.value, "container_registry_managed_identity_client_id", null)
      remote_debugging_enabled                      = lookup(site_config.value, "remote_debugging_enabled", false)
      remote_debugging_version                      = lookup(site_config.value, "remote_debugging_version", null)

      dynamic "ip_restriction" {
        for_each = local.access_rules
        content {
          name     = ip_restriction.name
          priority = ip_restriction.priority
          action   = ip_restriction.action

          ip_address                = ip_restriction.ip_address
          service_tag               = ip_restriction.service_tag
          virtual_network_subnet_id = ip_restriction.virtual_network_subnet_id
          headers                   = ip_restriction.headers
        }
      }
      dynamic "scm_ip_restriction" {
        for_each = local.access_rules
        content {
          name     = scm_ip_restriction.name
          priority = scm_ip_restriction.priority
          action   = scm_ip_restriction.action

          ip_address                = scm_ip_restriction.ip_address
          service_tag               = scm_ip_restriction.service_tag
          virtual_network_subnet_id = scm_ip_restriction.virtual_network_subnet_id
          headers                   = scm_ip_restriction.headers
        }
      }

      dynamic "cors" {
        for_each = var.cors == null ? [] : [1]
        content {
          allowed_origins     = lookup(var.cors, "allowed_origins", null)
          support_credentials = lookup(var.cors, "support_credentials", null)
        }
      }

      application_stack {
        docker_image        = lookup(var.application_stack, "docker_image", null)
        docker_image_tag    = lookup(var.application_stack, "docker_image_tag", null)
        dotnet_version      = lookup(var.application_stack, "dotnet_version", null)
        java_server         = lookup(var.application_stack, "java_server", null)
        java_server_version = lookup(var.application_stack, "java_server_version", null)
        java_version        = lookup(var.application_stack, "java_version", null)
        node_version        = lookup(var.application_stack, "node_version", null)
        php_version         = lookup(var.application_stack, "php_version", null)
        python_version      = lookup(var.application_stack, "python_version", null)
        ruby_version        = lookup(var.application_stack, "ruby_version", null)
        go_version          = lookup(var.application_stack, "go_version", null)
      }
    }
  }

  app_settings = local.app_settings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value["name"]
      type  = connection_string.value["type"]
      value = connection_string.value["value"]
    }
  }

  logs {
    detailed_error_messages = var.logs["detailed_error_messages"]
    failed_request_tracing  = var.logs["failed_request_tracing"]

    application_logs {
      file_system_level = var.logs["level"]
    }

    http_logs {
      file_system {
        retention_in_days = var.logs["retention_in_days"]
        retention_in_mb   = var.logs["retention_in_mb"]
      }
    }
  }

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to image tag, as this would be managed elsewhere.
      site_config[0].application_stack[0].docker_image_tag,
      # Ignore blob log configuration - ideally configure through diagnostic setting
      logs[0].application_logs[0].azure_blob_storage,
      logs[0].http_logs[0].azure_blob_storage,
      # Ignore hidden links that when deleted may break functionality
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      # Configure authentication outside of Terraform
      auth_settings_v2,
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}
