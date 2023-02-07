provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "bastion"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-bst"
}

resource "azurerm_resource_group" "bastion" {
  name     = "${local.resource_prefix}-vnet-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "bastion" {
  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.bastion.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.bastion.name
  virtual_network_name = azurerm_virtual_network.bastion.name

  address_prefixes = ["10.0.0.192/27"]
}

module "bastion" {
  source = "../../"

  name     = "${local.resource_prefix}-bst"
  location = local.location
  tags     = local.tags

  subnet_id = azurerm_subnet.bastion.id
}
