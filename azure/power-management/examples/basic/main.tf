provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "power-management"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-pm"
}

data "azurerm_subscription" "current" {}

module "power_management" {
  source = "../../"

  name     = "${local.resource_prefix}-pm-aa"
  location = local.location
  tags     = local.tags

  timezone        = "Europe/London"
  scheduled_hours = ["0900", "1730"]
}

/*
Due to a bug in the implementation of Runbooks in Azure, the
parameter names need to be specified in lowercase only.
See: "https://github.com/Azure/azure-sdk-for-go/issues/4780" for more information.
*/

resource "azurerm_automation_job_schedule" "vm_start" {
  schedule_name           = module.power_management.schedules["0900"].name
  resource_group_name     = module.power_management.resource_group_name
  automation_account_name = module.power_management.name
  runbook_name            = module.power_management.main_runbooks["AzVM"].name

  parameters = {
    action       = "Start"
    subscription = data.azurerm_subscription.current.subscription_id
    tag          = "aa-power-managed"
    tagvalue     = "on"
  }
}

resource "azurerm_automation_job_schedule" "vm_stop" {
  schedule_name           = module.power_management.schedules["1730"].name
  resource_group_name     = module.power_management.resource_group_name
  automation_account_name = module.power_management.name
  runbook_name            = module.power_management.main_runbooks["AzVM"].name

  parameters = {
    action       = "Stop"
    subscription = data.azurerm_subscription.current.subscription_id
    tag          = "aa-power-managed"
    tagvalue     = "on"
  }
}
