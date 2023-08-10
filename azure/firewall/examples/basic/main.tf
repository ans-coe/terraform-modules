provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
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
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

#############
# Firewall
#############

module "firewall" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = local.tags

  virtual_network_name    = azurerm_virtual_network.example.name
  pip_name                = "fw-pip"
  subnet_address_prefixes = azurerm_virtual_network.example.address_space

  firewall_name        = "fw"
  firewall_sku_name    = "AZFW_VNet"
  firewall_sku_tier    = "Standard"
  firewall_dns_servers = local.dns_servers

  # firewall_policy_name = "fw-policy"
  # firewall_policy_sku  = "Standard"
  # firewall_policy_dns = {
  #   servers       = local.dns_servers
  #   proxy_enabled = true
  # }
  # firewall_policy_threat_intelligence_mode = "Alert"

  # firewall_application_rules = [
  #   {
  #     name             = "microsoft"
  #     action           = "Allow"
  #     source_addresses = ["10.0.0.0/8"]
  #     target_fqdns     = ["*.microsoft.com"]
  #     protocol = {
  #       type = "Http"
  #       port = "80"
  #     }
  #   },
  # ]

  # firewall_network_rules = [
  #   {
  #     name                  = "ntp"
  #     action                = "Allow"
  #     source_addresses      = ["10.0.0.0/8"]
  #     destination_ports     = ["123"]
  #     destination_addresses = ["*"]
  #     protocols             = ["UDP"]
  #   },
  # ]

  # firewall_nat_rules = [
  #   {
  #     name                  = "testrule"
  #     action                = "Dnat"
  #     source_addresses      = ["10.0.0.0/8"]
  #     destination_ports     = ["53", ]
  #     destination_addresses = ["fw-pip"]
  #     translated_port       = 53
  #     translated_address    = "8.8.8.8"
  #     protocols             = ["TCP", "UDP", ]
  #   },
  # ]

  ## log_analytics_workspace_id = 
  ## log_storage_account_name = 
}