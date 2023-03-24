resource "azurerm_web_application_firewall_policy" "main" {
  count = var.waf_configuration != null ? 1 : 0

  name                = var.waf_configuration.policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "custom_rules" {
    for_each = var.waf_configuration.custom_rules
    content {
      name      = custom_rules.value["name"]
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
  name                = var.application_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  firewall_policy_id = var.waf_configuration != null ? azurerm_web_application_firewall_policy.main[0].id : null

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.sku.capacity
  }

  gateway_ip_configuration {
    name      = "ApplicationGatewayIP"
    subnet_id = var.subnet_id
  }

  autoscale_configuration {
    min_capacity = var.autoscale.min
    max_capacity = var.autoscale.max
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value["name"]
      ip_addresses = backend_address_pool.value["ip_addresses"]
    }
  }

  # [{
  #   name = value
  #   ip_address = ["1.1.1.1","1.0.0.1"]
  # },
  # {
  #   name = value
  #   ip_address = ["1.1.1.1","1.0.0.1"]
  # }]

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value["name"]
      port                                = backend_http_settings.value["port"]
      protocol                            = backend_http_settings.value["protocol"]
      cookie_based_affinity               = backend_http_settings.value["cookie_based_affinity"]
      probe_name                          = backend_http_settings.value["probe_name"]
      host_name                           = backend_http_settings.value["host_name"]
      pick_host_name_from_backend_address = backend_http_settings.value["pick_host_name_from_backend_address"]
      request_timeout                     = backend_http_settings.value["request_timeout"]
    }
  }

  # [{
  #   name = value
  #   port = 80
  #   protocol = http
  #   cookie_based_affinity = "Enabled"
  # },
  # {
  #   name = value2
  #   port = 443
  #   protocol = https
  #   cookie_based_affinity = "Enabled"
  # }]

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                          = frontend_ip_configuration.value["name"]
      private_ip_address            = frontend_ip_configuration.value["private_ip_address"]
      public_ip_address_id          = frontend_ip_configuration.value["public_ip_address_id"]
      private_ip_address_allocation = frontend_ip_configuration.value["private_ip_address"] != null ? "Static" : null
      subnet_id                     = frontend_ip_configuration.value["private_ip_address"] != null ? var.subnet_id : null
    }
  }

  # [{
  #   name = value
  #   private_ip_address = 1.1.1.1
  #   public_ip_address_id = id
  # },
  # {
  #   name = value
  #   private_ip_address = 1.1.1.1
  #   public_ip_address_id = id
  # }]

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = frontend_port.value["name"]
      port = frontend_port.value["port"]
    }
  }

  # [{
  #   name = value
  #   port = 80
  # },
  # [{
  #   name = value
  #   port = 443
  # }]

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value["name"]
      frontend_ip_configuration_name = http_listener.value["frontend_ip_configuration_name"]
      frontend_port_name             = http_listener.value["frontend_port_name"]
      protocol                       = http_listener.value["protocol"]
      require_sni                    = http_listener.value["protocol"] == "Https" ? true : false
      host_name                      = http_listener.value["host_name"]
      host_names                     = http_listener.value["host_names"]
      ssl_certificate_name           = http_listener.value["ssl_certificate_name"]
    }
  }

  # [{
  #   name = value
  #   frontend_ip_configuration_name = value
  #   frontend_port_name = value
  #   protocol = Https
  #   host_name = example.com
  #   ssl_certificate_name = ssl_cert
  # },
  # [{
  #   name = value
  #   frontend_ip_configuration_name = value
  #   frontend_port_name = value
  #   protocol = Https
  #   host_names = ["example.com","*.example"]
  #   ssl_certificate_name = ssl_cert
  # }]

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value["name"]
      data                = ssl_certificate.value["data"]
      password            = ssl_certificate.value["password"]
      key_vault_secret_id = ssl_certificate.value["key_vault_secret_id"]
    }
  }

  # [{
  #   name = value
  #   key_vault_secret_id = id
  # },
  # [{
  #   name = value2
  #   key_vault_secret_id = id
  # }]

  dynamic "url_path_map" {
    for_each = var.url_path_maps
    content {
      name                               = url_path_map.value["name"]
      default_backend_address_pool_name  = url_path_map.value["default_backend_address_pool_name"]
      default_backend_http_settings_name = url_path_map.value["default_backend_http_settings_name"]
      dynamic "path_rule" {
        for_each = url_path_map.value["path_rule"]
        content {
          name                       = path_rule.value["name"]
          paths                      = path_rule.value["paths"]
          backend_address_pool_name  = path_rule.value["backend_address_pool_name"]
          backend_http_settings_name = path_rule.value["backend_http_settings_name"]
        }
      }
    }
  }

  # [{
  #   name = value
  #   default_backend_address_pool_name = value
  #   default_backend_http_settings_name = value
  #   path_rule = [{
  #     name = value
  #     paths = ["path1"]
  #     backend_address_pool_name = Backend1
  #     backend_http_settings_name = BackendSetting1
  #     },
  #     {
  #     name = value1
  #     paths = ["path2"]
  #     backend_address_pool_name = Backend1
  #     backend_http_settings_name = BackendSetting1
  #     }]
  # },
  # {
  #   name = value
  #   default_backend_address_pool_name = value
  #   default_backend_http_settings_name = value
  #   path_rule = [{
  #     name = value
  #     paths = ["path1"]
  #     backend_address_pool_name = Backend1
  #     backend_http_settings_name = BackendSetting1
  #     },
  #     {
  #     name = value1
  #     paths = ["path2"]
  #     backend_address_pool_name = Backend1
  #     backend_http_settings_name = BackendSetting1
  #     }]
  # }]

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                       = request_routing_rule.value["name"]
      rule_type                  = request_routing_rule.value["rule_type"]
      http_listener_name         = request_routing_rule.value["http_listener_name"]
      backend_address_pool_name  = request_routing_rule.value["backend_address_pool_name"]
      backend_http_settings_name = request_routing_rule.value["backend_http_settings_name"] != null ? request_routing_rule.value["backend_http_settings_name"] : request_routing_rule.value["rule_type"] != "Basic" ? null : "Default"
      url_path_map_name          = request_routing_rule.value["url_path_map_name"]
      priority                   = request_routing_rule.value["priority"]
    }
  }

  tags = var.tags


  # [{
  #   name = value
  #   rule_type = "PathBasedRouting"
  #   http_listener_name = Listener1
  #   backend_address_pool_name = Backend1
  #   url_path_map_name = Path1
  # },
  # {
  #   name = value1
  #   rule_type = "PathBasedRouting"
  #   http_listener_name = Listener2
  #   backend_address_pool_name = Backend2
  #   url_path_map_name = Path2
  # }]

  dynamic "identity" {
    for_each = var.identity_ids != null ? [0] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  # ["id1","id2"]

  dynamic "probe" {
    for_each = var.probe
    content {
      name                                      = probe.value["name"]
      protocol                                  = probe.value["protocol"]
      interval                                  = probe.value["interval"]
      path                                      = probe.value["path"]
      host                                      = probe.value["host"]
      timeout                                   = probe.value["timeout"]
      unhealthy_threshold                       = probe.value["unhealthy_threshold"]
      port                                      = probe.value["port"]
      pick_host_name_from_backend_http_settings = probe.value["pick_host_name_from_backend_http_settings"]
    }
  }

  # [{
  #   name = value
  #   protocol = "Http"
  #   interval = 30
  #   path = "/"
  #   host = "example.com"
  #   timeout = 30
  #   unhealthy_threshold = 3
  #   port = 80
  #   pick_host_name_from_backend_http_settings = true
  # },
  # {
  #   name = value
  #   protocol = "Http"
  #   interval = 30
  #   path = "/"
  #   host = "example.com"
  #   timeout = 30
  #   unhealthy_threshold = 3
  #   port = 80
  #   pick_host_name_from_backend_http_settings = true
  # }]

}