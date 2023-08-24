##########################
# Birtual Network Gateway
##########################

resource "azurerm_public_ip" "virtual_network_gateway" {
  count = local.enable_virtual_network_gateway ? 1 : 0

  name                = var.virtual_network_gateway_config["public_ip_name"] == null ? format("pip-%s", var.virtual_network_gateway_config["name"]) : var.virtual_network_gateway_config["public_ip_name"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  sku               = "Standard"
  allocation_method = "Static"
}

resource "azurerm_virtual_network_gateway" "main" {
  count = local.enable_virtual_network_gateway ? 1 : 0

  name                = var.virtual_network_gateway_config["name"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  generation = var.virtual_network_gateway_config["generation"]
  sku        = var.virtual_network_gateway_config["sku"]
  type       = var.virtual_network_gateway_config["type"]
  vpn_type   = var.virtual_network_gateway_config["vpn_type"]

  ip_configuration {
    name                 = "default"
    subnet_id            = local.virtual_network_gateway_subnet.id
    public_ip_address_id = azurerm_public_ip.virtual_network_gateway[count.index].id
  }
}
