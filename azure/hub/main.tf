#################
# Resource Group
#################

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

##########
# Hub VNet
##########

module "network" {
  source  = "ans-coe/virtual-network/azurerm"
  version = "1.3.0"

  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  address_space = var.address_space

  dns_servers       = var.dns_servers != "" ? var.dns_servers : []
  include_azure_dns = var.include_azure_dns

  ddos_protection_plan_id = var.ddos_protection_plan_id
  bgp_community           = var.bgp_community

  subnets = local.subnets

  private_dns_zones = {
    for k, zone in var.private_dns_zones
    : k => {
      resource_group_name  = zone.resource_group_name != null ? zone.resource_group_name : azurerm_resource_group.main.name
      registration_enabled = zone.registration_enabled
    }
  }
}