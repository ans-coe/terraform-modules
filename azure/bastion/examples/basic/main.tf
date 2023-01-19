provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.resource_prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "example" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes = ["10.0.0.192/27"]
}

module "example" {
  source = "../../"

  name                = "${var.resource_prefix}-bst"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  subnet_id = azurerm_subnet.example.id
}
