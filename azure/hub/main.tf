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
  subnets = merge(
    local.enable_private_endpoint_subnet ? {
      (var.private_endpoint_subnet["subnet_name"]) = {
        prefix                                        = var.private_endpoint_subnet["subnet_prefix"]
        service_endpoints                             = var.private_endpoint_subnet["service_endpoints"]
        private_endpoint_network_policies_enabled     = false
        private_link_service_network_policies_enabled = false
      }
    } : {},

    # The firewall subnet is managed by the module found in firewall.tf
    #   count  = local.enable_firewall ? 1 : 0
    #   subnet_address_prefixes = [var.firewall_config["subnet_prefix"]

    local.enable_bastion ? {
      "AzureBastionSubnet" = {
        prefix = var.bastion_config["subnet_prefix"]
      }
    } : {},
    
    local.enable_virtual_network_gateway ? {
      "GatewaySubnet" = {
        prefix = var.virtual_network_gateway_config["subnet_prefix"]
      }
    } : {},
    
    local.enable_private_resolver ? {
      (var.private_resolver_config["inbound_subnet_name"]) = {
        prefix         = var.private_resolver_config["inbound_subnet_prefix"]
        associate_rt   = local.enable_firewall
        route_table_id = one(azurerm_route_table.firewall[*].id)
        delegations = {
          private-resolver = {
            service = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      },
      (var.private_resolver_config["outbound_subnet_name"]) = {
        prefix         = var.private_resolver_config["outbound_subnet_prefix"]
        associate_rt   = local.enable_firewall
        route_table_id = one(azurerm_route_table.firewall[*].id)
        delegations = {
          private-resolver = {
            service = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      },
    } : {},
    {
      for k, v in var.extra_subnets
      : k => merge(v, {
        associate_rt   = local.enable_firewall
        route_table_id = azurerm_route_table.firewall[0].id
      })
    }
  )

  peer_networks = {
    for spoke, id in var.spoke_networks
    : spoke => {
      id                    = id
      allow_gateway_transit = local.enable_virtual_network_gateway
    }
  }

  private_dns_zones = {
    for zone in azurerm_private_dns_zone.main
    : zone.name => { resource_group_name = zone.resource_group_name }
  }
}

#############
# Private DNS
#############

resource "azurerm_private_dns_zone" "main" {
  for_each = var.private_dns_domains

  name                = each.key
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}