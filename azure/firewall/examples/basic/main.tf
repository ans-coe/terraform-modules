provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

#############
# Locals
#############

locals {
  location    = "uksouth"
  dns_servers = ["1.1.1.1", "8.8.8.8"]
  tags = {
    module     = "firewall"
    owner      = "John Doe"
    department = "Technical"
  }
}

#############
# Global Resources
#############

resource "azurerm_resource_group" "example" {
  name     = "firewall-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

#############
# Firewall
#############

module "firewall" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags

  virtual_network_name    = azurerm_virtual_network.example.name
  pip_name                = "fw-pip"
  subnet_address_prefixes = azurerm_virtual_network.example.address_space

  firewall_name        = "fw"
  firewall_sku_name    = "AZFW_VNet"
  firewall_sku_tier    = "Standard"
  firewall_dns_servers = local.dns_servers
}