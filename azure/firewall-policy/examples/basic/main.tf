provider "azurerm" {
  features {}
}

#############
# Locals
#############

locals {
  location    = "uksouth"
  dns_servers = ["1.1.1.1", "8.8.8.8"]
  tags = {
    module     = "firewall"
    owner      = "John Doe"
    department = "Technical"
  }
}

#############
# Global Resources
#############

resource "azurerm_resource_group" "example" {
  name     = "firewall-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

#############
# Firewall
#############

module "firewall" {
  source = "../../../firewall"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags

  virtual_network_name    = azurerm_virtual_network.example.name
  pip_name                = "fw-pip"
  subnet_address_prefixes = azurerm_virtual_network.example.address_space

  firewall_name      = "fw"
  firewall_sku_name  = "AZFW_VNet"
  firewall_sku_tier  = "Standard"
  firewall_policy_id = module.firewall-policy.id
}

#############
# Firewall Policy
#############

module "firewall-policy" {
  source = "../.."

  name                     = "fw-policy"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = local.location
  tags                     = local.tags
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"

  dns = {
    servers       = local.dns_servers
    proxy_enabled = false
  }

  #############
  # Firewall Policy Rule Collection Group
  #############

  rule_collection_groups = {
    ApplicationOne = {
      priority             = "100"
      firewall_policy_name = "fw-policy"

      application_rule_collection = {
        AppOne-App-Collection = {
          action   = "Allow"
          priority = "100"

          rule = {
            Windows_Updates = {
              protocols = {
                80  = "Http"
                443 = "Https"
              }
              source_addresses  = "${azurerm_virtual_network.example.address_space}"
              destination_fqdns = ["*.microsoft.com"]
            }
          }
        }
      }

      network_rule_collection = {
        AppOne-Net-Collection = {
          action   = "Allow"
          priority = "101"

          rule = {
            ntp = {
              action                = "Allow"
              source_addresses      = "${azurerm_virtual_network.example.address_space}"
              destination_ports     = ["123"]
              destination_addresses = ["*"]
              protocols             = ["UDP"]
            }
          }
        }
      }

      nat_rule_collection = {
        AppOne-NAT-Collection = {
          priority = "102"

          rule = {
            DNS = {
              protocols           = ["TCP", "UDP"]
              source_addresses    = "${azurerm_virtual_network.example.address_space}"
              destination_ports   = ["53"]
              destination_address = module.firewall.private_ip
              translated_port     = "53"
              translated_address  = "8.8.8.8"
            }
          }
        }
      }
    }
  }
}