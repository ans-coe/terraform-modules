###########
# Firewall
###########

module "firewall" {
  count  = local.enable_firewall ? 1 : 0
  source = "../firewall"

  firewall_name       = var.firewall_config["name"]
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  virtual_network_name    = module.network.name
  pip_name                = var.firewall_config["public_ip_name"] == null ? format("pip-%s", var.firewall_config["name"]) : var.firewall_config["public_ip_name"]
  subnet_address_prefixes = [var.firewall_config["subnet_prefix"]]

  firewall_sku_name  = "AZFW_VNet"
  firewall_sku_tier  = var.firewall_config["sku_tier"]
  firewall_policy_id = var.firewall_config["firewall_policy_id"]
}

resource "azurerm_route_table" "firewall" {
  count = local.enable_firewall ? 1 : 0

  name                = var.firewall_config["route_table_name"] != null ? var.firewall_config["route_table_name"] : "rt-hub-${module.network.name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  disable_bgp_route_propagation = true
}

resource "azurerm_route" "firewall" {
  count = local.enable_firewall ? 1 : 0

  name                = var.firewall_config.default_route_name
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.firewall[count.index].name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.firewall[count.index].private_ip
}
