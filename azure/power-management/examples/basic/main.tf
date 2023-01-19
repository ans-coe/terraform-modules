provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
  tags     = var.tags
}

module "example" {
  source = "../../"

  name                = "${var.resource_prefix}-aa"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  timezone        = "Europe/London"
  scheduled_hours = ["0900", "1730"]
}

/*
Due to a bug in the implementation of Runbooks in Azure, the
parameter names need to be specified in lowercase only.
See: "https://github.com/Azure/azure-sdk-for-go/issues/4780" for more information.
*/

resource "azurerm_automation_job_schedule" "example_start" {
  schedule_name           = module.example.schedules["0900"].name
  resource_group_name     = module.example.resource_group_name
  automation_account_name = module.example.name
  runbook_name            = module.example.main_runbooks["AzVM"].name

  parameters = {
    action            = "Start"
    subscription      = data.azurerm_subscription.current.subscription_id
    resourcegroupname = azurerm_resource_group.example.name
    tag               = "aa-power-managed"
    tagvalue          = "on"
  }
}

resource "azurerm_automation_job_schedule" "example_stop" {
  schedule_name           = module.example.schedules["1730"].name
  resource_group_name     = module.example.resource_group_name
  automation_account_name = module.example.name
  runbook_name            = module.example.main_runbooks["AzVM"].name

  parameters = {
    action            = "Stop"
    subscription      = data.azurerm_subscription.current.subscription_id
    resourcegroupname = azurerm_resource_group.example.name
    tag               = "aa-power-managed"
    tagvalue          = "on"
  }
}
