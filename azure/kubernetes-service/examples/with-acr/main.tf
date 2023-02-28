provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "aks"
    example = "with-acr"
    usage   = "demo"
  }
  resource_prefix = "tfmex-with-acr-aks"
}

resource "azurerm_resource_group" "aks" {
  name     = "${local.resource_prefix}-acr"
  location = local.location
  tags     = local.tags
}

resource "azurerm_container_registry" "aks" {
  name                = lower(replace("${local.resource_prefix}acr", "/[-_]/", ""))
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags

  sku = "Basic"

  admin_enabled                 = false
  public_network_access_enabled = true
}

module "aks" {
  source = "../../"

  name                = "${local.resource_prefix}-aks"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags

  node_count = 2

  registry_ids = [azurerm_container_registry.aks.id]
}
