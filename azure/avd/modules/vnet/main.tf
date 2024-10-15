resource "azurerm_virtual_network" "vnet" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  address_space           = var.virtual_network_address_space
  dns_servers             = var.virtual_network_dns_servers
  bgp_community           = var.virtual_network_bgp_community
  edge_zone               = var.virtual_network_edge_zone
  flow_timeout_in_minutes = var.virtual_network_flow_timeout_in_minutes
  tags                    = merge(var.default_tags, var.extra_tags)

  dynamic "ddos_protection_plan" {
    for_each = var.virtual_network_ddos_protection_plan != null ? [var.virtual_network_ddos_protection_plan] : []

    content {
      enable = ddos_protection_plan.value.enable
      id     = ddos_protection_plan.value.id
    }
  }
}
