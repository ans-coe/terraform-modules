data "azurerm_virtual_network" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "main" {
  for_each = toset(data.azurerm_virtual_network.main.subnets)

  name                 = each.value
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
}

data "azurerm_network_security_group" "main" {
  for_each = var.fetch_nsg ? toset(data.azurerm_subnet.*.network_security_group_id) : []

  name                = slice(split("/", each.value), length(split("/", each.value)) - 1, length(split("/", each.value)))
  resource_group_name = var.resource_group_name
}

data "azurerm_route_table" "main" {
  for_each = var.fetch_rt ? toset(data.azurerm_subnet.*.route_table_id) : []

  name                = slice(split("/", each.value), length(split("/", each.value)) - 1, length(split("/", each.value)))
  resource_group_name = var.resource_group_name
}
