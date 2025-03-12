module "hub_route_table" {
  source = "../route-table"
  count  = alltrue(local.enable_firewall, var.create_hub_hub_route_table) ? 1 : 0

  name                = var.hub_route_table_name != null ? var.hub_route_table_name : "rt-hub-${module.network.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled

  subnet_ids = local.subnet_assoc_route_table

  default_route = local.default_route

  routes = var.extra_routes
}