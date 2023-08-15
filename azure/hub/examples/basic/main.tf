provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module  = "hub-vnet"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "hub-vnet-bas-demo-uks-03"
}

module "hub" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-${local.resource_prefix}"
  virtual_network_name = "vnet-${local.resource_prefix}"

  address_space = ["10.0.0.0/16"]
  extra_subnets = {
    "snet-default" = {
      prefix = "10.0.0.0/24"
    }
  }

  firewall_config = {
    name          = "fw-${local.resource_prefix}"
    subnet_prefix = "10.0.15.192/26"
  }

  bastion_config = {
    name          = "bas-${local.resource_prefix}"
    subnet_prefix = "10.0.15.0/26"
  }

  virtual_network_gateway_config = {
    name          = "vpngw-${local.resource_prefix}"
    subnet_prefix = "10.0.15.128/26"
  }

  private_resolver_config = {
    name                   = "dnspr-${local.resource_prefix}"
    inbound_subnet_prefix  = "10.0.14.224/28"
    outbound_subnet_prefix = "10.0.14.240/28"
  }

  network_watcher_config = {}
}
