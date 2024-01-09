############
# Spoke VNet
############

module "network" {
  source = "./_modules/vnet"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  address_space     = var.address_space
  dns_servers       = var.dns_servers != "" ? var.dns_servers : []
  include_azure_dns = var.include_azure_dns
  private_dns_zones = var.private_dns_zones

  ddos_protection_plan_id = var.ddos_protection_plan_id
  bgp_community           = var.bgp_community
}

##########
# Subnets
##########

resource "azurerm_subnet" "main" {
  for_each = var.subnets

  name                 = each.key
  virtual_network_name = module.network.name
  resource_group_name  = each.value["resource_group_name"] != null ? each.value["resource_group_name"] : var.resource_group_name

  address_prefixes = each.value["prefixes"]

  service_endpoints                             = each.value["service_endpoints"]
  private_endpoint_network_policies_enabled     = each.value["private_endpoint_network_policies_enabled"]
  private_link_service_network_policies_enabled = each.value["private_link_service_network_policies_enabled"]

  dynamic "delegation" {
    for_each = each.value["delegations"]
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value["service"]
        actions = delegation.value["actions"]
      }
    }
  }
}

###############
# Route Tables
###############

module "global_route_table" {
  count = var.create_global_route_table ? 1 : 0

  source = "./_modules/route-table"

  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = var.tags
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  subnet_ids                    = local.associate_global_rt_subnet_ids
  routes = {
    "var.default_route_name" = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.default_route_ip
    }
  }
}

module "custom_route_tables" {
  for_each = var.route_tables

  source = "./_modules/route-table"

  name                          = each.key
  location                      = var.location
  resource_group_name           = each.value["resource_group_name"]
  tags                          = var.tags
  disable_bgp_route_propagation = each.value["disable_bgp_route_propagation"]
  subnet_ids                    = local.associate_custom_rt_subnet_ids["each.key"]
  routes                        = each.value["routes"]
}

##########################
# Network Security Groups
##########################

module "global_network_security_group" {
  count = var.create_global_nsg ? 1 : 0
  
  source = "../network-security-group"

  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  rules_inbound       = tolist([for nsg_ri in var.nsg_rules_inbound : nsg_ri if nsg_ri.nsg_name == var.nsg_name])
  rules_outbound      = tolist([for nsg_ro in var.nsg_rules_outbound : nsg_ro if nsg_ro.nsg_name == var.nsg_name])
}

module "custom_network_security_group" {
  for_each = var.network_security_groups
  
  source = "../network-security-group"

  name                = each.key
  location            = each.value["location"]
  resource_group_name = each.value["resource_group_name"] != null ? each.value["resource_group_name"] : var.resource_group_name
  tags                = var.tags

  enable_flow_log = each.value["enable_flow_log"]
  flow_log_config = each.value["flow_log_config"]

  rules_inbound       = tolist([for nsg_ri in var.nsg_rules_inbound : nsg_ri if nsg_ri.nsg_name == each.key])
  rules_outbound      = tolist([for nsg_ro in var.nsg_rules_outbound : nsg_ro if nsg_ro.nsg_name == each.key])
}

##############
# NAT Gateway
##############



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