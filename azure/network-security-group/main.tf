#########################
# Network Security Group
#########################

resource "azurerm_network_security_group" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#########################
# Subnet NSG Association 
#########################

resource "azurerm_subnet_network_security_group_association" "main" {
  count = length(var.subnet_ids)

  subnet_id                 = var.subnet_ids[count.index]
  network_security_group_id = azurerm_network_security_group.main.id
}

############
# NSG Rules
############

resource "azurerm_network_security_rule" "inbound" {
  for_each = local.rules_inbound

  name                        = each.value.name
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name

  description = each.value.description
  direction   = "Inbound"
  access      = each.value.access
  priority    = each.value.priority == null ? (var.start_priority + (index(keys(local.rules_inbound), each.key) * var.priority_interval)) : each.value.priority

  protocol = each.value.protocol

  source_address_prefix                 = length(each.value.source_prefixes) == 1 ? one(each.value.source_prefixes) : null
  source_address_prefixes               = length(each.value.source_prefixes) == 1 ? null : each.value.source_prefixes
  source_port_range                     = "*"
  source_application_security_group_ids = each.value.source_application_security_group_ids

  destination_address_prefix                 = length(each.value.destination_prefixes) > 1 ? null : one(each.value.destination_prefixes)
  destination_port_range                     = length(each.value.ports) > 1 ? null : one(each.value.ports)
  destination_address_prefixes               = length(each.value.destination_prefixes) > 1 ? each.value.destination_prefixes : null
  destination_port_ranges                    = length(each.value.ports) > 1 ? each.value.ports : null
  destination_application_security_group_ids = each.value.destination_application_security_group_ids
}

resource "azurerm_network_security_rule" "outbound" {
  for_each = local.rules_outbound

  name                        = each.value.name
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name

  description = each.value.description
  direction   = "Outbound"
  access      = each.value.access
  priority    = each.value.priority == null ? (var.start_priority + (index(keys(local.rules_outbound), each.key) * var.priority_interval)) : each.value.priority

  protocol = each.value.protocol

  source_address_prefix                 = length(each.value.source_prefixes) == 1 ? one(each.value.source_prefixes) : null
  source_address_prefixes               = length(each.value.source_prefixes) == 1 ? null : each.value.source_prefixes
  source_port_range                     = "*"
  source_application_security_group_ids = each.value.source_application_security_group_ids

  destination_address_prefix                 = length(each.value.destination_prefixes) > 1 ? null : one(each.value.destination_prefixes)
  destination_port_range                     = length(each.value.ports) > 1 ? null : one(each.value.ports)
  destination_address_prefixes               = length(each.value.destination_prefixes) > 1 ? each.value.destination_prefixes : null
  destination_port_ranges                    = length(each.value.ports) > 1 ? each.value.ports : null
  destination_application_security_group_ids = each.value.destination_application_security_group_ids
}

############
# Flow Logs
############

resource "azurerm_network_watcher_flow_log" "main" {
  count = var.enable_flow_log ? 1 : 0

  name                      = var.flow_log_config["name"]
  network_security_group_id = azurerm_network_security_group.main.id
  tags                      = var.tags

  enabled              = true
  version              = var.flow_log_config["version"]
  network_watcher_name = var.flow_log_config["network_watcher_name"]
  resource_group_name  = var.flow_log_config["network_watcher_resource_group_name"]
  storage_account_id   = var.flow_log_config["storage_account_id"]

  dynamic "traffic_analytics" {
    for_each = var.flow_log_config["enable_analytics"] ? [1] : []
    content {
      enabled             = true
      interval_in_minutes = var.flow_log_config["analytics_interval_minutes"]

      workspace_resource_id = var.flow_log_config["workspace_resource_id"]
      workspace_region      = var.flow_log_config["workspace_region"]
      workspace_id          = var.flow_log_config["workspace_id"]
    }
  }

  dynamic "retention_policy" {
    for_each = var.flow_log_config["retention_days"] > 0 ? [1] : []
    content {
      enabled = true
      days    = var.flow_log_config["retention_days"]
    }
  }

  depends_on = [azurerm_network_security_group.main]
}