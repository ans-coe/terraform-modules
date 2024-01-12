locals {
  subnet_assoc_network_security_group = [
    for k, s in var.subnets
    : azurerm_subnet.main[k].id
    if s.associate_default_network_security_group == true
  ]

  subnet_assoc_route_table = [
    for k, s in var.subnets
    : azurerm_subnet.main[k].id
    if s.associate_default_route_table == true
  ]
}