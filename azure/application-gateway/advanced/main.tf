resource "azurerm_public_ip" "main" {
  count = var.create_public_ip ? 1 : 0

  name                = var.pip_name != null ? var.pip_name : "pip-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
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
    name     = local.use_waf ? "WAF_v2" : "Standard_v2"
    tier     = local.use_waf ? "WAF_v2" : "Standard_v2"
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
      affinity_cookie_name                = backend_http_settings.value["affinity_cookie_name"]
      probe_name                          = backend_http_settings.value["probe_name"]
      host_name                           = backend_http_settings.value["host_name"]
      pick_host_name_from_backend_address = backend_http_settings.value["host_name"] == null ? backend_http_settings.value["pick_host_name_from_backend_address"] : false
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
      require_sni                    = alltrue([http_listener.value["https_enabled"], length(http_listener.value["host_names"]) != 0])
      host_name = alltrue([
        length(http_listener.value["host_names"]) == 1,                                                           // Check to make sure there is only 1 hostname in the list
        length(regexall("^(\\*\\.){1}([\\w-]+\\.)+[\\w-]+$", try(http_listener.value["host_names"][0], ""))) == 0 // AND Check to make sure our host is not a wildcard
      ]) ? http_listener.value["host_names"][0] : null
      host_names = anytrue([
        length(http_listener.value["host_names"]) > 1,                                                           // Check if there is more than 1 hostname in the list
        length(regexall("^(\\*\\.){1}([\\w-]+\\.)+[\\w-]+$", try(http_listener.value["host_names"][0], ""))) > 0 // OR check if the single hostname is a wildcard
      ]) ? http_listener.value["host_names"] : null
      ssl_certificate_name = http_listener.value["ssl_certificate_name"]
      firewall_policy_id   = try(azurerm_web_application_firewall_policy.listener[local.listener_policy_map[http_listener.key]].id, null)
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
      ]) ? azurerm_key_vault_certificate.main[ssl_certificate.key].versionless_secret_id : ssl_certificate.value["key_vault_secret_id"]
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
      name                               = "${url_path_map.value.listener_name}_${url_path_map.key}_upm"
      default_backend_address_pool_name  = url_path_map.value["backend_address_pool_name"]
      default_backend_http_settings_name = url_path_map.value["backend_http_settings_name"]
      default_rewrite_rule_set_name      = url_path_map.value["rewrite_rule_set_name"]
      dynamic "path_rule" {
        for_each = url_path_map.value["path_rules"]
        content {
          name                       = path_rule.key
          paths                      = path_rule.value["paths"]
          backend_address_pool_name  = path_rule.value["backend_address_pool_name"]
          backend_http_settings_name = path_rule.value["backend_http_settings_name"]
          rewrite_rule_set_name      = path_rule.value["rewrite_rule_set_name"]
          firewall_policy_id         = try(azurerm_web_application_firewall_policy.path_rule[local.path_rule_policy_map[path_rule.key]].id, null)
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
      rewrite_rule_set_name = alltrue([
        request_routing_rule.value["path_rules"] == null,
        request_routing_rule.value["redirect_configuration"] == null
      ]) ? request_routing_rule.value["rewrite_rule_set_name"] : null
      url_path_map_name           = request_routing_rule.value["path_rules"] != null ? "${request_routing_rule.value.listener_name}_${request_routing_rule.key}_upm" : null
      priority                    = request_routing_rule.value["priority"]
      redirect_configuration_name = request_routing_rule.value["redirect_configuration"] != null ? "${request_routing_rule.value.listener_name}_${request_routing_rule.key}_rc" : null
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
      name                 = "${redirect_configuration.value.listener_name}_${redirect_configuration.key}_rc"
      redirect_type        = redirect_configuration.value.redirect_configuration["redirect_type"]
      target_listener_name = redirect_configuration.value.redirect_configuration["target_listener_name"]
      target_url           = redirect_configuration.value.redirect_configuration["target_url"]
      include_path         = redirect_configuration.value.redirect_configuration["include_path"]
      include_query_string = redirect_configuration.value.redirect_configuration["include_query_string"]
    }
  }

  # rewrite_rule_set = {
  #   rule_set_1 = {
  #     rule_1 = {
  #     }
  #     rule_2 = {
  #     }
  #   }
  # }

  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_set
    content {
      name = rewrite_rule_set.key
      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value
        content {
          name          = rewrite_rule.key
          rule_sequence = rewrite_rule.value["rule_sequence"]

          dynamic "condition" {
            for_each = rewrite_rule.value["condition"]
            content {
              variable    = condition.value["variable"]
              pattern     = condition.value["pattern"]
              ignore_case = condition.value["ignore_case"]
              negate      = condition.value["negate"]
            }
          }
          dynamic "request_header_configuration" {
            for_each = rewrite_rule.value["request_header_configuration"]
            content {
              header_name  = request_header_configuration.key
              header_value = request_header_configuration.value
            }
          }
          dynamic "response_header_configuration" {
            for_each = rewrite_rule.value["response_header_configuration"]
            content {
              header_name  = response_header_configuration.key
              header_value = response_header_configuration.value
            }
          }
          dynamic "url" {
            for_each = rewrite_rule.value["url"]
            content {
              path         = url.value["path"]
              query_string = url.value["query_string"]
              // The below works out like this: (c1 ? (c2 ? (c3 ? v1 : v2 ) : v3) : v4)
              components = (
                ((url.value["path"] != null) != (url.value["query_string"] != null)) ? // if one value is set but the other is not
                (url.value["path"] != null) ? "path_only" :                            // if the value that is set is path
                (url.value["query_string"] != null) ? "query_string_only" : null       // if the value that is set is query_string
                : null                                                                 // if both values are set or if neither value is set
              )
              reroute = url.value["reroute"]
            }
          }
        }
      }
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
      name     = probe.key
      protocol = probe.value["https_enabled"] ? "Https" : "Http"
      interval = probe.value["interval"]
      path     = probe.value["path"]
      host     = probe.value["host"]
      // Only one of host or pick_host_name_from_backend_http_settings can be set and at least one is required.
      pick_host_name_from_backend_http_settings = probe.value["host"] == null ? true : false
      timeout                                   = probe.value["timeout"]
      unhealthy_threshold                       = probe.value["unhealthy_threshold"]
      port                                      = probe.value["port"]
      dynamic "match" {
        for_each = probe.value["match"]
        content {
          body        = match.value["body"]
          status_code = match.value["status_code"]
        }
      }
    }
  }
  lifecycle {
    precondition {
      error_message = "For every backend_http_setting, both the backend_http_settings https_enabled option and the related probe https_enabled option must be the same value."
      condition     = alltrue([for k, v in var.backend_http_settings : var.probe[v.probe_name].https_enabled == v.https_enabled])
    }
  }
}