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

  os_type                = "Windows"
  zone_balancing_enabled = var.plan["zone_balancing"]
}

locals {
  plan_id = coalesce(one(azurerm_service_plan.main[*].id), var.plan["id"])
}