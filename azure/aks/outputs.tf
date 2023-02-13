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
# AKS Cluster
##############

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

output "kube_config" {
  description = "AKS Cluster Host."
  value       = one(azurerm_kubernetes_cluster.main.kube_config)
}
