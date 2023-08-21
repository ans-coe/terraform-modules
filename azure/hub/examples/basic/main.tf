provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module     = "hub-vnet"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic"
}

module "hub" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-hub-${local.resource_prefix}"
  virtual_network_name = "vnet-hub-${local.resource_prefix}"

  address_space = ["10.0.0.0/16"]
  extra_subnets = {
    "snet-hub" = {
      prefix = "10.0.0.0/24"
    }
  }

  firewall_config = {
    name          = "fw-hub-${local.resource_prefix}"
    subnet_prefix = "10.0.15.192/26"
  }

  bastion_config = {
    name                = "bas-hub-${local.resource_prefix}"
    subnet_prefix       = "10.0.15.0/26"
  }

  virtual_network_gateway_config = {
    name          = "vpngw-hub-${local.resource_prefix}"
    subnet_prefix = "10.0.15.128/26"
  }

  private_resolver_config = {
    name                   = "dnspr-hub-${local.resource_prefix}"
    inbound_subnet_prefix  = "10.0.14.224/28"
    outbound_subnet_prefix = "10.0.14.240/28"
  }

  network_watcher_config = {
    name                = "NetworkWatcher_UKSouth-${local.resource_prefix}"
    resource_group_name = "rg-nw-${local.resource_prefix}"
  }
}