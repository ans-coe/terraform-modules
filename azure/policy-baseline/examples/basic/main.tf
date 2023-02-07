provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "rbaseline_policies"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-basepol"
}

resource "azurerm_resource_group" "baseline_policies_1" {
  name     = "${local.resource_prefix}-rg1"
  location = local.location
  tags     = local.tags
}

resource "azurerm_resource_group" "baseline_policies_2" {
  name     = "${local.resource_prefix}-rg2"
  location = local.location
  tags     = local.tags
}

resource "azurerm_resource_group" "baseline_policies_3" {
  name     = "${local.resource_prefix}-rg3"
  location = "westeurope"
  tags     = local.tags
}

resource "azurerm_virtual_network" "baseline_policies_1" {
  name                = "${local.resource_prefix}-vnet1"
  resource_group_name = azurerm_resource_group.baseline_policies_1.name
  location            = local.location
  tags                = local.tags

  address_space = ["192.168.1.0/24"]
}

resource "azurerm_virtual_network" "baseline_policies_2" {
  name                = "${local.resource_prefix}-vnet2"
  resource_group_name = azurerm_resource_group.baseline_policies_1.name
  location            = local.location
  tags                = local.tags

  address_space = ["192.168.2.0/24"]
}

resource "azurerm_virtual_network" "baseline_policies_3" {
  name                = "${local.resource_prefix}-vnet3"
  resource_group_name = azurerm_resource_group.baseline_policies_3.name
  location            = "westeurope"
  tags                = local.tags

  address_space = ["192.168.3.0/24"]
}

data "azurerm_management_group" "root" {
  display_name = "Tenant Root Group"
}

data "azurerm_subscription" "current" {}

module "baseline_policies" {
  source = "../../"

  management_group_id = data.azurerm_management_group.root.id

  # The values in this example are here for example purposes only.
  # Terraform needs these values to be known prior to apply.
  # Run the below then a plain terraform apply:
  # terraform apply \
  #  -target data.azurerm_management_group.root -target data.azurerm_subscription.current \
  #  -target azurerm_resource_group.baseline_policies_1 -target azurerm_resource_group.baseline_policies_2 \
  #  -target azurerm_virtual_network.baseline_policies_2
  scopes = [
    data.azurerm_management_group.root.id,
    data.azurerm_subscription.current.id,
    azurerm_resource_group.baseline_policies_1.id
  ]
  exclude_scopes = [
    azurerm_resource_group.baseline_policies_2.id,
    azurerm_virtual_network.baseline_policies_2.id
  ]
  # 
  tags = [
    "owner",
    "application",
    "environment"
  ]
  locations = [
    "uksouth",
    "eastus"
  ]
  enforce = false
}
