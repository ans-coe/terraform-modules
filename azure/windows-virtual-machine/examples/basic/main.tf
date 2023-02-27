provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "windows-virtual-machine"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-wvm"
}

resource "random_password" "vm" {
  length = 20
}

resource "azurerm_resource_group" "vm" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "vm" {
  name                = "${local.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.vm.name
  location            = local.location
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "vm" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.vm.name
  virtual_network_name = azurerm_virtual_network.vm.name

  address_prefixes = azurerm_virtual_network.vm.address_space
}

module "vm" {
  source = "../../"

  name                = "${local.resource_prefix}-vm"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  computer_name = "vm"
  password      = random_password.vm.result
  subnet_id     = azurerm_subnet.vm.id
  size          = "Standard_B2s"
}
