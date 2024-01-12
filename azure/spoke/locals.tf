locals {
  routes = {
    for key, rts in azurerm_route.default
    : key => merge(rts, azurerm_route.custom)
  }

  enable_network_watcher = var.network_watcher_config != null
}
