terraform {
  required_version = ">= 1.6.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.86"
    }
  }
}

provider "random" {}

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

resource "azurerm_resource_group" "nw" {
  name     = "rg-${local.resource_infix}-nw-${local.location}"
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

  address_space = "10.0.0.0/16"

  include_azure_dns = true

  subnets = {
    snet-prod = {
      prefix = "10.0.0.0/24"
    }
    snet-app1 = {
      prefix                                   = "10.0.1.0/24"
      associate_default_network_security_group = false
    }
    snet-app2 = {
      prefix                        = "10.0.2.0/24"
      associate_default_route_table = false
    }
  }

  route_table_name = "rt-prod-${local.resource_infix}"
  default_route = {
    ip = "10.10.4.10"
  }
  extra_routes = {
    route_01 = {
      address_prefix         = "10.0.1.0/24"
      next_hop_in_ip_address = "10.10.4.20"
    }
  }

  network_security_group_name = "nsg-prod-${local.resource_infix}"
  nsg_rules_inbound = [
    {
      rule     = "https"
      name     = "AllowHttpsInBound"
      priority = 105
    }
  ]

  nsg_rules_outbound = [{
    name = "AllowALLOutBound"
  }]

  network_watcher_name                = "nw-${local.resource_infix}-${local.location}"
  network_watcher_resource_group_name = azurerm_resource_group.nw.name

  flow_log_config = {
    name                 = "fl-${local.resource_infix}"
    storage_account_name = lower(replace("fl-sa-${local.resource_infix}${random_integer.sa.result}", "/[-_]/", ""))

    enable_analytics             = true
    log_analytics_workspace_name = "fl-law-${local.resource_infix}"
  }
}

module "app1-nsg" {
  source = "../../../network-security-group"

  name                = "nsg-${local.resource_infix}-app1"
  location            = local.location
  resource_group_name = azurerm_resource_group.app1.name
  tags                = local.tags

  subnet_ids = [module.spoke.subnets["snet-app1"].id]

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

module "app2-route-table" {
  source = "../../../route-table"

  name                = "rt-${local.resource_infix}-app2"
  resource_group_name = azurerm_resource_group.app2.name
  tags                = local.tags

  subnet_ids = [module.spoke.subnets["snet-app2"].id]

  default_route = {
    ip = "10.10.4.30"
  }
}

resource "random_integer" "sa" {
  min = 1
  max = 999
}