provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module     = "spoke-vnet"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic-spoke"
}

module "spoke" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-${local.resource_prefix}"
  virtual_network_name = "vnet-${local.resource_prefix}"

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-default = {
      prefix = "10.0.1.0/24"
    }
  }

  network_security_group_name = "nsg-${local.resource_prefix}"
  route_table_name            = "rt-${local.resource_prefix}"
  default_route_name          = "route-${local.resource_prefix}"
  default_route_ip            = "192.168.0.1"
}