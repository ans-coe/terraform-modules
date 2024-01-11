##############
# Route Table
##############

resource "azurerm_route_table" "main" {

  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = var.disable_bgp_route_propagation
}

#########
# Routes
#########

resource "azurerm_route" "main" {
  for_each = var.route

  name                = each.key
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.main.name

  address_prefix         = each.value["address_prefix"]
  next_hop_type          = each.value["next_hop_type"]
  next_hop_in_ip_address = each.value["next_hop_in_ip_address"]
}

##########################
# Route Table Association
##########################

resource "azurerm_subnet_route_table_association" "main" {
  for_each = var.subnet_ids

  subnet_id      = each.value
  route_table_id = azurerm_route_table.main.id
}