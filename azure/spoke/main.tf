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

  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled

  subnet_ids = local.subnet_assoc_route_table

  default_route = var.default_route

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

resource "azurerm_virtual_network_peering" "main" {
  for_each = var.vnet_peering

  name                      = format("%s_to_%s", module.network.name, each.key)
  virtual_network_name      = module.network.name
  resource_group_name       = module.network.resource_group_name
  remote_virtual_network_id = each.value["remote_vnet_id"]

  allow_virtual_network_access = each.value["allow_virtual_network_access"]
  allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
  allow_gateway_transit        = each.value["allow_gateway_transit"]
  use_remote_gateways          = each.value["use_remote_gateways"]
}