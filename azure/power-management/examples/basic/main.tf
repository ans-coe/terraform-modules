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
    module  = "power-management"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-pm"
}

resource "azurerm_resource_group" "power_management" {
  name     = "rg-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

data "azurerm_subscription" "current" {}

module "power_management" {
  source = "../../"

  name                = "aa-pm-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.power_management.name
  tags                = local.tags

  timezone        = "Europe/London"
  scheduled_hours = {
    "morning" = "0830"
    "evening" = "1800"
  }
}

/*
Due to a bug in the implementation of Runbooks in Azure, the
parameter names need to be specified in lowercase only.
See: "https://github.com/Azure/azure-sdk-for-go/issues/4780" for more information.
*/

resource "azurerm_automation_job_schedule" "vm_start" {
  schedule_name           = module.power_management.schedules["morning"].name
  resource_group_name     = azurerm_resource_group.power_management.name
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
  schedule_name           = module.power_management.schedules["evening"].name
  resource_group_name     = azurerm_resource_group.power_management.name
  automation_account_name = module.power_management.name
  runbook_name            = module.power_management.main_runbooks["AzVM"].name

  parameters = {
    action       = "Stop"
    subscription = data.azurerm_subscription.current.subscription_id
    tag          = "aa-power-managed"
    tagvalue     = "on"
  }
}
