locals {
  routes = {
    for key, rts in azurerm_route.default
    : key => merge(rts, azurerm_route.custom)
  }
}