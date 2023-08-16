#############
# Resource Group
#############

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

############
# Spoke VNet
############

module "network" {
  source  = "ans-coe/virtual-network/azurerm"
  version = "1.3.0"

  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  address_space = var.address_space
  subnets       = local.subnets

  peer_networks = var.hub_virtual_network_id != null ? {
    "hub" = {
      id                  = var.hub_virtual_network_id
      use_remote_gateways = var.use_remote_gateways
    }
  } : {}
}

module "network_security_group" {
  count  = var.network_security_group_name != null ? 1 : 0
  source = "git::https://github.com/ans-coe/terraform-modules.git//azure/network-security-group/?ref=745f0256ad0499aefe97f7b2a8b7e6027ec92e88"

  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_route_table" "main" {
  count = var.route_table_name != null ? 1 : 0

  name                = var.route_table_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_route" "main_default" {
  count = var.route_table_name != null ? 1 : 0

  name                = "default"
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.main[count.index].name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.default_route_ip
}
