provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module     = "hub-hub-example"
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

  firewall = {
    name          = "fw-hub-${local.resource_prefix}"
    subnet_prefix = "10.0.15.192/26"
  }

  bastion = {
    name          = "bas-hub-${local.resource_prefix}"
    subnet_prefix = "10.0.15.0/26"
  }

  # Commented out as this takes ~30 mins to deploy.  Uncomment if specifically testing VNGs

  # virtual_network_gateway = {
  #   name          = "vpngw-hub-${local.resource_prefix}"
  #   subnet_prefix = "10.0.15.128/26"
  # }

  private_resolver = {
    name                   = "dnspr-hub-${local.resource_prefix}"
    inbound_subnet_prefix  = "10.0.14.224/28"
    outbound_subnet_prefix = "10.0.14.240/28"
  }

  network_watcher_config = {
    name                = "nw_uks-${local.resource_prefix}"
    resource_group_name = "rg-nw-${local.resource_prefix}"
  }
}