#############
# Network
#############

resource "azurerm_public_ip" "main" {
  name                = var.pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_subnet" "main" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_address_prefix
}

#############
# Firewall
#############

resource "azurerm_firewall" "main" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  dns_servers         = var.firewall_dns_servers
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.main.id
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

#############
# Firewall Policy
#############
resource "azurerm_firewall_policy" "firewall-policy" {
  name                     = var.firewall_policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.firewall_policy_sku
  base_policy_id           = var.firewall_policy_base_policy_id
  threat_intelligence_mode = var.firewall_policy_threat_intelligence_mode

  dynamic "dns" {
    for_each = var.firewall_policy_dns != null ? [var.firewall_policy_dns] : []
    content {
      servers       = dns.value.servers
      proxy_enabled = dns.value.proxy_enabled
    }
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = var.firewall_policy_threat_intelligence_allow_list != null ? [var.firewall_policy_threat_intelligence_allow_list] : []
    content {
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses
      fqdns        = threat_intelligence_allowlist.value.fqdns
    }
  }
}

#############
# Firewall Rules (Network, Application, NAT)
#############

resource "azurerm_firewall_application_rule_collection" "firewall_app_rules" {
  for_each            = local.fw_application_rules
  name                = lower(format("firewall_app_rule-%s-${var.firewall_name}-${var.location}", each.key))
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name             = each.key
    description      = each.value.rule.description
    source_addresses = each.value.rule.source_addresses
    source_ip_groups = each.value.rule.source_ip_groups
    fqdn_tags        = each.value.rule.fqdn_tags
    target_fqdns     = each.value.rule.target_fqdns

    protocol {
      type = each.value.rule.protocol.type
      port = each.value.rule.protocol.port
    }
  }
}


resource "azurerm_firewall_network_rule_collection" "firewall_network_rules" {
  for_each            = local.fw_network_rules
  name                = lower(format("firewall_network_rules-%s-${var.firewall_name}-${var.location}", each.key))
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name                  = each.key
    description           = each.value.rule.description
    source_addresses      = each.value.rule.source_addresses
    destination_ports     = each.value.rule.destination_ports
    destination_addresses = each.value.rule.destination_addresses
    destination_fqdns     = each.value.rule.destination_fqdns
    protocols             = each.value.rule.protocols
  }
}

resource "azurerm_firewall_nat_rule_collection" "firewall_nat_rules" {
  for_each            = local.fw_nat_rules
  name                = lower(format("firewall_nat_rules-%s-${var.firewall_name}-${var.location}", each.key))
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name                  = each.key
    description           = each.value.rule.description
    source_addresses      = each.value.rule.source_addresses
    destination_ports     = each.value.rule.destination_ports
    destination_addresses = each.value.rule.destination_addresses
    protocols             = each.value.rule.protocols
    translated_address    = each.value.rule.translated_address
    translated_port       = each.value.rule.translated_port
  }
}

#############
# Monitoring
#############

# resource "azurerm_monitor_diagnostic_setting" "firewall-pip-diag" {
#   name                       = "${var.firewall_name}-pip-diag"
#   target_resource_id         = azurerm_public_ip.main.id
#   storage_account_id         = var.log_storage_account_name
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = var.firewall_pip_diag_logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = false
#         days    = 0
#       }
#     }
#   }

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = false
#       days    = 0
#     }
#   }

#   lifecycle {
#     ignore_changes = [log, metric]
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "firewall-diag" {
#   name                       = "${var.firewall_name}-diag"
#   target_resource_id         = azurerm_firewall.main.id
#   storage_account_id         = var.log_storage_account_name
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = var.firewall_diag_logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = false
#         days    = 0
#       }
#     }
#   }

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = false
#       days    = 0
#     }
#   }

#   lifecycle {
#     ignore_changes = [log, metric]
#   }
# }