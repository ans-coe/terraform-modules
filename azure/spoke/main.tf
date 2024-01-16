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
  resource_group_name  = var.resource_group_name

  address_prefixes = each.value["address_prefixes"]

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
  depends_on = [module.network]
}

##############
# Route Table
##############

# Conditions for Route Table Association:
# If var.subnet[].associate_default_route_table == true then the default route table is associated with the subnet.

module "route-table" {
  count  = var.create_default_route_table ? 1 : 0
  source = "../route-table"

  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  subnet_ids = local.subnet_assoc_route_table

  default_route_name = var.default_route_name
  default_route_ip   = var.default_route_ip

  routes = var.extra_routes
}

##################
# Network Watcher
##################

# Conditions for Network Watcher variables:
# If var.network_watcher_name is not specificed, use "network-watcher-${var.location}"
# If var.network_watcher_resource_group_name is not specified, use var.resource_group_name

resource "azurerm_network_watcher" "main" {
  count = var.enable_network_watcher ? 1 : 0

  name                = local.network_watcher_name
  location            = var.location
  resource_group_name = local.network_watcher_resource_group_name
  tags                = var.tags
}

##########
# Peering 
##########

# Conditions for reverse peering
# If vnet_peering.create_reverse_peering = true (default) > create peering from remote vnet back to the new spoke vnet.

resource "azurerm_virtual_network_peering" "main" {
  for_each = var.vnet_peering

  name                      = format("%s_to_%s", module.network.name, each.key)
  virtual_network_name      = module.network.name
  resource_group_name       = var.resource_group_name
  remote_virtual_network_id = each.value["id"]

  allow_virtual_network_access = each.value["allow_virtual_network_access"]
  allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
  allow_gateway_transit        = each.value["allow_gateway_transit"]
  use_remote_gateways          = each.value["use_remote_gateways"]
}

resource "azurerm_virtual_network_peering" "reverse" {
  for_each = { for k, v in var.vnet_peering : k => v if v.create_reverse_peering }

  name                      = format("%s_to_%s", each.key, module.network.name)
  virtual_network_name      = each.key
  resource_group_name       = each.value["vnet_resource_group_name"]
  remote_virtual_network_id = module.network.id

  allow_virtual_network_access = each.value["allow_virtual_network_access"]
  allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
  allow_gateway_transit        = true
  use_remote_gateways          = false

  provider = each.value["provider_alias"]
}