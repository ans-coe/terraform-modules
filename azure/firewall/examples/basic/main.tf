provider "azurerm" {
  features {}
}

locals {
  location    = "uksouth"
  dns_servers = ["1.1.1.1", "8.8.8.8"]
  vnet_address_space = ["10.0.0.0/16"]
  tags = {
    department = "CoE"
    owner      = "Jon Kelly"
  }
}

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

module "firewall" {
  source = "../../"

  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  tags                = local.tags

  virtual_network_name  = azurerm_virtual_network.main.name
  pip_name              = "tfmex-basic-fw-pip"
  subnet_address_prefix = ["10.0.0.192/26"]

  firewall_name        = "tfmex-basic-fw"
  firewall_sku_name    = "AZFW_VNet"
  firewall_sku_tier    = "Standard"
  firewall_dns_servers = local.dns_servers

  # firewall_policy_name = "tfmex-basic-fw-policy"
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
  #     destination_addresses = ["tfmex-basic-fw-pip"]
  #     translated_port       = 53
  #     translated_address    = "8.8.8.8"
  #     protocols             = ["TCP", "UDP", ]
  #   },
  # ]

  ## log_analytics_workspace_id = 
  ## log_storage_account_name = 
}