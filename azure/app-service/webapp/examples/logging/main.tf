provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module  = "app-service-webapp"
    example = "logging"
    usage   = "demo"
  }
  resource_prefix = "tfmex-logging-wwa"
}

resource "azurerm_resource_group" "webapp" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

module "webapp" {
  source = "../../"

  os_type = "Windows"

  name                = "${local.resource_prefix}-wa"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  logs = {
    level                   = "Verbose"
    detailed_error_messages = true
    failed_request_tracing  = true
  }
}

resource "azurerm_storage_account" "webapp" {
  name                = lower(replace("${local.resource_prefix}stl", "/[-_]/", ""))
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

locals {
  webapp_log_types = [
    "AppServiceHTTPLogs", "AppServiceAppLogs", "AppServiceConsoleLogs",
    "AppServiceAuditLogs", "AppServiceIPSecAuditLogs", "AppServicePlatformLogs"
  ]
}

resource "azurerm_monitor_diagnostic_setting" "webapp" {
  name               = "${module.webapp.name}-diag"
  target_resource_id = module.webapp.id
  storage_account_id = azurerm_storage_account.webapp.id

  dynamic "enabled_log" {
    for_each = local.webapp_log_types
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}