output "id" {
  description = "ID of the app service."
  value       = local.app_service.id
}

output "location" {
  description = "Location of the app service."
  value       = local.app_service.location
}

output "name" {
  description = "Name of the app service."
  value       = local.app_service.name
}

output "identity" {
  description = "Identity of the app service."
  value       = one(local.app_service.identity)
}

output "app_service_plan_id" {
  description = "ID of the service plan."
  value       = local.plan_id
}

output "fqdn" {
  description = "Default FQDN of the app service."
  value       = local.app_service.default_hostname
}

output "app_service" {
  description = "Output containing the main app service."
  value       = local.app_service
}

output "slots" {
  description = "Object containing details for the created deployment slots."
  value       = local.app_service_slots
}
output "umid_name" {
  description = "Name of the UMID"
  value       = local.umid_name
}

output "umid_id" {
  description = "AzureRM ID of the UMID"
  value       = local.umid_id
}
output "umid_principal_id" {
  description = "Principal ID of the Service Principal of the created UMID - Only set if UMID is created"
  value       = local.umid_principal_id
}