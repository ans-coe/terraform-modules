###############
# Log Analytics
###############

output "log_analytics_id" {
  description = "ID of the log analytics."
  value       = local.log_analytics_id
}

#####################
# Container Registry
#####################

output "acr_id" {
  description = "Resource ID of the container registry."
  value       = try(one(azurerm_container_registry.main).id, null)
}

output "acr_name" {
  description = "Name of the container registry."
  value       = try(one(azurerm_container_registry.main).name, null)
}

output "acr_login_server" {
  description = "Login server of the container registry."
  value       = try(one(azurerm_container_registry.main).login_server, null)
}

output "acr_admin_user" {
  description = "Admin user for the container registry."
  value       = try(one(azurerm_container_registry.main).admin_username, null)
}

output "acr_admin_password" {
  description = "Admin password for the container registry."
  value       = try(one(azurerm_container_registry.main).admin_password, null)
  sensitive   = true
}

##############
# AKS Cluster
##############

locals {
  cluster = {
    host               = one(coalescelist(azurerm_kubernetes_cluster.main.kube_admin_config, azurerm_kubernetes_cluster.main.kube_config)).host
    ca_certificate     = base64decode(one(coalescelist(azurerm_kubernetes_cluster.main.kube_admin_config, azurerm_kubernetes_cluster.main.kube_config)).cluster_ca_certificate)
    client_certificate = base64decode(one(coalescelist(azurerm_kubernetes_cluster.main.kube_admin_config, azurerm_kubernetes_cluster.main.kube_config)).client_certificate)
    client_key         = base64decode(one(coalescelist(azurerm_kubernetes_cluster.main.kube_admin_config, azurerm_kubernetes_cluster.main.kube_config)).client_key)
  }
}

output "id" {
  description = "Resource ID of the AKS Cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "name" {
  description = "Name of the AKS Cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "node_resource_group_name" {
  description = "Name of the AKS Cluster Resource Group."
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "identity" {
  description = "AKS Cluster identity."
  value       = one(azurerm_kubernetes_cluster.main.identity)
}

output "kubelet_identity" {
  description = "AKS Cluster kubelet identity."
  value       = one(azurerm_kubernetes_cluster.main.kubelet_identity)
}

output "kubeconfig" {
  description = "Kubeconfig for the AKS Cluster."
  value       = coalesce(azurerm_kubernetes_cluster.main.kube_admin_config_raw, azurerm_kubernetes_cluster.main.kube_config_raw)
  sensitive   = true
}

output "host" {
  description = "AKS Cluster Host."
  value       = local.cluster.host
}

output "ca_certificate" {
  description = "AKS Cluster CA Certificate."
  value       = local.cluster.ca_certificate
}

output "client_certificate" {
  description = "AKS Cluster Client Certificate."
  value       = local.cluster.client_certificate
}

output "client_key" {
  description = "AKS Cluster Client Key."
  value       = local.cluster.client_key
  sensitive   = true
}
