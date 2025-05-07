resource "azurerm_private_endpoint" "private_endpoint" {
  name     = var.private_endpoint_name
  location = var.location

  resource_group_name = var.resource_group_name

  custom_network_interface_name = var.custom_private_endpoint_nic_name

  subnet_id = var.subnet_id

  dynamic "ip_configuration" {
    for_each = var.ip_configurations
    content {
      name               = ip_configuration.value.name
      member_name        = local.is_not_private_link_service ? ip_configuration.value.member_name : null
      subresource_name   = local.is_not_private_link_service ? coalesce(ip_configuration.value.subresource_name, var.subresource_name) : null
      private_ip_address = ip_configuration.value.private_ip_address
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = local.is_not_private_link_service ? ["enabled"] : []
    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = var.private_dns_zones_ids
    }
  }

  private_service_connection {
    name                              = var.private_service_connection_name
    is_manual_connection              = var.is_manual_connection
    request_message                   = var.is_manual_connection ? var.request_message : null
    private_connection_resource_id    = local.resource_id
    private_connection_resource_alias = local.resource_alias
    subresource_names                 = var.subresource_name
  }

  tags = merge(var.default_tags, var.extra_tags)
}
