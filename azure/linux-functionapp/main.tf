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

#tfsec:ignore:azure-storage-queue-services-logging-enabled
resource "azurerm_storage_account" "app" {
  name                = var.storage_account_name == null ? lower(replace("${var.name}fasa", "/[-_]/", "")) : var.storage_account_name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version           = "TLS1_2"
  account_kind              = "BlobStorage"
  shared_access_key_enabled = false
}

resource "azurerm_role_assignment" "main_app" {
  for_each = toset(["Reader", "Storage Blob Data Contributor"])

  description          = format("Allows the function app %s %s access to the storage account %s.", azurerm_linux_function_app.main.name, each.value, azurerm_storage_account.app.name)
  principal_id         = one(azurerm_linux_function_app.main.identity).principal_id
  scope                = azurerm_storage_account.app.id
  role_definition_name = each.value

  skip_service_principal_aad_check = false
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

  storage_uses_managed_identity = true
  storage_account_name          = azurerm_storage_account.app.name
  builtin_logging_enabled       = true

  dynamic "site_config" {
    for_each = [var.site_config]

    content {
      worker_count           = lookup(site_config.value, "worker_count", 1)
      app_scale_limit        = lookup(site_config.value, "app_scale_limit", null)
      use_32_bit_worker      = lookup(site_config.value, "use_32_bit_worker", true)
      always_on              = lookup(site_config.value, "always_on", false)
      vnet_route_all_enabled = lookup(site_config.value, "vnet_route_all_enabled", false)
      load_balancing_mode    = lookup(site_config.value, "load_balancing_mode", null)

      minimum_tls_version = lookup(site_config.value, "minimum_tls_version", "1.2")
      http2_enabled       = lookup(site_config.value, "http2_enabled", false)
      websockets_enabled  = lookup(site_config.value, "websockets_enabled", false)
      default_documents   = lookup(site_config.value, "default_documents", null)

      api_definition_url    = lookup(site_config.value, "api_definition_url", null)
      api_management_api_id = lookup(site_config.value, "api_management_api_id", null)

      health_check_path                 = lookup(site_config.value, "health_check_path", null)
      health_check_eviction_time_in_min = lookup(site_config.value, "health_check_eviction_time_in_min", null)

      application_insights_key               = lookup(site_config.value, "application_insights_key", null)
      application_insights_connection_string = lookup(site_config.value, "application_insights_connection_string", null)

      ip_restriction                                = local.access_rules
      scm_ip_restriction                            = local.scm_access_rules
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

      app_service_logs {
        disk_quota_mb         = lookup(site_config.value, "log_disk_quota_mb", 25)
        retention_period_days = lookup(site_config.value, "log_retention_days", 7)
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
    for_each = length(concat(var.sticky_app_settings, var.sticky_connection_strings)) == 0 ? [] : [1]

    content {
      app_setting_names       = length(var.sticky_app_settings) == 0 ? null : var.sticky_app_settings
      connection_string_names = length(var.sticky_connection_strings) == 0 ? null : var.sticky_connection_strings
    }
  }

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }
}
