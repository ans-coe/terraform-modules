locals {
  routes = {
    for key, rts in azurerm_route.main
    : key => merge(rts, one(azurerm_route.default))
  }
}