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
    module     = "bastion"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic-bastion"
}

resource "azurerm_resource_group" "bastion" {
  name     = "rg-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "bastion" {
  name                = "vnet-${local.resource_prefix}"
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

  name     = "bas-${local.resource_prefix}"
  location = local.location
  tags     = local.tags

  subnet_id = azurerm_subnet.bastion.id
}