terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.86"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module     = "network_security_group"
    example    = "subnets"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-snet-nsg"
}

resource "azurerm_resource_group" "main" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

module "network" {
  source  = "ans-coe/virtual-network/azurerm"
  version = "1.3.0"

  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-prod = {
      prefix = "10.0.0.0/24"
    }
    snet-dev = {
      prefix = "10.0.1.0/24"
    }
  }
  include_azure_dns = true
}

module "nsg" {
  source = "../../"

  name                = "${local.resource_prefix}-nsg"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  subnet_ids = [
    module.network.subnets["snet-prod"].id,
    module.network.subnets["snet-dev"].id
  ]

  rules_inbound = [
    {
      rule     = "http"
      name     = "AllowHttpInBound"
      priority = 100
    },
    {
      rule     = "https"
      name     = "AllowHttpsInBound"
      priority = 105
    },
    {
      rule            = "rdp"
      name            = "AllowRdpInBound"
      source_prefixes = ["1.2.3.4/32"]
    }
  ]

  rules_outbound = [
    {
      rule = "https"
      name = "AllowHttpsOutBound"
    },
    {
      rule = "dns"
      name = "AllowDnsOutBound"
    }
  ]
}
