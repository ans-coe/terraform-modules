#################
# Resource Group
#################

resource "azurerm_resource_group" "main" {
  count = var.resource_group_name == null ? 1 : 0

  name     = "${var.name}-rg"
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = coalesce(one(azurerm_resource_group.main[*].name), var.resource_group_name)
}

#####################
# Container Registry
#####################

resource "azurerm_container_registry" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  sku = var.sku

  admin_enabled                 = false
  public_network_access_enabled = var.enable_public_access
  export_policy_enabled         = var.enable_export_policy
  anonymous_pull_enabled        = var.enable_anonymous_pull
  data_endpoint_enabled         = var.enable_data_endpoint

  quarantine_policy_enabled = var.enable_quarantine_policy
  zone_redundancy_enabled   = var.enable_zone_redundancy

  trust_policy {
    enabled = var.enable_trust_policy
  }
  retention_policy {
    enabled = var.enable_retention_policy
    days    = var.retention_policy_days
  }

  network_rule_bypass_option = "AzureServices"

  dynamic "network_rule_set" {
    for_each = length(var.allowed_cidrs) + length(var.allowed_subnet_ids) == 0 ? [] : [1]

    content {
      default_action = "Deny"

      ip_rule = [for cidr in var.allowed_cidrs : {
        action   = "Allow"
        ip_range = cidr
      }]

      virtual_network = [for subnet_id in var.allowed_subnet_ids : {
        action    = "Allow"
        subnet_id = subnet_id
      }]
    }
  }

  dynamic "georeplications" {
    for_each = { for g in var.georeplications : g.location => g }
    iterator = g

    content {
      location                  = g.value["location"]
      regional_endpoint_enabled = g.value["enable_regional_endpoint"]
      zone_redundancy_enabled   = g.value["enable_zone_redundancy"]
      tags                      = var.tags
    }
  }

  dynamic "encryption" {
    for_each = toset(var.encryption == null ? [] : [var.encryption])
    iterator = e

    content {
      enabled            = true
      key_vault_key_id   = e["vault_key_id"]
      identity_client_id = e["identity_client_id"]
    }
  }

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }
}

resource "azurerm_role_assignment" "main_acr_pull" {
  for_each = toset(var.pull_object_ids)

  description          = format("Allows the principal %s to pull images from the ACR %s.", each.value, azurerm_container_registry.main.id)
  principal_id         = each.value
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "main_acr_push" {
  for_each = toset(var.push_object_ids)

  description          = format("Allows the principal %s to push images from the ACR %s.", each.value, azurerm_container_registry.main.id)
  principal_id         = each.value
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
}

###########
# Webhooks
###########

locals {
  webhooks = { for w in var.webhooks : w.name => w }
}

resource "azurerm_container_registry_webhook" "main" {
  for_each = local.webhooks

  name                = each.value["name"]
  location            = var.location
  resource_group_name = local.resource_group_name

  registry_name = azurerm_container_registry.main.name

  service_uri    = each.value["uri"]
  actions        = each.value["actions"]
  status         = each.value["enabled"] ? "enabled" : "disabled"
  scope          = each.value["scope"]
  custom_headers = each.value["headers"]
}

##############
# Agent Pools
##############

locals {
  agent_pools = { for p in var.agent_pools : p.name => p }
}

resource "azurerm_container_registry_agent_pool" "main" {
  for_each = local.agent_pools

  name                = each.value["name"]
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  container_registry_name   = azurerm_container_registry.main.name
  instance_count            = each.value["instances"]
  tier                      = each.value["tier"]
  virtual_network_subnet_id = each.value["subnet_id"]
}

#############
# Scope Maps
#############

locals {
  scope_maps = { for m in var.scope_maps : m.name => m }
}

resource "azurerm_container_registry_scope_map" "main" {
  for_each = local.scope_maps

  name                = each.value["name"]
  resource_group_name = local.resource_group_name

  container_registry_name = azurerm_container_registry.main.name
  description             = each.value["description"]

  actions = each.value["actions"]
}
