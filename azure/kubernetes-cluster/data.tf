data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
}
