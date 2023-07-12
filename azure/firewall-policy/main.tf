#############
# Firewall Policy
#############
resource "azurerm_firewall_policy" "firewall-policy" {
  for_each                 = var.firewall_policies
  name                     = firewall_policies.value.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = firewall_policies.value.sku
  base_policy_id           = firewall_policies.value.base_policy_id
  threat_intelligence_mode = firewall_policies.value.threat_intelligence_mode

  dynamic "dns" {
    for_each = var.firewall_policies.dns != null ? [var.firewall_policies.dns] : []
    content {
      servers       = dns.value.servers
      proxy_enabled = dns.value.proxy_enabled
    }
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = var.firewall_policies.threat_intelligence_allow_list != null ? [var.firewall_policies.threat_intelligence_allow_list] : []
    content {
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses
      fqdns        = threat_intelligence_allowlist.value.fqdns
    }
  }
}

#############
# Firewall Policy Rule Collection Group
#############

resource "azurerm_firewall_policy_rule_collection_groups" "main" {
  for_each           = var.firewall_policy_rule_collection_groups
  name               = firewall_policy_rule_collection_groups.value.name
  priority           = firewall_policy_rule_collection_groups.value.priority
  firewall_policy_id = azurerm_firewall_policy.firewall-policy.main[each.firewall_policy_name].id

  dynamic "application_rule_collection" {
    for_each = var.firewall_policy_rule_collection_groups.application_rule_collection
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name = rule.value.name
          protocols {
            type = rule.value.protocol.type
            port = rule.value.protocol.port
          }
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_urls      = rule.value.destination_urls
          destination_fqdns     = rule.value.destination_fqdns
          destination_fqdn_tags = rule.value.destination_fqdn_tags
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = var.firewall_policy_rule_collection_groups.network_rule_collection
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value.name
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_ip_groups = rule.value.destination_ip_groups
          destination_fqdns     = rule.value.destination_fqdns
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = var.firewall_policy_rule_collection_groups.nat_rule_collection
    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules
        content {
          name                = rule.value.name
          protocols           = rule.value.protocols
          source_addresses    = rule.value.source_addresses
          source_ip_groups    = rule.value.source_ip_groups
          destination_address = rule.value.destination_address
          destination_ports   = rule.value.destination_ports
          translated_address  = rule.value.translated_address
          translated_fqdn     = rule.value.translated_fqdn
          translated_port     = rule.value.translated_port
        }
      }
    }
  }
}