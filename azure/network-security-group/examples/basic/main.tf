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
    module     = "network-security-group"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic-nsg"
}

resource "azurerm_resource_group" "nsg" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

module "nsg" {
  source = "../../"

  name                = "${local.resource_prefix}-nsg"
  location            = local.location
  resource_group_name = azurerm_resource_group.nsg.name
  tags                = local.tags

  rules_inbound = [
    {
      rule = "http"
      name = "AllowHttpInBound"
    },
    {
      rule = "https"
      name = "AllowHttpsInBound"
    },
    {
      name  = "AllowHttpAltInBound"
      ports = ["8080"]
    },
    {
      name  = "AllowHttpsAltInBound"
      ports = ["8443"]
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
    },
    {
      rule     = "deny"
      name     = "DenyAll"
      priority = 4000
    }
  ]
}
