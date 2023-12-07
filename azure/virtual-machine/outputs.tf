output "id" {
  description = "ID of the virtual machine."
  value       = local.virtual_machine.id
}

output "location" {
  description = "Location of the virtual machine."
  value       = local.virtual_machine.location
}

output "name" {
  description = "Name of the virtual machine."
  value       = local.virtual_machine.name
}

output "resource_group_name" {
  description = "Name of the virtual machine."
  value       = local.virtual_machine.resource_group_name
}

output "computer_name" {
  description = "The OS-level computer name of the virtual machine."
  value       = local.virtual_machine.computer_name
}

output "username" {
  description = "The username on the created virtual machine."
  value       = local.virtual_machine.admin_username
}

output "ip_address" {
  description = "IP address of the virtual machine."
  value       = local.virtual_machine.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the virtual machine."
  value       = local.virtual_machine.public_ip_address
}

output "fqdn" {
  description = "FQDN of the virtual machine,"
  value       = one(azurerm_public_ip.main[*].fqdn)
}

output "identity" {
  description = "ID of the virtual machine."
  value       = one(local.virtual_machine.identity)
}
output "attached_luns" {
  description = "A map of the lun for each data disk attachment"
  value = {
    for d in azurerm_virtual_machine_data_disk_attachment.main 
    : d.name => d.lun
  }
}