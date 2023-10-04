##################
# Network Watcher
##################

### Conditions for resource group:
### If network_watcher_config.resource_group_name is specified = create network watcher RG
### If network_watcher_config.resource_group_name is unspecified = use default RG
###
### Since the hub module is designed to be ran as the first code within a region, no other resource groups should exist.
### So we can either use the main one or specify a new one.

resource "azurerm_resource_group" "network_watcher" {
  count = var.network_watcher_config.resource_group_name != null ? 1 : 0

  name     = var.network_watcher_config["resource_group_name"]
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_watcher" "main" {
  count = local.enable_network_watcher ? 1 : 0

  name                = var.network_watcher_config["name"] != null ? var.network_watcher_config["name"] : "nw_${var.location}"
  location            = var.location
  resource_group_name = var.network_watcher_config.resource_group_name != null ? azurerm_resource_group.network_watcher[count.index].name : azurerm_resource_group.main.name
  tags                = var.tags
}
