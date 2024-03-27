##########################
# Virtual Network Gateway
##########################

resource "azurerm_resource_group" "virtual_network_gateway" {
  count = local.create_virtual_network_gateway_resource_group ? 1 : 0

  name     = var.virtual_network_gateway["resource_group_name"]
  location = var.location
  tags     = var.tags
}

resource "azurerm_public_ip" "virtual_network_gateway" {
  count = local.enable_virtual_network_gateway ? 1 : 0

  name                = var.virtual_network_gateway["public_ip_name"] == null ? format("pip-%s", var.virtual_network_gateway["name"]) : var.virtual_network_gateway["public_ip_name"]
  location            = var.location
  resource_group_name = local.virtual_network_gateway_resource_group_name
  tags                = var.tags

  sku               = "Standard"
  allocation_method = "Static"
}

resource "azurerm_route_table" "virtual_network_gateway" {
  count = local.use_virtual_network_gateway_route_table ? 1 : 0

  name                = var.virtual_network_gateway.route_table.name
  resource_group_name = local.virtual_network_gateway_resource_group_name
  location            = var.location
  tags                = var.tags

  route = [for name, route in var.virtual_network_gateway.route_table.routes : merge({ name = name }, route)]
}

resource "azurerm_virtual_network_gateway" "main" {
  count = local.enable_virtual_network_gateway ? 1 : 0

  name                = var.virtual_network_gateway["name"]
  location            = var.location
  resource_group_name = local.virtual_network_gateway_resource_group_name
  tags                = var.tags

  generation = var.virtual_network_gateway["generation"]
  sku        = var.virtual_network_gateway["sku"]
  type       = var.virtual_network_gateway["type"]
  vpn_type   = var.virtual_network_gateway["vpn_type"]

  ip_configuration {
    name                 = "default"
    subnet_id            = local.virtual_network_gateway_subnet.id
    public_ip_address_id = azurerm_public_ip.virtual_network_gateway[count.index].id
  }
}
