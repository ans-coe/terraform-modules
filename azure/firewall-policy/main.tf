#############
# Firewall Policy
#############

resource "azurerm_firewall_policy" "main" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku
  base_policy_id           = var.base_policy_id
  threat_intelligence_mode = var.threat_intelligence_mode

  dns {
    servers       = var.dns.servers
    proxy_enabled = var.dns.proxy_enabled
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = each.value.threat_intelligence_allow_list != null ? [each.value.threat_intelligence_allowlist] : []
    content {
      ip_addresses = each.value.ip_addresses
      fqdns        = each.value.fqdns
    }
  }
}

#############
# Firewall Policy Rule Collection Group
#############
resource "azurerm_firewall_policy_rule_collection_group" "main" {
  for_each = var.rule_collection_groups

  name               = each.key
  priority           = each.value.priority
  firewall_policy_id = azurerm_firewall_policy.main[var.name].id

  dynamic "application_rule_collection" {
    for_each = each.value.application_rule_collection

    content {
      name     = application_rule_collection.key
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action
      dynamic "rule" {
        for_each = application_rule_collection.value.rule

        content {
          name                  = rule.key
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_urls      = rule.value.destination_urls
          destination_fqdns     = rule.value.destination_fqdns
          destination_fqdn_tags = rule.value.destination_fqdn_tags

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              port = protocols.key
              type = protocols.value
            }
          }
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = each.value.network_rule_collection

    content {
      name     = network_rule_collection.key
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rule

        content {
          name                  = rule.key
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
    for_each = each.value.nat_rule_collection
    content {
      name     = nat_rule_collection.key
      priority = nat_rule_collection.value.priority
      action   = "Dnat"

      dynamic "rule" {
        for_each = nat_rule_collection.value.rule
        content {
          name                = rule.key
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