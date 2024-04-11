#################
# Resource Group
#################

resource "azurerm_resource_group" "main" {
  count = var.resource_group_name == null ? 1 : 0

  name     = "${var.name}-rg"
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = coalesce(one(azurerm_resource_group.main[*].name), var.resource_group_name)
}

##########
# Insights
##########

resource "azurerm_log_analytics_workspace" "main" {
  count = var.create_application_insights ? 1 : 0

  name                = "${var.name}-log"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_application_insights" "main" {
  count = var.create_application_insights ? 1 : 0

  name                = "${var.name}-ai"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  application_type = "web"
  workspace_id     = one(azurerm_log_analytics_workspace.main[*].id)
}

###############
# Service Plan
###############

resource "azurerm_service_plan" "main" {
  count = var.plan["create"] ? 1 : 0

  name                = var.plan["name"] == null ? "${var.name}-sp" : var.plan["name"]
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  sku_name = var.plan["sku_name"]

  os_type                = "Linux"
  zone_balancing_enabled = var.plan["zone_balancing"]
}

locals {
  plan_id = coalesce(one(azurerm_service_plan.main[*].id), var.plan["id"])
}

##########
# Storage
##########

resource "azurerm_storage_account" "app" {
  name                = var.storage_account_name == null ? lower(replace("${var.name}fasa", "/[-_]/", "")) : var.storage_account_name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }
}

###############
# Function App
###############

resource "azurerm_linux_function_app" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  service_plan_id           = local.plan_id
  daily_memory_time_quota   = var.daily_memory_time_quota_gs
  virtual_network_subnet_id = var.subnet_id

  https_only                      = true
  functions_extension_version     = var.functions_extension_version
  key_vault_reference_identity_id = var.key_vault_identity_id

  storage_account_name       = azurerm_storage_account.app.name
  storage_account_access_key = azurerm_storage_account.app.primary_access_key

  public_network_access_enabled = var.public_network_access_enabled



  site_config {
    always_on                                     = var.site_config.always_on
    api_management_api_id                         = var.site_config.api_management_api_id
    api_definition_url                            = var.site_config.api_definition_url
    app_command_line                              = var.site_config.app_command_line
    app_scale_limit                               = var.site_config.app_scale_limit
    application_insights_key                      = var.site_config.application_insights_key
    application_insights_connection_string        = var.site_config.application_insights_connection_string
    container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    default_documents                             = var.default_documents
    elastic_instance_minimum                      = var.site_config.elastic_instance_minimum
    http2_enabled                                 = var.site_config.http2_enabled
    scm_use_main_ip_restriction                   = var.site_config.scm_use_main_ip_restriction
    load_balancing_mode                           = var.site_config.load_balancing_mode
    managed_pipeline_mode                         = var.site_config.managed_pipeline_mode
    pre_warmed_instance_count                     = var.site_config.pre_warmed_instance_count
    remote_debugging_enabled                      = var.site_config.remote_debugging_enabled
    remote_debugging_version                      = var.site_config.remote_debugging_version
    runtime_scale_monitoring_enabled              = var.site_config.runtime_scale_monitoring_enabled
    scm_type                                      = var.site_config.scm_type
    use_32_bit_worker                             = var.site_config.use_32_bit_worker
    websockets_enabled                            = var.site_config.websockets_enabled
    ftps_state                                    = var.site_config.ftps_state
    health_check_path                             = var.site_config.health_check_path
    health_check_eviction_time_in_min             = var.site_config.health_check_eviction_time_in_min
    worker_count                                  = var.site_config.worker_count
    minimum_tls_version                           = var.site_config.minimum_tls_version
    scm_minimum_tls_version                       = var.site_config.scm_minimum_tls_version
    vnet_route_all_enabled                        = var.site_config.vnet_route_all_enabled
    detailed_error_logging_enabled                = var.site_config.detailed_error_logging_enabled
    linux_fx_version                              = var.site_config.linux_fx_version

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
      dynamic "docker" {
        for_each = lookup(var.application_stack, "docker_image", null) == null ? [] : [1]
        content {
          registry_url = lookup(var.application_stack, "docker_registry", null)
          image_name   = lookup(var.application_stack, "docker_image", null)
          image_tag    = lookup(var.application_stack, "docker_image_tag", null)
        }
      }
      use_dotnet_isolated_runtime = lookup(var.application_stack, "use_dotnet_isolated_runtime", null)
      dotnet_version              = lookup(var.application_stack, "dotnet_version", null)
      java_version                = lookup(var.application_stack, "java_version", null)
      node_version                = lookup(var.application_stack, "node_version", null)
      python_version              = lookup(var.application_stack, "python_version", null)
      powershell_core_version     = lookup(var.application_stack, "powershell_core_version", null)
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

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to image tag, as this would be managed elsewhere.
      site_config[0].application_stack[0].docker[0].image_tag,
      # Ignore hidden links that when deleted may break functionality
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

resource "azurerm_linux_function_app_slot" "main" {
  for_each = var.slots

  name            = each.value
  function_app_id = azurerm_linux_function_app.main.id
  tags            = var.tags

  daily_memory_time_quota   = var.daily_memory_time_quota_gs
  virtual_network_subnet_id = var.subnet_id

  https_only                      = true
  functions_extension_version     = var.functions_extension_version
  key_vault_reference_identity_id = var.key_vault_identity_id

  storage_account_name       = azurerm_storage_account.app.name
  storage_account_access_key = azurerm_storage_account.app.primary_access_key

  site_config {
    always_on                                     = var.site_config.always_on
    api_management_api_id                         = var.site_config.api_management_api_id
    api_definition_url                            = var.site_config.api_definition_url
    app_command_line                              = var.site_config.app_command_line
    app_scale_limit                               = var.site_config.app_scale_limit
    application_insights_key                      = var.site_config.application_insights_key
    application_insights_connection_string        = var.site_config.application_insights_connection_string
    container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    default_documents                             = var.default_documents
    elastic_instance_minimum                      = var.site_config.elastic_instance_minimum
    http2_enabled                                 = var.site_config.http2_enabled
    scm_use_main_ip_restriction                   = var.site_config.scm_use_main_ip_restriction
    load_balancing_mode                           = var.site_config.load_balancing_mode
    managed_pipeline_mode                         = var.site_config.managed_pipeline_mode
    pre_warmed_instance_count                     = var.site_config.pre_warmed_instance_count
    remote_debugging_enabled                      = var.site_config.remote_debugging_enabled
    remote_debugging_version                      = var.site_config.remote_debugging_version
    runtime_scale_monitoring_enabled              = var.site_config.runtime_scale_monitoring_enabled
    scm_type                                      = var.site_config.scm_type
    use_32_bit_worker                             = var.site_config.use_32_bit_worker
    websockets_enabled                            = var.site_config.websockets_enabled
    ftps_state                                    = var.site_config.ftps_state
    health_check_path                             = var.site_config.health_check_path
    health_check_eviction_time_in_min             = var.site_config.health_check_eviction_time_in_min
    worker_count                                  = var.site_config.worker_count
    minimum_tls_version                           = var.site_config.minimum_tls_version
    scm_minimum_tls_version                       = var.site_config.scm_minimum_tls_version
    vnet_route_all_enabled                        = var.site_config.vnet_route_all_enabled
    detailed_error_logging_enabled                = var.site_config.detailed_error_logging_enabled
    linux_fx_version                              = var.site_config.linux_fx_version

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

    dynamic "cors" {
      for_each = var.cors == null ? [] : [1]
      content {
        allowed_origins     = lookup(var.cors, "allowed_origins", null)
        support_credentials = lookup(var.cors, "support_credentials", null)
      }
    }

    application_stack {
      dynamic "docker" {
        for_each = lookup(var.application_stack, "docker_image", null) == null ? [] : [1]
        content {
          registry_url = lookup(var.application_stack, "docker_registry", null)
          image_name   = lookup(var.application_stack, "docker_image", null)
          image_tag    = lookup(var.application_stack, "docker_image_tag", null)
        }
      }
      use_dotnet_isolated_runtime = lookup(var.application_stack, "use_dotnet_isolated_runtime", null)
      dotnet_version              = lookup(var.application_stack, "dotnet_version", null)
      java_version                = lookup(var.application_stack, "java_version", null)
      node_version                = lookup(var.application_stack, "node_version", null)
      python_version              = lookup(var.application_stack, "python_version", null)
      powershell_core_version     = lookup(var.application_stack, "powershell_core_version", null)
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

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to image tag, as this would be managed elsewhere.
      site_config[0].application_stack[0].docker[0].image_tag,
      # Ignore hidden links that when deleted may break functionality
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}
