locals {
  network_security_group_config = {
    for key, subnet in var.subnets : key => merge({
      for k, nsg in module.network_security_group
      : key => {
        associate_nsg = true
      network_security_group_id = module.network_security_group["${subnet.subnet_nsg_name}"].id }
    if k == subnet.subnet_nsg_name })
  }

  subnets = {
    for key, props in var.subnets
    : key => merge(props, local.network_security_group_config[key][key])
  }

  default_route_table = module.global_route_table
  custom_route_tables = module.custom_route_tables

  route_tables = {
    for key, rts in local.default_route_table
    : key => merge(rts, local.custom_route_tables)
  }

  associate_global_rt_subnet_ids = [
    for subnet in var.subnets
    : (subnet.associate_global_route_table ? azurerm_subnet.main[subnet].id : null)
  ]

  associate_custom_rt_subnet_ids = {
    for key, route_table in var.route_tables
    : key => [for subnet in route_tables.subnets
    : azurerm_subnet.main[subnet].id]
  }
}