resource "azurerm_web_application_firewall_policy" "main" {
  count = var.waf_configuration != null ? 1 : 0

  name                = var.waf_configuration.policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "custom_rules" {
    for_each = var.waf_configuration.custom_rules
    content {
      name      = custom_rules.key
      priority  = custom_rules.value["priority"]
      rule_type = "MatchRule"
      action    = custom_rules.value["action"]
      dynamic "match_conditions" {
        for_each = custom_rules.value["match_conditions"]

        content {
          dynamic "match_variables" {
            for_each = match_conditions.value["match_variables"]
            content {
              variable_name = match_variables.value["variable_name"]
              selector      = match_variables.value["selector"]
            }
          }
          match_values       = match_conditions.value["match_values"]
          operator           = match_conditions.value["operator"]
          negation_condition = match_conditions.value["negation_condition"]
          transforms         = match_conditions.value["transforms"]
        }
      }
    }
  }

  managed_rules {
    dynamic "exclusion" {
      for_each = var.waf_configuration.managed_rule_exclusion
      content {
        match_variable          = exclusion.value["match_variable"]
        selector_match_operator = exclusion.value["selector_match_operator"]
        selector                = exclusion.value["selector"]
      }
    }

    ## OWASP
    dynamic "managed_rule_set" {
      for_each = var.waf_configuration.enable_OWASP ? [0] : []
      content {
        type    = "OWASP"
        version = var.waf_configuration.OWASP_rule_set_version
        dynamic "rule_group_override" {
          for_each = var.waf_configuration.OWASP_rule_group_override
          content {
            rule_group_name = rule_group_override.key
            dynamic "rule" {
              for_each = rule_group_override.value
              content {
                id      = rule.key
                enabled = rule.value["enabled"]
                action  = rule.value["action"]
              }
            }
          }
        }
      }
    }

    ## Microsoft_BotManagerRuleSet

    dynamic "managed_rule_set" {
      for_each = var.waf_configuration.enable_Microsoft_BotManagerRuleSet ? [0] : []
      content {
        type    = "Microsoft_BotManagerRuleSet"
        version = var.waf_configuration.Microsoft_BotManagerRuleSet_rule_set_version
        dynamic "rule_group_override" {
          for_each = var.waf_configuration.Microsoft_BotManagerRuleSet_rule_group_override
          content {
            rule_group_name = rule_group_override.key
            dynamic "rule" {
              for_each = rule_group_override.value
              content {
                id      = rule.key
                enabled = rule.value["enabled"]
                action  = rule.value["action"]
              }
            }
          }
        }
      }
    }
  }

  policy_settings {
    enabled = true
    mode    = var.waf_configuration.firewall_mode
    # Global parameters
    request_body_check          = true
    max_request_body_size_in_kb = var.waf_configuration.max_request_body_size_kb
    file_upload_limit_in_mb     = var.waf_configuration.file_upload_limit_mb
  }
}

resource "azurerm_web_application_firewall_policy" "listener" {
  for_each = coalesce(var.listener_waf_configuration, {})

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "custom_rules" {
    for_each = each.value.custom_rules
    content {
      name      = custom_rules.key
      priority  = custom_rules.value["priority"]
      rule_type = "MatchRule"
      action    = custom_rules.value["action"]
      dynamic "match_conditions" {
        for_each = custom_rules.value["match_conditions"]

        content {
          dynamic "match_variables" {
            for_each = match_conditions.value["match_variables"]
            content {
              variable_name = match_variables.value["variable_name"]
              selector      = match_variables.value["selector"]
            }
          }
          match_values       = match_conditions.value["match_values"]
          operator           = match_conditions.value["operator"]
          negation_condition = match_conditions.value["negation_condition"]
          transforms         = match_conditions.value["transforms"]
        }
      }
    }
  }

  managed_rules {
    dynamic "exclusion" {
      for_each = each.value.managed_rule_exclusion
      content {
        match_variable          = exclusion.value["match_variable"]
        selector_match_operator = exclusion.value["selector_match_operator"]
        selector                = exclusion.value["selector"]
      }
    }

    ## OWASP
    dynamic "managed_rule_set" {
      for_each = each.value.enable_OWASP ? [0] : []
      content {
        type    = "OWASP"
        version = each.value.OWASP_rule_set_version
        dynamic "rule_group_override" {
          for_each = each.value.OWASP_rule_group_override
          content {
            rule_group_name = rule_group_override.key
            dynamic "rule" {
              for_each = rule_group_override.value
              content {
                id      = rule.key
                enabled = rule.value["enabled"]
                action  = rule.value["action"]
              }
            }
          }
        }
      }
    }

    ## Microsoft_BotManagerRuleSet

    dynamic "managed_rule_set" {
      for_each = each.value.enable_Microsoft_BotManagerRuleSet ? [0] : []
      content {
        type    = "Microsoft_BotManagerRuleSet"
        version = each.value.Microsoft_BotManagerRuleSet_rule_set_version
        dynamic "rule_group_override" {
          for_each = each.value.Microsoft_BotManagerRuleSet_rule_group_override
          content {
            rule_group_name = rule_group_override.key
            dynamic "rule" {
              for_each = rule_group_override.value
              content {
                id      = rule.key
                enabled = rule.value["enabled"]
                action  = rule.value["action"]
              }
            }
          }
        }
      }
    }
  }

  policy_settings {
    enabled = true
    mode    = each.value.firewall_mode
    # Global parameters
    request_body_check          = true
    request_body_enforcement    = each.value.request_body_enforcement
    max_request_body_size_in_kb = each.value.max_request_body_size_kb
    file_upload_limit_in_mb     = each.value.file_upload_limit_mb
  }
}

resource "azurerm_web_application_firewall_policy" "path_rule" {
  for_each = coalesce(var.path_rule_waf_configuration, {})

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "custom_rules" {
    for_each = each.value.custom_rules
    content {
      name      = custom_rules.key
      priority  = custom_rules.value["priority"]
      rule_type = "MatchRule"
      action    = custom_rules.value["action"]
      dynamic "match_conditions" {
        for_each = custom_rules.value["match_conditions"]

        content {
          dynamic "match_variables" {
            for_each = match_conditions.value["match_variables"]
            content {
              variable_name = match_variables.value["variable_name"]
              selector      = match_variables.value["selector"]
            }
          }
          match_values       = match_conditions.value["match_values"]
          operator           = match_conditions.value["operator"]
          negation_condition = match_conditions.value["negation_condition"]
          transforms         = match_conditions.value["transforms"]
        }
      }
    }
  }

  managed_rules {
    dynamic "exclusion" {
      for_each = each.value.managed_rule_exclusion
      content {
        match_variable          = exclusion.value["match_variable"]
        selector_match_operator = exclusion.value["selector_match_operator"]
        selector                = exclusion.value["selector"]
      }
    }

    ## OWASP
    dynamic "managed_rule_set" {
      for_each = each.value.enable_OWASP ? [0] : []
      content {
        type    = "OWASP"
        version = each.value.OWASP_rule_set_version
        dynamic "rule_group_override" {
          for_each = each.value.OWASP_rule_group_override
          content {
            rule_group_name = rule_group_override.key
            dynamic "rule" {
              for_each = rule_group_override.value
              content {
                id      = rule.key
                enabled = rule.value["enabled"]
                action  = rule.value["action"]
              }
            }
          }
        }
      }
    }

    ## Microsoft_BotManagerRuleSet

    dynamic "managed_rule_set" {
      for_each = each.value.enable_Microsoft_BotManagerRuleSet ? [0] : []
      content {
        type    = "Microsoft_BotManagerRuleSet"
        version = each.value.Microsoft_BotManagerRuleSet_rule_set_version
        dynamic "rule_group_override" {
          for_each = each.value.Microsoft_BotManagerRuleSet_rule_group_override
          content {
            rule_group_name = rule_group_override.key
            dynamic "rule" {
              for_each = rule_group_override.value
              content {
                id      = rule.key
                enabled = rule.value["enabled"]
                action  = rule.value["action"]
              }
            }
          }
        }
      }
    }
  }

  policy_settings {
    enabled = true
    mode    = each.value.firewall_mode
    # Global parameters
    request_body_check          = true
    max_request_body_size_in_kb = each.value.max_request_body_size_kb
    file_upload_limit_in_mb     = each.value.file_upload_limit_mb
  }
}