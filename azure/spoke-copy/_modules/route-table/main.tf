##############
# Route Table
##############

resource "azurerm_route_table" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = var.disable_bgp_route_propagation
}


resource "azurerm_subnet_route_table_association" "main" {
  for_each = var.subnet_ids

  subnet_id      = each.key
  route_table_id = azurerm_route_table.main.id
}

resource "azurerm_route" "default" {
  for_each = var.routes

  name                = each.key
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.main.name

  address_prefix         = each.value["address_prefix"]
  next_hop_type          = each.value["next_hop_type"]
  next_hop_in_ip_address = each.value["next_hop_in_ip_address"]

  depends_on = [azurerm_route_table.main]
}