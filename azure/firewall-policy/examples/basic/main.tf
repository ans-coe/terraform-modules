provider "azurerm" {
  features {}
}

#############
# Locals
#############

locals {
  location           = "uksouth"
  dns_servers        = ["1.1.1.1", "8.8.8.8"]
  vnet_address_space = ["10.0.0.0/16"]
  tags = {
    department = "CoE"
    owner      = "Jon Kelly"
  }
}

#############
# Global Resources
#############

resource "azurerm_resource_group" "main" {
  name     = "tfmex-basic-fw-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "tfmex-basic-fw-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = local.vnet_address_space
  dns_servers         = local.dns_servers
  tags                = local.tags

  subnet {
    name           = "tfmex-basic-fw-snet1"
    address_prefix = "10.0.0.0/24"
  }
}

#############
# Firewall
#############

module "firewall" {
  source = "../../../firewall"

  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  tags                = local.tags

  virtual_network_name  = azurerm_virtual_network.main.name
  pip_name              = "tfmex-basic-fw-pip"
  subnet_address_prefix = ["10.0.0.0/26"]

  firewall_name        = "tfmex-basic-fw"
  firewall_sku_name    = "AZFW_VNet"
  firewall_sku_tier    = "Standard"
  firewall_dns_servers = local.dns_servers
}

#############
# Firewall Policy
#############

module "firewall-policy" {
  source = "../.."

  firewall_policies = {
    tfmex-basic-fw-policy = {
      resource_group_name      = azurerm_resource_group.main.name
      location                 = local.location
      tags                     = local.tags
      sku                      = "Standard"
      threat_intelligence_mode = "Alert"

      dns = {
        servers       = ["1.1.1.1", "8.8.8.8"]
        proxy_enabled = false
      }

      #############
      # Firewall Policy Rule Collection Group
      #############

      rule_collection_groups = {
        ApplicationOne = {
          priority             = "100"
          firewall_policy_name = "tfmex-basic-fw-policy"

          application_rule_collection = {
            AppOne-App-Collection = {
              action   = "Allow"
              priority = "100"

              rule = {
                Windows_Updates = {
                  protocols = {
                    Http = {
                      type = "Http"
                      port = "80"
                    },
                    Https = {
                      type = "Https"
                      port = "443"
                    }
                  }
                  source_addresses  = "${local.vnet_address_space}"
                  destination_fqdns = ["*.microsoft.com"]
                }
              }
            }
          }

          network_rule_collection = {
            AppOne-Net-Collection = {
              action   = "Allow"
              priority = "100"

              rule = {
                ntp = {
                  action                = "Allow"
                  source_addresses      = "${local.vnet_address_space}"
                  destination_ports     = ["123"]
                  destination_addresses = ["*"]
                  protocols             = ["UDP"]
                }
              }
            }
          }

          nat_rule_collection = {
            AppOne-NAT-Collection = {
              priority = "100"
              action   = "Allow"

              rule = {
                DNS = {
                  protocols           = ["TCP", "UDP"]
                  source_addresses    = "${local.vnet_address_space}"
                  destination_ports   = ["53"]
                  destination_address = "${module.firewall.firewall_public_ip}"
                  translated_port     = "53"
                  translated_address  = "8.8.8.8"
                }
              }
            }
          }
        }
      }
    }
  }
}