provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "aks"
    example = "cni"
    usage   = "demo"
  }
  resource_prefix = "tfmex-cni-aks"
}

resource "azurerm_resource_group" "aks" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "aks" {
  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-default"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = ["10.0.0.0/20"]
}

module "aks" {
  source = "../../"

  name                = "${local.resource_prefix}-aks"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags

  node_count = 2

  use_azure_cni  = true
  node_subnet_id = azurerm_subnet.aks.id
  network_policy = "azure"
  service_cidr   = "10.1.0.0/16"
}
