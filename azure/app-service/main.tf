##############################
#|#        Insights        #|#
##############################

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

##############################
#|#      Service Plan      #|#
##############################

resource "azurerm_service_plan" "main" {
  count = var.plan["create"] ? 1 : 0

  name                = var.plan["name"] == null ? "asp-${var.name}" : var.plan["name"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku_name = var.plan["sku_name"]

  os_type                = var.os_type
  zone_balancing_enabled = var.plan["zone_balancing"]
}

locals {
  plan_id = coalesce(one(azurerm_service_plan.main[*].id), var.plan["id"])
}

##############################
#|#   Shared App Service   #|#
##############################

resource "azurerm_app_service_custom_hostname_binding" "main" {
  count = var.custom_domain != null ? 1 : 0

  hostname            = var.custom_domain
  app_service_name    = local.app_service.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "main" {
  count = local.create_umid ? 1 : 0 // create a umid if we set use_umid to true and we don't provide a umid id

  name                = local.umid_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

##############################
#|#      Autoscaling       #|#
##############################

// To-Do - Complex Autoscaling - This is a basic implementation
resource "azurerm_monitor_autoscale_setting" "main" {
  count = local.use_autoscaling ? 1 : 0

  name                = "autoscaleappservice"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = local.app_service.id
  tags                = var.tags

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = local.app_service.app_service_plan_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 50
        metric_namespace   = "Microsoft.Web/serverfarms"
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = local.app_service.app_service_plan_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 15
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
