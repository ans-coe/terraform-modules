resource "azurerm_container_registry" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku = var.sku

  admin_enabled                 = var.enable_admin
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

  network_rule_set {
    default_action = length(var.allowed_cidrs) + length(var.allowed_subnet_ids) == 0 ? "Allow" : "Deny"

    ip_rule = [for cidr in var.allowed_cidrs : {
      action   = "Allow"
      ip_range = cidr
    }]

    virtual_network = [for subnet_id in var.allowed_subnet_ids : {
      action    = "Allow"
      subnet_id = subnet_id
    }]
  }

  dynamic "georeplications" {
    for_each = { for georeplication in var.georeplications : georeplication.location => georeplication }

    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.enable_regional_endpoint
      zone_redundancy_enabled   = georeplications.value.enable_zone_redundancy
      tags                      = var.tags
    }
  }

  dynamic "encryption" {
    for_each = toset(var.encryption == null ? [] : [1])

    content {
      enabled            = true
      key_vault_key_id   = var.encryption.vault_key_id
      identity_client_id = var.encryption.identity_client_id
    }
  }

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }
}

resource "azurerm_role_assignment" "main_acr_pull" {
  for_each = toset(var.pull_object_ids)

  description          = "Allows the principal ${each.value} to pull images from the ACR ${azurerm_container_registry.main.id}."
  principal_id         = each.value
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "main_acr_push" {
  for_each = toset(var.push_object_ids)

  description          = "Allows the principal ${each.value} to push images from the ACR ${azurerm_container_registry.main.id}."
  principal_id         = each.value
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
}

###########
# Webhooks
###########

resource "azurerm_container_registry_webhook" "main" {
  for_each = { for webhook in var.webhooks : webhook.name => webhook }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  registry_name = azurerm_container_registry.main.name

  service_uri    = each.value.uri
  actions        = each.value.actions
  status         = each.value.enabled ? "enabled" : "disabled"
  scope          = each.value.scope
  custom_headers = each.value.headers
}

##############
# Agent Pools
##############

resource "azurerm_container_registry_agent_pool" "main" {
  for_each = { for agent_pool in var.agent_pools : agent_pool.name => agent_pool }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  container_registry_name   = azurerm_container_registry.main.name
  instance_count            = each.value.instances
  tier                      = each.value.tier
  virtual_network_subnet_id = each.value.subnet_id
}

#############
# Scope Maps
#############

resource "azurerm_container_registry_scope_map" "main" {
  for_each = { for scope_map in var.scope_maps : scope_map.name => scope_map }

  name                = each.value.name
  resource_group_name = var.resource_group_name

  container_registry_name = azurerm_container_registry.main.name

  actions = each.value.actions
}
