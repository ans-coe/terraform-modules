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

  address_space     = var.address_space
  subnets           = local.subnets
  dns_servers       = var.dns_servers != "" ? var.dns_servers : []
  include_azure_dns = var.include_azure_dns

  private_dns_zones = var.private_dns_zones

  ddos_protection_plan_id = var.ddos_protection_plan_id

  peer_networks = var.hub_peering
}

##############################
# VNet Network Security Group
##############################

module "network_security_group" {
  for_each = { for nsg in var.subnets : nsg.subnet_nsg_name
  => nsg if nsg.create_subnet_nsg }
  source = "../network-security-group"

  name                = each.key
  location            = var.location
  resource_group_name = each.value["resource_group_name"] != null ? each.value["resource_group_name"] : var.resource_group_name
  tags                = var.tags
  rules_inbound       = tolist([for nsg_ri in var.nsg_rules_inbound : nsg_ri if nsg_ri.nsg_name == each.key])
  rules_outbound      = tolist([for nsg_ro in var.nsg_rules_outbound : nsg_ro if nsg_ro.nsg_name == each.key])
}

##############
# Route Table
##############

resource "azurerm_route_table" "default" {
  for_each = { for rt in var.subnets : rt.default_route_table_name
  => rt if rt.create_default_route_table }

  name                = each.key
  location            = var.location
  resource_group_name = each.value["resource_group_name"] != null ? each.value["resource_group_name"] : var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = each.value["disable_bgp_route_propagation"]
}

resource "azurerm_route_table" "custom" {
  for_each = { for rt in var.subnets : rt.custom_route_table_name
  => rt if rt.create_custom_route_table }

  name                = each.key
  location            = var.location
  resource_group_name = each.value["resource_group_name"] != null ? each.value["resource_group_name"] : var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = each.value["disable_bgp_route_propagation"]
}

##########################
# Route Table Association
##########################

resource "azurerm_subnet_route_table_association" "main" {
  for_each = { for k, v in var.subnets : k
  => v if anytrue([v.create_default_route_table, v.create_custom_route_table, v.associate_existing_route_table]) }

  subnet_id = module.network.subnets[each.key].id
  route_table_id = var.subnets[each.key].create_default_route_table ? "${azurerm_route_table.default[var.subnets[each.key].default_route_table_name].id}" : (
    var.subnets[each.key].create_custom_route_table ? "${azurerm_route_table.custom[each.value["custom_route_table_name"]].id}" : (
      var.subnets[each.key].associate_existing_route_table ? var.subnets[each.key].existing_route_table_id : null
    )
  )
}

#########
# Routes
#########

resource "azurerm_route" "default" {
  for_each = { for k, v in var.subnets : k
  => v if v.create_default_route_table }

  name                = each.value["default_route_name"]
  resource_group_name = each.value["resource_group_name"] != null ? each.value["resource_group_name"] : var.resource_group_name
  route_table_name    = each.value["default_route_table_name"]

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = each.value["default_route_ip"]

  depends_on = [azurerm_route_table.default]
}

resource "azurerm_route" "custom" {
  for_each = { for k, vars in var.custom_routes : k
  => merge(vars, { for v in var.subnets : "resource_group_name" => v.resource_group_name if v.custom_route_table_name == vars.route_table_name }) }

  name                = each.key
  resource_group_name = each.value["resource_group_name"] != null ? each.value["resource_group_name"] : var.resource_group_name
  route_table_name    = each.value["route_table_name"]

  address_prefix         = each.value["address_prefix"]
  next_hop_type          = each.value["next_hop_type"]
  next_hop_in_ip_address = each.value["next_hop_in_ip_address"]

  depends_on = [azurerm_route_table.custom]
}

######################
# Peering back to Hub
######################

resource "azurerm_virtual_network_peering" "reverse" {
  for_each = { for k, v in var.hub_peering : k => v if v.create_reverse_peering }

  name                      = format("%s_to_%s", each.key, module.network.name)
  virtual_network_name      = each.key
  resource_group_name       = each.value["hub_resource_group_name"]
  remote_virtual_network_id = module.network.id

  allow_virtual_network_access = each.value["allow_virtual_network_access"]
  allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
  allow_gateway_transit        = true
  use_remote_gateways          = false
}