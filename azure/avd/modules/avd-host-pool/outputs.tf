output "avd_host_pool_id" {
  description = "Host pool ID"
  value       = azurerm_virtual_desktop_host_pool.host_pool.id
}

output "avd_host_pool_name" {
  description = "Host pool name"
  value       = azurerm_virtual_desktop_host_pool.host_pool.name
}