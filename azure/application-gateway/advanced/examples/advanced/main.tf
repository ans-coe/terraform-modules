provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.93"
    }
  }
}

locals {
  tags = {
    module     = "application-gateway"
    example    = "advanced"
    usage      = "demo"
    owner      = "Dee Vops"
    department = "CoE"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "awg-rg"
  location = "uksouth"
  tags     = local.tags
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

module "example" {
  source = "../../"

  name                = "agw-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags
  subnet_id           = azurerm_subnet.example.id

  sku = {
    capacity     = 1
    max_capacity = 3
  }

  private_ip       = cidrhost(one(azurerm_subnet.example.address_prefixes), 5)
  create_public_ip = true
  pip_name         = "agw-pip"

  additional_frontend_ports = {
    alt_http = 8080
  }

  enable_http2 = true

  ssl_certificates = {
    // Specifying an empty cert will automatically generate one
    example_cert = {}
  }

  rewrite_rule_set = {
    example_rule_set = {
      example_rule = {
        rule_sequence = 100
        request_header_configuration = {
          "Cache-Control" = "no-cache" // headers are key, value pair
        }
      }
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
      frontend_port_name = "https" // default port names are "http" for 80 and "https" for 443
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
          rewrite_rule_set_name      = "example_rule_set"
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

  // This is the global waf_configuration
  // By setting waf_configuration, we change the sku to WAF_v2
  // If waf_configuration is removed, the application gateway will need replacing
  // otherwise Terraform will try to delete the firewall policy before removing it from the AGW
  waf_configuration = {
    policy_name            = "agw-waf-policy"
    firewall_mode          = "Prevention"
    enable_OWASP           = true // default value
    OWASP_rule_set_version = "3.2"
    OWASP_rule_group_override = {
      REQUEST-942-APPLICATION-ATTACK-SQLI = {
        942120 = { enabled = false }
        942130 = { enabled = false }
        942260 = { enabled = false }
        942370 = { enabled = false }
        942430 = { enabled = false }
        942440 = { enabled = false }
      }
    }
    custom_rules = {
      "AllowClientIP" = {
        priority = 5
        match_conditions = [
          {
            // Rule to only allow local traffic
            match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
            operator           = "IPMatch"
            negation_condition = true
            match_variables    = [{ variable_name = "RemoteAddr" }]
          }
        ]
      }
    }
  }

  // This is the listener waf_configurations, you can set multiple configurations and apply each one to multiple listeners.
  // However, a listener can itself only have 1 policy.
  listener_waf_configuration = {
    "agw-waf-policy-https-listener" = {
      associated_listeners     = ["https_listener"]
      firewall_mode            = "Prevention"
      enable_OWASP             = true // default value
      OWASP_rule_set_version   = "3.2"
      request_body_enforcement = false
      custom_rules = {
        "AllowClientIP" = {
          priority = 5
          match_conditions = [
            {
              // Rule to only allow local traffic
              match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
              operator           = "IPMatch"
              negation_condition = true
              match_variables    = [{ variable_name = "RemoteAddr" }]
            }
          ]
        }
      }
    }
  }
}