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

  include_azure_dns = true

  network_security_group_name = "nsg-${local.resource_infix}"
  route_table_name            = "rt-${local.resource_infix}"

  default_route_ip = "192.168.4.10"

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-prod = {
      address_prefixes = ["10.0.0.0/24"]
    }
    snet-app1 = {
      address_prefixes    = ["10.0.1.0/24"]
      resource_group_name = azurerm_resource_group.app1.name
    }
    snet-app2 = {
      address_prefixes    = ["10.0.2.0/24"]
      resource_group_name = azurerm_resource_group.app2.name
    }
  }

  routes = {
    route_01 = {
      address_prefix         = "192.168.0.0/24"
      next_hop_in_ip_address = "192.168.4.10"
    }
  }

  nsg_rules_inbound = [{
    name     = "rulein_1"
    protocol = "Tcp"
    ports    = ["443"]
  }]

  nsg_rules_outbound = [{
    name = "ruleout_1"
  }]

  network_watcher_config = {name = "nw-${local.resource_infix}-${local.location}"}
}