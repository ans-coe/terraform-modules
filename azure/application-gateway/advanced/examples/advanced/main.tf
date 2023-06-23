provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  tags = {
    module  = "application-gateway"
    example = "advanced"
    usage   = "demo"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "awg-rg"
  location = "uksouth"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "example" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes = azurerm_virtual_network.example.address_space
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "umid-agw"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

module "example" {
  source = "../../"

  name                = "agw-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags
  subnet_id           = azurerm_subnet.example.id

  sku = {
    name         = "WAF_v2"
    tier         = "WAF_v2"
    capacity     = 1
    max_capacity = 3
  }

  identity_ids = [azurerm_user_assigned_identity.example.id]

  private_ip       = cidrhost(one(azurerm_subnet.example.address_prefixes), 5)
  create_public_ip = true
  pip_name         = "agw-pip"

  additional_frontend_ports = {
    alt_http = 8080
  }

  enable_http2 = true

  ssl_certificates = {
    example_cert = {
      data     = filebase64("selfsigned.pfx")
      password = "default"
    }
  }

  ssl_policy = "AppGwSslPolicy20220101"

  http_listeners = {
    http_listener = {
      frontend_port_name = "alt_http"
      host_names         = ["example.com"]
      routing = {
        http_rewrite_routing_rule = {
          priority = 100
          redirect_configuration = {
            target_listener_name = "https_listener"
          }
        }
      }
    }
    https_listener = {
      frontend_port_name = "Https"
      https_enabled      = true
      host_names = [
        "example.com",
        "www.example.com"
      ]
      ssl_certificate_name = "example_cert"
      routing = {
        https_path_routing_rule = {
          priority                   = 200
          backend_address_pool_name  = "default_backend"
          backend_http_settings_name = "default_settings"
          path_rules = {
            example_path = {
              paths                     = ["/path", "/another-path"]
              backend_address_pool_name = "second_backend"
            }
          }
        }
      }
    }
  }

  backend_address_pools = {
    default_backend = {
      ip_addresses = ["1.1.1.1", "1.0.0.1"]
    }
    second_backend = {}
  }

  probe = {
    default_probe = {
      host = "example.com"
    }
  }

  waf_configuration = {
    policy_name      = "agw-waf-policy"
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
    custom_rules = {
      example_rule = {
        priority = 5
        match_conditions = [
          {
            match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
            operator           = "IPMatch"
            negation_condition = false
            match_variables    = [{ variable_name = "RemoteAddr" }]
          }
        ]
      }
    }
  }
}
