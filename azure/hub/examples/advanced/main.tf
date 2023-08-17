provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module     = "hub-spoke-example"
    example    = "advanced"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-adv"
}

#####
# Hub
#####

module "hub" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-${local.resource_prefix}-hub"
  virtual_network_name = "vnet-${local.resource_prefix}-hub"

  address_space = ["10.0.0.0/16"]
  extra_subnets = {
    "hub-net-default" = {
      prefix = "10.0.0.0/24"
    }
  }

  firewall_config = {
    name             = "fw-${local.resource_prefix}-hub"
    subnet_prefix    = "10.0.15.192/26"
    public_ip_name   = "fw-pip${local.resource_prefix}-hub"
    route_table_name = "rt-${local.resource_prefix}-hub"
  }

  bastion_config = {
    name                = "bas-${local.resource_prefix}-hub"
    resource_group_name = "rg-bas-${local.resource_prefix}-hub"
    subnet_prefix       = "10.0.15.0/26"
  }

  virtual_network_gateway_config = {
    name          = "vpngw-${local.resource_prefix}-hub"
    subnet_prefix = "10.0.15.128/26"
  }

  private_resolver_config = {
    name                   = "dnspr-${local.resource_prefix}-hub"
    inbound_subnet_prefix  = "10.0.14.224/28"
    outbound_subnet_prefix = "10.0.14.240/28"
  }

  network_watcher_config = {
    name                = "NetworkWatcher_UKSouth-${local.resource_prefix}"
    resource_group_name = "rg-nw-${local.resource_prefix}"
  }
}

########
# Spokes
########

module "spoke-mgmt" {
  source = "../../../spoke"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-mgmt-${local.resource_prefix}-spoke"
  virtual_network_name = "vnet-mgmt-${local.resource_prefix}-spoke"

  address_space = ["10.1.0.0/16"]
  subnets = {
    "snet-mgmt-tfmex-adv-hub" = {
      prefix = "10.1.0.0/24"
    }
  }

  network_security_group_name = "nsg-mgmt-${local.resource_prefix}-spoke"
  route_table_name            = "rt-mgmt-${local.resource_prefix}-spoke"
  default_route_ip            = module.hub.firewall.private_ip
}

module "spoke-prd" {
  source = "../../../spoke"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-prd-${local.resource_prefix}-spoke"
  virtual_network_name = "vnet-prd-${local.resource_prefix}-spoke"

  address_space = ["10.2.0.0/16"]
  subnets = {
    "snet-prd-tfmex-adv-spoke" = {
      prefix = "10.2.0.0/24"
    }
  }

  network_security_group_name = "nsg-prd-${local.resource_prefix}-spoke"
  route_table_name            = "rt-prd-${local.resource_prefix}-spoke"
  default_route_ip            = module.hub.firewall.private_ip
}

#########
# Peering
#########

resource "azurerm_virtual_network_peering" "hub-mgmt" {
  name                         = "peer-hub-mgmt-${local.resource_prefix}"
  resource_group_name          = module.hub.network.resource_group_name
  virtual_network_name         = module.hub.network.name
  remote_virtual_network_id    = module.spoke-mgmt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "mgmt-hub" {
  name                         = "peer-mgmt-hub-${local.resource_prefix}"
  resource_group_name          = module.spoke-mgmt.network.resource_group_name
  virtual_network_name         = module.spoke-mgmt.network.name
  remote_virtual_network_id    = module.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "hub-prd" {
  name                         = "peer-hub-prd-${local.resource_prefix}"
  resource_group_name          = module.hub.network.resource_group_name
  virtual_network_name         = module.hub.network.name
  remote_virtual_network_id    = module.spoke-prd.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "prd-hub" {
  name                         = "peer-prd-hub-${local.resource_prefix}"
  resource_group_name          = module.spoke-prd.network.resource_group_name
  virtual_network_name         = module.spoke-prd.network.name
  remote_virtual_network_id    = module.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}