##################
# Network Watcher
##################

# Conditions for resource group:
# If network_watcher_resource_group is specified = create network watcher RG
# If network_watcher_resource_group is unspecified = spoke resource group

resource "azurerm_resource_group" "network_watcher" {
  count = var.network_watcher_resource_group != null ? 1 : 0

  name     = var.network_watcher_resource_group
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_watcher" "main" {
  count = var.create_network_watcher ? 1 : 0

  name                = var.network_watcher_name != null ? var.network_watcher_name : "nw-${var.location}"
  location            = var.location
  resource_group_name = var.network_watcher_resource_group != null ? var.network_watcher_resource_group : var.resource_group_name
  tags                = var.tags
}
