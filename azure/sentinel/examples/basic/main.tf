provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module     = "spoke-vnet"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic-sentinel"
}

resource "azurerm_resource_group" "main" {
  location = local.location
  name     = "rg-${local.resource_prefix}"
  tags     = local.tags
}

module "sentinel" {
  source = "../../"

  resource_group_name          = azurerm_resource_group.main.name
  location                     = local.location
  tags                         = local.tags
  log_analytics_workspace_name = "law-${local.resource_prefix}"

  # dc_ad_enabled                                            = true
  dc_security_center_enabled                                 = true
  # dc_advanced_threat_protection_enabled                    = true
  # dc_microsoft_cloud_app_security_enabled                  = true
  dc_microsoft_threat_intelligence_enabled                   = true
  # dc_office_365_enabled                                    = true
  # dc_microsoft_defender_advanced_threat_protection_enabled = true
  # dc_microsoft_threat_protection_enabled                   = true
}