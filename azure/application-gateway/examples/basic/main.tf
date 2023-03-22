# provider "azurerm" {
#   features {}
# }

provider "azurerm" {
  subscription_id = "c1b8750f-48de-43bd-b366-8128e418abd5"
  features {
  }
}

locals {
  location = "uksouth"
  tags = {
    module  = "acr"
    example = "basic"
    usage   = "demo"
  }
}

data "azurerm_subnet" "example" {
  name                 = "sn-vnet"
  virtual_network_name = "vnet"
  resource_group_name  = "vnet-rg"
}

resource "azurerm_public_ip" "example" {
  name                = "pip-vnet"
  resource_group_name = "vnet-rg"
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

module "example" {
  source = "../../"

  application_gateway_name = "agw-example"

  resource_group_name   = "agw-rg"
  create_resource_group = true
  location              = local.location
  subnet_id             = data.azurerm_subnet.example.id
  backend_address_pools = [{
    name         = "BackendPool"
    ip_addresses = ["1.1.1.1", "1.0.0.1"]
  }]
  frontend_ip_configurations = [{
    name                 = "PublicFrontend"
    public_ip_address_id = azurerm_public_ip.example.id
  }]

  http_listeners = [{
    name                           = "HTTPFrontendListener"
    frontend_ip_configuration_name = "PublicFrontend"
    host_name                      = "example.com"
  }]

  request_routing_rules = [{
    http_listener_name         = "HTTPFrontendListener"
    rule_type                  = "Basic"
    name                       = "HTTPRequestRoutingRule"
    backend_address_pool_name  = "BackendPool"
  }]

  probe = [{
    host = "example.com"
  }]

  tags = local.tags
}
