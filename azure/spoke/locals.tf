locals {
  network_security_group_config = var.network_security_group_name != null ? {
    associate_nsg             = true
    network_security_group_id = one(module.network_security_group[*].id)
  } : {}

  route_table_config = var.route_table_name != null ? {
    associate_rt   = true
    route_table_id = one(azurerm_route_table.main[*].id)
  } : {}

  subnets = {
    for key, props in var.subnets
    : key => merge(props, local.network_security_group_config, local.route_table_config)
  }
}