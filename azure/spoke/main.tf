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

  peer_networks = var.hub_peering
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

  name                = var.default_route_name != null ? var.default_route_name : "default"
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.main[0].name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.default_route_ip
}
