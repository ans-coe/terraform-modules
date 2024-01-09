terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module     = "spoke-vnet"
    example    = "advanced"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_infix = "tfmex-adv-spoke"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_infix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_resource_group" "app1" {
  name     = "rg-${local.resource_infix}-app1"
  location = local.location
  tags     = local.tags
}

resource "azurerm_resource_group" "app2" {
  name     = "rg-${local.resource_infix}-app2"
  location = local.location
  tags     = local.tags
}

module "spoke" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = "vnet-${local.resource_infix}"

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-prod = {
      prefix           = "10.0.0.0/24"
      default_route_ip = "192.168.0.1"
    }
    snet-app1 = {
      prefix              = "10.0.1.0/24"
      resource_group_name = azurerm_resource_group.app1.name
      default_route_ip    = "192.168.0.1"
      subnet_nsg_name     = "nsg-${local.resource_infix}-app2"
    }
    snet-app2 = {
      prefix                     = "10.0.2.0/24"
      resource_group_name        = azurerm_resource_group.app2.name
      create_default_route_table = false
      create_custom_route_table  = true
      custom_route_table_name    = "app2_route_table"
      default_route_ip           = "192.168.0.1"
      create_subnet_nsg          = true
      subnet_nsg_name            = "nsg-${local.resource_infix}-app2"
    }
  }

  custom_routes = {
    app2_route_01 = {
      route_table_name       = "app2_route_table"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = "192.168.4.10"
    }
  }

  nsg_rules_inbound = [{
    name     = "app2_rulein_1"
    nsg_name = "nsg-${local.resource_infix}-custom"
    protocol = "Tcp"
    ports    = ["443"]
  }]

  nsg_rules_outbound = [{
    name     = "app2_ruleout_1"
    nsg_name = "nsg-${local.resource_infix}-custom"
  }]
}