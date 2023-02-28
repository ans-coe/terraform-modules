#################
# Resource Group
#################

output "resource_group_name" {
  description = "Name of the resource group."
  value       = local.resource_group_name
}

###############
# Log Analytics
###############

output "log_analytics_id" {
  description = "ID of the log analytics."
  value       = local.log_analytics_id
}

##############
# AKS cluster
##############

output "id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "location" {
  description = "Location of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.location
}

output "name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "node_resource_group_name" {
  description = "Name of the AKS cluster resource group."
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "identity" {
  description = "AKS cluster identity."
  value       = one(azurerm_kubernetes_cluster.main.identity)
}

output "kubelet_identity" {
  description = "AKS cluster kubelet identity."
  value       = one(azurerm_kubernetes_cluster.main.kubelet_identity)
}

output "kube_config" {
  description = "AKS cluster host."
  value       = one(azurerm_kubernetes_cluster.main.kube_config)
}
