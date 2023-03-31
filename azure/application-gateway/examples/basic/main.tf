provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "acr"
    example = "basic"
    usage   = "demo"
  }
}
resource "azurerm_resource_group" "example" {
  name     = "awg-rg"
  location = local.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
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

  application_gateway_name = "agw-example"

  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  subnet_id           = azurerm_subnet.example.id
  backend_address_pools = [{
    name         = "BackendPool"
    ip_addresses = ["1.1.1.1", "1.0.0.1"]
  }]
  request_routing_rules = [{
    http_listener_name        = "Default"
    rule_type                 = "Basic"
    name                      = "HTTPRequestRoutingRule"
    backend_address_pool_name = "BackendPool"
  }]

  probe = [{
    host = "example.com"
  }]

  tags = local.tags
}
