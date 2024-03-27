##########################
# Virtual Network Gateway
##########################

resource "azurerm_resource_group" "vng" {
  count = local.create_virtual_network_gateway_resource_group ? 1 : 0
  name  = var.virtual_network_gateway["resource_group_name"]


}

resource "azurerm_public_ip" "virtual_network_gateway" {
  count = local.enable_virtual_network_gateway ? 1 : 0

  name                = var.virtual_network_gateway["public_ip_name"] == null ? format("pip-%s", var.virtual_network_gateway["name"]) : var.virtual_network_gateway["public_ip_name"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  sku               = "Standard"
  allocation_method = "Static"
}

resource "azurerm_virtual_network_gateway" "main" {
  count = local.enable_virtual_network_gateway ? 1 : 0

  name                = var.virtual_network_gateway["name"]
  location            = var.location
  resource_group_name = try(var.virtual_network_gateway["resource_group_name"], null) != null ? var.virtual_network_gateway["resource_group_name"] : azurerm_resource_group.main.name
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
