resource "azurerm_public_ip" "main_agw" {
  count = var.enable_public_frontend ? 1 : 0

  name                = var.public_ip_name != null ? var.public_ip_name : "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_web_application_firewall_policy" "main" {
  count = var.default_waf_policy["enabled"] && local.enable_waf ? 1 : 0

  name                = var.default_waf_policy["name"] != null ? var.default_waf_policy["name"] : "wafpol-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = var.default_waf_policy["enable_prevention"] ? "Prevention" : "Detection"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
    dynamic "managed_rule_set" {
      for_each = var.default_waf_policy["enable_bot_rules"] ? [1] : []
      content {
        type    = "Microsoft_BotManagerRuleSet"
        version = "1.0"
      }
    }
  }
}

resource "azurerm_application_gateway" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Basics

  enable_http2 = var.enable_http2

  sku {
    name     = var.sku["name"]
    tier     = var.sku["tier"]
    capacity = local.enable_autoscaling ? null : var.sku["capacity"]
  }

  dynamic "autoscale_configuration" {
    for_each = local.enable_autoscaling ? [1] : []
    content {
      min_capacity = var.autoscale_configuration["min_capacity"]
      max_capacity = var.autoscale_configuration["max_capacity"]
    }
  }

  gateway_ip_configuration {
    name      = "gateway"
    subnet_id = var.subnet_id
  }

  firewall_policy_id                = local.enable_waf ? coalesce(var.firewall_policy_id, one(azurerm_web_application_firewall_policy.main[*].id)) : null
  force_firewall_policy_association = local.enable_waf

  # Frontend Configuration

  dynamic "frontend_port" {
    for_each = local.default_frontend_ports
    content {
      name = frontend_port.key
      port = frontend_port.value
    }
  }

  dynamic "frontend_port" {
    for_each = var.custom_frontend_ports
    content {
      name = frontend_port.key
      port = frontend_port.value
    }
  }

  ssl_policy {
    policy_name = var.ssl_policy
    policy_type = "Predefined"
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  ssl_certificate {
    name     = "selfsigned"
    data     = filebase64("${path.module}/files/selfsigned.pfx")
    password = "default"
  }

  dynamic "ssl_certificate" {
    for_each = var.certificates
    content {
      name                = ssl_certificate.key
      key_vault_secret_id = ssl_certificate.value
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.enable_public_frontend ? [1] : []
    content {
      name                 = local.public_frontend_name
      public_ip_address_id = one(azurerm_public_ip.main_agw[*].id)
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.enable_private_frontend ? [1] : []
    content {
      name                          = local.private_frontend_name
      subnet_id                     = var.private_frontend_subnet_id
      private_ip_address_allocation = var.private_frontend_ip != null ? "Static" : "Dynamic"
      private_ip_address            = var.private_frontend_ip
    }
  }

  # Backend Pools

  backend_address_pool {
    name = "default"
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.key
      fqdns        = backend_address_pool.value["fqdns"]
      ip_addresses = backend_address_pool.value["ip_addresses"]
    }
  }

  # Backend Routing

  dynamic "http_listener" {
    for_each = local.backends
    content {
      name                           = format("%s-http-%s", (http_listener.value["private_frontend"] ? "private" : "public"), http_listener.key)
      frontend_ip_configuration_name = http_listener.value["private_frontend"] ? local.private_frontend_name : local.public_frontend_name
      protocol                       = "Http"
      frontend_port_name             = http_listener.value["http_frontend_port_name"]

      host_name = http_listener.key
    }
  }

  dynamic "http_listener" {
    for_each = local.backends
    content {
      name                           = format("%s-https-%s", (http_listener.value["private_frontend"] ? "private" : "public"), http_listener.key)
      frontend_ip_configuration_name = http_listener.value["private_frontend"] ? local.private_frontend_name : local.public_frontend_name
      protocol                       = "Https"
      frontend_port_name             = http_listener.value["https_frontend_port_name"]

      host_name = http_listener.key

      ssl_certificate_name = http_listener.value["ssl_certificate_name"]
    }
  }

  dynamic "redirect_configuration" {
    for_each = {
      for k, v in local.backends
      : k => v
      if v.upgrade_connection
    }
    content {
      name                 = format("%s-HttpToHttps", redirect_configuration.key)
      redirect_type        = "Permanent"
      include_path         = true
      include_query_string = true

      target_listener_name = format("%s-https-%s", (redirect_configuration.value["private_frontend"] ? "private" : "public"), redirect_configuration.key)
    }
  }

  dynamic "request_routing_rule" {
    for_each = {
      for k, v in local.backends
      : k => v
      if v.upgrade_connection
    }
    content {
      name = format("%s-HttpToHttps", request_routing_rule.key)
      # Calculate priority by retrieving index of the backend + 1 then
      # multiplying by 2 then taking 1 away
      priority  = ((index(keys(local.backends), request_routing_rule.key) + 1) * 2) - 1
      rule_type = "Basic"

      http_listener_name = format("%s-http-%s", (request_routing_rule.value["private_frontend"] ? "private" : "public"), request_routing_rule.key)

      redirect_configuration_name = format("%s-HttpToHttps", request_routing_rule.key)
    }
  }

  # Basic Backend Configuration

  dynamic "trusted_root_certificate" {
    for_each = {
      for k, v in var.basic_backends
      : k => v
      if v.trusted_root_certificate_data != null
    }
    content {
      name = trusted_root_certificate.key
      data = trusted_root_certificate.value["trusted_root_certificate_data"]
    }
  }

  dynamic "probe" {
    for_each = {
      for k, v in var.basic_backends
      : k => v
      if v.probe.enabled
    }
    content {
      name                                      = probe.key
      pick_host_name_from_backend_http_settings = true
      protocol                                  = probe.value["backend_protocol"]
      port                                      = probe.value["backend_port"]

      minimum_servers = probe.value["probe"].minimum_servers
      path            = probe.value["probe"].path
      match {
        body        = probe.value["probe"].body
        status_code = probe.value["probe"].status_codes
      }

      interval            = 5
      timeout             = 2
      unhealthy_threshold = 3
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.basic_backends
    content {
      name                                = backend_http_settings.key
      host_name                           = backend_http_settings.value["backend_hostname"] != null ? backend_http_settings.value["backend_hostname"] : backend_http_settings.value["hostname"]
      pick_host_name_from_backend_address = backend_http_settings.value["hostname"] == null

      protocol                       = backend_http_settings.value["backend_protocol"]
      port                           = backend_http_settings.value["backend_port"]
      trusted_root_certificate_names = backend_http_settings.value["trusted_root_certificate_data"] != null ? [backend_http_settings.key] : null

      probe_name = backend_http_settings.value["probe"].enabled ? backend_http_settings.key : null

      cookie_based_affinity = backend_http_settings.value["cookie_based_affinity"] ? "Enabled" : "Disabled"
    }
  }

  dynamic "request_routing_rule" {
    for_each = {
      for k, v in var.basic_backends
      : k => v
      if !v.upgrade_connection
    }
    content {
      name = format("%s-Http", request_routing_rule.key)
      # Calculate priority by retrieving index of the backend + 1 then
      # multiplying by 2 then taking 1 away
      priority  = ((index(keys(local.backends), request_routing_rule.key) + 1) * 2) - 1
      rule_type = "Basic"

      http_listener_name = format("%s-http-%s", (request_routing_rule.value["private_frontend"] ? "private" : "public"), request_routing_rule.key)

      backend_address_pool_name  = request_routing_rule.value["address_pool_name"]
      backend_http_settings_name = request_routing_rule.key
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.basic_backends
    content {
      name = format("%s-Https", request_routing_rule.key)
      # Calculate priority by retrieving index of the backend + 1 then
      # multiplying by 2
      priority  = ((index(keys(local.backends), request_routing_rule.key) + 1) * 2)
      rule_type = "Basic"

      http_listener_name = format("%s-https-%s", (request_routing_rule.value["private_frontend"] ? "private" : "public"), request_routing_rule.key)

      backend_address_pool_name  = request_routing_rule.value["address_pool_name"]
      backend_http_settings_name = request_routing_rule.key
    }
  }

  # Redirect Backends

  dynamic "redirect_configuration" {
    for_each = var.redirect_backends
    content {
      name                 = redirect_configuration.key
      redirect_type        = "Permanent"
      include_path         = true
      include_query_string = true

      target_url = redirect_configuration.value.url
    }
  }

  dynamic "request_routing_rule" {
    for_each = {
      for k, v in var.redirect_backends
      : k => v
      if !v.upgrade_connection
    }
    content {
      name = format("%s-Http", request_routing_rule.key)
      # Calculate priority by retrieving index of the backend + 1 then
      # multiplying by 2 then taking 1 away
      priority  = ((index(keys(local.backends), request_routing_rule.key) + 1) * 2) - 1
      rule_type = "Basic"

      http_listener_name = format("%s-http-%s", (request_routing_rule.value["private_frontend"] ? "private" : "public"), request_routing_rule.key)

      redirect_configuration_name = request_routing_rule.key
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.redirect_backends
    content {
      name = format("%s-Https", request_routing_rule.key)
      # Calculate priority by retrieving index of the backend + 1 then
      # multiplying by 2
      priority  = ((index(keys(local.backends), request_routing_rule.key) + 1) * 2)
      rule_type = "Basic"

      http_listener_name = format("%s-https-%s", (request_routing_rule.value["private_frontend"] ? "private" : "public"), request_routing_rule.key)

      redirect_configuration_name = request_routing_rule.key
    }
  }
}
