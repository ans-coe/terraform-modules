provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example_1" {
  name     = "${var.resource_prefix}-rg1"
  location = "westeurope"
  tags     = var.tags
}

resource "azurerm_resource_group" "example_2" {
  name     = "${var.resource_prefix}-rg2"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "example_1" {
  name                = "${var.resource_prefix}-vnet1"
  resource_group_name = azurerm_resource_group.example_1.name
  location            = var.location
  tags                = var.tags

  address_space = ["192.168.1.0/24"]
}

resource "azurerm_virtual_network" "example_2" {
  name                = "${var.resource_prefix}-vnet2"
  resource_group_name = azurerm_resource_group.example_1.name
  location            = var.location
  tags                = var.tags

  address_space = ["192.168.2.0/24"]
}

data "azurerm_management_group" "example" {
  display_name = "Tenant Root Group"
}

data "azurerm_subscription" "current" {}

module "example" {
  source = "../../"

  management_group_id = data.azurerm_management_group.example.id

  # The values in this example are here for example purposes only.
  # Terraform needs these values to be known prior to apply.
  scopes = [
    data.azurerm_management_group.example.id,
    data.azurerm_subscription.current.id,
    azurerm_resource_group.example_1.id
  ]
  exclude_scopes = [
    azurerm_resource_group.example_2.id,
    azurerm_virtual_network.example_2.id
  ]

  locations = [
    "uksouth", "eastus"
  ]
  enforce = false
}
