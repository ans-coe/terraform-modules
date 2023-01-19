##################
# Virtual Network
##################

resource "azurerm_virtual_network" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  address_space = var.address_space
  dns_servers   = var.dns_servers

  bgp_community = var.bgp_community
  dynamic "ddos_protection_plan" {
    for_each = toset(var.ddos_protection_plan_id == null ? [] : [true])

    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }
}

##########
# Subnets
##########

resource "azurerm_subnet" "main" {
  for_each = { for s in var.subnets : s.name => s }

  name                 = each.value.name
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name

  address_prefixes = [each.value.prefix]

  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegations == null ? {} : each.value.delegations

    content {
      name = delegation.key

      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}

# Associations

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = var.subnet_network_security_group_map

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = each.value
}

resource "azurerm_subnet_route_table_association" "main" {
  for_each = var.subnet_route_table_map

  subnet_id      = azurerm_subnet.main[each.key].id
  route_table_id = each.value
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  for_each = var.subnet_nat_gateway_map

  subnet_id      = azurerm_subnet.main[each.key].id
  nat_gateway_id = each.value
}
