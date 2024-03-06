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
    module     = "network-security-group"
    example    = "adv"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-adv-nsg"
}

resource "azurerm_resource_group" "nsg" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_network_watcher" "nsg" {
  name                = "${local.resource_prefix}-nw"
  location            = local.location
  resource_group_name = azurerm_resource_group.nsg.name
  tags                = local.tags
}

resource "azurerm_log_analytics_workspace" "nsg" {
  name                = "${local.resource_prefix}-la"
  location            = local.location
  resource_group_name = azurerm_resource_group.nsg.name
  tags                = local.tags

  retention_in_days = 30
  daily_quota_gb    = 1
}

resource "azurerm_storage_account" "nsg" {
  name                = lower(replace("${local.resource_prefix}sa1${random_integer.sa.result}", "/[-_]/", ""))
  location            = local.location
  resource_group_name = azurerm_resource_group.nsg.name
  tags                = local.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "nsg" {
  source = "../../"

  name                = "${local.resource_prefix}-nsg"
  location            = local.location
  resource_group_name = azurerm_resource_group.nsg.name
  tags                = local.tags

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

  enable_flow_log = true
  flow_log_config = {
    name                                = "${local.resource_prefix}-fl"
    network_watcher_name                = azurerm_network_watcher.nsg.name
    network_watcher_resource_group_name = azurerm_resource_group.nsg.name
    storage_account_id                  = azurerm_storage_account.nsg.id

    enable_analytics      = true
    workspace_id          = azurerm_log_analytics_workspace.nsg.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.nsg.location
    workspace_resource_id = azurerm_log_analytics_workspace.nsg.id
  }
}

resource "random_integer" "sa" {
  min = 1
  max = 999
}