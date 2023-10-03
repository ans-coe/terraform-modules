##################
# Network Watcher
##################

resource "azurerm_resource_group" "network_watcher" {
  for_each = var.network_watcher_config.resource_group_name != null ? [0] : []

  name     = var.network_watcher_config["resource_group_name"] != null ? var.network_watcher_config["resource_group_name"] : "NetworkWatcherRG_${var.location}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_watcher" "main" {
  count = local.enable_network_watcher ? 1 : 0

  name                = var.network_watcher_config["name"] != null ? var.network_watcher_config["name"] : "nw_${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_watcher[count.index].name
  tags                = var.tags
}
