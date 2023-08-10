#############
# Firewall Policy
#############
resource "azurerm_firewall_policy" "main" {
  for_each                 = var.firewall_policies
  name                     = each.key
  resource_group_name      = each.value.resource_group_name
  location                 = each.value.location
  sku                      = each.value.sku
  base_policy_id           = each.value.base_policy_id
  threat_intelligence_mode = each.value.threat_intelligence_mode

  dns {
    servers       = each.value.dns.servers
    proxy_enabled = each.value.dns.proxy_enabled
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = each.value.threat_intelligence_allow_list != null ? [each.value.threat_intelligence_allowlist] : []
    content {
      ip_addresses = each.value.ip_addresses
      fqdns        = each.value.fqdns
    }
  }
}

locals {
  rule_collection_map = merge([
    for policy_name, collection_group_map in {
    for k, v in var.firewall_policies : k => v.rule_collection_groups }
    : { for k, v in collection_group_map
  : k => merge(v, { policy_name = policy_name }) }]...)
}

#############
# Firewall Policy Rule Collection Group
#############
resource "azurerm_firewall_policy_rule_collection_group" "main" {
  for_each = local.rule_collection_map
  
  # merge([
  #   for policy_name, collection_group_map in {
  #   for k, v in var.firewall_policies : k => v.rule_collection_groups }
  #   : { for k, v in collection_group_map
  # : k => merge(v, { policy_name = policy_name }) }]...)

  name               = each.key
  priority           = each.value.priority
  #firewall_policy_id = azurerm_firewall_policy.main[each.value.policy_name].id

  dynamic "application_rule_collection" {
    for_each = 
    content {
      name     = application_rule_collection.key
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rule
        content {
          name = rule.key
          dynamic "protocols" {
            for_each = protocols.key
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
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
      action   = nat_rule_collection.value.action

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