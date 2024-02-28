provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

#########
# Locals
#########

locals {
  location = "uksouth"
  tags = {
    module     = "hub-fwpol-example"
    example    = "advanced"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-adv"
}

###################
# Global Resources
###################

resource "azurerm_resource_group" "example" {
  name     = "rg-fwpol-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-fwpol-${local.resource_prefix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

###########
# Firewall
###########

module "firewall" {
  source = "../../../firewall"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags

  virtual_network_name    = azurerm_virtual_network.example.name
  pip_name                = "pip-fw-fwpol-${local.resource_prefix}"
  subnet_address_prefixes = azurerm_virtual_network.example.address_space

  firewall_name      = "fw-fwpol-${local.resource_prefix}"
  firewall_sku_name  = "AZFW_VNet"
  firewall_sku_tier  = "Premium"
  firewall_policy_id = module.firewall_policy.id

  depends_on = [module.firewall_policy]
}

##################
# Firewall Policy
##################

module "firewall_policy" {
  source = "../.."

  name                     = "fwpol-fwpol-${local.resource_prefix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = local.location
  tags                     = local.tags
  sku                      = "Premium"
  threat_intelligence_mode = "Alert"

  intrusion_detection = {
    mode = "Alert"
    signature_overrides = {
      "2004039" = "Off"
      "2023753" = "Deny"
    }
    traffic_bypass = {
      "Traffic Bypass Rule" = {
        description           = "Example IDPS Traffic Bypass."
        protocol              = "TCP"
        destination_addresses = ["10.0.1.10", "10.0.1.11"]
        destination_ports     = ["8080"]
        source_addresses      = ["*"]
      }
    }
    private_ranges = ["10.0.0.0/24"]
  }

  ########################################
  # Firewall Policy Rule Collection Group
  ########################################

  rule_collection_groups = {
    ApplicationOne = {
      priority             = 100
      firewall_policy_name = "fwpol-fwpol-${local.resource_prefix}"

      application_rule_collections = {
        AppOne-App-Collection = {
          action   = "Allow"
          priority = 101

          rules = {
            Windows_Updates = {
              protocols = {
                80  = "Http"
                443 = "Https"
              }
              source_addresses      = azurerm_virtual_network.example.address_space
              destination_fqdn_tags = ["WindowsUpdate"]
            }
          }
        }
      }

      network_rule_collections = {
        AppOne-Net-Collection = {
          action   = "Allow"
          priority = 102

          rules = {
            ntp = {
              action                = "Allow"
              source_addresses      = azurerm_virtual_network.example.address_space
              destination_ports     = ["123"]
              destination_addresses = ["*"]
              protocols             = ["UDP"]
            }
          }
        }
      }
    }
  }
}