provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
  tags     = var.tags
}

module "example" {
  source = "../../"

  name                = "${var.resource_prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  address_space = ["10.0.0.0/16"]
  # ddos_protection_plan_id = azurerm_network_ddos_protection_plan.example.id
  subnets = [
    {
      name              = "default"
      prefix            = "10.0.0.0/24"
      service_endpoints = ["Microsoft.Storage"]
    },

    {
      name                                          = "private-links"
      prefix                                        = "10.0.1.0/24"
      service_endpoints                             = ["Microsoft.Storage"]
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = true
    },

    {
      name              = "appservice"
      prefix            = "10.0.11.0/24"
      service_endpoints = ["Microsoft.Storage"]
      delegations = {
        appservice = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    },

    {
      name   = "blackhole"
      prefix = "10.0.255.0/24"
    }
  ]

  subnet_network_security_group_map = {
    "blackhole" = azurerm_network_security_group.example.id
  }

  subnet_route_table_map = {
    "blackhole" = azurerm_route_table.example.id
  }

  subnet_nat_gateway_map = {
    "default" = azurerm_nat_gateway.example.id
  }
}

# ddos protection plans are expensive so this has been commented out
# resource "azurerm_network_ddos_protection_plan" "example" {
#   name                = "${var.resource_prefix}-ddos-plan"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.example.name
#   tags                = var.tags
# }

resource "azurerm_network_security_group" "example" {
  name                = "${var.resource_prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags
}

resource "azurerm_route_table" "example" {
  name                = "${var.resource_prefix}-blackhole-rt"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  route {
    name           = "blackhole"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "None"
  }
}

resource "azurerm_public_ip" "example" {
  name                = "${var.resource_prefix}-ngw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  sku               = "Standard"
  allocation_method = "Static"
}

resource "azurerm_nat_gateway" "example" {
  name                = "${var.resource_prefix}-ngw"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.example.id
  public_ip_address_id = azurerm_public_ip.example.id
}

output "subnets" {
  description = "Created subnets."
  value       = module.example.subnets
}
