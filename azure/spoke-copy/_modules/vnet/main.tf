##################
# Virtual Network
##################

resource "azurerm_virtual_network" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  address_space = var.address_space

  bgp_community = var.bgp_community
  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id == null ? [] : [1]
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }
}

resource "azurerm_virtual_network_dns_servers" "main" {
  count = length(var.dns_servers) > 0 ? 1 : 0

  virtual_network_id = azurerm_virtual_network.main.id
  dns_servers        = var.include_azure_dns ? concat(var.dns_servers, [local.azure_dns_ip]) : var.dns_servers
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = var.private_dns_zones

  name                  = azurerm_virtual_network.main.name
  resource_group_name   = each.value["resource_group_name"]
  tags                  = var.tags
  virtual_network_id    = azurerm_virtual_network.main.id
  private_dns_zone_name = each.key

  registration_enabled = each.value["registration_enabled"]
}