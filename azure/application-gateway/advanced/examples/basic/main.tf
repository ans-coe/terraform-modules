provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  tags = {
    module  = "application-gateway"
    example = "basic"
    usage   = "demo"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "awg-rg"
  location = "uksouth"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "example" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes = azurerm_virtual_network.example.address_space
}

module "example" {
  source = "../../"

  name                = "agw-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags
  subnet_id           = azurerm_subnet.example.id

  backend_address_pools = {
    default_backend = {
      ip_addresses = ["1.1.1.1", "1.0.0.1"]
    }
  }

  probe = {
    default_probe = {
      host = "example.com"
    }
  }
}
