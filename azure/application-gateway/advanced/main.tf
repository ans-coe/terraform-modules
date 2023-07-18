resource "azurerm_public_ip" "main" {
  count = var.create_public_ip ? 1 : 0

  name                = var.pip_name != null ? var.pip_name : "pip-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

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
    managed_rule_set {
      type    = var.waf_configuration.rule_set_type
      version = var.waf_configuration.rule_set_version
      dynamic "rule_group_override" {
        for_each = var.waf_configuration.rule_group_override
        content {
          rule_group_name = rule_group_override.key
          dynamic "rule" {
            for_each = rule_group_override.value
            content {
              id = rule.key
              enabled = rule.value["enabled"]
              action = rule.value["action"]
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

resource "azurerm_application_gateway" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  enable_http2        = var.enable_http2

  firewall_policy_id                = var.waf_configuration != null ? azurerm_web_application_firewall_policy.main[0].id : null
  force_firewall_policy_association = var.waf_configuration != null

  gateway_ip_configuration {
    name      = "ApplicationGatewayIP"
    subnet_id = var.subnet_id
  }

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = local.enable_autoscaling ? null : var.sku.capacity
  }

  dynamic "autoscale_configuration" {
    for_each = local.enable_autoscaling ? [0] : []

    content {
      min_capacity = var.sku.capacity
      max_capacity = var.sku.max_capacity
    }
  }

  ssl_policy {
    policy_name = var.ssl_policy
    policy_type = "Predefined"
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.key
      ip_addresses = backend_address_pool.value["ip_addresses"]
      fqdns        = backend_address_pool.value["fqdns"]
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.key
      port                                = backend_http_settings.value["port"]
      protocol                            = backend_http_settings.value["https_enabled"] ? "Https" : "Http"
      cookie_based_affinity               = backend_http_settings.value["cookie_based_affinity"] ? "Enabled" : "Disabled"
      affinity_cookie_name                = backend_http_settings.value["cookie_based_affinity"] ? backend_http_settings.value["affinity_cookie_name"] : null
      probe_name                          = backend_http_settings.value["probe_name"]
      host_name                           = backend_http_settings.value["host_name"]
      pick_host_name_from_backend_address = backend_http_settings.value["pick_host_name_from_backend_address"]
      request_timeout                     = backend_http_settings.value["request_timeout"]
      trusted_root_certificate_names      = backend_http_settings.value["trusted_root_certificate_names"]
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_ip != null ? [0] : []

    content {
      name                          = "private_frontend"
      private_ip_address            = var.private_ip
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "Static"
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.create_public_ip ? [0] : []

    content {
      name                 = "public_frontend"
      public_ip_address_id = azurerm_public_ip.main[0].id
    }
  }

  # Frontend Configuration

  dynamic "frontend_port" {
    for_each = local.default_frontend_ports
    content {
      name = frontend_port.key
      port = frontend_port.value
    }
  }

  dynamic "frontend_port" {
    for_each = var.additional_frontend_ports
    content {
      name = frontend_port.key
      port = frontend_port.value
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = http_listener.value["frontend_ip_configuration_name"]
      frontend_port_name             = http_listener.value["frontend_port_name"]
      protocol                       = http_listener.value["https_enabled"] ? "Https" : "Http"
      require_sni                    = alltrue([http_listener.value["https_enabled"],length(http_listener.value["host_names"]) != 0])
      host_name = alltrue([
        length(http_listener.value["host_names"]) == 1,                                                           // Check to make sure there is only 1 hostname in the list
        length(regexall("^(\\*\\.){1}([\\w-]+\\.)+[\\w-]+$", try(http_listener.value["host_names"][0], ""))) == 0 // AND Check to make sure our host is not a wildcard
      ]) ? http_listener.value["host_names"][0] : null
      host_names = anytrue([
        length(http_listener.value["host_names"]) > 1,                                                           // Check if there is more than 1 hostname in the list
        length(regexall("^(\\*\\.){1}([\\w-]+\\.)+[\\w-]+$", try(http_listener.value["host_names"][0], ""))) > 0 // OR check if the single hostname is a wildcard
      ]) ? http_listener.value["host_names"] : null
      ssl_certificate_name = http_listener.value["ssl_certificate_name"]
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name = ssl_certificate.key
      // For the below, if we have a condition where there is no automatically generated keyvault certificate and no user defined certificate, then we want to fall back to a regular file
      data     = alltrue([!var.use_key_vault, ssl_certificate.value["data"] == null, ssl_certificate.value["key_vault_secret_id"] == null]) ? filebase64("files/selfsigned.pfx") : ssl_certificate.value["data"]
      password = alltrue([!var.use_key_vault, ssl_certificate.value["data"] == null, ssl_certificate.value["key_vault_secret_id"] == null]) ? "default" : ssl_certificate.value["password"]
      // If key_vault_secret_id isn't defined, then use the secretid of the generated keyvault instead
      key_vault_secret_id = alltrue([
        ssl_certificate.value["key_vault_secret_id"] == null,
        ssl_certificate.value["data"] == null,
        ssl_certificate.value["password"] == null
      ]) ? azurerm_key_vault_certificate.main[ssl_certificate.key].secret_id : ssl_certificate.value["key_vault_secret_id"]
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificate
    content {
      name = trusted_root_certificate.key
      data = trusted_root_certificate.value["data"]
    }
  }

  dynamic "url_path_map" {
    // we create a list of maps that are then unlisted and merged but only if path_rules is set
    for_each = merge([
      for listener_name, routing_map in {
      for k, v in var.http_listeners : k => v.routing }
      : { for k, v in routing_map
    : k => merge(v, { listener_name = listener_name }) if v.path_rules != null }]...)
    content {
      name                               = "${url_path_map.value.listener_name}_${url_path_map.key}_urlpathmap"
      default_backend_address_pool_name  = url_path_map.value["backend_address_pool_name"]
      default_backend_http_settings_name = url_path_map.value["backend_http_settings_name"]
      dynamic "path_rule" {
        for_each = url_path_map.value["path_rules"]
        content {
          name                       = path_rule.key
          paths                      = path_rule.value["paths"]
          backend_address_pool_name  = path_rule.value["backend_address_pool_name"]
          backend_http_settings_name = path_rule.value["backend_http_settings_name"]
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    // we create a list of maps that are then delisted and merged.
    for_each = merge([
      for listener_name, routing_map in {
      for k, v in var.http_listeners : k => v.routing }
      : { for k, v in routing_map
    : k => merge(v, { listener_name = listener_name }) }]...)
    content {
      name               = request_routing_rule.key
      rule_type          = request_routing_rule.value["path_rules"] != null ? "PathBasedRouting" : "Basic"
      http_listener_name = request_routing_rule.value["listener_name"]
      backend_address_pool_name = alltrue([
        request_routing_rule.value["path_rules"] == null,
        request_routing_rule.value["redirect_configuration"] == null
      ]) ? request_routing_rule.value["backend_address_pool_name"] : null
      backend_http_settings_name = alltrue([
        request_routing_rule.value["path_rules"] == null,
        request_routing_rule.value["redirect_configuration"] == null
      ]) ? request_routing_rule.value["backend_http_settings_name"] : null
      url_path_map_name           = request_routing_rule.value["path_rules"] != null ? "${request_routing_rule.value.listener_name}_${request_routing_rule.key}_urlpathmap" : null
      priority                    = request_routing_rule.value["priority"]
      redirect_configuration_name = request_routing_rule.value["redirect_configuration"] != null ? "${request_routing_rule.value.listener_name}_${request_routing_rule.key}_redirectconfiguration" : null
    }
  }

  dynamic "redirect_configuration" {
    // we create a list of maps that are then unlisted and merged but only if redirect_configuration is set
    for_each = merge([
      for listener_name, routing_map in {
      for k, v in var.http_listeners : k => v.routing }
      : { for k, v in routing_map
    : k => merge(v, { listener_name = listener_name }) if v.redirect_configuration != null }]...)

    content {
      name                 = "${redirect_configuration.value.listener_name}_${redirect_configuration.key}_redirectconfiguration"
      redirect_type        = redirect_configuration.value.redirect_configuration["redirect_type"]
      target_listener_name = redirect_configuration.value.redirect_configuration["target_listener_name"]
      target_url           = redirect_configuration.value.redirect_configuration["target_url"]
      include_path         = redirect_configuration.value.redirect_configuration["include_path"]
      include_query_string = redirect_configuration.value.redirect_configuration["include_query_string"]
    }
  }

  dynamic "identity" {
    for_each = var.use_key_vault ? [0] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.main_gateway[0].id]
    }
  }

  dynamic "probe" {
    for_each = var.probe
    content {
      name                                      = probe.key
      protocol                                  = probe.value["https_enabled"] ? "Https" : "Http"
      interval                                  = probe.value["interval"]
      path                                      = probe.value["path"]
      host                                      = probe.value["host"]
      timeout                                   = probe.value["timeout"]
      unhealthy_threshold                       = probe.value["unhealthy_threshold"]
      port                                      = probe.value["port"]
      pick_host_name_from_backend_http_settings = probe.value["pick_host_name_from_backend_http_settings"]
      dynamic "match" {
        for_each = probe.value["match"]
        content {
          body        = match.value["body"]
          status_code = match.value["status_code"]
        }
      }
    }
  }
}