############
# Spoke VNet
############

module "network" {
  source  = "ans-coe/virtual-network/azurerm"
  version = "1.3.0"

  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  address_space = var.address_space
  subnets       = local.subnets
  dns_servers   = var.dns_servers != "" ? var.dns_servers : []

  peer_networks = var.hub_peering
}

#########################
# Network Security Group
#########################

module "network_security_group" {
  count  = var.network_security_group_name != null ? 1 : 0
  source = "../network-security-group"

  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  rules_inbound       = var.nsg_rules_inbound
  rules_outbound      = var.nsg_rules_outbound

}

##############
# Route Table
##############

resource "azurerm_route_table" "main" {
  count = var.route_table_name != null ? 1 : 0

  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = var.disable_bgp_route_propagation
}

resource "azurerm_route" "main_default" {
  count = var.route_table_name != null ? 1 : 0

  name                = var.default_route_name
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.main[0].name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.default_route_ip
}

##########
# Peering
##########

resource "azurerm_virtual_network_peering" "main" {
  for_each = var.hub_peering

  name                      = format("%s_to_%s", each.key, module.network.name)
  virtual_network_name      = each.key
  resource_group_name       = var.resource_group_name
  remote_virtual_network_id = module.network.id

  allow_virtual_network_access = each.value["allow_virtual_network_access"]
  allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
  allow_gateway_transit        = each.value["allow_gateway_transit"]
  use_remote_gateways          = each.value["use_remote_gateways"]
}