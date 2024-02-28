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
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic"
}

###################
# Global Resources
###################

resource "azurerm_resource_group" "main" {
  name     = "rg-fwpol-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-fwpol-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

###########
# Firewall
###########

module "firewall" {
  source = "../../../firewall"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags

  virtual_network_name    = azurerm_virtual_network.main.name
  pip_name                = "pip-fwpol-${local.resource_prefix}"
  subnet_address_prefixes = azurerm_virtual_network.main.address_space

  firewall_name      = "fw-fwpol-${local.resource_prefix}"
  firewall_sku_name  = "AZFW_VNet"
  firewall_sku_tier  = "Standard"
  firewall_policy_id = module.firewall_policy.id
}

##################
# Firewall Policy
##################

module "firewall_policy" {
  source = "../.."

  name                     = "fwpol-fwpol-${local.resource_prefix}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = local.location
  tags                     = local.tags
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"

  ########################################
  # Firewall Policy Rule Collection Group
  ########################################

  rule_collection_groups = {
    ApplicationOne = {
      priority             = 100
      firewall_policy_name = "fw-policy"
      application_rule_collections = {
        "AppOne-App-Collection" = {
          action   = "Allow"
          priority = 101
          rules = {
            "Windows_Updates" = {
              protocols = {
                80  = "Http"
                443 = "Https"
              }
              source_addresses      = azurerm_virtual_network.main.address_space
              destination_fqdn_tags = ["WindowsUpdate"]
            }
          }
        }
      }

      network_rule_collections = {
        "AppOne-Net-Collection" = {
          action   = "Allow"
          priority = 102
          rules = {
            "ntp" = {
              action                = "Allow"
              source_addresses      = azurerm_virtual_network.main.address_space
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