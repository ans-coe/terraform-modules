output "id" {
  description = "ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.id
}

output "location" {
  description = "Location of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.location
}

output "name" {
  description = "Name of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.name
}

output "resource_group_name" {
  description = "Name of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.resource_group_name
}

output "computer_name" {
  description = "The OS-level computer name of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.computer_name
}

output "username" {
  description = "The username on the created virtual machine."
  value       = azurerm_linux_virtual_machine.main.admin_username
}

output "ip_address" {
  description = "IP address of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.public_ip_address
}

output "identity" {
  description = "ID of the virtual machine."
  value       = one(azurerm_linux_virtual_machine.main.identity)
}
