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

#########################
# Network Security Group
#########################

module "network_security_group" {
  count  = var.create_default_network_security_group ? 1 : 0
  source = "../network-security-group"

  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Awaiting future change to network_security_group module
  # subnets = [for v in var.subnets : azurerm_subnet.main[v.key].id if v.associate_default_route_table == "true" ]

  tags           = var.tags
  rules_inbound  = var.nsg_rules_inbound
  rules_outbound = var.nsg_rules_outbound
}

##############
# Route Table
##############

resource "azurerm_route_table" "default" {
  count = var.create_default_route_table ? 1 : 0

  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = var.disable_bgp_route_propagation
}

#########
# Routes
#########

resource "azurerm_route" "default" {
  count = var.create_default_route_table ? 1 : 0

  name                = var.default_route_name
  resource_group_name = var.resource_group_name
  route_table_name    = var.route_table_name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.default_route_ip

  depends_on = [azurerm_route_table.default]
}

resource "azurerm_route" "custom" {
  for_each = var.routes

  name                = each.key
  resource_group_name = var.resource_group_name
  route_table_name    = var.route_table_name

  address_prefix         = each.value["address_prefix"]
  next_hop_type          = each.value["next_hop_type"]
  next_hop_in_ip_address = each.value["next_hop_in_ip_address"]

  depends_on = [azurerm_route_table.default]
}

##########################
# Route Table Association
##########################

resource "azurerm_subnet_route_table_association" "main" {
  for_each = { for k, v in var.subnets : k => v if v.associate_default_route_table }

  subnet_id      = azurerm_subnet.main[each.key].id
  route_table_id = azurerm_route_table.default[0].id
}

##################
# Network Watcher
##################

### Conditions for resource group:
### If network_watcher_config.resource_group_name is specified = create network watcher RG
### If network_watcher_config.resource_group_name is unspecified = spoke resource group

resource "azurerm_resource_group" "network_watcher" {
  count = var.network_watcher_config.resource_group_name != null ? 1 : 0

  name     = var.network_watcher_config["resource_group_name"]
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_watcher" "main" {
  count = local.enable_network_watcher ? 1 : 0

  name                = var.network_watcher_config["name"] != null ? var.network_watcher_config["name"] : "nw-${var.virtual_network_name}"
  location            = var.location
  resource_group_name = var.network_watcher_config.resource_group_name != null ? azurerm_resource_group.network_watcher[count.index].name : var.resource_group_name
  tags                = var.tags
}

######################
# Peering back to Hub
######################

resource "azurerm_virtual_network_peering" "main" {
  for_each = var.hub_peering

  name                      = format("%s_to_%s", module.network.name, each.key)
  virtual_network_name      = module.network.id
  resource_group_name       = each.value["hub_resource_group_name"]
  remote_virtual_network_id = each.key

  allow_virtual_network_access = each.value["allow_virtual_network_access"]
  allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
  allow_gateway_transit        = each.value["allow_gateway_transit"]
  use_remote_gateways          = each.value["use_remote_gateways"]
}

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