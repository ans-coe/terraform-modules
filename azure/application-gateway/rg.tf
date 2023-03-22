resource "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 1 : 0

  name     = var.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 0 : 1

  name = var.resource_group_name
}
