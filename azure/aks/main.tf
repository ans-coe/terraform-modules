#############
# Monitoring
#############

resource "azurerm_log_analytics_workspace" "main" {
  count = var.use_log_analytics && var.log_analytics_id == null ? 1 : 0

  name                = "${var.name}-la"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_role_assignment" "main_log_analytics_read" {
  for_each = toset(var.use_log_analytics ? var.aad_admin_group_object_ids : [])

  description          = "Allows the group ID ${each.value} read access to the Log Analytics ${local.log_analytics_id}."
  principal_id         = each.value
  scope                = local.log_analytics_id
  role_definition_name = "Log Analytics Reader"

  skip_service_principal_aad_check = false
}

##########
# Storage
##########

resource "azurerm_container_registry" "main" {
  count = var.create_acr ? 1 : 0

  name                = lower(replace("${var.name}acr", "/[-_]/", ""))
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku = var.acr_sku

  admin_enabled                 = var.acr_enable_admin
  public_network_access_enabled = var.acr_enable_public_access
}

resource "azurerm_role_assignment" "main_acr_pull" {
  count = var.create_acr ? 1 : 0

  description          = "Allows the AKS cluster ${azurerm_kubernetes_cluster.main.id} to pull images from the ACR ${one(azurerm_container_registry.main).id}."
  principal_id         = one(azurerm_kubernetes_cluster.main.kubelet_identity).object_id
  scope                = one(azurerm_container_registry.main).id
  role_definition_name = "AcrPull"

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "other_acr_pull" {
  for_each = toset(var.acr_registry_ids)

  description          = "Allows the AKS cluster ${azurerm_kubernetes_cluster.main.id} to pull images from the ACR ${each.value}."
  principal_id         = one(azurerm_kubernetes_cluster.main.kubelet_identity).object_id
  scope                = each.value
  role_definition_name = "AcrPull"

  skip_service_principal_aad_check = true
}

##########
# Compute
##########

# Ignore tfsec rule relating to configuring monitoring and RBAC rule as it is implicitly enabled on this version.
#tfsec:ignore:azure-container-logging tfsec:ignore:azure-container-use-rbac-permissions tfsec:ignore:azure-container-limit-authorized-ips
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  kubernetes_version        = var.kubernetes_version == null ? data.azurerm_kubernetes_service_versions.current.latest_version : var.kubernetes_version
  automatic_channel_upgrade = var.automatic_channel_upgrade

  dns_prefix = var.name

  private_cluster_enabled = var.enable_private_cluster
  private_dns_zone_id     = var.enable_private_cluster ? var.private_dns_zone_id : null

  public_network_access_enabled   = var.enable_private_cluster ? null : var.aks_enable_public_access
  api_server_authorized_ip_ranges = var.enable_private_cluster ? null : var.api_server_authorized_ranges

  local_account_disabled = var.disable_local_account

  dynamic "maintenance_window" {
    for_each = var.allowed_maintenance_windows != null ? [1] : []

    content {
      dynamic "allowed" {
        for_each = var.allowed_maintenance_windows

        content {
          day   = allowed.value["day"]
          hours = allowed.value["hours"]
        }
      }
    }
  }

  identity {
    type         = var.cluster_identity == null ? "SystemAssigned" : "UserAssigned"
    identity_ids = var.cluster_identity == null ? [] : [var.cluster_identity["id"]]
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    tenant_id              = var.aad_tenant_id
    admin_group_object_ids = var.aad_admin_group_object_ids
    azure_rbac_enabled     = true
  }

  network_profile {
    network_plugin    = var.use_azure_cni ? "azure" : "kubenet"
    load_balancer_sku = "standard"

    pod_cidr           = var.use_azure_cni ? null : "10.244.0.0/16"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = var.service_cidr
    dns_service_ip     = cidrhost(var.service_cidr, 10)

    network_policy = var.network_policy
  }

  default_node_pool {
    name = var.default_node_pool_name
    type = "VirtualMachineScaleSets"
    tags = var.tags

    vm_size             = var.node_size
    node_count          = var.node_count
    enable_auto_scaling = var.node_count_max != null ? true : false
    min_count           = var.node_count_max != null ? var.node_count : null
    max_count           = var.node_count_max

    zones          = var.node_zones
    vnet_subnet_id = var.use_azure_cni ? var.node_subnet_id : null
    pod_subnet_id  = var.use_azure_cni ? var.pod_subnet_id : null

    os_disk_size_gb          = lookup(var.node_config, "os_disk_size_gb", null)
    os_disk_type             = lookup(var.node_config, "os_disk_type", null)
    os_sku                   = lookup(var.node_config, "os_sku", null)
    kubelet_disk_type        = lookup(var.node_config, "kubelet_disk_type", null)
    enable_host_encryption   = lookup(var.node_config, "enable_host_encryption", null)
    fips_enabled             = lookup(var.node_config, "fips_enabled", null)
    enable_node_public_ip    = lookup(var.node_config, "enable_node_public_ip", false)
    node_public_ip_prefix_id = lookup(var.node_config, "node_public_ip_prefix_id", null)
    ultra_ssd_enabled        = lookup(var.node_config, "ultra_ssd_enabled", null)
    orchestrator_version     = lookup(var.node_config, "orchestrator_version", null)
    max_pods                 = lookup(var.node_config, "max_pods", null)

    only_critical_addons_enabled = var.node_critical_addons_only
    node_labels                  = var.node_labels
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = lookup(auto_scaler_profile.value, "balance_similar_node_groups", null)
      expander                         = lookup(auto_scaler_profile.value, "expander", null)
      max_graceful_termination_sec     = lookup(auto_scaler_profile.value, "max_graceful_termination_sec", null)
      max_node_provisioning_time       = lookup(auto_scaler_profile.value, "max_node_provisioning_time", null)
      max_unready_nodes                = lookup(auto_scaler_profile.value, "max_unready_nodes", null)
      max_unready_percentage           = lookup(auto_scaler_profile.value, "max_unready_percentage", null)
      new_pod_scale_up_delay           = lookup(auto_scaler_profile.value, "new_pod_scale_up_delay", null)
      scale_down_delay_after_add       = lookup(auto_scaler_profile.value, "scale_down_delay_after_add", null)
      scale_down_delay_after_delete    = lookup(auto_scaler_profile.value, "scale_down_delay_after_delete", null)
      scale_down_delay_after_failure   = lookup(auto_scaler_profile.value, "scale_down_delay_after_failure", null)
      scan_interval                    = lookup(auto_scaler_profile.value, "scan_interval", null)
      scale_down_unneeded              = lookup(auto_scaler_profile.value, "scale_down_unneeded", null)
      scale_down_unready               = lookup(auto_scaler_profile.value, "scale_down_unready", null)
      scale_down_utilization_threshold = lookup(auto_scaler_profile.value, "scale_down_utilization_thresho", null)
      empty_bulk_delete_max            = lookup(auto_scaler_profile.value, "empty_bulk_delete_max", null)
      skip_nodes_with_local_storage    = lookup(auto_scaler_profile.value, "skip_nodes_with_local_storage", null)
      skip_nodes_with_system_pods      = lookup(auto_scaler_profile.value, "skip_nodes_with_system_pods", null)
    }
  }

  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity != null ? [1] : []

    content {
      user_assigned_identity_id = var.kubelet_identity["id"]
      object_id                 = var.kubelet_identity["principal_id"]
      client_id                 = var.kubelet_identity["client_id"]
    }
  }

  azure_policy_enabled             = var.enable_azure_policy
  http_application_routing_enabled = var.enable_http_application_routing
  open_service_mesh_enabled        = var.enable_open_service_mesh

  dynamic "oms_agent" {
    for_each = var.use_log_analytics ? [1] : []

    content {
      log_analytics_workspace_id = local.log_analytics_id
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.enable_ingress_application_gateway ? [1] : []

    content {
      gateway_id   = var.ingress_application_gateway_id
      gateway_name = var.ingress_application_gateway_name
      subnet_id    = var.ingress_application_subnet_id
      subnet_cidr  = var.ingress_application_subnet_cidr
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_azure_keyvault_secrets_provider ? [1] : []

    content {
      secret_rotation_enabled  = var.azure_keyvault_secrets_provider_config["enable_secret_rotation"]
      secret_rotation_interval = var.azure_keyvault_secrets_provider_config["rotation_interval"]
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version
    ]
  }
}

resource "azurerm_role_assignment" "main_aks_reader" {
  for_each = toset(var.aad_admin_group_object_ids)

  description          = "Allows the group ID ${each.value} read access to the cluster ${azurerm_kubernetes_cluster.main.id}."
  principal_id         = each.value
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Reader"

  skip_service_principal_aad_check = false
}

resource "azurerm_role_assignment" "main_aks_cluster_user" {
  for_each = toset(var.aad_admin_group_object_ids)

  description          = "Allows the group ID ${each.value} to list their cluster user on ${azurerm_kubernetes_cluster.main.id}."
  principal_id         = each.value
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"

  skip_service_principal_aad_check = false
}

resource "azurerm_role_assignment" "main_aks_node_network_contributor" {
  count = var.use_azure_cni ? 1 : 0

  description          = "Allows the AKS cluster ${azurerm_kubernetes_cluster.main.id} to manage the subnet ${var.node_subnet_id}."
  principal_id         = var.cluster_identity != null ? var.cluster_identity["principal_id"] : one(azurerm_kubernetes_cluster.main.identity).principal_id
  scope                = var.node_subnet_id
  role_definition_name = "Network Contributor"

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "main_aks_pod_network_contributor" {
  count = var.use_azure_cni && var.pod_subnet_id != null ? 1 : 0

  description          = "Allows the AKS cluster ${azurerm_kubernetes_cluster.main.id} to manage the subnet ${var.pod_subnet_id}."
  principal_id         = var.cluster_identity != null ? var.cluster_identity["principal_id"] : one(azurerm_kubernetes_cluster.main.identity).principal_id
  scope                = var.pod_subnet_id
  role_definition_name = "Network Contributor"

  skip_service_principal_aad_check = true
}
