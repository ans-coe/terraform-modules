locals {
#   network_security_group_config = {
#     for key, subnet in var.subnets : key => merge({
#       for k, nsg in module.network_security_group
#       : key => {
#         associate_nsg = true
#       network_security_group_id = module.network_security_group["${subnet.subnet_nsg_name}"].id }
#     if k == subnet.subnet_nsg_name })
#   }

#   subnets = {
#     for key, props in var.subnets
#     : key => merge(props, local.network_security_group_config[key][key])
#   }

#   default_route_table = azurerm_route_table.default
#   custom_route_tables = azurerm_route_table.custom

#   route_tables = {
#     for key, rts in local.default_route_table
#     : key => merge(rts, local.custom_route_tables)
#   }

  enable_network_watcher = var.network_watcher_config.name != null
}