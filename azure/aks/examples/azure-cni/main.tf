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

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "aks-default"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes = ["10.0.0.0/20"]
}

module "aks" {
  source = "../../"

  name                = "${var.resource_prefix}-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  node_count = 2

  use_azure_cni  = true
  node_subnet_id = azurerm_subnet.example.id
  network_policy = "azure"
  service_cidr   = "10.1.0.0/16"
}
