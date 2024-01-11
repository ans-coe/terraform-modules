#############
# Resource Group
#############

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

############
# Spoke VNet
############

module "network" {
  source  = "ans-coe/virtual-network/azurerm"
  version = "1.3.0"

  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  address_space = var.address_space
  subnets       = local.subnets
  dns_servers   = var.dns_servers != "" ? var.dns_servers : []

  peer_networks = var.hub_peering != null ? {
    "hub" = {
      id                           = var.hub_peering.id
      allow_virtual_network_access = var.hub_peering.allow_virtual_network_access
      allow_forwarded_traffic      = var.hub_peering.allow_forwarded_traffic
      allow_gateway_transit        = var.hub_peering.allow_gateway_transit
      use_remote_gateways          = var.hub_peering.use_remote_gateways
    }
  } : {}
}

module "network_security_group" {
  count  = var.network_security_group_name != null ? 1 : 0
  source = "../network-security-group"

  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_route_table" "main" {
  count = var.route_table_name != null ? 1 : 0

  name                = var.route_table_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  disable_bgp_route_propagation = var.disable_bgp_route_propagation
}

resource "azurerm_route" "main_default" {
  count = var.route_table_name != null ? 1 : 0

<<<<<<< HEAD
  name                = var.default_route_name
=======
  name                = "default"
>>>>>>> parent of 1a6ac52 (peering and default route name changes)
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.main[0].name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.default_route_ip
}
