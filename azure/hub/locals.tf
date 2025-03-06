#########
# Locals
#########

locals {
  enable_private_endpoint_subnet = var.private_endpoint_subnet != null

  ###########
  # Firewall
  ###########

  enable_firewall = var.firewall != null
  firewall        = one(module.firewall)

  ##########
  # Bastion
  ##########

  enable_bastion = var.bastion != null
  bastion        = one(module.bastion)

  create_bastion_resource_group = local.enable_bastion ? var.bastion["create_resource_group"] : false

  bastion_resource_group_name = local.create_bastion_resource_group ? (
    one(azurerm_resource_group.bastion[*].name)
    ) : (
    try(var.bastion["resource_group_name"], null) != null ? var.bastion["resource_group_name"] : azurerm_resource_group.main.name
  )

  bastion_subnet = local.enable_bastion ? module.network.subnets["AzureBastionSubnet"] : null

  ##########################
  # Virtual Network Gateway
  ##########################

  enable_virtual_network_gateway = var.virtual_network_gateway != null
  virtual_network_gateway        = one(azurerm_virtual_network_gateway.main)

  virtual_network_gateway_subnet = local.enable_virtual_network_gateway ? module.network.subnets["GatewaySubnet"] : null

  use_virtual_network_gateway_route_table = var.virtual_network_gateway != null ? var.virtual_network_gateway["route_table"] != null : false

  ###################
  # Private Resolver
  ###################

  enable_private_resolver            = var.private_resolver != null
  private_resolver                   = one(azurerm_private_dns_resolver.main)
  private_resolver_inbound_endpoint  = one(azurerm_private_dns_resolver_inbound_endpoint.main)
  private_resolver_outbound_endpoint = one(azurerm_private_dns_resolver_outbound_endpoint.main)
  private_resolver_inbound_subnet    = local.enable_private_resolver ? module.network.subnets[var.private_resolver["inbound_subnet_name"]] : null
  private_resolver_outbound_subnet   = local.enable_private_resolver ? module.network.subnets[var.private_resolver["outbound_subnet_name"]] : null

  ##################
  # Network Watcher
  ##################

  network_watcher_name = var.enable_network_watcher ? (
    var.network_watcher_name != null ? var.network_watcher_name : "network-watcher-${var.location}"
  ) : null

  create_network_watcher_resource_group = var.enable_network_watcher ? var.create_network_watcher_resource_group : false

  network_watcher_resource_group_name = local.create_network_watcher_resource_group ? (
    one(azurerm_resource_group.network_watcher[*].name)
    ) : (
    var.network_watcher_resource_group_name != null ? var.network_watcher_resource_group_name : azurerm_resource_group.main.name
  )

  ############
  # Flow Log
  ############

  create_flow_log_storage_account = var.flow_log != null ? var.flow_log.storage_account_name != null : false
  flow_log_sa_id                  = local.create_flow_log_storage_account ? azurerm_storage_account.flow_log_sa[0].id : try(var.flow_log.storage_account_id, "")

  create_flow_log_log_analytics_workspace = var.flow_log != null ? var.flow_log.log_analytics_workspace_name != null : false

  flow_log_workspace_id = local.create_flow_log_log_analytics_workspace ? azurerm_log_analytics_workspace.flow_log_law[0].workspace_id : try(var.flow_log.workspace_id, null)

  flow_log_workspace_resource_id = local.create_flow_log_log_analytics_workspace ? azurerm_log_analytics_workspace.flow_log_law[0].id : try(var.flow_log.workspace_resource_id, null)

  ################
  # Extra Subnets
  ################

  subnets = merge(
    local.enable_private_endpoint_subnet ? {
      (var.private_endpoint_subnet["subnet_name"]) = {
        prefix                                        = var.private_endpoint_subnet["address_prefix"]
        service_endpoints                             = var.private_endpoint_subnet["service_endpoints"]
        private_endpoint_network_policies_enabled     = false
        private_link_service_network_policies_enabled = false
      }
    } : {},

    # The firewall subnet is managed by the module found in firewall.tf
    #   count  = local.enable_firewall ? 1 : 0
    #   subnet_address_prefixes = [var.firewall["address_prefix"]

    local.enable_bastion ? {
      "AzureBastionSubnet" = {
        prefix = var.bastion["address_prefix"]
      }
    } : {},

    local.enable_virtual_network_gateway ? {
      "GatewaySubnet" = {
        prefix         = var.virtual_network_gateway["address_prefix"]
        associate_rt   = local.use_virtual_network_gateway_route_table ? true : null
        route_table_id = local.use_virtual_network_gateway_route_table ? one(azurerm_route_table.virtual_network_gateway[*].id) : null
      }
    } : {},

    local.enable_private_resolver ? {
      (var.private_resolver["inbound_subnet_name"]) = {
        prefix         = var.private_resolver["inbound_address_prefix"]
        associate_rt   = local.enable_route_table
        route_table_id = module.hub_route_table.id
        delegations = {
          private-resolver = {
            service = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      },
      (var.private_resolver["outbound_subnet_name"]) = {
        prefix         = var.private_resolver["outbound_address_prefix"]
        associate_rt   = local.enable_route_table
        route_table_id = module.hub_route_table.id
        delegations = {
          private-resolver = {
            service = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      },
    } : {},
  )

  ###########
  # Route Table
  ###########

  enable_route_table = var.create_hub_route_table
  default_route = local.enable_route_table ? (        // create default route is false, don't create default route 
    var.default_route != null ? var.default_route : ( // default route is set = use default route
      local.enable_firewall ? {                       // default route is empty and azure firewall = use azure firewall
        name                   = "default-route"
        next_hop_in_ip_address = one(module.firewall[*].private_ip)
      } : {} // default route is empty and no azure firewall = don't create default route
    )
  ) : {}

  subnet_assoc_route_table = [
    for k, s in local.subnets
    : module.network.subnets[k].id
    if s.associate_subnets_route_table
  ]

  #################################
  # Private Endpoint Private DNS Zones
  #################################

  private_endpoint_private_dns_zones = var.create_private_endpoint_private_dns_zones ? toset([
    "privatelink.adf.azure.com",
    "privatelink.afs.azure.net",
    "privatelink.agentsvc.azure-automation.net",
    "privatelink.analysis.windows.net",
    "privatelink.api.azureml.ms",
    "privatelink.azconfig.io",
    "privatelink.azure-api.net",
    "privatelink.azure-automation.net",
    "privatelink.azure-devices-provisioning.net",
    "privatelink.azure-devices.net",
    "privatelink.azurecr.io",
    "privatelink.azurehdinsight.net",
    "privatelink.azurehealthcareapis.com",
    "privatelink.azurestaticapps.net",
    "privatelink.azuresynapse.net",
    "privatelink.batch.azure.com",
    "privatelink.azurewebsites.net",
    "privatelink.blob.core.windows.net",
    "privatelink.cassandra.cosmos.azure.com",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.database.windows.net",
    "privatelink.datafactory.azure.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.developer.azure-api.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.dicom.azurehealthcareapis.com",
    "privatelink.digitaltwins.azure.net",
    "privatelink.directline.botframework.com",
    "privatelink.documents.azure.com",
    "privatelink.eventgrid.azure.net",
    "privatelink.file.core.windows.net",
    "privatelink.gremlin.cosmos.azure.com",
    "privatelink.guestconfiguration.azure.com",
    "privatelink.his.arc.azure.com",
    "privatelink.kubernetesconfiguration.azure.com",
    "privatelink.managedhsm.azure.net",
    "privatelink.mariadb.database.azure.com",
    "privatelink.mongo.cosmos.azure.com",
    "privatelink.media.azure.net",
    "privatelink.monitor.azure.com",
    "privatelink.mysql.database.azure.com",
    "privatelink.notebooks.azure.net",
    "privatelink.ods.opinsights.azure.com",
    "privatelink.oms.opinsights.azure.com",
    "privatelink.pbidedicated.windows.net",
    "privatelink.postgres.database.azure.com",
    "privatelink.prod.migration.windowsazure.com",
    "privatelink.purview.azure.com",
    "privatelink.purviewstudio.azure.com",
    "privatelink.queue.core.windows.net",
    "privatelink.redis.cache.windows.net",
    "privatelink.redisenterprise.cache.azure.net",
    "privatelink.search.windows.net",
    "privatelink.service.signalr.net",
    "privatelink.servicebus.windows.net",
    "privatelink.siterecovery.windowsazure.com",
    "privatelink.sql.azuresynapse.net",
    "privatelink.table.core.windows.net",
    "privatelink.table.cosmos.azure.com",
    "privatelink.tip1.powerquery.microsoft.com",
    "privatelink.token.botframework.com",
    "privatelink.uks.backup.windowsazure.com",
    "privatelink.uksouth.azmk8s.io",
    "privatelink.uksouth.kusto.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.web.core.windows.net",
    "privatelink.webpubsub.azure.com"
  ]) : []
} 